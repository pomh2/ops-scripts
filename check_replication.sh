#!/bin/bash
#Mysql主从复制监控脚本
HOST="127.0.0.1"
PORT="3308"
USER="monitor"
PASS="monitor123"
LOG_FILE="./replication_status.log"

#查询从库状态
RESULT=$(MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -u$USER -p$PASS -h$HOST -P3306 -e "SHOW SLAVE STATUS\G" 2>/dev/null)

#提取关键指标
IO=$(echo "$RESULT" | grep "Slave_IO_Running:" | awk -F': ' '{print $2}')
SQL=$(echo "$RESULT" | grep "Slave_SQL_Running:" | awk -F': ' '{print $2}')
DELAY=$(echo "$RESULT" | grep "Seconds_Behind_Master:" | awk -F': ' '{print $2}')
ERR=$(echo "$RESULT" | grep "Last_IO_Error:" | grep -v "Timestamp" | awk -F': ' '{print $2}')

#判断状态
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
if [ "$IO" = "Yes" ] && [ "$SQL" = "Yes" ] && [ "$DELAY" = "0" ]; then
	echo "[$TIMESTAMP] OK - IO:$IO SQL:$SQL Delay:${DELAY}s" >> $LOG_FILE
else
	echo "[$TIMESTAMP] ALERT! IO:$IO SQL:$SQL Delay:${DELAY}s Error:$ERR" >> $LOG_FILE

fi

