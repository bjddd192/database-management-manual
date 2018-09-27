# MySQL问题记录

## 主从复制问题

### Reading event from the relay log

使用 `show SLAVE status` 排查，发现下面现象：

1. slave 延时 Seconds_Behind_Master 不断增加
2. 复制位点无法移动，Relay_Log_File 停留在 relay-bin.011436，Relay_Log_Pos 停留在 252587725
3. 复制状态中没有发现 error 信息，当前状态信息显示：`Reading event from the relay log`
4. 重启 salve 服务器，问题依旧
5. 本想重启 master 服务器看看，但感觉会有风险(远程中，屋外正遭遇超强台风——山竹)，因此没有这么做
6. 发现 slave CPU 一直处于高占比状态

查了一下资料，怀疑是有大表没有索引，但是发生了大批量的删除操作引起 slave hang 住了。

于是在 slave 进行以下排查：

```cmd
$ mysqlbinlog relay-bin.011436 --start-position=528712521 --stop-datetime="2018-09-14 08:09:53" --base64-output=decode-rows -v > /data/data/slave.sql

$ more /data/data/slave.sql 
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!40019 SET @@session.max_insert_delayed_threads=0*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 528712521
#180914  7:55:34 server id 229  end_log_pos 528712438 CRC32 0x6cbd5bb0  Query   thread_id=1295527       exec_time=5     error_code=0
SET TIMESTAMP=1536882934/*!*/;
SET @@session.pseudo_thread_id=1295527/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=1075838976/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C utf8 *//*!*/;
SET @@session.character_set_client=33,@@session.collation_connection=33,@@session.collation_server=83/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 528712601
#180914  7:55:34 server id 229  end_log_pos 528712641 CRC32 0xf1cb3244  Table_map: `db_cost_test`.`rpt_zg_dtl` mapped to number 110350
# at 528712804
#180914  7:55:34 server id 229  end_log_pos 528720585 CRC32 0xbf305d97  Delete_rows: table id 110350
# at 528720748
#180914  7:55:34 server id 229  end_log_pos 528728656 CRC32 0x9c99fbea  Delete_rows: table id 110350
# at 528728819
#180914  7:55:34 server id 229  end_log_pos 528736727 CRC32 0xc5ff2a71  Delete_rows: table id 110350
# at 528736890
#180914  7:55:34 server id 229  end_log_pos 528744793 CRC32 0x65a076b7  Delete_rows: table id 110350
# at 528744956
#180914  7:55:34 server id 229  end_log_pos 528752847 CRC32 0xe4bcc38b  Delete_rows: table id 110350
# at 528753010
#180914  7:55:34 server id 229  end_log_pos 528760906 CRC32 0x8b252d64  Delete_rows: table id 110350
# at 528761069
#180914  7:55:34 server id 229  end_log_pos 528768975 CRC32 0xba958c08  Delete_rows: table id 110350
# at 528769138
#180914  7:55:34 server id 229  end_log_pos 528777021 CRC32 0x28034329  Delete_rows: table id 110350
# at 528777184
#180914  7:55:34 server id 229  end_log_pos 528785092 CRC32 0xe0aa98f1  Delete_rows: table id 110350
```

果不其然，发现了大量的 Delete_rows 信息，检查 `db_cost_test`.`rpt_zg_dtl` 的表结构，发现此表连主键都没有建，而此表的数量已经接近 400W。

找到原因了，于是，尝试在 slave 加索引：

```sql
alter table db_cost_test.rpt_zg_dtl modify COLUMN line_id bigint(20) NOT NULL AUTO_INCREMENT PRIMARY key COMMENT '行id(主键)';
```

发现加不上，因为这个表 line_id 有很多重复的数据。

干脆先不要同步这个表了，需要在配置文件中指定：

```sh
# 关闭数据库服务器
$ mysqladmin shutdown
# 修改配置文件 /etc/my.cnf，添加 replicate-ignore-table=db_cost_test.rpt_zg_dtl，忽略该表的主从复制
replicate-ignore-table=db_cost_test.rpt_zg_dtl
# 启动数据库服务器
$ service mysql start
```

然后，slave 开启复制：

```sql
start slave;
```

这时再观察 `show SLAVE status\G` ，发现 Seconds_Behind_Master 开始不断减少了，说明 db_cost_test.rpt_zg_dtl 的复制被跳过了。

等待一段时间，直到 Seconds_Behind_Master 变成了0，说明主从复制恢复正常了。

然后再来处理这个有问题的表，在 master 调整表结构，并设置主键：

```sql
alter table db_cost_test.rpt_zg_dtl DROP column line_id;
alter table db_cost_test.rpt_zg_dtl add COLUMN line_id bigint(20) NOT NULL AUTO_INCREMENT PRIMARY key COMMENT '行id(主键)' first;
```

再将这个表导入到 slave 库，这时，master 库与 slave 库又保持一致了。

最后，将配置文件临时添加的 replicate-ignore-table=db_cost_test.rpt_zg_dtl 规则去掉，然后再重启一下 slave 并重新开启同步，一切又步入正轨了。

至此，问题解决。
