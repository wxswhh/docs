### 搭建本地测试网

参考   http://www.r9it.com/20200106/lotus-local-testnet.html

官网： https://github.com/filecoin-project/lotus/blob/master/documentation/en/local-dev-net.md

### 开始搭建


编译代码


    // 拉取代码
    gti clone https://github.com/filecoin-project/lotus.git

    // 编译代码
    cd {LOTUS_BASE_DIR}
    make clean debug 


    // 这里我们采用 1024 Byte 的扇区，如果你要测试 32GB 扇区的话，把 --sector-size 设置成 34,359,738,944
    ./lotus-seed pre-seal --sector-size 1024 --num-sectors 2

    // 生成创世区块，并运行第一个节点, genesis.car 文件会默认在当前的目录下面,这个文件其他节点会用到，初始化矿工
    ./lotus daemon --lotus-make-random-genesis=genesis.car \
			   --genesis-presealed-sectors=~/.genesis-sectors/pre-seal-t0101.json \
			   --bootstrap=false

    // 设置创世矿工
    ./lotus-storage-miner init --genesis-miner --actor=t0101 --sector-size=1024 --pre-sealed-sectors=~/.genesis-sectors --nosync

     //启动矿工
    ./lotus-storage-miner run --nosync

    // 查看钱包地址, 这个后面会用到，创建其他矿工需要该地址
    ./lotus wallet list

    //查看钱包余额
    ./lotus wallet balance
    
    // 查看当前监听的地址,后面需要用到，启动其它的节点，需要连接上该地址
    ./lotus net listen

    //查看矿工信息
    ./lotus-storage-miner info


编译创建矿工 fountain程序

    进入在 ./cmd/lotus-fountain 目录下

    // 编译程序，默认程序生成在当前目录下 文件名称 lotus-fountain 
    go build

    // 运行程序 默认监听 7777端口;地址为创世节点钱包地址
    ./fountain run –front 0.0.0.0:7777 –from t3xe2uwpwag4kyo4igucvgdkqukaqbys3k362dtirnkr6meeu5o2xq4mfnuye7imqp5bcszwq。。。

    // tips: 最新代码里面没有 1024 扇区，需要更改部分代码
    在 ./cmd/lotus-fountain/main.go 文件 在 263行左右

    // 此处添加代码，更改为指定要创建的扇区大小/ 或者更改网页 代码
    
    // ... 更改为指定扇区大小
    ssize = 1024 
	params, err := actors.SerializeParams(&actors.CreateStorageMinerParams{
		Owner:      owner,
		Worker:     owner,
		SectorSize: uint64(ssize),
		PeerID:     peer.ID("SETME"),
	})
    ...




 运行其他的节点

    // 将初始节点生成的 genecis.car 拷贝过来，初始化
    ./lotus daemon --genesis=genesis.car --bootstrap=false   
    
    // 连接创世节点, 地址为创世节点执行  ./louts net listen 出来的地址 libp2p地址（示例 /ip4/ip/tcp/port/p2p/id）
    ./lotus net connect 地址

    //创建钱包地址
    ./lotus wallet new bls

    // 进入上面 fountain web页面创建 初始化创建矿工 返回命令信息
    lotus-storage-miner init --actor=t01424 --owner=t3spmep2xxsl33o4gxk7yjxcobyohzgj3vejzerug25iinbznpzob6a6kexcbeix73th6vjtzfq7boakfdtd6a

    // 运行即可，其余与官网一直操作
    

