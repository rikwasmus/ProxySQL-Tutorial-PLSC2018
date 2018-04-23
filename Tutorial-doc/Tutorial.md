## Get familiar with the system

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
```
```
SHOW DATABASES;
SHOW TABLES;
SHOW TABLES FROM main;
SHOW TABLES FROM disk;
SHOW TABLES FROM stats;
SHOW TABLES FROM monitor;
SHOW TABLES FROM stats_history;
SELECT name AS tables FROM sqlite_master WHERE type='table';
SELECT name AS tables FROM disk.sqlite_master WHERE type='table';
```
```
SHOW CREATE TABLE mysql_users\G
SHOW CREATE TABLE disk.mysql_users\G
SHOW CREATE TABLE runtime_mysql_users\G
SHOW CREATE TABLE mysql_servers\G
SHOW CREATE TABLE disk.mysql_servers\G
SHOW CREATE TABLE runtime_mysql_servers\G
SHOW CREATE TABLE mysql_replication_hostgroups\G
SHOW CREATE TABLE disk.mysql_replication_hostgroups\G
SHOW CREATE TABLE runtime_mysql_replication_hostgroups\G
```

Repeat the same on other 2 proxysql instances.
```
mysql -uradmin -pradmin -h127.0.0.1 -P16042
mysql -uradmin -pradmin -h127.0.0.1 -P16052
```


## Create a user on first proxysql instance:

Try to connect to ProxySQL:
```
mysql -uroot -proot -h 127.0.0.1 -P16033
```

Create user:
```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
```
```
INSERT INTO mysql_users (username,password,active) values ('root','root',1);
```

Try to connect to ProxySQL:
```
mysql -uroot -proot -h 127.0.0.1 -P16033
```

Manage user:
```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
```
```
SELECT * FROM mysql_users;
SELECT * FROM runtime_mysql_users;
SELECT * FROM disk.mysql_users;
LOAD MYSQL USERS TO RUNTIME;
SELECT * FROM runtime_mysql_users;
SAVE MYSQL USERS TO DISK;
SELECT * FROM disk.mysql_users;
```

Try to connect to ProxySQL:
```
mysql -uroot -proot -h 127.0.0.1 -P16033
```

Try to conect on other 2 instances:
```
mysql -uroot -proot -h 127.0.0.1 -P16043
```
```
mysql -uroot -proot -h 127.0.0.1 -P16053
```

## Enabling cluster
```
mysql -uradmin -pradmin -h127.0.0.1 -P16032

SHOW VARIABLES LIKE 'admin-cluster%';

SET admin-cluster_username='radmin';
SET admin-cluster_password='radmin';
LOAD ADMIN VARIABLES TO RUNTIME;
SAVE ADMIN VARIABLES TO DISK;

SHOW CREATE TABLE proxysql_servers\G

INSERT INTO proxysql_servers (hostname) VALUES ('proxysql1'),('proxysql2'),('proxysql3');
LOAD PROXYSQL SERVERS TO RUNTIME;
SAVE PROXYSQL SERVERS TO DISK;
```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16042
source conf/proxysql/enable_cluster.sql
```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16052
source conf/proxysql/enable_cluster.sql


DELETE FROM mysql_servers;

LOAD MYSQL SERVERS TO RUNTIME;
SELECT * FROM mysql_servers;
SELECT * FROM disk.mysql_servers;

```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM mysql_servers;
```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16052
SELECT * FROM disk.mysql_servers;
LOAD MYSQL SERVERS FROM DISK;
LOAD MYSQL SERVERS TO RUNTIME;

SELECT * FROM stats_proxysql_servers_metrics;
SELECT * FROM stats_proxysql_servers_checksums;
```

## Rewrite queries

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM mysql_query_rules\G
INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply) VALUES (1,1,'^SELECT.*FOR UPDATE',0,1),(2,1,'^SELECT',1,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

```

```
mysql -uroot -proot -h127.0.0.1 -P16033

source ./conf/mysql/mysql1/perconalive_schema.sql

use perconalive
SHOW TABLES;
INSERT INTO customer VALUES (NULL, '987-65-4321');
SELECT * FROM customer;

```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM stats_mysql_query_rules;
SELECT hostgroup, digest_text, count_star FROM stats_mysql_query_digest;

INSERT INTO mysql_query_rules (rule_id,active,match_pattern,replace_pattern,destination_hostgroup,apply)
          VALUES (3,1,'^select (.*)sensitive_number([ ,])(.*)',
                "SELECT \1CONCAT(REPEAT('X',8),RIGHT(sensitive_number,4)) sensitive_number\2\3",0,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

```

```
mysql -uroot -proot -h127.0.0.1 -P16033
use perconalive
SELECT id, sensitive_number FROM customer;
```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM mysql_query_rules\G


UPDATE mysql_query_rules SET active=0 WHERE rule_id=2;
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

```

```
mysql -uroot -proot -h127.0.0.1 -P16033
use perconalive
SELECT id, sensitive_number FROM customer;
```

## Mirror queries

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
INSERT INTO mysql_query_rules (rule_id,active,match_pattern,mirror_flagOUT,apply) VALUES (4,1,'^insert into customer(.*)',5,1);
INSERT INTO mysql_query_rules (rule_id,active,match_pattern,replace_pattern,flagIN,apply) VALUES (5,1,'^insert into customer(.*)',"INSERT INTO perconalive.audit (`user_name`, `table_name`) VALUES (USER(), 'customer')",5,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
```

```
mysql -uroot -proot -h127.0.0.1 -P16033
use perconalive
INSERT INTO customer VALUES (NULL, '987-65-4321');

SELECT * FROM customer;
SELECT * FROM audit;
```

```
mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM stats_mysql_query_rules;

SELECT hostgroup, digest_text, count_star FROM stats_mysql_query_digest;
```


## MySQL failover with Orchestrator

```
export ORCHESTRATOR_API="http://localhost:23101/api http://localhost:23102/api http://localhost:23103/api"

orchestrator-client -c topology -a $(orchestrator-client -c clusters)

orchestrator-client -c set-read-only -i mysql1

# try to read from sql interface: mysql -uroot -proot -h127.0.0.1 -P16033

orchestrator-client -c set-writeable -i mysql1

```

```
docker-compose stop mysql1

mysql -uradmin -pradmin -h127.0.0.1 -P16032
SELECT * FROM runtime_mysql_servers;
```


