# Redis单机部署

以下为本人在 Centos7.5 下的安装 redis-4.0.11 过程。

## 安装步骤

```sh
# 这里视安全需求决定，我的机器默认配置的是关闭安全控制
# 关闭防火墙
# 关闭 Selinux

cd /tmp/
# 下载 Redis
wget http://download.redis.io/releases/redis-4.0.11.tar.gz
# 解包
tar zxvf redis-4.0.11.tar.gz 
cd /tmp/redis-4.0.11
# 编译 Redis
make
# 安装 Redis
make PREFIX=/usr/local/redis-4.0.11 install
# 配置 Redis 并设置开机启动
mv /tmp/redis-4.0.11 /usr/local/
sh /tmp/redis-4.0.11/utils/install_server.sh
```

一路回车，默认配置结果如下：

```
Welcome to the redis service installer
This script will help you easily set up a running redis server

Please select the redis port for this instance: [6379] 
Selecting default: 6379
Please select the redis config file name [/etc/redis/6379.conf] 
Selected default - /etc/redis/6379.conf
Please select the redis log file name [/var/log/redis_6379.log] 
Selected default - /var/log/redis_6379.log
Please select the data directory for this instance [/var/lib/redis/6379] 
Selected default - /var/lib/redis/6379
Please select the redis executable path [/usr/local/bin/redis-server] 
Selected config:
Port           : 6379
Config file    : /etc/redis/6379.conf
Log file       : /var/log/redis_6379.log
Data dir       : /var/lib/redis/6379
Executable     : /usr/local/bin/redis-server
Cli Executable : /usr/local/bin/redis-cli
Is this ok? Then press ENTER to go on or Ctrl-C to abort.
Copied /tmp/6379.conf => /etc/init.d/redis_6379
Installing service...
Successfully added to chkconfig!
Successfully added to runlevels 345!
Starting Redis server...
Installation successful!
```

此时，安装完成，注意一下默认的配置即可。

Redis 服务默认还没有启动，可以启动一下：

```sh
/etc/init.d/redis_6379 start
/etc/init.d/redis_6379 status
# 查看 Redis 开机启动配置
chkconfig | grep redis

# 关闭 Redis 服务
# /etc/init.d/redis_6379 stop
```

做一个简单的测试

```sh
ps -ef | grep redis         
root     30248     1  0 17:25 ?        00:00:00 /usr/local/bin/redis-server 127.0.0.1:6379
root     30333  2267  0 17:25 pts/0    00:00:00 grep --color=auto redis

redis-cli 
127.0.0.1:6379> set name yanglei
OK
127.0.0.1:6379> get name
"yanglei"
127.0.0.1:6379> exit
```

进程、操作都 OK，说明安装成功。

## 开启远程访问

安装完成后，使用客户端工具，如：`redis-desktop-manager` 来进行远程连接，会发现连不上。

## 参考资料

[Redis系列一：Reids的单机版安装](https://www.cnblogs.com/leeSmall/p/8331695.html)

[CentOS7 下安装 Redis](https://www.cnblogs.com/zuidongfeng/p/8032505.html)

[CentOS7 下安装 Redis-4.0.6](https://blog.csdn.net/weixin_37939964/article/details/78903034)


