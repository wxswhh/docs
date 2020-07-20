# 修改过程
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
* 修改配置

** 最新的版本 ** 
```shell
[dependencies.filecoin-proofs-api]
version = "4.0.2"
git = "https://github.com/plotozhu/rust-filecoin-proofs-api"
branch = "prefetch"
```
目前优化的版本是prefetch
* 然后执cargo更新，并且退到上一层目录
```shell
cargo update 
cd ..
```

# 新增加的环境变量
FIL_PROOFS_SSD_PARENT : SSD盘所在的位置

4. 然后重新执行 
```shell
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```
5. 进入到lotus目录，重新生成
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
1. 进入源码目录
```shell
cd  extern/filecoin-ffi/rust
```
2. 更新记录对应的rust-fil-proofs

```shell
cargo update
```
3. 从源码生成rust-fil-proof库
```shell
cd ..
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```
4. 进入到lotus目录，重新生成
```shell
cd ../..
make 
```

# 增加的参数
CACHE_ADD_PIECE=1 或其它 是否启动addpiece缓存
FIL_PROOFS_SSD_PARENT="/opt/local_ssd/SSD_PARENT"  ADD_PIECE缓存路径
FIL_PROOFS_MAX_FETCH_COUNT=4    P1缓存数，以8M为单位，值从0到16，如果小于2，不启动，如果大于16，只取16，一般取4即可

rm .install-filcrypto \数据
rm .install-filcrypto \
