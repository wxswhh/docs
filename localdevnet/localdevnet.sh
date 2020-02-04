#!/usr/bin/env bash

#set -xeo

PIDS=`ps -ef | grep lotus | awk '{print $2}'`
for pid in $PIDS
do
  kill -9 $pid
done

NUM_SECTORS=2
SECTOR_SIZE=1024

localdevnet=~/localdevnet/tmp

rm -rf $localdevnet
mkdir $localdevnet
cd $localdevnet
mkdir sectorbuilderdir01 sectorbuilderdir02 sectorbuilderdir03 staging 

sdt0111=$localdevnet/sectorbuilderdir01
sdt0222=$localdevnet/sectorbuilderdir02
sdt0333=$localdevnet/sectorbuilderdir03
staging=$localdevnet/staging


cd ~/lotus

git pull origin master

make  debug

./lotus-seed --sectorbuilder-dir="${sdt0111}" pre-seal --miner-addr=t0111 --sector-offset=0 --sector-size=${SECTOR_SIZE} --num-sectors=${NUM_SECTORS} &
./lotus-seed --sectorbuilder-dir="${sdt0222}" pre-seal --miner-addr=t0222 --sector-offset=0 --sector-size=${SECTOR_SIZE} --num-sectors=${NUM_SECTORS} &
./lotus-seed --sectorbuilder-dir="${sdt0333}" pre-seal --miner-addr=t0333 --sector-offset=0 --sector-size=${SECTOR_SIZE} --num-sectors=${NUM_SECTORS} &

wait


./lotus-seed aggregate-manifests "${sdt0111}/pre-seal-t0111.json" "${sdt0222}/pre-seal-t0222.json" "${sdt0333}/pre-seal-t0333.json" > "${staging}/genesis.json"

mkdir $localdevnet/lotus_path
lotus_path=$localdevnet/lotus_path


./lotus --repo="${lotus_path}" daemon --lotus-make-random-genesis="${staging}/devnet.car" --genesis-presealed-sectors="${staging}/genesis.json" --bootstrap=false &
lpid=$!

sleep 3

kill "$lpid"

wait

cp "${staging}/devnet.car" build/genesis/devnet.car

make debug

mkdir $localdevnet/ldt0111 $localdevnet/ldt0222 $localdevnet/ldt0333
ldt0111=$localdevnet/ldt0111
ldt0222=$localdevnet/ldt0222
ldt0333=$localdevnet/ldt0333

sdlist=( "$sdt0111" "$sdt0222" "$sdt0333" )
ldlist=( "$ldt0111" "$ldt0222" "$ldt0333" )

for (( i=0; i<${#sdlist[@]}; i++ )); do
  preseal=${sdlist[$i]}
  fullpath=$(find ${preseal} -type f -iname 'pre-seal-*.json')
  filefull=$(basename ${fullpath})
  filename=${filefull%%.*}
  mineraddr=$(echo $filename | sed 's/pre-seal-//g')

  wallet_raw=$(jq -rc ".${mineraddr}.Key" < ${preseal}/${filefull})
  wallet_b16=$(./lotus-shed base16 "${wallet_raw}")
  wallet_adr=$(./lotus-shed keyinfo --format="{{.Address}}" "${wallet_b16}")
  wallet_adr_enc=$(./lotus-shed base32 "wallet-${wallet_adr}")

  mkdir -p "${ldlist[$i]}/keystore"
  cat > "${ldlist[$i]}/keystore/${wallet_adr_enc}" <<EOF
${wallet_raw}
EOF

  chmod 0700 "${ldlist[$i]}/keystore/${wallet_adr_enc}"
done
 

pids=()
for (( i=0; i<${#ldlist[@]}; i++ )); do
  repo=${ldlist[$i]}
  ./lotus --repo="${repo}" daemon --api "400$i" --bootstrap=false &
  pids+=($!)
done

sleep 10


boot=$(./lotus --repo="${ldlist[0]}" net listen)

for (( i=1; i<${#ldlist[@]}; i++ )); do
  repo=${ldlist[$i]}
  ./lotus --repo="${repo}" net connect ${boot}
done

sleep 3

mkdir $localdevnet/mdt0111 $localdevnet/mdt0222 $localdevnet/mdt0333

mdt0111=$localdevnet/mdt0111
mdt0222=$localdevnet/mdt0222
mdt0333=$localdevnet/mdt0333
mdlist=( "$mdt0111" "$mdt0222" "$mdt0333" )

env LOTUS_PATH="${ldt0111}" LOTUS_STORAGE_PATH="${mdt0111}" ./lotus-storage-miner init --genesis-miner --actor=t0111 --pre-sealed-sectors="${sdt0111}" --nosync=true --sector-size="${SECTOR_SIZE}" || true
env LOTUS_PATH="${ldt0111}" LOTUS_STORAGE_PATH="${mdt0111}" ./lotus-storage-miner run --nosync &
mpid=$!

env LOTUS_PATH="${ldt0222}" LOTUS_STORAGE_PATH="${mdt0222}" ./lotus-storage-miner init                 --actor=t0222 --pre-sealed-sectors="${sdt0222}" --nosync=true --sector-size="${SECTOR_SIZE}" || true
env LOTUS_PATH="${ldt0333}" LOTUS_STORAGE_PATH="${mdt0333}" ./lotus-storage-miner init                 --actor=t0333 --pre-sealed-sectors="${sdt0333}" --nosync=true --sector-size="${SECTOR_SIZE}" || true

kill $mpid
wait $mpid

for (( i=0; i<${#pids[@]}; i++ )); do
  kill ${pids[$i]}
done

wait

PIDS=`ps -ef | grep lotus | awk '{print $2}'`
for pid in $PIDS
do
  kill -9 $pid
done

echo "-----------------开始部署-------------------"

#启动初始节点
repo=${ldlist[0]}
rm -rf ~/.lotus ~/.lotusstorage
mkdir ~/.lotus ~/.lotusstorage
cp -r $ldt0111/* ~/.lotus
cp -r $mdt0111/* ~/.lotusstorage
nohup ./lotus   daemon  --bootstrap=false >> ~/lotus/lotus.log 2>&1 &

sleep 10

boot=$(./lotus  net listen)

./lotus net listen | grep -v '/10' | grep -v '/127'  > $localdevnet/net-addr
wallet=$(./lotus wallet list)
nohup ./lotus-storage-miner run --nosync >>~/lotus/miner.log 2>&1 &
sleep 10

# 启动fountain程序
pids=`ps -ef | grep fountain | awk '{print $2}'`
for pid in $pids
do
 kill -9 $pid
done
cd ~/lotus/cmd/lotus-fountain
cp -f  ~/localdevnet/miner.html ~/lotus/cmd/lotus-fountain/site
go build  -o fountain *.go
nohup ./fountain run -front 0.0.0.0:7778 -from $wallet >> ~/lotus/cmd/lotus-fountain/fountain.log 2>&1 &
sleep 3


# 其它中继节点
for (( i=1; i<${#ldlist[@]}; i++ )); do
#for (( i=1; i<0; i++ )); do
  repo=${ldlist[$i]}
  host=$(sed -n "$i"p ~/localdevnet/bootstraphost)	
  mdt=${mdlist[$i]}
  echo $host
ssh "$host" 'bash -s' <<'EOF'
PIDS=`ps -ef | grep lotus | awk '{print $2}'`
for pid in $PIDS
do      
  kill -9 $pid
done
EOF
  
  ssh root@$host "rm -rf ~/.genesis-sectors ~/.lotus ~/.lotusstorage ~/lotus-bin/*"
  ssh root@$host "mkdir ~/.lotus ~/.lotusstorage"
  scp ~/lotus/lotus ~/lotus/lotus-storage-miner $localdevnet/net-addr root@$host:~/lotus-bin
  scp -r $repo/* root@$host:~/.lotus
  scp -r $mdt/* root@$host:~/.lotusstorage
ssh "$host" 'bash -s' <<'EOF'
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_PARAMETER_CACHE=/tmp/filecoin-proof-parameters  
cd ~/lotus-bin         
nohup ./lotus  daemon  --bootstrap=false >>lotus.log  2>&1 &
sleep 10
./lotus net connect $(cat net-addr|sed -n 1p)
sleep 3
nohup ./lotus-storage-miner run  --nosync >> miner.log 2>&1 &
sleep 1
EOF
done

# 普通节点
for line in $(cat ~/localdevnet/host)
do
  host=$line
  echo $host
  ssh root@$host "rm -rf ~/.genesis-sectors ~/.lotus ~/.lotusstorage ~/lotus-bin/*"
  scp ~/lotus/lotus ~/lotus/lotus-storage-miner $localdevnet/net-addr root@$host:~/lotus-bin
ssh "$host" 'bash -s' <<'EOF'
PIDS=`ps -ef | grep lotus | awk '{print $2}'`
for pid in $PIDS
do      
  kill -9 $pid
done
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
export FIL_PROOFS_PARAMETER_CACHE=/tmp/filecoin-proof-parameters  
cd ~/lotus-bin         
nohup ./lotus  daemon  >>lotus.log  2>&1 &
sleep 10
./lotus net connect $(cat net-addr|sed -n 1p)
nohup ./lotus sync wait >>chain.log 2>&1 &
./lotus wallet new bls > wallet-addr
EOF
done

echo "Done (0_0)"

exit

rm -rf $mdt0111
rm -rf $mdt0222
rm -rf $mdt0333

rm -rf $ldt0111
rm -rf $ldt0222
rm -rf $ldt0333

rm -rf $sdt0111
rm -rf $sdt0222
rm -rf $sdt0333

rm -rf $staging

