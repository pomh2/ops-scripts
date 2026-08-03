#!/bin/bash
# Nginx + Tomcat 集群 + MySQL 主从 全链路巡检
LOG_FILE="./cluster_status.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "========== $TIMESTAMP 全链路巡检 ==========" | tee -a $LOG_FILE

# 1. Nginx HTTPS
echo -n "Nginx :443 " | tee -a $LOG_FILE
NGINX_CODE=$(curl -sk -o /dev/null -w "%{http_code}" https://localhost/ --connect-timeout 3)
if [ "$NGINX_CODE" = "200" ]; then
    echo "✅ HTTP $NGINX_CODE" | tee -a $LOG_FILE
else
    echo "❌ HTTP $NGINX_CODE" | tee -a $LOG_FILE
fi

# 2. Tomcat 集群
for PORT in 8081 8082; do
    echo -n "Tomcat :$PORT " | tee -a $LOG_FILE
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health.jsp --connect-timeout 3)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ HTTP $HTTP_CODE" | tee -a $LOG_FILE
    else
        echo "❌ HTTP $HTTP_CODE" | tee -a $LOG_FILE
    fi
done

# 3. MySQL 主从
echo -n "主从复制 " | tee -a $LOG_FILE
IO=$(MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -umonitor -pmonitor123 -h127.0.0.1 -P3306 -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep "Slave_IO_Running:" | awk -F': ' '{print $2}')
SQL=$(MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -umonitor -pmonitor123 -h127.0.0.1 -P3306 -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep "Slave_SQL_Running:" | awk -F': ' '{print $2}')
if [ "$IO" = "Yes" ] && [ "$SQL" = "Yes" ]; then
    echo "✅ IO:$IO SQL:$SQL" | tee -a $LOG_FILE
else
    echo "❌ IO:$IO SQL:$SQL" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
