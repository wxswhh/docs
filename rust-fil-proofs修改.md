# 修改过程--获取源码
1.  下载编译lotus
```shell
git clone https://github.com/filecoin-project/lotus
cd lotus
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

# 使用本地文件
1. clone api 
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

3. 编译rust-fil-proofs  
* 保证gcc 版本在10以上  
* 安装了cmake

``` shell 
cd ~/rust-fil-proofs
cd lib/sha256
cmake . 
make
cp libflo-shani.a ../libsha256.a

cd ~/rust-fil-proofs
env 'RUSTFLAGS=-C target-cpu=native -g'  rm .install-filcrypto     ; make clean     ; FFI_BUILD_FROM_SOURCE=1 make

```
库编译完成   



# 生成lotus
 进入到lotus目录，重新生成
```shell
cd ../..
make 
```
需要生成bench的话:
```shell
make bench
```
注意这里如果使用make clean会把第4步编译好的删除，需要重新到extern/filecoin-ffi目录下执行一次第4步

# 使用更新版的rust-fil-proofs
1. 进入rust-fil源码目录
执行 [编译rust-fil-proofs]

2. 更新记录对应的rust-fil-proofs

```shell
cargo update
```
3. 从源码生成rust-fil-proof库
```shell
cd ~/rust-fil-proofs
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```
4. 进入到lotus目录，重新生成
```shell
cd ../..
make 
```
**注意**
代码里写死了~的目录必须是/home/xjrw



# 新增加的环境变量
* FIL_PROOFS_SSD_PARENT : SSD盘所在的位置  

* CACHE_ADD_PIECE=1 或其它 是否启动addpiece缓存   

* FIL_PROOFS_USE_SSD_CACHE =1 或其它， 是否使用FIL_PROOFS_SSD_PARENT作为缓存路径，如果使用，cache中的文件临时生成在这个路径上，生成后再转移到实际的目标路径中去   

* FIL_PROOFS_SSD_PARENT="/opt/local_ssd/SSD_PARENT"  ADD_PIECE和临时的cache文件的缓存路径

* FIL_PROOFS_MAX_FETCH_COUNT=4    P1缓存数，以8M为单位，值从0到16，如果小于2，不启动，如果大于16，只取16，一般取4即可  
