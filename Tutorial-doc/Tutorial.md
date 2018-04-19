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

## 
