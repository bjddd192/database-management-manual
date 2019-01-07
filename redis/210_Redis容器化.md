# Redis容器化

redis.conf 是 Redis 的核心配置文件，默认 docker 运行的 redis 是不存在配置文件的，这里可以先从官网下载：

```sh
wget http://download.redis.io/redis-stable/redis.conf
wget http://download.redis.io/redis-stable/sentinel.conf
```

## 检视 Redis 容器

```sh
docker run --rm -it redis:4.0.12 bash
```

## 启动单实例

```sh
docker stop redis && docker rm redis

docker run -d --name redis -p 6379:6379 --restart always \
  redis:4.0.12
```

### 使用自定义配置文件

```sh
tee /data/redis/redis.conf <<-'EOF'
protected-mode no

# 接受指定端口上的连接，默认为 6379
port 6379

tcp-backlog 511

save 900 1
save 300 10
save 60 10000

stop-writes-on-bgsave-error yes

rdbcompression yes

# 在存储快照后，我们还可以让redis使用CRC64算法来进行数据校验，但是这样做会增加大约10%的性能消耗，
# 如果希望获取到最大的性能提升，可以关闭此功能。
rdbchecksum yes

# 设置快照的文件名
dbfilename dump.rdb

requirepass 123456
EOF

docker stop redis && docker rm redis

docker run -d --name redis -p 6379:6379 --restart always \
  -v /data/redis/redis.conf:/etc/redis.conf \
  redis:4.0.12 \
  redis-server /etc/redis.conf
```

## 主从模式

### 不指定 redis.conf

```sh
docker stop redis-master && docker rm redis-master

docker run -d --name redis-master -p 6300:6379 --restart always \
  redis:4.0.12 \
  --requirepass 123456
  
docker exec -it redis-master redis-cli -a 123456

127.0.0.1:6379> info Replication

docker stop redis-slave && docker rm redis-slave

docker run -d --name redis-slave -p 6301:6379 --restart always \
  redis:4.0.12 \
  --requirepass 123456
  
docker exec -it redis-slave redis-cli

127.0.0.1:6379> auth 123456
127.0.0.1:6379> slaveof 10.240.116.36 6300
127.0.0.1:6379> config set masterauth 123456
```

### 指定 redis.conf

推荐模式：为了让 redis-sentinel 可以发现 slave，要确保 redis 服务端口和容器映射端口一致，这里使用 host 网络模式。

当使用了 sentinel 时，由于一个 master 可能会变成一个 slave，一个 slave 也可能会变成 master，所以需要在 master 和 slave 的配置文件中同时都要设置 requirepass、masterauth 两个配置项，才能多次切换，否则就有可能只能切换一次。

```sh
tee /data/redis/redis-master.conf <<-'EOF'
port 6300
requirepass 123456
masterauth 123456
EOF

tee /data/redis/redis-slave.conf <<-'EOF'
port 6301
requirepass 123456
slaveof 10.240.116.46 6300
masterauth 123456
EOF

docker stop redis-master && docker rm redis-master

docker run -d --name redis-master --net=host --restart always \
  -v /data/redis/redis-master.conf:/etc/redis.conf \
  redis:4.0.12 \
  redis-server /etc/redis.conf

docker exec -it redis-master redis-cli -a 123456 -p 6300

127.0.0.1:6300> info Replication

docker stop redis-slave && docker rm redis-slave

docker run -d --name redis-slave --net=host --restart always \
  -v /data/redis/redis-slave.conf:/etc/redis.conf \
  redis:4.0.12 \
  redis-server /etc/redis.conf

docker exec -it redis-slave redis-cli -a 123456 -p 6301

127.0.0.1:6301> info Replication
```

## 哨兵模式

**哨兵节点至少配置 2 个以上。SENTINEL_QUORUM 的数量需要根据哨兵节点的数量而定，一般为哨兵节点数量减 1。**

**在生产环境下建议 sentinel 节点的数量能在 3 个以上，并且最好不要在同一台机器上(使用同一网卡)。 所以一般正式环境上的操作,是采用 docker 单个服务运行。**

```sh
tee /data/redis/redis-sentinel.conf <<-'EOF'
# 当前Sentinel服务运行的端口
port 26379

# Sentinel去监视一个名为mymaster的主redis实例，这个主实例的IP地址为 10.240.116.46，端口号为 6300，
# 而将这个主实例判断为失效至少需要2个Sentinel进程的同意，只要同意Sentinel的数量不达标，自动failover就不会执行
sentinel monitor mymaster 10.240.116.46 6300 2

# 指定了 Sentinel 认为 Redis 实例已经失效所需的毫秒数。
# 当实例超过该时间没有返回 PING，或者直接返回错误，那么 Sentinel 将这个实例标记为主观下线。
# 只有一个 Sentinel 进程将实例标记为主观下线并不一定会引起实例的自动故障迁移：
# 只有在足够数量的 Sentinel 都将一个实例标记为主观下线之后，实例才会被标记为客观下线，这时自动故障迁移才会执行
sentinel down-after-milliseconds mymaster 30000

# 指定了在执行故障转移时，最多可以有多少个从Redis实例在同步新的主实例，
# 在从Redis实例较多的情况下这个数字越小，同步的时间越长，完成故障转移所需的时间就越长
sentinel parallel-syncs mymaster 1

# 如果在该时间（ms）内未能完成failover操作，则认为该failover失败
sentinel failover-timeout mymaster 180000

# 设置主服务密码
sentinel auth-pass mymaster 123456
EOF

\cp -f /data/redis/redis-sentinel.conf /data/redis/redis-sentinel-01.conf
\cp -f /data/redis/redis-sentinel.conf /data/redis/redis-sentinel-02.conf
\cp -f /data/redis/redis-sentinel.conf /data/redis/redis-sentinel-03.conf

docker stop redis-sentinel-01 && docker rm redis-sentinel-01
docker stop redis-sentinel-02 && docker rm redis-sentinel-02
docker stop redis-sentinel-03 && docker rm redis-sentinel-03

docker run -d --name redis-sentinel-01 --user root --restart always \
  -v /data/redis/redis-sentinel-01.conf:/etc/redis-sentinel.conf \
  redis:4.0.12 \
  redis-server /etc/redis-sentinel.conf --sentinel

docker run -d --name redis-sentinel-02 --user root --restart always \
  -v /data/redis/redis-sentinel-02.conf:/etc/redis-sentinel.conf \
  redis:4.0.12 \
  redis-server /etc/redis-sentinel.conf --sentinel

docker run -d --name redis-sentinel-03 --user root --restart always \
  -v /data/redis/redis-sentinel-03.conf:/etc/redis-sentinel.conf \
  redis:4.0.12 \
  redis-server /etc/redis-sentinel.conf --sentinel

docker exec -it redis-master redis-cli -a 123456 -p 6300

127.0.0.1:6379> info Replication
127.0.0.1:6379> set age 18

docker stop redis-master

docker exec -it redis-slave redis-cli -a 123456 -p 6301

127.0.0.1:6379> info Replication
127.0.0.1:6379> set age 18

# 等待 30 秒后，sentinel 节点判断 master 节点客观下线，slave 节点被选举为主节点。

docker start redis-master
```

## 参考资料

[基于Docker的Redis高可用集群搭建（redis-sentinel）](https://cloud.tencent.com/developer/article/1343834)

[使用 Docker Compose 本地部署基于 Sentinel 的高可用 Redis 集群](https://juejin.im/post/5a9bce1a518825557f005e92)

[阿里云使用Docker Compose部署基于Sentinel的高可用Redis集群](https://yq.aliyun.com/articles/57953)

[bitnami-docker-redis](https://hub.docker.com/r/bitnami/redis)

[bitnami-docker-redis-sentinel](https://hub.docker.com/r/bitnami/redis-sentinel/)

[深入浅出Docker技术- Redis sentinel 集群的搭建](http://www.dczou.com/viemall/837.html)

[viemall-redis-sentinel](https://gitee.com/gz-tony/viemall-dubbo/tree/master/viemall-docekr/compose/redis-sentinel)

https://123.belle.net.cn/cas/login?service=https%3A%2F%2Fpetrel-scm01.belle.net.cn%2Fpetrel%2Fsso%2Flogin%3FsystemCode%3DPetrel
