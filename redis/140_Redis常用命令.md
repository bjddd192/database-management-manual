# Redis常用命令

Redis 命令采用单线程执行。

执行过程：发送指令--》执行命令--》返回结果

执行命令：单线程执行，所有命令进入队列，按顺序执行，使用I/O多路复用解决I/O问题

单线程快的原因：纯内存访问，非阻塞I/O（使用多路复用），单线程避免线程切换和竞争产生资源消耗。

```sh
# 设置键值
127.0.0.1:6379> set name zorin
OK
127.0.0.1:6379> set name2 fubao
OK

# keys * 查看所有键
127.0.0.1:6379> keys *
1) "name2"
2) "name"

# 获取键值
127.0.0.1:6379> get name
"zorin"
127.0.0.1:6379> get name2
"fubao"

# 查看键的数据结构类型：返回类型的 string，键不存在返回 none
127.0.0.1:6379> type name
string
127.0.0.1:6379> type name3
none

# 查看当前所在 redis 库的键总数
# 因线上存在大量的键，因此禁止使用此指令
127.0.0.1:6379> dbsize
(integer) 2

# 检查键是否存在，存在返回 1，不存在返回 0
127.0.0.1:6379> exists name
(integer) 1
127.0.0.1:6379> exists name1
(integer) 0

# 删除键，返回删除键个数，删除不存在键返回 0
127.0.0.1:6379> del name2 name1
(integer) 1
127.0.0.1:6379> del name1
(integer) 0

# expire 设置键过期的时间，单位是秒
# ttl 查看键过期剩余的时间，单位是秒
127.0.0.1:6379> expire name 10
(integer) 1
127.0.0.1:6379> get name
"zorin"
127.0.0.1:6379> ttl name
(integer) 7
127.0.0.1:6379> ttl name
(integer) 6
127.0.0.1:6379> ttl name
(integer) 5
127.0.0.1:6379> ttl name
(integer) 4
127.0.0.1:6379> ttl name
(integer) 3
127.0.0.1:6379> ttl name
(integer) 2
127.0.0.1:6379> ttl name
(integer) 1
127.0.0.1:6379> ttl name
(integer) -2
127.0.0.1:6379> get name
(nil)
127.0.0.1:6379> keys *
1) "foo"

# 设置键同时设置过期时间
127.0.0.1:6379> set name zorin ex 10
OK

# 不存在键 name 时才能设置，返回 1 设置成功；存在的话失败，返回 0
127.0.0.1:6379> setnx name zorin
(integer) 1
127.0.0.1:6379> setnx name yanglei
(integer) 0

# 批量设置和批量获取
127.0.0.1:6379> mset country china city shenzhen
OK
127.0.0.1:6379> mget country city address
1) "china"
2) "shenzhen"
3) (nil)

# 计数
# 必须为整数自加 1，非整数返回错误，无 age 键从 0 自增返回 1
127.0.0.1:6379> set age 10
OK
127.0.0.1:6379> incr age
(integer) 11
127.0.0.1:6379> incr age
(integer) 12
127.0.0.1:6379> decr age
(integer) 11
127.0.0.1:6379> decr age
(integer) 10
127.0.0.1:6379> decr age
(integer) 9
127.0.0.1:6379> expire age 2
(integer) 1
127.0.0.1:6379> incr age
(integer) 1
127.0.0.1:6379> incr age
(integer) 2
127.0.0.1:6379> set age 10
OK
127.0.0.1:6379> incrby age 2
(integer) 12
127.0.0.1:6379> incrbyfloat age 4.4
"16.4"
127.0.0.1:6379> incrbyfloat age -4.4
"12"
127.0.0.1:6379> decrby age 3
(integer) 9
127.0.0.1:6379> incrbyfloat age 4.4
"13.4"
127.0.0.1:6379> decrby age 2
(error) ERR value is not an integer or out of range

# 字符串键值追加
127.0.0.1:6379> set name "hello "
OK
127.0.0.1:6379> append name "world!"
(integer) 12
127.0.0.1:6379> get name
"hello world!"

# 截取字符串
127.0.0.1:6379> getrange name 0 5
"hello "
127.0.0.1:6379> getrange name 6 11
"world!"

# 获取内部编码
# int: 8 字节长整型
# embstr: 小于等于 39 字节串
# raw: 大于 39 字节的字符串
127.0.0.1:6379> get age
"100"
127.0.0.1:6379> object encoding age 
"int"
127.0.0.1:6379> set name bejin
OK
127.0.0.1:6379> object encoding name
"embstr"
127.0.0.1:6379> set name aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
OK
127.0.0.1:6379> object encoding name
"raw"

# 切回数据库，只有 16 个库，索引为 0～15
127.0.0.1:6379> select 1
OK
127.0.0.1:6379[1]> select 16
(error) ERR DB index is out of range
127.0.0.1:6379[1]> select 15
OK
127.0.0.1:6379[15]> select 0
OK

# 临时配置数据库密码
# 永久修改更改配置文件，加了密码后，需同时修改 /etc/init.d/redis_6379 的 stop 方法，加入密码，才能正常关闭服务器
127.0.0.1:6379> config set requirepass 123456
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
127.0.0.1:6379> quit
redis-cli -p 6379 -a 123456
127.0.0.1:6379> keys *
1) "city"
2) "age"

# 模糊查询 keys
# 考虑到是单线程，在生产环境不建议使用，如果键多可能会阻塞，如果键少，才考虑使用
127.0.0.1:6379> keys c*y
1) "city"
2) "country"
127.0.0.1:6379> keys ci*y
1) "city"
127.0.0.1:6379> keys n?m*
1) "name"
127.0.0.1:6379> keys [c,n]*
1) "city"
2) "country"
3) "name"

# 渐进式遍历查询
# 渐进式遍历可有效地解决 keys 命令可能产生的阻塞问题
# 除 scan 字符串外，还有以下：
# scan 命令用于迭代当前数据库中的数据库键。
# sscan 命令用于迭代集合键中的元素。
# hscan 命令用于迭代哈希键中的键值对。
# zscan 命令用于迭代有序集合中的元素（包括元素成员和元素分值）。
# 用法和 scan 一样
127.0.0.1:6379> select 1
127.0.0.1:6379[1]> mset  a a b b c c d d e e f f g g h h i i j j k k l l m m n n o o p p q q r r s s t t u u v v w w x x y y z z
127.0.0.1:6379[1]> scan 0 match k*  count 50
1) "0"
2) 1) "k"

# 清空当前数据库的键值对，慎用！！！
127.0.0.1:6379[1]> flushdb
OK
127.0.0.1:6379[1]> keys *
(empty list or set)
127.0.0.1:6379[1]> dbsize
(integer) 0

# 清空所有库的键值对，慎用！！！
# 127.0.0.1:6379> flushall
```
 


