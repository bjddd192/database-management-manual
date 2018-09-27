# Redis管理

## redis-cli 命令

```sh
# 返回 pong 表示 172.20.32.125:6379 能通，r 代表次数
$ redis-cli -r 3 -h 172.20.32.125 -p 6379 -a 123456 ping
PONG
PONG
PONG

# 每秒输出内存使用量，输出 10 次，i 代表执行的时间间隔，单位是秒
$ redis-cli -r 10 -h 172.20.32.125 -p 6379 -a 123456 -i 1 info | grep used_memory_human
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K
used_memory_human:871.22K

```

## redis-server 命令

## redis-benchmark 命令

基准性测试，测试redis的性能

```sh
# 模拟 100 个并发连接，100000 个请求
$ redis-benchmark -h 172.20.32.125 -p 6379 -a 123456 -c 100 -n 10000
```

## Pipeline

## 事务

## LUA

## 发布与订阅
