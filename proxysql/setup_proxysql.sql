--==========================
--ProxySQL 读写分离完整配置
--==========================

--第一组：注册后端MySQL服务器
INSERT INTO mysql_servers (hostgroup_id, hostname, port)VALUES(10, 'host.docker.internal', 3307);
INSERT INTO mysql_servers (hostgroup_id, hostname, port)VALUES(20, 'host.docker.internal', 3308);

--第二组： 配置监控账号（健康检查）
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='monitor123' WHERE variable_name='mysql-monitor_password';

--第三组：注册应用链接账号
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES ('appuser', 'app123', 10);

--第四组： 读写分离规则
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (1, 1, '^SELECT.*', 20, 1);
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply) VALUES (2, 1, '^INSERT.*|^UPDATE.*|^DELETE.*', 10, 1);

--第五组：加载生效+持久化
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL VARIABLES TO RUNTIME; SAVE MYSQL VARIABLE TO DISK;
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;
