# 运维项目集

> 西南石油大学 软件工程 · 运维方向 · 秋招备战  
> 涵盖 Shell 自动化、MySQL 高可用、Docker/K8s/Jenkins 三大方向

---

## 项目一：Shell 脚本自动化运维

### `check_services.sh` — Docker 环境服务巡检

一键检查 Docker 服务、三个关键容器（mysql-master / mysql-slave / proxysql）、主从复制状态、磁盘使用率。正常打印 ✅，异常打印 ❌ 并附带实际状态。同步写入日志 `service_status.log`。

**技术点：** `docker inspect` 取容器状态 | `SHOW SLAVE STATUS` grep+awk 提取 IO/SQL 线程 | `df -h` 磁盘检查 | `tee -a` 双输出（屏幕+日志）

### `backup_db.sh` — 数据库自动备份

`mysqldump` 导出全库 SQL → `gzip` 压缩 → 文件名带日期 → `find -mtime +7 -delete` 自动清理 7 天前旧备份。滚动保留一周，磁盘不炸。

### `loadbalance.conf` — Nginx 负载均衡

`upstream` 定义三台后端服务器，`weight=5/3/2` 加权轮询，`proxy_pass` 转发请求。配合 SELinux `httpd_can_network_connect=1` 解决 502 问题。

---

## 项目二：MySQL 主从复制 + SSL 加密 + GTID + ProxySQL 读写分离 + 监控

### 架构

```
应用 → ProxySQL:6033（统一入口）
         ├─ SELECT → 从库(3308)
         └─ INSERT/UPDATE/DELETE → 主库(3307)
              ↑
         主从复制 + SSL 加密 + GTID 自动恢复
```

### 配置文件 `mysql-ssl-replication/`

| 文件 | 作用 |
|------|------|
| `master.cnf` | 主库 binlog + GTID 配置 |
| `slave.cnf` | 从库 relay-log + 只读 + GTID 配置 |
| `ssl.cnf` | SSL 证书路径（ca + cert + key） |
| `ca.pem` | CA 根证书（从库验证主库身份用） |
| `setup_replication.sql` | CHANGE MASTER TO + GTID 完整步骤 |

### 技术链路

1. Docker 启动两个独立 MySQL 8.0 容器（3307 主 / 3308 从）
2. `master.cnf` 开启 binlog 记录所有写操作
3. `slave.cnf` 配置 relay-log + `read-only=1` 只读保护
4. `mysql_ssl_rsa_setup` 生成 SSL 证书（ca + server-cert + server-key）
5. `ALTER USER repl REQUIRE SSL` 强制加密传输
6. `docker cp` 分发 CA 证书到从库
7. `CHANGE MASTER TO ... MASTER_AUTO_POSITION=1`（GTID 模式，重建容器自动恢复）
8. ProxySQL 6033 统一入口，正则路由 `^SELECT.*` → 读组 / `^INSERT.*` → 写组
9. `check_replication.sh` 定时查 SHOW SLAVE STATUS，IO/SQL/Delay 三灯全绿=OK

### 监控 `check_replication.sh`

提取 `Slave_IO_Running` / `Slave_SQL_Running` / `Seconds_Behind_Master` / `Last_IO_Error` 四个关键指标，`if` 三灯全绿写 OK，任一异常写 ALERT 并打印实际值。

### 读写分离验证 `test_read_write_split.sh`

主库 INSERT → 从库 SELECT 验证同步，配合 ProxySQL `stats_mysql_query_digest` 表确认 SELECT 命中 hostgroup=20（从库）、INSERT 命中 hostgroup=10（主库）。

### ProxySQL 配置 `setup_proxysql.sql`

5 组 SQL：注册后端 → 监控账号 → 应用账号 → 读写分离规则 → LOAD+SAVE 生效持久化。三张核心表：`mysql_servers`（后端地址）、`mysql_users`（代理认证）、`mysql_query_rules`（路由规则）。

---

## 项目三：Docker 容器化 + K8s 部署 + Jenkins CI/CD

### `deploy.yaml` — Kubernetes Deployment

2 副本 Nginx Pod + `livenessProbe` 存活探针（定时 GET / 路径，无响应自动重启 = 自愈）。`kubectl apply -f deploy.yaml` 提交。

### `Jenkinsfile` — CI/CD 声明式 Pipeline

3 阶段：Build（`mvn clean package`）→ Test（`mvn test`）→ Deploy（`docker build && docker push`）。git push → Webhook 触发 → 全自动零停机部署。

---

## 环境

| 组件 | 版本 | 端口 |
|------|------|------|
| Docker Desktop | latest | - |
| MySQL 主库 | 8.0 | 3307 |
| MySQL 从库 | 8.0 | 3308 |
| ProxySQL | latest | 6032（管理）/ 6033（代理） |

---

## 核心账号

| 账号 | 权限 | 用途 |
|------|------|------|
| `root / 123456` | 全部 | 运维管理 |
| `repl / repl123` | `REPLICATION SLAVE` | 从库拉 binlog |
| `monitor / monitor123` | `REPLICATION CLIENT` | 健康检查 + 监控脚本 |
| `appuser / app123` | `shop.*` 读写 | 应用连 ProxySQL |
| `admin / admin` | ProxySQL 管理 | 配置路由规则 |

---

## 关键命令速查

```bash
# 启动所有容器
docker start mysql-master mysql-slave proxysql

# 主从状态
docker exec mysql-slave mysql -uroot -p123456 -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep -E "Slave_IO|Slave_SQL"

# 服务巡检
cd ~/Desktop/ops-scripts && ./check_services.sh

# 主从监控
./check_replication.sh && cat replication_status.log

# 验证读写分离
docker exec proxysql mysql -uadmin -padmin -h127.0.0.1 -P6032 -e "SELECT hostgroup, digest_text FROM stats_mysql_query_digest ORDER BY last_seen DESC LIMIT 5;"
```
