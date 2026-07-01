#!/bim/bash
#每天检查Mysql和1Nginx是否活着
echo "=== $(date) 服务巡检 ==="

#检查nginx
if systemctl is-active --quiet nginx; then
   echo "Nginx :运行中"
else
   echo "Nginx :已停止！"
fi

#检查MySQL
if systemctl is-active --quiet mysqld; then
   echo "MySQL :运行中"
else
   echo "MySQL :已停止"
fi

#检查磁盘
echo "磁盘使用"
df -h /


