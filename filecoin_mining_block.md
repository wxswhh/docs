# lotus出块概率源码级分析

## 1. 目的
```
详细研究lotus代码和spec
分析清楚filecoin详细的出块流程及计算方法
报告文档需要详细到具体的出块流程图，以及每个流程具体的计算公式（输入及输出）
并指向到具体的源文件和代码行
```
**通过该任务的输出需要能够准确回答以下问题（需要扫地阿姨也能照着文档算出结果）**

1. 假如系统总容量10P ，某个大矿工总共有1P容量，占全网10%。他是合并到一个huge-miner上，还是分拆成10个100T的tiny-miner,后面出块的优势更大？需要列出具体的计算公式。
1. 在全网算力固定为1P的情况下，设一个有效Power是100T的miner某一天内出块产量期望值的1%为A，另外一个有效Power是10T的miner同一天的出块产量期望值的10%为B，列出计算过程比较A和B的大小。
1. 一个Tipset 理论上最多有几个矿工出块？一个Tipset上的每个获得出块权的矿工获得的奖励是不是一样多？
1. 在同一个高度上，1个矿工出块和N个矿工出块，该高度产出的FIL总和是一样的吗？

## 2. 分析

**lotus实现方案**
* 奖励计算过程
```
// github.com\filecoin-project\lotus\chain\vm\vm.go:731

var miningRewardTotal = types.FromFil(build.MiningRewardTotal)
var blocksPerEpoch = types.NewInt(build.BlocksPerEpoch)

// MiningReward returns correct mining reward
// coffer is amount of FIL in NetworkAddress
func MiningReward(remainingReward types.BigInt) types.BigInt {
	ci := big.NewInt(0).Set(remainingReward.Int) //<-- 这个是奖励所有余额
	res := ci.Mul(ci, build.InitialReward) //<-- 15.xx个，第一个区块（100%还没有发放的时候）的奖励
	res = res.Div(res, miningRewardTotal.Int)
	res = res.Div(res, blocksPerEpoch.Int)
	return types.BigInt{res}
}
```
* 剩余奖励 / 总共奖励 = 余额比例
* 奖励= 初始奖励 * 余额比例 / 每epoch区块
* 奖励发放过程
```
// github.com\filecoin-project\lotus\chain\stmgr\stmgr.go:154

reward := vm.MiningReward(netact.Balance)
for tsi, b := range blks {
	// .........
	if err := vm.Transfer(netact, act, reward); err != nil {
	    return cid.Undef, cid.Undef, xerrors.Errorf("failed to deduct funds from network actor: %w", err)
	 	}
	//.........
}
```
* * 由此看来， lotus目前测试版本中的:
* * 预估每个tipset平均5个块
* * 每个块发放一样的奖励
* * 即使用的是第一种方案，但是epoch的含义不是这个，因此我相信这个是临时的分发算法方案，并不是最终的。
* * **但是** 我们应该可以看到一些理念，即每个tipset中的出块者应该得到一定的奖励，一个tipset中出块者如果多，给出的奖励就多，如果保证平衡且按照计划给，还需要进一步研究。

**以这个为基础，我们来计算 问题1和2**
* 不同miner模式的出块概率说明

* * 本质上，如果我们把所有的算力合在一起，每次出块得到的出块机会的概率为Pall，而把算力分成K个节点，那么对于每个节点来说，概率为P=Pall/K，但是同时有K次机会获得出块权。
* * 那么我们就把问题转化成这样描述，我们用红黑球来描述更直观些，假设每次出块时就是从样本空间中取出一个球，得到出块权就是拿到红球，没有出块权就是拿到黑球：
* * 在一个拿到红球概率为P的盒子里，取出K个球，那么：
* * 至少取到一次红球的概率是多少？
* * 取到至少一个红球时，红球数量的期望是多少？
* * 对于问题1：解决方案很容易：P无=1-P一次都取不到的概率 = 1-(1-Pall/K)^K，从数学上可以得到，当Pall很小时，比如小于0.01时，这个结果与1-Pall略大，但几乎一致。详细的数学推导不在此描述。（可以直接用Pall=0.01，K=10来测试下）。
* * 对于问题2：需要使用超几何多项式，或者使用近似的伯努利二项式进行计算，但是显然，拿到红球时，红球的数量是从1个到K个之间，因此肯定大于等于1。


## 3. 结论

* 按照目前的代码里给出的奖励发放方式，使用把算力分解到多个矿工上，在每个区块周期上，出块的概率与合并的一致，但是可能获得的奖励将会更多，分解成多个矿工更有利。
