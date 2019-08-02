# 更新 blob 字段

## 知识点

oracle 函数 `utl_raw.cast_to_varchar2` 将 blob 转为可视化的字符串

`dbms_lob.substr`函数用来操作数据库的大型对象，叫做大型对象定位器，长度限制：2000

```sql
-- 如果长度超出2000
SELECT 
	utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(t.command,2000,1)),
	utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(t.command,2000,2001))
from nc_his.ESB_INTERFACE_LOG_H t
```

## 实际操作

更新调度中心的 jmx IP、端口。

背景：公司一个老的调度中心，配置采用了 blob 定义，这样在数据迁移时就需要刷新 blob 值，由于数据比较多，必须采用后台模式进行刷新。

```sql
-- 备份待刷新的表
CREATE TABLE Z_BAK_SCHEDULER_TRIGGERS as SELECT * from SCHEDULER_TRIGGERS;

-- 复制待刷新待表为临时表
CREATE TABLE Z_TMP_SCHEDULER_TRIGGERS as SELECT * from SCHEDULER_TRIGGERS;

-- 给临时表增加字段
ALTER TABLE Z_TMP_SCHEDULER_TRIGGERS ADD JOB_DATA2 VARCHAR2(2000);

-- 取出 BLOB 字段转换为 VARCHAR2
UPDATE Z_TMP_SCHEDULER_TRIGGERS SET JOB_DATA2 = utl_raw.cast_to_varchar2(dbms_lob.substr(job_data));

-- 查看所有的 jmx 调度地址
SELECT 
    regexp_substr(JOB_DATA2,'service.+[remoteRMI|jmxrmi]') jmx,JOB_DATA2
FROM Z_TMP_SCHEDULER_TRIGGERS
where JOB_DATA2 like '%scm-%';

-- 汇总查看所有的 jmx 调度地址
SELECT 
    DISTINCT regexp_substr(JOB_DATA2,'service.+[remoteRMI|jmxrmi]') jmx
FROM Z_TMP_SCHEDULER_TRIGGERS
where JOB_DATA2 like '%scm-%'
ORDER BY 1;
/*
汇总结果：
service\:jmx\:rmi\://scm-lmd-01.pre.bjds.belle.lan/jndi/rmi\://scm-lmd-01.pre.bjds.belle.lan\:3802/remoteRMI
service\:jmx\:rmi\://scm-lmd-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-lmd-api-01.pre.bjds.belle.lan\:8352/remoteRMI
service\:jmx\:rmi\://scm-nlop-01.pre.bjds.belle.lan/jndi/rmi\://scm-nlop-01.pre.bjds.belle.lan\:7801/remoteRMI
service\:jmx\:rmi\://scm-tms-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-01.pre.bjds.belle.lan\:18080/jmxrmi
service\:jmx\:rmi\://scm-tms-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-01.pre.bjds.belle.lan\:18080/remoteRMI
service\:jmx\:rmi\://scm-tms-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-api-01.pre.bjds.belle.lan\:18080/remoteRMI
service\:jmx\:rmi\://scm-tms-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-api-01.pre.bjds.belle.lan\:6401/remoteRMI
service\:jmx\:rmi\://scm-wms-city-web-01.pre.bjds.belle.lan/jndi/rmi\://scm-wms-city-web-01.pre.bjds.belle.lan\:1099/remoteRMI
service\:jmx\:rmi\://scm-wms-city-web-01.pre.bjds.belle.lan/jndi/rmi\://scm-wms-city-web-01.pre.bjds.belle.lan\:3092/remoteRMI
*/

-- 逐个更新 jmx 配置
UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-wms-city-web-01.pre.bjds.belle.lan','10.243.1.175'),'3092','36605'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-wms-city-web-01.pre.bjds.belle.lan/jndi/rmi\://scm-wms-city-web-01.pre.bjds.belle.lan\:3092/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-wms-city-web-01.pre.bjds.belle.lan','10.243.1.175'),'1099','36605'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-wms-city-web-01.pre.bjds.belle.lan/jndi/rmi\://scm-wms-city-web-01.pre.bjds.belle.lan\:1099/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-tms-api-01.pre.bjds.belle.lan','10.243.1.174'),'6401','36698'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-tms-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-api-01.pre.bjds.belle.lan\:6401/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-tms-api-01.pre.bjds.belle.lan','10.243.1.174'),'18080','36698'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-tms-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-api-01.pre.bjds.belle.lan\:18080/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-tms-01.pre.bjds.belle.lan','10.243.1.174'),'18080','36618'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-tms-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-01.pre.bjds.belle.lan\:18080/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-tms-01.pre.bjds.belle.lan','10.243.1.174'),'18080','36618'）
WHERE JOB_DATA2 like '%scm-tms-01.pre.bjds.belle.lan/jndi/rmi\://scm-tms-01.pre.bjds.belle.lan\:18080/jmxrmi%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-nlop-01.pre.bjds.belle.lan','10.243.1.174'),'7801','36659'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-nlop-01.pre.bjds.belle.lan/jndi/rmi\://scm-nlop-01.pre.bjds.belle.lan\:7801/remoteRMI%';

UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-lmd-api-01.pre.bjds.belle.lan','10.243.1.174'),'8352','36638'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-lmd-api-01.pre.bjds.belle.lan/jndi/rmi\://scm-lmd-api-01.pre.bjds.belle.lan\:8352/remoteRMI%';
 
UPDATE Z_TMP_SCHEDULER_TRIGGERS
    SET JOB_DATA2 = REPLACE(REPLACE(JOB_DATA2,'scm-lmd-01.pre.bjds.belle.lan','10.243.1.174'),'3802','36663'）
WHERE JOB_DATA2 like '%service\:jmx\:rmi\://scm-lmd-01.pre.bjds.belle.lan/jndi/rmi\://scm-lmd-01.pre.bjds.belle.lan\:3802/remoteRMI%';

-- 将数据刷回原表
MERGE INTO SCHEDULER_TRIGGERS A
USING 
(
SELECT SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP,utl_raw.cast_to_raw(JOB_DATA2) JOB_DATA  from Z_TMP_SCHEDULER_TRIGGERS
) B
ON (A.SCHED_NAME = B.SCHED_NAME AND A.TRIGGER_NAME = B.TRIGGER_NAME AND A.TRIGGER_GROUP = B.TRIGGER_GROUP)
WHEN MATCHED THEN UPDATE SET A.JOB_DATA = B.JOB_DATA;
```
