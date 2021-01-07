# 创建event

```sql
show variables like 'event_scheduler';

set global event_scheduler = on;

-- drop procedure if exists proc_delete_xxl_trigger_log;
create procedure proc_delete_xxl_trigger_log (i_days int)
language sql			-- 说明是SQL语言编写
not deterministic		-- 说明输出结果不确定
sql security definer
comment '删除 i_days 天以前的 xxl job trigger log'
begin
	-- 变量、条件、处理程序、光标都是通过 declare 定义的，它们之间是有先后顺序的要求的。
	-- 变量和条件必须在最前面声明，然后才能是光标的声明，最后才可以是处理程序的声明。
	
	-- 定义局部变量
	declare 	i_date1 			date						;
	declare 	i_date2 			date						;
	
	-- 给变量赋值
	SELECT ifnull(min(date(trigger_time)),date_sub(CURRENT_DATE,interval i_days day)) into i_date2
	from 
	db_xxl_job.xxl_job_qrtz_trigger_log;
	set i_date1 = date_sub(i_date2, interval 1 day);
	
	-- while语句
	mywhile: while i_date1 < date_sub(CURRENT_DATE,interval i_days day) do
		delete from db_xxl_job.xxl_job_qrtz_trigger_log 
		where trigger_time >= i_date1 and trigger_time < i_date2;
		set i_date1 = date_add(i_date1, interval 1 day);
		set i_date2 = date_add(i_date2, interval 1 day);
	end while mywhile;
end;

-- drop event if exists evt_delete_xxl_trigger_log;
create event if not exists evt_delete_xxl_trigger_log
on schedule 
every 1 day starts date_add(date_add(curdate(), interval 1 day), interval 5 hour)
on completion preserve
comment '删除7天以前的xxl job trigger log'
do 
begin
	call proc_delete_xxl_trigger_log(7);
end;

-- 数据验证
SELECT ifnull(min(date(trigger_time)),date_sub(CURRENT_DATE,interval 15 day)),max(date(trigger_time)) 
from db_xxl_job.xxl_job_qrtz_trigger_log;
```
