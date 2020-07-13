
新添加的环境变量：

1. "FIL_PROOFS_SSD_PARENT"：存储临时文件的SSD目录，值应该是一个目录，例如："/opt/local_ssd/SSD_PARENT"，这个应该是放在SSD上
2. "CACHE_ADD_PIECE"：是否缓存add_piece产生的数据，值是1或是其他。如果是1，系统在第一次运行的时候在FIL_PROOFS_SSD_PARENT下生成add_piece的文件，后续将一直复用这个文件，如果不是1，和原来的方式一致

