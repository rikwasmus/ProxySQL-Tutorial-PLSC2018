#!/bin/bash
. constants

# set up replication
./bin/docker-mysql-post.bash

# set up orchestrator
./bin/docker-orchestrator-post.bash

# load perconalive schema
printf "$POWDER_BLUE[$(date)] Loading perconalive schema...$LIME_YELLOW\n"
mysql -h127.0.0.1 -P13306 -uroot -p$MYSQL_PWD <$(pwd)/conf/mysql/mysql1/perconalive_schema.sql > /dev/null 2>&1

# ensure proxysql1 config
printf "$POWDER_BLUE[$(date)] Configuring proxysql1...$LIME_YELLOW\n"
mysql -h127.0.0.1 -P13306 -uroot -p$MYSQL_PWD <$(pwd)/conf/proxysql/config-local.sql > /dev/null 2>&1

printf "$POWDER_BLUE$BRIGHT[$(date)] MySQL Configuration COMPLETE!$NORMAL\n"

