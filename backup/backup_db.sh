#!/bin/bash
DB_USER="root"
DB_PASS="123456"
DB_NAME="mydb"
BACKUP_DIR="/home/chenjunjian/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql
gzip $BACKUP_DIR/${DB_NAME}_${DATE}.sql
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete
echo "$(date) - 备份完成: ${DB_NAME}_${DATE}.sql.gz" >> $BACKUP_DIR/backup.log
