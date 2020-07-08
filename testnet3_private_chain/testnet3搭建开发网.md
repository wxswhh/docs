#### 说明

    在 sh 18 号机器上面 (注意地址是内网地址，需要外网请更换) lotus版本  0.4.1+git.5de7b62d.dirty+api0.5.0
    
    其余节点要连接到该初始节点需要进行以下下操作:
    1. 将/home/xjrw/private-chain-0.4.1/devnet.car 拷贝到到你的项目 覆盖 build/genesis/devnet.car文件
    2. /ip4/172.16.23.118/tcp/35579/p2p/12D3KooWREo6qCDza57FxQNnDPSy4QyLm1t1eJtW4A9A3QM32MMW    这个地址覆盖 build/bootstrap/bootstrap.pi 文件的内容
    3. env 'RUSTFLAGS=-C target-cpu=native -g' FFI_BUILD_FROM_SOURCE=1 make  clean all 编译即可
    4. http://172.16.23.118:7778/  创建矿工地址
   
upateTime: 2020/0708
tips: 连接到该节点操作只需关心 说明 内容，下面部分为详细搭建初始节点操作可以不管。文档待整理更新

#### 初始节点编译搭建

    # 截止当前测试中 testnet/3 分支代码编译测试，跑不成功，以 interopnet 分支代码测试部署

    git clone https://github.com/filecoin-project/lotus.git
    
    // 互通网分支
    git checkout -b interopnet origin/ineropnet

    // 编译之前需要先修改部分代码, 非debug模式编译，部
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
        ./lotus fetch-params --proving-params 536870912  、// 536870912    34359738368    68719476736
        ```


        Pre-seal some sectors:

        ```sh
        nohup ./lotus-seed  --sector-dir /opt/local_ssd/.genesis-sectors pre-seal  --sector-size 34359738368 --num-sectors 4  >presector.log 2>&1 &  // 至少2G的有效存储 


        // 多个miner合并
        nohup ./lotus-seed   pre-seal  --miner-addr=t01001 --sector-offset=0  --sector-size 34359738368 --num-sectors 1  >presector.log 2>&1 & 

        nohup ./lotus-seed   pre-seal  --miner-addr=t01002 --sector-offset=0  --sector-size 34359738368 --num-sectors 1  >presector.log 2>&1 & 

        nohup ./lotus-seed   --sector-dir=/opt/local_ssd/.genesis-sectors   pre-seal  --miner-addr=t01003 --sector-offset=0  --sector-size 34359738368 --num-sectors 1  >presector.log 2>&1 & 
        nohup ./lotus-seed   --sector-dir=/opt/local_ssd/.genesis-sectors   pre-seal  --miner-addr=t01004 --sector-offset=0  --sector-size 34359738368 --num-sectors 1  >presector.log 2>&1 & 

        nohup ./lotus-seed   --sector-dir=/opt/local_ssd/.genesis-sectors01   pre-seal  --miner-addr=t01001 --sector-offset=1  --sector-size 34359738368 --num-sectors 1  >presector.log 2>&1 & 

        ./lotus-seed aggregate-manifests ./pre-seal-t01000.json ./pre-seal-t01001.json ./pre-seal-t01002.json ./pre-seal-t01003.json ./pre-seal-t01004.json > ./pre-seal-genesis.json

        ```

        Create the genesis block and start up the first node:

        ```sh
        ./lotus-seed genesis new localnet.json
        
        ./lotus-seed genesis add-miner localnet.json ~/.genesis-sectors/pre-seal-genesis.json
        
        nohup ./lotus daemon --lotus-make-genesis=dev.gen --genesis-template=localnet.json --bootstrap=false >lotus.log 2>&1 &
        ```

        Then, in another console, import the genesis miner key:

        ```sh
        ./lotus wallet import ~/.genesis-sectors/pre-seal-t01000.key
        ```

        Set up the genesis miner:

        ```sh
        nohup ./lotus-storage-miner init --genesis-miner --actor=t01000 --sector-size=34359738368 --pre-sealed-sectors=~/.genesis-sectors --pre-sealed-metadata=~/.genesis-sectors/pre-seal-t01000.json --nosync >minerinit.log 2>&1 &
        ```

        Now, finally, start up the miner:

        ```sh
        nohup ./lotus-storage-miner run --nosync >miner.log 2>&1 &
        ```

        If all went well, you will have your own local Lotus Devnet running.

lotus-fountain程序

    // 编译该目录文件
    cmd/lotus-fountain/main.go
    go build
    nohup ./lotus-fountain run -front 0.0.0.0:7778 -from t3u6grpdmn65jfn2iyuzo47kyf64yumxvrbz7clkw77jtpwy6mamogiovbbs42sikhsqhkhnp3lepqy46slpsq >lotus-fountain.log 2>&1 &

初始节点初始化完成

#### 编译普通的节点

    1. 将生成的 devnet.car文件拷贝到 build/genesis/ 目录中

    2. 在初始节点 执行 lotus net listen ,将p2p节点地址覆盖原始中继点 build/bootstrap/bootstrap.pi ,在运行的时候会连接到我们自定义的初始节点
    
    3. 编译 make build

    4.后续的部署操作与官方操作一致，创建矿工等




