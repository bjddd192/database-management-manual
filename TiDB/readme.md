# TiDB

TiDB 是一款定位于在线事务处理/在线分析处理的融合型数据库产品，实现了一键水平伸缩，强一致性的多副本数据安全，分布式事务，实时 OLAP 等重要特性。同时兼容 MySQL 协议和生态，迁移便捷，运维成本极低。

[官方网站](https://pingcap.com/zh/)

[官方文档](https://docs.pingcap.com/zh/tidb/stable)

[TiDB 整体架构](https://docs.pingcap.com/zh/tidb/stable/tidb-architecture)

[TiDB 数据库快速上手指南](https://docs.pingcap.com/zh/tidb/stable/quick-start-with-tidb)

[TiDB 软件和硬件环境建议配置](https://docs.pingcap.com/zh/tidb/stable/hardware-and-software-requirements)

[使用 TiUP 部署 TiDB 集群](https://docs.pingcap.com/zh/tidb/stable/production-deployment-using-tiup)

### 单机快速体验

```sh
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
source /root/.bash_profile
tiup playground v6.1.0 --db 2 --pd 3 --kv 3
# 清理集群
tiup clean --all
```

此方式只能在单机进行访问。

### 标准测试集群构建

```sh
yum -y install numactl

# 设置机器对中控机免密

curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
source .bash_profile
which tiup
tiup cluster template > topology.yaml
vi topology.yaml

# 检查集群存在的潜在风险
tiup cluster check ./topology.yaml --user root

# 部署 TiDB 集群
tiup cluster deploy tidb-test v6.1.0 ./topology.yaml --user root

# 查看 TiDB 集群
tiup cluster list

# 检查部署的 TiDB 集群情况
tiup cluster display tidb-test

# 安全启动集群
tiup cluster start tidb-test --init
# Started cluster `tidb-test` successfully
# The root password of TiDB database has been changed.
# The new password is: '=3479f6+Wja!rtc*0L'.
# Copy and record it to somewhere safe, it is only displayed once, and will not be stored.
# The generated password can NOT be get and shown again.

# 检查部署的 TiDB 集群情况
tiup cluster display tidb-test
# tiup is checking updates for component cluster ...
# Starting component `cluster`: /root/.tiup/components/cluster/v1.10.3/tiup-cluster display tidb-test
# Cluster type:       tidb
# Cluster name:       tidb-test
# Cluster version:    v6.1.0
# Deploy user:        tidb
# SSH type:           builtin
# Dashboard URL:      http://10.10.217.88:2379/dashboard
# Grafana URL:        http://10.10.217.80:3000
# ID                  Role          Host          Ports        OS/Arch       Status   Data Dir                      Deploy Dir
# --                  ----          ----          -----        -------       ------   --------                      ----------
# 10.10.217.80:9093   alertmanager  10.10.217.80  9093/9094    linux/x86_64  Up       /tidb-data/alertmanager-9093  /tidb-deploy/alertmanager-9093
# 10.10.217.80:3000   grafana       10.10.217.80  3000         linux/x86_64  Up       -                             /tidb-deploy/grafana-3000
# 10.10.217.70:2379   pd            10.10.217.70  2379/2380    linux/x86_64  Up       /tidb-data/pd-2379            /tidb-deploy/pd-2379
# 10.10.217.80:2379   pd            10.10.217.80  2379/2380    linux/x86_64  Up       /tidb-data/pd-2379            /tidb-deploy/pd-2379
# 10.10.217.88:2379   pd            10.10.217.88  2379/2380    linux/x86_64  Up|L|UI  /tidb-data/pd-2379            /tidb-deploy/pd-2379
# 10.10.217.80:9090   prometheus    10.10.217.80  9090/12020   linux/x86_64  Up       /tidb-data/prometheus-9090    /tidb-deploy/prometheus-9090
# 10.10.217.70:4000   tidb          10.10.217.70  4000/10080   linux/x86_64  Up       -                             /tidb-deploy/tidb-4000
# 10.10.217.80:4000   tidb          10.10.217.80  4000/10080   linux/x86_64  Up       -                             /tidb-deploy/tidb-4000
# 10.10.217.88:4000   tidb          10.10.217.88  4000/10080   linux/x86_64  Up       -                             /tidb-deploy/tidb-4000
# 10.10.217.70:20160  tikv          10.10.217.70  20160/20180  linux/x86_64  Up       /tidb-data/tikv-20160         /tidb-deploy/tikv-20160
# 10.10.217.80:20160  tikv          10.10.217.80  20160/20180  linux/x86_64  Up       /tidb-data/tikv-20160         /tidb-deploy/tikv-20160
# 10.10.217.88:20160  tikv          10.10.217.88  20160/20180  linux/x86_64  Up       /tidb-data/tikv-20160         /tidb-deploy/tikv-20160

# 停止集群
tiup cluster stop tidb-test

# 修改参数后重新加载参数
tiup cluster reload tidb-test -R tidb
```

### 集群验证

```sql
mysql -u root -h 10.10.217.88 -P 4000 -p

MySQL [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| INFORMATION_SCHEMA |
| METRICS_SCHEMA     |
| PERFORMANCE_SCHEMA |
| mysql              |
| test               |
+--------------------+

MySQL [(none)]> select tidb_version()\G
*************************** 1. row ***************************
tidb_version(): Release Version: v6.1.0
Edition: Community
Git Commit Hash: 1a89decdb192cbdce6a7b0020d71128bc964d30f
Git Branch: heads/refs/tags/v6.1.0
UTC Build Time: 2022-06-05 05:15:11
GoVersion: go1.18.2
Race Enabled: false
TiKV Min Version: v3.0.0-60965b006877ca7234adaced7890d7b029ed1306
Check Table Before Drop: false
1 row in set (0.00 sec)
MySQL [(none)]> create database pingcap;
Query OK, 0 rows affected (0.12 sec)

MySQL [(none)]> use pingcap;
Database changed

MySQL [pingcap]> CREATE TABLE `tab_tidb` (
    -> `id` int(11) NOT NULL AUTO_INCREMENT,
    -> `name` varchar(20) NOT NULL DEFAULT '',
    -> `age` int(11) NOT NULL DEFAULT 0,
    -> `version` varchar(20) NOT NULL DEFAULT '',
    -> PRIMARY KEY (`id`),
    -> KEY `idx_age` (`age`));
Query OK, 0 rows affected (0.12 sec)

MySQL [pingcap]> insert into `tab_tidb` values (1,'TiDB',5,'TiDB-v5.0.0');
Query OK, 1 row affected (0.02 sec)

MySQL [pingcap]> select * from tab_tidb;
+----+------+-----+-------------+
| id | name | age | version     |
+----+------+-----+-------------+
|  1 | TiDB |   5 | TiDB-v5.0.0 |
+----+------+-----+-------------+

-- 查看 TiKV store 状态、store_id、存储情况以及启动时间
MySQL [pingcap]> select STORE_ID,ADDRESS,STORE_STATE,STORE_STATE_NAME,CAPACITY,AVAILABLE,UPTIME from INFORMATION_SCHEMA.TIKV_STORE_STATUS;
```

### sysbench 压测

[severalnines/sysbench](https://hub.docker.com/r/severalnines/sysbench)

```sh
CREATE SCHEMA sbtest;
CREATE USER sbtest@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sbtest.* to sbtest@'%';

docker run \
--rm=true \
--name=sb-prepare \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=1 \
--mysql-host=10.10.217.70 \
--mysql-port=4000 \
--mysql-user=sbtest \
--mysql-password=password \
/usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
run

docker run \
--name=sb-run \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--report-interval=2 \
--mysql-table-engine=innodb \
--oltp-table-size=100000 \
--oltp-tables-count=16 \
--threads=16 \
--time=300 \
--mysql-host=10.10.217.70 \
--mysql-port=4000 \
--mysql-user=sbtest \
--mysql-password=password \
/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
run
```

### 安装 TiUP DM 组件迁移数据

[使用 TiUP 部署 DM 集群](https://docs.pingcap.com/zh/tidb/stable/deploy-a-dm-cluster-using-tiup)

[DM 任务完整配置文件介绍](https://docs.pingcap.com/zh/tidb/stable/task-configuration-file-full#%E5%8A%9F%E8%83%BD%E9%85%8D%E7%BD%AE%E9%9B%86)

```sh
tiup install dm dmctl
tiup dm template > dm-topology.yaml
vi dm-topology.yaml

# 执行部署命令
tiup dm deploy dm-test v6.1.0 ./dm-topology.yaml --user root
# 查看 TiUP 管理的集群情况
tiup dm list
# 检查部署的 DM 集群情况
tiup dm display dm-test
# 启动集群
tiup dm start dm-test

# 创建数据源
vi source1.yaml
tiup dmctl --master-addr 10.10.217.70:8261 operate-source create source1.yaml

# 创建迁移任务
vi task1.yaml
# 检查任务
tiup dmctl --master-addr 10.10.217.70:8261 check-task task1.yaml
# 启动迁移任务
tiup dmctl --master-addr 10.10.217.70:8261 start-task task1.yaml
tiup dmctl --master-addr 10.10.217.70:8261 start-task --remove-meta task1.yaml
# 查看任务状态
tiup dmctl --master-addr 10.10.217.70:8261 query-status
tiup dmctl --master-addr 10.10.217.70:8261 query-status test
# 重启任务
tiup dmctl --master-addr 10.10.217.70:8261 resume-task task1.yaml
# 停止迁移任务
tiup dmctl --master-addr 10.10.217.70:8261 stop-task task1.yaml
```
