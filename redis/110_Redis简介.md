# Redis简介

Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries. Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster. 

Redis 是一个开源(BSD许可)的，内存中的数据结构存储系统，它可以用作数据库、缓存和消息中间件。 它支持多种类型的数据结构，如：字符串(strings)，散列(hashes)，列表(lists)，集合(sets)，有序集合(sorted sets)与范围查询，bitmaps，hyperloglogs和地理空间(geospatial)索引半径查询。Redis 内置了复制(replication)，LUA脚本(Lua scripting)，LRU驱动事件(LRU eviction)，事务(transactions)和不同级别的磁盘持久化(persistence)，并通过 Redis哨兵(Sentinel)和自动分区(Cluster)提供高可用性(high availability)。

Redis 是一种基于键值对(key-value)数据库，其中 value 可以为 string、hash、list、set、zset 等多种数据结构，可以满足很多应用场景。还提供了键过期，发布订阅，事务，流水线，等附加功能。

流水线: Redis 的流水线功能允许客户端一次将多个命令请求发送给服务器， 并将被执行的多个命令请求的结果在一个命令回复中全部返回给客户端， 使用这个功能可以有效地减少客户端在执行多个命令时需要与服务器进行通信的次数。

## 官方资源

[Redis官网](https://redis.io/)

[Redis中文官网](http://www.redis.cn/)

[Redis官方下载地址](http://download.redis.io/releases/)

[Redis官方在线试用教程](http://try.redis.io/)

## 优质学习资源

[小不点啊——Redis系列](https://www.cnblogs.com/leeSmall/category/1090974.html)

## 特性

1. 速度快，数据放在内存中，官方给出的读写性能10万/S，与机器性能也有关
	- 数据放内存中是速度快的主要原因
	- C语言实现，与操作系统距离近
	- 使用了单线程架构，预防多线程可能产生的竞争问题
2. 键值对的数据结构服务器
3. 丰富的功能：键过期，发布订阅，事务，流水线.....
4. 简单稳定：单线程
5. 持久化：发生断电或机器故障，数据可能会丢失，持久化到硬盘
6. 主从复制：实现多个相同数据的redis副本
7. 高可用和分布式：哨兵机制实现高可用，保证redis节点故障发现和自动转移
8. 客户端语言多：java php python c c++ nodejs等

## 应用场景
1. 缓存：合理使用缓存加快数据访问速度，降低后端数据源压力
2. 排行榜：按照热度排名，按照发布时间排行，主要用到列表和有序集合
3. 计数器应用：视频网站播放数，网站浏览数，使用redis计数
4. 社交网络：赞、踩、粉丝、下拉刷新
5. 消息队列：发布和订阅

## 版本说明

版本号第二位为奇数，为非稳定版本（2.7、2.9、3.1）

第二为偶数，为稳定版本（2.6、2.8、3.0）

当前奇数版本是下一个稳定版本的开发版本，如2.9是3.0的开发版本。