-- mysqld-exporter 监控账号（主库 + 从库都要执行）
-- mysql 系统库账号不会随 binlog 同步（binlog-do-db=shop 只复制 shop 库），
-- 所以 exporter 账号必须在主从两边各建一次。
-- 权限：PROCESS(进程列表) + REPLICATION CLIENT(SHOW SLAVE STATUS) + SELECT

CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exporter123' WITH MAX_USER_CONNECTIONS 3;

GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';

FLUSH PRIVILEGES;
