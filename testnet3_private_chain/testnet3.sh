#!/usr/bin/env bash
echo "
`echo -e "\033[35m 1)初始化genesis lotus和miner\033[0m"`
`echo -e "\033[35m 2)启动gensis lotus和miner\033[0m"`
`echo -e "\033[35m 3)启动bootstrap lotus和miner\033[0m"`
`echo -e "\033[35m 4)停止genesis lotus和miner\033[0m"`
`echo -e "\033[35m 5)停止bootstap lotus和miner\033[0m"`
`echo -e "\033[35m 6)启动fountain程序\033[0m"`
`echo -e "\033[35m 7)停止fountain程序\033[0m"`
"

data_lotus=~/.lotus
data_lotusstorage=~/.lotusstorage
data_lotusworker=~/.lotusworker
data_log=./log
data_config=./config
data_genesis_sector=~/.genesis-sectors

if [ -e /etc/yum.repos.d/public-yum-ol7.repo ]
then
	mv /etc/yum.repos.d/public-yum-ol7.repo /root/
fi


init_genesis_node(){
	set -xeo
	echo "start init genesis node"
	#rm -rf ~/.lotus ~/.lotusstorage/ ~/.genesis-sectors ~/.lotusworker
	rm -rf $data_lotus $data_lotusstorage $data_lotusworker $data_log $data_config
	mkdir -p $data_log $data_config
	./lotus fetch-params --proving-params 536870912
	#./lotus-seed pre-seal --sector-dir="${data_genesis_sector}"  --sector-size 536870912 --num-sectors 4
	./lotus-seed genesis new $data_config/localnet.json
	./lotus-seed genesis add-miner $data_config/localnet.json $data_genesis_sector/pre-seal-t01000.json
	nohup ./lotus --repo=$data_lotus   daemon  --lotus-make-genesis=$data_config/devnet.car --genesis-template=$data_config/localnet.json --bootstrap=false >$data_log/lotus.log 2>&1 &
	sleep 30
	./lotus wallet import ~/.genesis-sectors/pre-seal-t01000.key
	./lotus wallet list > $data_config/wallet-addr
	./lotus-storage-miner --repo=$data_lotus --storagerepo=$data_lotusstorage init --genesis-miner --actor=t01000 --sector-size=536870912 --pre-sealed-sectors=$data_genesis_sector --pre-sealed-metadata=$data_genesis_sector/pre-seal-t01000.json --nosync >$data_log/miner-init.log 2>&1 &	
	sleep 50
	nohup ./lotus-storage-miner --storagerepo=$data_lotusstorage run --nosync >$data_log/miner.log 2>&1 &
	echo "Done"
}

start_gensis_node(){
	set -xeo
	nohup ./lotus daemon --bootstrap=false >$data_log/lotus.log 2>&1 &
	sleep 30
	./lotus wallet list > $data_config/wallet-addr
	nohup ./lotus-storage-miner run --nosync >$data_log/miner.log 2>&1 &
	sleep 20
	echo "Done"
}

stop_genesis_node(){
	pids=`ps -ef | grep lotus | awk '{print $2}'`
	for pid in $pids
	do
 		kill -9 $pid
	done
	echo "Done"
}

start_fountain(){
	set -xeo
	nohup ./lotus-fountain run -front 0.0.0.0:7778 -from $(cat "$data_config/wallet-addr") > $data_log/fountain.log  2>&1 &
	echo "Done"
}

stop_fountain(){
	 pids=`ps -ef | grep lotus-fountain | awk '{print $2}'`
         for pid in $pids
         do
                kill -9 $pid
         done
         echo "Done"
}


start_bootstrap_node(){
	set -xeo
	nohup ./lotus --repo=$data_lotus daemon  >$data_log/lotus.log 2>&1 &
        sleep 30
        nohup ./lotus-storage-miner --repo=$data_lotus --storagerepo=$data_lotusstorage  run  >$data_log/miner.log 2>&1 &
        sleep 20
        echo "Done"
	
}
stop_bootstap_node(){
	pids=`ps -ef | grep lotus | awk '{print $2}'`
        for pid in $pids
        do
                kill -9 $pid
        done
        echo "Done"		
}






case $1 in
1)
init_genesis_node
;;
2)
start_genesis_node
;;
3)
strat_bootstrap_node
;;
4)
stop_genesis_node
;;
5)
stop_bootstrap_node
;;
6)
start_fountain
;;
7)
stop_fountain
;;
*)
echo "这个帮助提示"
esac
