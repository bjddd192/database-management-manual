# sysbench

[severalnines/sysbench](https://hub.docker.com/r/severalnines/sysbench)

```sh
CREATE SCHEMA sbtest;
CREATE USER sbtest@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sbtest.* to sbtest@'%';

docker run \
--rm=true \
--name=sb-prepare \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=1 \
--mysql-host=10.32.1.242 \
--mysql-port=3306 \
--mysql-user=sbtest \
--mysql-password=password \
/usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
run


docker run \
--name=sb-run \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--report-interval=2 \
--mysql-table-engine=innodb \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=64 \
--time=99999 \
--mysql-host=10.32.1.242 \
--mysql-port=3306 \
--mysql-user=sbtest \
--mysql-password=password \
/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
run


docker run --rm \
-v /root/sysbench_json_test.lua:/usr/share/sysbench/tests/include/oltp_legacy/sysbench_json_test.lua \
severalnines/sysbench \
sysbench \
--db-driver=mysql \
--report-interval=2 \
--threads=32 \
--time=300 \
--mysql-host=polardb-test.lesoon.lan \
--mysql-port=3306 \
--mysql-user=sbtest \
--mysql-password=password \
--mysql-db=sbtest \
--test=/usr/share/sysbench/tests/include/oltp_legacy/sysbench_json_test.lua \
run

```