## 代码所在的位置
成都node35 的 /mnt/bin目录
lotus 版本: 7bd130628a1179f23f744b7b19e749d7

## 环境变量设置
> WORKER_PATH="/mnt/.lotusstorage" 
> LOTUS_STORAGE_PATH="/mnt/.lotusstorage" 
> FIL_PROOFS_PARAMETER_CACHE="/dev/shm/tmp/filecoin-proof-parameters" 
> TMPDIR="/dev/shm/tmp" 
###  提高运行速度 
/dev/shm/tmp 是运行在内存里的，因此可以加快速度，经过实测，启动速度从5分钟缩短成1分钟 
需要将filecoin-proof-parameters复制到/dev/shm/tmp/

## 配置文件<sup>1</sup>
把.lotusstorage/config.toml中的noprecommit和nocommit设置成true，并且把注释去掉

## 启动worker 
> 只启动precommit lotus-seal-worker --no-commit=true run  <sup>2</sup>
> 只启动commit lotus-seal-worker --no-precommit=true run  <sup>3</sup>

## 启动方案
1. 启动 lotus daemon 
2. 根据<sup>1</sup>启动miner 
3. 三分之二的节点只启动precommit<sup>2</sup>，每个节点启动一个worker 
3. 三分之一的节点只启动commit<sup>3</sup>，每个节点启动两个worker 
