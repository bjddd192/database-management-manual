# 创建event

```sql
show variables like 'event_scheduler';

set global event_scheduler = on;

create event if not exists db_xxl_job.evt_delete_xxl_trigger_log
on schedule 
every 1 day starts date_add(date_add(curdate(), interval 1 day), interval 5 hour)
on completion preserve
comment '删除15天以前的xxl job trigger log'
do 
begin
	delete from db_xxl_job.xxl_job_qrtz_trigger_log where trigger_time < date_sub(sysdate(),interval 15 day);
end;
```
