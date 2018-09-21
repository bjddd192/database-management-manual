# Redis数据类型

## 字符串类型

可以是字符串（包括XML JSON），数字（整形 浮点数），二进制（图片 音频 视频），最大不能超过512MB。

## 哈希 hash

```sh
127.0.0.1:6379> hmset user:1 name yanglei age 28 sex man
OK
127.0.0.1:6379> hmget user:1 name age sex
1) "yanglei"
2) "28"
3) "man"

# 判断 field 是否存在
127.0.0.1:6379> hexists user:2 name
(integer) 0
127.0.0.1:6379> hexists user:1 name
(integer) 1

# 获取 user:1 所有的 field
127.0.0.1:6379> hkeys user:2 
(empty list or set)
127.0.0.1:6379> hkeys user:1
1) "name"
2) "age"
3) "sex"

# 获取 user:1 所有value
127.0.0.1:6379> hvals user:2
(empty list or set)
127.0.0.1:6379> hvals user:1
1) "yanglei"
2) "28"
3) "man"

# 获取 user:1 所有的 field 与 value
127.0.0.1:6379> hgetall user:2
(empty list or set)
127.0.0.1:6379> hgetall user:1
1) "name"
2) "yanglei"
3) "age"
4) "28"
5) "sex"
6) "man"

# 内部编码：ziplist<压缩列表> 和 hashtable<哈希表>
# 当 field 个数少且没有大的 value 时，内部编码为 ziplist
# 当 value 大于 64 字节，内部编码由 ziplist 变成 hashtable
127.0.0.1:6379> object encoding user:1
"ziplist"
```

## 列表 list

用来存储多个有序的字符串，一个列表最多可存 2 的 32 次方减 1 个元素

因为有序，可以通过索引下标获取元素或某个范围内元素列表，列表元素可以重复

**添加命令：rpush lpush linset**

**查找命令：lrange lindex llen**

**删除命令：lpop rpop lrem ltrim**

**修改命令：lset**

**阻塞命令：blpop brpop**

```sh
127.0.0.1:6379> hmset order:1 orderId 1 money 36.6 time 2018-01-01
OK
127.0.0.1:6379> hmset order:2 orderId 2 money 38.6 time 2018-01-01
OK
127.0.0.1:6379> hmset order:3 orderId 3 money 39.6 time 2018-01-01
OK
127.0.0.1:6379> hgetall order:1
1) "orderId"
2) "1"
3) "money"
4) "36.6"
5) "time"
6) "2018-01-01"
127.0.0.1:6379> hgetall order:2
1) "orderId"
2) "2"
3) "money"
4) "38.6"
5) "time"
6) "2018-01-01"
127.0.0.1:6379> hgetall order:3
1) "orderId"
2) "3"
3) "money"
4) "39.6"
5) "time"
6) "2018-01-01"
127.0.0.1:6379> lpush user:2:order order:1 order:2 order:3
(integer) 3
127.0.0.1:6379> lrange user:2:order 0 2
1) "order:3"
2) "order:2"
3) "order:1"
127.0.0.1:6379> hmset order:4 orderId 4 money 40.6 time 2018-01-01
OK
127.0.0.1:6379> lpush user:2:order order:4
(integer) 4
127.0.0.1:6379> lrange user:2:order 0 3
1) "order:4"
2) "order:3"
3) "order:2"
4) "order:1"

# 3.2 版本以后，内部编码为：quicklist
127.0.0.1:6379> object encoding user:2:order
"quicklist"
```

## 无序集合 set

保存多元素，与列表不一样的是不允许有重复元素，且集合是无序，一个集合最多可存 2 的 32 次方减 1 个元素，除了支持增删改查，还支持集合交集、并集、差集；

```sh
# 给用户添加标签
127.0.0.1:6379> sadd user:5:fav basball fball pq
(integer) 3
127.0.0.1:6379> sadd user:6:fav basball fball
(integer) 2

# 计算出共同感兴趣爱好
127.0.0.1:6379> sinter user:5:fav user:6:fav
1) "fball"
2) "basball"

# 内部编码
# 当元素个数少(小于 512 个)且都为整数，redis 使用 intset 减少内存的使用
# 当超过 512 个或不为整数时，编码为 hashtable
127.0.0.1:6379> object encoding user:5:fav
"hashtable"
```

## 有序集合

```sh
# 点赞数
127.0.0.1:6379> zadd user:20:20180106 3 mike
(integer) 1
# 再获一赞
127.0.0.1:6379> zincrby user:20:20180106 1 mike
"4"
# 查看用户点赞数
127.0.0.1:6379> zscore user:20:20180106 mike
"4"
# 查看用户排名
127.0.0.1:6379> zrank user:20:20180106 mike
(integer) 0

# 内部编码
# 当元素个数少（小于 128 个），元素值小于 64 字节时，使用 ziplist 编码，可有效减少内存的使用
# 大于 128 个元素或元素值大于 64 字节时为 skiplist 编码
127.0.0.1:6379> object encoding user:20:20180106
"ziplist"
```

## 集合类型对比

数据结构 | 是否允许元素重复 | 是否有序 | 有序实现方式 | 应用场景
---------|------------------|----------|--------------|-----------------
列表     | 是               | 是       | 索引下标     | 时间轴，有序简单
集合     | 否               | 否       | 无           | 标签，社交
有序集合 | 否               | 是       | 分值         | 排行榜，点赞数
