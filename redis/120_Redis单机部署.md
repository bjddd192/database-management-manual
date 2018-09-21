# Redis单机部署

以下为本人在 Centos7.5 下的安装 redis-4.0.11 过程，实验机器 IP 为 172.20.32.125。

## 官方安装步骤

[官方安装说明](https://redis.io/download)

```sh
# 这里视安全需求决定，我的机器默认配置的是关闭安全控制
# 关闭防火墙
# 关闭 Selinux

$ cd /tmp/
# 下载 Redis
$ wget http://download.redis.io/releases/redis-4.0.11.tar.gz
# 解包
$ tar zxvf redis-4.0.11.tar.gz 
$ cd /tmp/redis-4.0.11
# 编译 Redis
$ make
# 运行 Redis
$ /tmp/redis-4.0.11/src/redis-server

# 使用客户端验证
$ /tmp/redis-4.0.11/src/redis-cli 
127.0.0.1:6379> set foo bar
OK
127.0.0.1:6379> get foo
"bar"
127.0.0.1:6379> exit
```

使用上面的方式会启动一个本地 Redis 服务器，但仅限于本机访问，而且进程不是守护的。

显然还不符合使用的需求，但是可以看出 Redis 是编译完成后就能直接使用的，下面在此基础上再进行改造。

## 配置 Redis 服务

```sh
# 配置 Redis 并设置开机启动
$ sh /tmp/redis-4.0.11/utils/install_server.sh
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
$ /etc/init.d/redis_6379 start
$ /etc/init.d/redis_6379 status
# 查看 Redis 开机启动配置
$ chkconfig | grep redis
```

做一个简单的测试

```sh
$ ps -ef | grep redis         
root     30248     1  0 17:25 ?        00:00:00 /usr/local/bin/redis-server 127.0.0.1:6379
root     30333  2267  0 17:25 pts/0    00:00:00 grep --color=auto redis

$ redis-cli 
127.0.0.1:6379> set name yanglei
OK
127.0.0.1:6379> get name
"yanglei"
127.0.0.1:6379> exit
```

进程、操作都 OK，说明安装成功。

此时发现 Redis 已安装成服务的模式，而且设置成了开机启动。

但此时使用客户端工具，如：`redis-desktop-manager` 来进行远程连接，会发现仍然连不上。

原因是：Redis 默认只允许本地访问，要使 Redis 可以远程访问需要修改配置文件。

## 开启远程访问

```sh
# 关闭 Redis 服务
$ /etc/init.d/redis_6379 stop
# 修改绑定的主机 IP
$ sed -i 's/bind 127.0.0.1/bind 127.0.0.1 172.20.32.125/g' /etc/redis/6379.conf
# 关闭保护模式
$ sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/6379.conf
$ /etc/init.d/redis_6379 start
```

再次使用客户端工具连接，发现可以进行远程访问了。

## 参考资料

[Redis系列一：Reids的单机版安装](https://www.cnblogs.com/leeSmall/p/8331695.html)

[CentOS7 下安装 Redis](https://www.cnblogs.com/zuidongfeng/p/8032505.html)

[CentOS7 下安装 Redis-4.0.6](https://blog.csdn.net/weixin_37939964/article/details/78903034)


