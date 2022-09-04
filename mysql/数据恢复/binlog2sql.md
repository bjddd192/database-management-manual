# binlog2sql

从MySQL binlog解析出你要的SQL。根据不同选项，你可以得到原始SQL、回滚SQL、去除主键的INSERT SQL等。

[danfengcao/binlog2sql](https://github.com/danfengcao/binlog2sql)

```sh
docker run --rm -it hub.wonhigh.cn/basic/flask-base:1.1.3 bash
shell> git clone https://github.com/danfengcao/binlog2sql.git && cd binlog2sql
shell> pip install -r requirements.txt
# 根据大致时间过滤数据
shell> python binlog2sql/binlog2sql.py -h10.0.30.129 -P3306 -uroot -p'yougou' -d db_integration -t sys_project sys_menu sys_resource sys_resource_permission --start-file='binlog.003078' --start-datetime='2022-07-25 16:00:00' --stop-datetime='2022-07-25 18:00:00' --sql-type DELETE
# 根据位置进一步过滤，使用flashback模式生成回滚sql
shell> python binlog2sql/binlog2sql.py -h10.0.30.129 -P3306 -uroot -p'yougou' -d db_integration -t sys_project sys_menu sys_resource sys_resource_permission --start-file='binlog.003078' --start-position=228518951 --stop-position=348975144 -B --sql-type DELETE > rollback.sql

sys_project
sys_menu
sys_resource
sys_resource_permission
```

### 异常处理

[运行时报错 UnicodeDecodeError](https://github.com/danfengcao/binlog2sql/issues/70)
