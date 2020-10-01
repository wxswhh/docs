

# 关于C2外包 
1. C2外包使用单独编译的程序，教程按照：
  目前的分支号是cddc56607e1d851e-webapi,详细的教程可以见这个文档 

    [Filecoin Snark计算API接口使用手册.docx](https://kdocs.cn/l/sygDgqBm7?f=111)
2. 系统中将会有两个lotus-storage-miner（C2外包的版本和我们优化的版本，注意C2外包的版本程序一定不能跑P1和P2）


# 关于环境变量


这些环境变量仅对P1/P2起作用，只需要给运行P1/P2 的AMD版本配置。

*  FIL_PROOFS_ADDPIECE_CACHE: 缓存的空预处理好的add_piece所在的位置，如果为空，表示不跳过add_piece，如果有值，生成或使用该目录下的文件

*  FIL_PROOFS_SSD_PARENT="/opt/local_ssd/SSD_PARENT" 临时的cache文件的缓存路径，如果不设置，就不做缓存，直接向目标文件夹中写入（如果目标文件系统不支持大量的小数据读写，可能会有性能问题）

**注意** 在做P2时，直接写入分布式存储将会导致P2速度慢，因此还是需要设置FIL_PROOFS_SSD_PARENT，需要将这个值设置成/dev/shm，这样将会在内存中存储P2产生tree-c/tree-r-last文件，生成完毕后自动移动到文件系统上。 

*  FIL_PROOFS_P2_THREADS = 3    做P2时，同时读取数据的线程数，如果CPU速度慢，用GPU做P2时GPU的使用率不满，可以适当增大该值，一般可选为2，如果不设置，默认为2
*  FIL_PROOFS_RESERVED_MEMORY=40 系统保留的内存，是一个数字，以G为单位，为了安全起见一般选为40

*  XJRW_SHOW_LOGS =y 打开更详细的日志    

* FIL_PROOFS_PREFETCH_ONCE = 5/10      P2一次读取数据个数     
* FIL_PROOFS_PREFETCH_TOTAL = 5/10      P2总缓存的个数

* FIL_PROOFS_CPU_BOND = "xxx/...../cpu_bond.json" 这个是绑核的配置，具体的配置见下章

* FIL_PROOFS_MEM_ITEM_CNT = xx   用于P1的内存的数

**非常重要**
* 删除 RAYON_NUM_THREADS  这个将系统中的全局线程池中的线程数，默认与系统中的逻辑核心数一致

#### C2环境变量   
* FIL_PROOFS_C2_TASKS = 1/2/3/4/.....  C2可以同时运行的电路综合任务，与内存有关，256G 一个， 384G 两个  512G 3个

C2 分为三个阶段 CPU  使用CPU/ FFT使用第一个GPU /multiexp  使用所有GPU， 以目前2080TI为例， 
> 一个任务  CPU  14m / FFT 5m /multiexp 12.5m  共计 31.5 m 
> 2个任务   
>>   task 1   CPU  14m / FFT 5m /multiexp 12.5m  
>>  task  2                        CPU  14m / FFT 5m /multiexp 12.5m 
共计   31.5+5+12.5 = 49m 平均 25m

### 
```shell
RUST_LOG="trace" FIL_PROOFS_ADDPIECE_CACHE="/mnt/ssd/bench/piece32G"  FIL_PROOFS_SDR_PARENTS_CACHE_SIZE=65536 FIL_PROOFS_USE_SSD_CACHE=1 FIL_PROOFS_USE_GPU_TREE_BUILDER=1 FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1  XJRW_SHOW_LOG=y XJRW_SHOW_LOGS=y FIL_PROOFS_SSD_PARENT="/mnt/ssd/bench/$2" FIL_PROOFS_PARAMETER_CACHE="/home/zhu/filecoin-proof-parameters-v28" FIL_PROOFS_PARENT_CACHE="/mnt/ssd/parent" ........
```


### P2 IO  ----------- 暂时无效-----------
## 策略  
>  echo deadline > /sys/block/sdd/queue/scheduler   
>  echo deadline > /sys/block/sde/queue/scheduler    
>  echo deadline > /sys/block/sdf/queue/scheduler    
> echo deadline > /sys/block/sdg/queue/scheduler    
> cat /sys/block/sde/queue/scheduler    

## 快速存储    

> echo 0 > /proc/sys/vm/dirty_ratio     
> echo 0 > /proc/sys/vm/dirty_background_ratio    

# 绑核文件说明
绑核文件中每个具有5个项，其绑定方式如下：    
* 1 -  哈希线程： 主哈希线程，绑定到物理核心上    
* 2 - 喂哈希数据线程： 绑定到距离哈希线程最近的核心上（超线程？需要测试）    
* 3/4 -  数据预读线程：同一核心的两个线程（超线程）    
* 5 -  调度线程： 调用3／4的线程（是否可以和2绑一个？）    
