# 修改过程--获取源码
1.  下载编译lotus
```shell
git clone https://github.com/filecoin-project/lotus
cd lotus
# 切换到需要的分支
# git checkout interopnet
make

```
2.  进入extern/filecoin-ffi，然后从源码编译
```shell
cd extern/filecoin-ffi
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```


3. 第2步会下载rust-fil-proof的源码并进行编译，修改rust-fil-proofs
```shell
 cd rust
 vim rust/Cargo.toml
```
修改 
```shell
[dependencies.filecoin-proofs-api]
```
**这一节**，改成

`filecoin-proofs-api = {path="../../../../rust-filecoin-proofs-api", version = "4.0.2"}`

# 使用本地的rust-fil-proofs
修改后的fust-fil-proofs是私有库，必须下载到本地后才能使用。 使用本地的rust-fil-proofs需要分成两步
1. clone 可以使用本地rust-fil-proofs api 
```shell
git clone https://github.com/plotozhu/rust-filecoin-proofs-api
git checkout -b local origin/local
```

2. clone rust-fil-proofs
```shell
git clone https://github.com/xjrwfilecoin/rust-fil-rpoofs
git checkout -b prefetch origin/prefetch

```
注意，这一步需要使用可用的github密码和帐号

3. 修改本地指向

     `cd extern/filecoin-ffi`
    
    修改 filecoin-proofs-api节,使用本地的fiecoin-proofs-api库

    ```
    #[dependencies.filecoin-proofs-api]
    #version = "4.0.3"
    filecoin-proofs-api = {path="../../../../rust-filecoin-proofs-api", version = "4.0.3"}
    #branch = "v4.0.4"

    ```
    修改rust-filecoin-proofs-api,指向本地的rust-fil-proofs
    ```
    [dependencies.filecoin-proofs-v1]
        version = "4.0.4"
        path = "/home/xjrw/rust-fil-proofs/filecoin-proofs"
        rev = "prefetch"
        package = "filecoin-proofs"
    ```
    **注意**
    这里的代码里写死了~的目录必须是/home/xjrw，实际可以按需要改动

4.编译rust-fil-proofs使用的库
* 保证gcc 版本在10以上  
* 安装了cmake

``` shell 
cd ~/rust-fil-proofs
cd lib/sha256
cmake . 
make clean
make
# 复制库
cp libflo-shani.a ../libsha256.a

```
库编译完成   



# 生成lotus
 进入到lotus目录，重新生成
```shell
cd ~/lotus
env 'RUSTFLAGS=-C target-cpu=native -g' FFI_BUILD_FROM_SOURCE=1 make clean all bench
```
需要生成bench的话:


# 使用更新版的rust-fil-proofs
1. 进入rust-fil-proofs源码目录
```
#更新最新的prefetch分支
    git pull xjrw prefetch
```




# 新增加的环境变量
* FIL_PROOFS_SSD_PARENT : SSD盘所在的位置  

* FIL_PROOFS_ADDPIECE_CACHE: 缓存的空预处理好的add_piece所在的位置，如果为空，表示不跳过add_piece，如果有值，生成或使用该目录下的文件

* FIL_PROOFS_USE_SSD_CACHE =1 或其它， 是否使用FIL_PROOFS_SSD_PARENT作为缓存路径，如果使用，cache中的文件临时生成在这个路径上，生成后再转移到实际的目标路径中去   

* FIL_PROOFS_SSD_PARENT="/opt/local_ssd/SSD_PARENT"  临时的cache文件的缓存路径

* FIL_PROOFS_MAX_FETCH_COUNT=4    P1缓存数，以8M为单位，值从0到16，如果小于2，不启动，如果大于16，只取16，一般取4即可  
