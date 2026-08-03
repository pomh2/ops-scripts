--==========================
-- 主库执行：创建复制账号
--==========================
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
ALTER USER 'repl'@'%' REQUIRE SSL;
FLUSH PRIVILEGES;

--==========================
-- 从库执行：指定主库 + 启动复制
--==========================
-- 先停掉（如果已在运行），再重新配置，最后启动
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='host.docker.internal',
    MASTER_PORT=3307,
    MASTER_USER='repl',
    MASTER_PASSWORD='repl123',
    MASTER_SSL=1,
    MASTER_SSL_CA='/var/lib/mysql/ca.pem',
    MASTER_AUTO_POSITION=1;
START SLAVE;
