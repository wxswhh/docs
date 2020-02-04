### 搭建本地测试网

参考   http://www.r9it.com/20200106/lotus-local-testnet.html

官网： https://github.com/filecoin-project/lotus/blob/master/documentation/en/local-dev-net.md


#### 脚本简化
主要参考了: lotus/scripts/init-network.sh 脚本创建

说明:所有脚本在 29机器上面   ~/localdevnet 目录下

    // 中继节点 主机地址列表
    bootstrap
    // 普通节点(需要自己初始化矿工)
    host
    //部署初始化脚本发
    localdevnet.sh
    //1024扇区 fountain页面
    miner.html
    //临时目录
    tmp

29机器对 33，41，54做了免密登录；29 创世矿工的节点，22，41，为中继节点，54为普通节点;

### 开始搭建

在成都 172.16.8.29 的机器上面 ~/devnet ，脚本都在此目录下， 可执行文件在 ~/lotus目录下面

另外三台机器: 172.16.8.33 /172.16.8.41 /172.16.8.54； 可执行文件日志都在 ~/lotus-bin 目录下
	
	// 菜单导航
	devnetmenu.sh 
	
	tips:lotus-storage-miner init ... 时候, 需要加上 --nosyn参数
	//-----------------------------------
	// 初始化初始节点矿工
	genesis-init.sh
	//重启矿工
	genesis-start.sh
	// 停止矿工
	genesis-stop.sh

	//启动fountain程序,创建初始化矿工地址; http://110.185.107.117:7778/
	fountain-start.sh
	//停止fountain
	fountain-stop.sh

	// 初始化其他节点 示例 sh setup-host.sh 172.16.8.33，该脚本只初始化了节点，未创建初始化矿工
	//需要自己手动按照流程创建
	setup-host.sh
	//启动其他节点 sh setup-host.sh 172.16.8.33,重新启动节点矿工
	deploy-host.sh

	




### 具体步骤


编译代码


    // 拉取代码
    gti clone https://github.com/filecoin-project/lotus.git

    // 编译代码
    cd {LOTUS_BASE_DIR}
    make clean debug 


    // 这里我们采用 1024 Byte 的扇区，如果你要测试 32GB 扇区的话，把 --sector-size 设置成 34359738368,
    // 这初始化执行一次就行(除非你想重新开始)
    ./lotus-seed pre-seal --sector-size 1024 --num-sectors 2

    // 初始化创世节点,生成创世区块，并运行第一个节点, 会生成 genesis.car，文件会默认在当前的目录下面,这个文件其他节点会用到
     ./lotus daemon --lotus-make-random-genesis=genesis.car  --genesis-presealed-sectors=~/.genesis-sectors/pre-seal-t0101.json --bootstrap=false

         // 如果是重新启动创世节点，运行以下命令
         ./lotus daemon --genesis=genesis.car --genesis-presealed-sectors=~/.genesis-sectors/pre-seal-t0101.json --bootstrap=false
   

    

    // 设置创世矿工
    ./lotus-storage-miner init --genesis-miner --actor=t0101 --sector-size=1024 --pre-sealed-sectors=~/.genesis-sectors --nosync
    

     //启动矿工
    ./lotus-storage-miner run --nosync

    // 查看钱包地址, 这个后面会用到，创建其他矿工需要该地址
    ./lotus wallet list

    //查看钱包余额
    ./lotus wallet balance
    
    // 查看当前监听的地址,启动其它的节点，需要连接上该地址,需要记录,可以配置固定地址 libp2p
    ./lotus net listen

    //查看矿工信息
    ./lotus-storage-miner info


编译创建矿工 fountain程序

    进入在 ./cmd/lotus-fountain 目录下

    // 编译程序，默认程序生成在当前目录下 文件名称 lotus-fountain 
    go build

    // 运行程序 默认监听 7777端口(要改ocfs心跳占用这个端口); 地址为创世节点钱包地址，注意   
    ./fountain run -front 0.0.0.0:7778 -from t3wx7kkfvox2wp5dkyg7ghj5d2wyws4axrparfytqu4nvs3mosmopzw5o5ic5kxnmlbaivgob6rww5fcsygj6q

    // tips: 最新代码里面没有 1024 扇区，需要更改部分代码
    在 ./cmd/lotus-fountain/main.go 文件 在 263行左右


    // 此处添加代码，更改为指定要创建的扇区大小/ 或者更改网页 代码
    
    // ... 更改为指定扇区大小
    ssize = 1024 
	params, err := actors.SerializeParams(&actors.CreateStorageMinerParams{
		Owner:      owner,
		Worker:     owner,
		SectorSize: uint64(ssize),
		PeerID:     peer.ID("SETME"),
	})
    ...
    // 或者更改网页 当前目录下面的 site/miner.html
      <select name="sectorSize">
                    <option selected value="1024">1024 sectors</option>
      </select>




 运行其他的节点，将可执行文件拷贝到指定服务器

    // 将初始节点生成的 genecis.car 拷贝过来，初始化
    ./lotus daemon --genesis=genesis.car --bootstrap=false   
    
    // 连接创世节点, 地址为创世节点执行  ./louts net listen 出来的地址 libp2p地址（示例 /ip4/ip/tcp/port/p2p/id）
    ./lotus net connect 地址

    //创建钱包地址
    ./lotus wallet new bls

    // 进入上面 fountain web页面创建 初始化创建矿工,返回初始化就行,初始化是需要加上 --nosync=true参数
    lotus-storage-miner init --actor=t01424 --owner=t3spmep2xxsl33o4gxk7yjxcobyohzgj3vejzerug25iinbznpzob6a6kexcbeix73th6vjtzfq7boakfdtd6a --nosync=true


#### 脚本部署

在35机器上面 ~/deploy_dev_net 目录下

初始化操作

    //复制可执行程序到目标机器上面


    // 复制 lotus-daemon.service lotus-miner.service 当相应的主机上面
    sh setup-host.sh 172.16.8.33









    

