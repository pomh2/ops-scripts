#!/bin/bash
# Docker 环境服务巡检脚本

LOG_FILE="./service_status.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "========== $TIMESTAMP 服务巡检 ==========" | tee -a $LOG_FILE

# 1. 检查 Docker 是否在跑
echo -n "Docker 服务: " | tee -a $LOG_FILE
if docker info >/dev/null 2>&1; then
    echo "✅ 运行中" | tee -a $LOG_FILE
else
    echo "❌ 未启动" | tee -a $LOG_FILE
fi

# 2. 检查关键容器
for CONTAINER in mysql-master mysql-slave proxysql; do
    echo -n "容器 $CONTAINER: " | tee -a $LOG_FILE
    STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER 2>/dev/null)
    if [ "$STATUS" = "running" ]; then
        echo "✅ 运行中" | tee -a $LOG_FILE
    else
        echo "❌ 状态异常 ($STATUS)" | tee -a $LOG_FILE
    fi
done

# 3. 检查主从复制
echo -n "主从复制: " | tee -a $LOG_FILE
IO=$(MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -uroot -p123456 -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep "Slave_IO_Running:" | awk -F': ' '{print $2}')
SQL=$(MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -uroot -p123456 -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep "Slave_SQL_Running:" | awk -F': ' '{print $2}')

    if [ "$IO" = "Yes" ] && [ "$SQL" = "Yes" ]; then
    echo "✅ IO:$IO SQL:$SQL" | tee -a $LOG_FILE
else
    echo "❌ IO:$IO SQL:$SQL" | tee -a $LOG_FILE
fi
# 4. 检查磁盘
echo "磁盘使用:" | tee -a $LOG_FILE
df -h / | grep -v Filesystem | awk '{print "  路径:"$6"  已用:"$3"/"$2"  使用率:"$5}' | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
