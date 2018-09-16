最初发现mysql主从数据库的从库与主库数据不一致，从库一直处于忙的状态，
同时存在数据同步延时和relaybin日志堆积现象，
以下是调查解决过程：
1、在从库的MySQL shell中输入show mysql status;
   结果为Slave_IO_State、Master_Host、Master_User。。。等等
2、在Slave_SQL_Running_State字段内容一直为
   Reading event from the relay log，
   并且Seconds_Behind_Master字段值不为0，
   说明从库同步存在问题。
3、在show mysql status结果集中找到Relay_Log_File和Relay_Log_Pos字段
   内容：f62de755ed08-relay-bin.000005      252587725
4、跟上面字段信息，执行sql语句：
   show relaylog events in 'f2fd44f1d6d9-relay-bin.000005' limit 252587725,50 ;
   结果会显示出从库执行速度慢的操作。  
5、分析从库执行速度慢的操作，例如，存在大量的delete_row()操作
   这时我们根据主库对应的执行语句，可以适当在对应表建立主键或索引，优化对语句的数据处理，提升执行速度。
6、再次执行show mysql status；
   结果中Slave_SQL_Running_State字段：
   Slave has read all relay log; waiting for more updates
   Seconds_Behind_Master字段值为0
   至此，数据库恢复正常。  