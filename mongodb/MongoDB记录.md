# MongoDB

MongoDB 是最常用的 nosql 数据库，在数据库排名中已经上升到了前六。

当前，MongoDB 4.0 已正式发布，MongoDB 是一个开源文档数据库，提供高性能、高可用性和自动扩展。

首先，需要看看 MongoDB 适用于什么场景：[对比MySQL，什么场景MongoDB更适用](https://www.cnblogs.com/imhurley/p/6060229.html)

## 官方资源

[MongoDB Manual](https://docs.mongodb.com/manual/)

## 版本说明

[官方说明](https://docs.mongodb.com/manual/release-notes/)

MongoDB 的版本号十分方便理解，偶数的版本号为稳定版，奇数则为开发版。

MongoDB 3.0 支持用户自定义存储引擎，用户可配置使用mmapv1或者wiredTiger存储引擎。

MongoDB 3.2 版本以后默认的开启的是wiredTiger存储引擎，之前用的是mmapv1存储引擎。并且2个存储引擎生成的数据文档格式不兼容。也就是说mmapv1引擎生成的数据文档wiredTiger引擎读取不出来。

[MongoDB 3.4 功能改进一览](http://www.mongoing.com/archives/3586)

[首个最全的MongoDB 3.6 全览](https://segmentfault.com/a/1190000011934989)

[MongoDB 4.0 正式发布，支持多文档事务](https://www.oschina.net/news/97524/mongodb-4-0-released)

## 安装部署

### 二进制安装部署

[搭建高可用mongodb集群](http://www.lanceyan.com/tech/mongodb)

[mongodb 3.4 集群搭建：分片+副本集](http://www.ityouknow.com/mongodb/2017/08/05/mongodb-cluster-setup.html)

[mongodb 3.4 集群搭建升级版 五台集群](https://www.cnblogs.com/ityouknow/p/7566682.html)

[搭建高可用mongodb集群（一）——配置MongoDB](http://www.lanceyan.com/tech/mongodb/mongodb_cluster_1.html)

[搭建高可用mongodb集群（二）—— 副本集](http://www.lanceyan.com/tech/mongodb/mongodb_repset1.html)

[搭建高可用mongodb集群（三）—— 深入副本集内部机制](http://www.lanceyan.com/tech/mongodb_repset2.html)

[搭建高可用mongodb集群（四）—— 分片](http://www.lanceyan.com/tech/arch/mongodb_shard1.html)

[mongodb 3.4复制集配置](https://www.cnblogs.com/shengdimaya/p/6598450.html)

[MongoDB 3.0 常见集群的搭建(主从复制，副本集，分片)](https://blog.csdn.net/canot/article/details/50739359)

### 容器化部署

[使用docker搭建mongodb集群](http://bazingafeng.com/2017/06/19/create-mongodb-replset-cluster-using-docker/)

[reactioncommerce/mongo-rep-set](https://github.com/reactioncommerce/mongo-rep-set)

[frontalnh/mongodb-replica-set](https://github.com/frontalnh/mongodb-replica-set)

[How to deploy a MongoDB Replica Set using Docker](https://towardsdatascience.com/how-to-deploy-a-mongodb-replica-set-using-docker-6d0b9ac00e49)

## 权限管理

```sh
Read：允许用户读取指定数据库
readWrite：允许用户读写指定数据库
dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
root：只在admin数据库中可用。超级账号，超级权限。
```

## 数据导入导出

[MongoDB 备份(mongodump)与恢复(mongorestore)](http://www.runoob.com/mongodb/mongodb-mongodump-mongorestore.html)

[Mongodb命令行导入导出数据](https://blog.csdn.net/cupid_1314/article/details/79153480)

```sh
# 导出数据
mongodump -h 127.0.0.1 -p 27017 -d belledoc -o /data/db/backup

# 导入数据
mongorestore -h 127.0.0.1:27017 -d belledoc --drop /data/db/backup/belledoc -u root -p=mongoDev123 --authenticationDatabase admin
```

## 可视化工具

[adminMongo](https://github.com/mrvautin/adminMongo)

[Robo 3T](https://robomongo.org/)

[MongoVUE](http://mongodb-tools.com/tool/mongovue/)

