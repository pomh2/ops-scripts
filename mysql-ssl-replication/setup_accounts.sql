--==========================
-- 业务账号创建（主库 + 从库都要执行）
-- 注意：主库配了 binlog-do-db=shop，只复制 shop 库，
--       mysql 系统库里的账号不会同步到从库，所以 monitor/appuser 必须在从库再建一次。
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
