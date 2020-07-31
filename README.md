

# 关于C2外包 
1. C2外包使用单独编译的程序，教程按照：
  目前的分支号是cddc56607e1d851e-webapi,详细的教程可以见这个文档 

    [Filecoin Snark计算API接口使用手册.docx](https://kdocs.cn/l/sygDgqBm7?f=111)
2. 系统中将会有两个lotus-storage-miner（C2外包的版本和我们优化的版本，注意C2外包的版本程序一定不能跑P1和P2）


# 关于环境变量

* FIL_PROOFS_SSD_PARENT : SSD盘所在的位置  

* CACHE_ADD_PIECE=1 或其它 是否启动addpiece缓存   

* FIL_PROOFS_USE_SSD_CACHE =1 或其它， 是否使用FIL_PROOFS_SSD_PARENT作为缓存路径，如果使用，cache中的文件临时生成在这个路径上，生成后再转移到实际的目标路径中去   

* FIL_PROOFS_SSD_PARENT="/opt/local_ssd/SSD_PARENT"  ADD_PIECE和临时的cache文件的缓存路径

* FIL_PROOFS_MAX_FETCH_COUNT=4    P1缓存数，以8M为单位，值从0到16，如果小于2，不启动，如果大于16，只取16，一般取4即可  




