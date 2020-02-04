#!/usr/bin/env bash

host=$1
localdevnet=~/localdevnet/tmp
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
nohup ./lotus  daemon >>lotus.log  2>&1 &
sleep 10
./lotus wallet new bls > addr

curl http://172.16.8.29:7778/send?address=$(cat addr) &
curl http://172.16.8.29:7778/send?address=$(cat addr) &
#curl http://172.16.8.29:7778/send?address=$(cat addr) &
echo "SYNC WAIT"
sleep 30
./lotus net connect $(cat net-addr|sed -n 1p)
./lotus sync wiat
./lotus-storage-miner init --owner=$(cat addr) --sector-size=1024
nohup ./lotus-storage-miner run >>miner.log 2>&1 &

EOF



