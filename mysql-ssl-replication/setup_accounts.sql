--==========================
-- 业务账号创建（在主库执行）
-- monitor: 监控专用，REPLICATION CLIENT 权限
-- appuser: 应用读写，shop 库增删改查
--==========================

-- 监控账号
CREATE USER IF NOT EXISTS 'monitor'@'%' IDENTIFIED BY 'monitor123';
GRANT REPLICATION CLIENT ON *.* TO 'monitor'@'%';

-- 应用账号
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'app123';
GRANT SELECT, INSERT, UPDATE, DELETE ON shop.* TO 'appuser'@'%';

FLUSH PRIVILEGES;
