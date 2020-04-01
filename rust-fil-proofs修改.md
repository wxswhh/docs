# 修改过程
1.  下载编译lotus
```shell
git clone https://github.com/filecoin-project/lotus
cd lotus
git checkot testnet/3
make

```
2.  进入extern/filecoin-ffi，然后从源码编译
```shell
cd extern/filecoin-ffi
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```
3. 第2步会下载rust-fil-proof的源码并进行编译，在testnet/3分支中使用了 1.0-alpha的版本了，修改rust-fil-proofs
```shell
 vim rust/Cargo.toml
```
修改配置
```
git = "https://github.com/filecoin-project/rust-filecoin-proofs-api.git"
改成
git = "https://github.com/plotozhu/rust-filecoin-proofs-api.git"
```
4. 然后重新执行 
```shell
rm .install-filcrypto \
    ; make clean \
    ; FFI_BUILD_FROM_SOURCE=1 make
```
5. 进入到lotus目录，重新生成
```shell
cd ../..
make debug
make 
```
注意这里如果使用make clean会把第4步编译好的删除，需要重新到extern/filecoin-ffi目录下执行一次第4步
