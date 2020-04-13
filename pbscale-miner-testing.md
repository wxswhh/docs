# Test plan
## Team Introduction
Our team is called Xinji Rongwei, base in Chengdu, China. We have already deployed six IDCs distributed in Chengdu, Xian, Wuhan, Shanghai, Guangzhou, and Chongqing, with different Networking Operators. Configuring 3PB+ storage pool for each IDC, high-performance CPU of Intel,378GB RAM, and 10 Gigabit networking. We will also add new high-performance servers to achieve the optimal configurations and maximum efficiency of the cluster.

We currently have a team of 12 people including R & D, hardware and software engineering and maintenance personnel for Filecoin.
So, we have adequate resources to participate in the PB-scale miner test, And we are willing to provide real valuable testing data.
## Power validation(testnet II,todo) 

## Test list
- Benchmarking
  - CPU, GPU, RAM, SSD and HDDs, also including Switches
  - Different hardware configurations(it has been determined that 4 CPUs will be tested, Combined test of different CPU and different capacity of RAM,
  SSD/HDDs and networking will be included too.)
- Networking bandwidth and throughput metrics
  - Metrics of Gigabit and 10 Gigabit networking 
- Filecoin software configurations
  - Sealing and Proofs metrics
  - Sector loss monitoring
  - Daemon - Miner configurations desicription
  - Blockchain metrics
  - Mined block and commited block metrics(ePoSt time)
  - Seal Worker configurations desicription(divied by different jobs that is based on the job which is needs resources and comsuption time, different configurations do different job, maximum efficiency)  
  - Seal speed per US Dollar (GB/h) metrics
  - Find out performance bottlenecks
  - Performance of ePoSt on 5 PB+ of sealed data metrics

## 
