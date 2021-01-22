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

```sh

```

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

### 常用操作

```sql
-- 插入单条数据
db.fruit.insertOne({name: "apple"})

-- 插入多条数据
db.fruit.insertMany([{name: "apple"}, {name: "pear"}, {name: "orange"}])

-- 查询所有数据
db.fruit.find()

-- 按条件查询数据
db.fruit.find({name: "apple"})
db.fruit.find({$or: [{name: "apple"}, {name: "orange"}]})
-- 投影查询
db.fruit.find({name: "pear"},{"_id": 0, name: 1})

-- 查找子文档
db.fruit.insertOne({name: "apple", from: {country: "China", province: "Shenzhen"}})
db.fruit.find({"from.country": "China"})
db.fruit.insertOne({name: "apple", from: [{country: "China", province: "Shenzhen"}, {country: "China", province: "Guangzhou"}]})
db.fruit.find({"from": {$elemMatch: {country: "China", province: "Shenzhen"}}})
db.fruit.find({},{"_id": 0, name: 1})

-- 更新文档
db.fruit.updateOne({name: "orange"}, {"$set": {from: "English"}})
db.fruit.updateMany({name: "orange"}, {"$set": {from: "English"}})
db.fruit.find({name: "orange"})

-- 删除文档
db.testdel.insertMany([{name: "apple"}, {name: "pear"}, {name: "orange"}])
-- 按条件删除一个
db.testdel.deleteOne({name: "orange"})
-- 删除所有
db.testdel.deleteMany({})

-- 删除集合
db.testdel.drop()
```

### python 验证

```python
docker run -it --rm -e COLUMNS=200 -e LINES=200 hub.wonhigh.cn/library/python:3.7.4-alpine3.10 sh
pip install pymongo
python
Python 3.7.4 (default, Aug 21 2019, 00:19:59) 
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pymongo
>>> pymongo.version
>>> from pymongo import MongoClient
>>> uri = "mongodb://root:mongoDev123@172.17.209.202:27017/admin"    
>>> client = MongoClient(uri)
>>> print(client)
>>> db = client["eshop"]
>>> user_coll = db["users"]
>>> new_user = {"username": "leo", "password": "xxxx"}
>>> result = user_coll.insert_one(new_user)
>>> print(result)
>>> result = user_coll.update_one({"username": "leo"}, {"$set": {"phone": "123456789"}})  
>>> print(result)
```

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

[关于MongoDB的URL连接时用户名或密码中出现特殊字符问题](https://blog.csdn.net/u013732444/article/details/78229177)

## 数据导入导出

[MongoDB 备份(mongodump)与恢复(mongorestore)](http://www.runoob.com/mongodb/mongodb-mongodump-mongorestore.html)

[Mongodb命令行导入导出数据](https://blog.csdn.net/cupid_1314/article/details/79153480)

[MongoDB 数据集合导出与导入](https://blog.csdn.net/wangmx1993328/article/details/82663617)

[使用MongoDB导入和导出Json文档](https://www.pianshen.com/article/9726287590/)

```sh
# 导出数据
mongodump -h 127.0.0.1 -p 27017 -d belledoc -o /data/db/backup

# 导入数据
mongorestore -h 127.0.0.1:27017 -d belledoc --drop /data/db/backup/belledoc -u root -p=mongoDev123 --authenticationDatabase admin
```

## 数据安全

[Mongodb 误删除 使用Oplog数据恢复](https://www.jianshu.com/p/4c1a8175732e)

[MongoDB Oplog 详解](https://www.cnblogs.com/operationhome/p/10688798.html)

[单台MongoDB实例开启Oplog](https://www.cnblogs.com/xuliuzai/p/9643128.html)

## 可视化工具

[adminMongo](https://github.com/mrvautin/adminMongo)

[Robo 3T](https://robomongo.org/)

[MongoVUE](http://mongodb-tools.com/tool/mongovue/)

### 性能优化

[MongoDB实战性能优化](https://www.cnblogs.com/swordfall/p/10427150.html)

### 参考资料

[记一次 MongoDB 占用 CPU 过高问题的排查](https://cloud.tencent.com/developer/article/1495820)

[排查MongoDB CPU使用率高的问题](https://help.aliyun.com/document_detail/62224.html)

[性能提升数十倍！百万级高并发MongoDB集群优化实践](https://dbaplus.cn/news-162-2986-1.html)

[MongoDB服务器相关选型和基础优化参考](https://blog.51cto.com/smileyouth/1653790)

[mongodb分片模式分片键的选择](https://cloud.tencent.com/developer/article/1451897)

[Mongodb Sharding架构如何选择分片片键](http://blog.chinaunix.net/uid-15795819-id-3521990.html)

[快速了解MongoDB](https://my.oschina.net/u/4374969/blog/4065569)

