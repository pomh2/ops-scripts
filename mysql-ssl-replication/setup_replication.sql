-- 在主库执行
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
ALTER USER 'repl'@'%' REQUIRE SSL;
FLUSH PRIVILEGES;

-- 在从库执行
CHANGE MASTER TO
    MASTER_HOST='host.docker.internal',
    MASTER_PORT=3307,
    MASTER_USER='repl',
    MASTER_PASSWORD='repl123',
    MASTER_SSL=1,
    MASTER_SSL_CA='/var/lib/mysql/ca.pem',
    MASTER_AUTO_POSITION=1;
START SLAVE;
