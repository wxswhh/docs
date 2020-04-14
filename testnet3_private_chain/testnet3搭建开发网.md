#### 说明

    西安 node02 机器上面是初始节点, 相关的bin,脚本，配置文件 在 ~/interopnet-release-bin/ 目录下面，
    
    其余节点要连接到该初始节点需要进行以下下操作:
    1. 将 ~/interopnet-release-bin/config/devnet.car 拷贝到到你的项目 覆盖 build/genesis/devnet.car文件
    2. 将 /ip4/113.142.73.227/tcp//p2p/12D3KooWG38mEdUdPhDpbY5c9FgxHngZnc3UhWsp4SC9sBgJTyH2    这个地址覆盖 build/bootstrap/bootstrap.pi 文件的内容
    3. make build 编译即可
    4. http://113.142.73.227:7778/  创建矿工地址
   

tips: 连接到该节点操作只需关心 说明 内容，下面部分为详细搭建初始节点操作可以不管。

#### 初始节点编译搭建

    # 截止当前测试中 testnet/3 分支代码编译测试，跑不成功，以 interopnet 分支代码测试部署

    git clone https://github.com/filecoin-project/lotus.git
    
    // 互通网分支
    git checkout -b interopnet origin/ineropnet

    // 编译之前需要先修改部分代码, 非debug模式编译，部分参数默认隐藏，需要手动开启
    修改cmd/lotus/daemon.go文件中

    var DaemonCmd = &cli.Command{
	Name:  "daemon",
	Usage: "Start a lotus daemon process",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "api",
			Value: "1234",
		},
		&cli.StringFlag{
			Name:   makeGenFlag,
			Value:  "",
			Hidden: false, // 改成 false, 默认为true
		},
		&cli.StringFlag{
			Name:   preTemplateFlag,
			Hidden: false, // 改成 false, 默认为true
		},
		&cli.StringFlag{
			Name:   "import-key",
			Usage:  "on first run, import a default key from a given file",
			Hidden: false, // 改成 false, 默认为true
		},

        修改 cmd/lotus-storage-miner/init.go文件中
    
        var initCmd = &cli.Command{
        Name:  "init",
        Usage: "Initialize a lotus storage miner repo",
        Flags: []cli.Flag{
            &cli.StringFlag{
                Name:  "actor",
                Usage: "specify the address of an already created miner actor",
            },
            &cli.BoolFlag{
                Name:   "genesis-miner",
                Usage:  "enable genesis mining (DON'T USE ON BOOTSTRAPPED NETWORK)",
                Hidden: false,    // 改成 false, 默认为true
            },

        修改 cmd/lotus-seed/genesis.go文件
        	template.Miners = append(template.Miners, miner)
			log.Infof("Giving %s some initial balance", miner.Owner)
			template.Accounts = append(template.Accounts, genesis.Actor{
				Type:    genesis.TAccount,
				Balance: big.NewInt(1000000000000000000), //这个改大点，创建其它矿工需要fil ，添加两个0 足够测试
				Meta:    (&genesis.AccountMeta{Owner: miner.Owner}).ActorMeta(),
			})



        #开始编译
        make build
        make lotus-seed


        # 以下操作跟 docoumentation/local-dev-net.md 文档一致，
        # tips: 扇区预密封大小测试为 4个 512M的扇区，测试中 修改代码以 2048扇区大小测试发现无效

        Download the 2048 byte parameters:
        ```sh
        ./lotus fetch-params --proving-params 536870912
        ```


        Pre-seal some sectors:

        ```sh
        ./lotus-seed pre-seal --sector-size 536870912 --num-sectors 4 // 至少2G的有效存储 
        ```

        Create the genesis block and start up the first node:

        ```sh
        ./lotus-seed genesis new localnet.json
        
        ./lotus-seed genesis add-miner localnet.json ~/.genesis-sectors/pre-seal-t01000.json
        
        ./lotus daemon --lotus-make-genesis=dev.gen --genesis-template=localnet.json --bootstrap=false
        ```

        Then, in another console, import the genesis miner key:

        ```sh
        ./lotus wallet import ~/.genesis-sectors/pre-seal-t01000.key
        ```

        Set up the genesis miner:

        ```sh
        ./lotus-storage-miner init --genesis-miner --actor=t01000 --sector-size=536870912 --pre-sealed-sectors=~/.genesis-sectors --pre-sealed-metadata=~/.genesis-sectors/pre-seal-t01000.json --nosync
        ```

        Now, finally, start up the miner:

        ```sh
        ./lotus-storage-miner run --nosync
        ```

        If all went well, you will have your own local Lotus Devnet running.

lotus-fountain程序

    // 编译该目录文件
    cmd/lotus-fountain/main.go
    go build
    ./fountain run -front 0.0.0.0:7778 -from t3wx7kkfvox2wp5dkyg7ghj5d2wyws4axrparfytqu4nvs3mosmopzw5o5ic5kxnmlbaivgob6rww5fcsygj6q

初始节点初始化完成

#### 编译普通的节点

    1. 将生成的 devnet.car文件拷贝到 build/genesis/ 目录中

    2. 在初始节点 执行 lotus net listen ,将p2p节点地址覆盖原始中继点 build/bootstrap/bootstrap.pi ,在运行的时候会连接到我们自定义的初始节点
    
    3. 编译 make build

    4.后续的部署操作与官方操作一致，创建矿工等




