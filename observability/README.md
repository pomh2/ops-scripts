# Prometheus + Grafana 监控大盘（observability）

> 给 MySQL 主从 + 宿主机资源配的实时监控，对应 DOUC 路线第 10 关「可观测性」。
> 一行 `docker compose up -d` 起 5 个容器，Grafana 里直接看大盘，无需手动导入。

## 架构

```
MySQL主库(3307) ──┐
                  ├──> mysqld-exporter ×2 ──┐
MySQL从库(3308) ──┘                         ├──> Prometheus:9090 ──> Grafana:3000
WSL2宿主机 ─────────> node-exporter ────────┘
```

## 访问入口

| 服务 | 地址 | 说明 |
|------|------|------|
| **Grafana 大盘** | http://localhost:3000 | 账号 `admin/admin`，已预置「MySQL 主从复制监控」大盘 |
| Prometheus | http://localhost:9090 | 查询/告警，`Status → Targets` 看抓取目标 |
| 主库 exporter | http://localhost:9104/metrics | MySQL 主库指标 |
| 从库 exporter | http://localhost:9105/metrics | MySQL 从库指标（含复制状态） |
| 宿主机 exporter | http://localhost:9100/metrics | WSL2 虚拟机 CPU/内存/磁盘 |

## 大盘内容

- **主从复制状态**：Seconds_Behind_Master 延迟、Slave_IO/SQL 线程运行状态（绿灯=正常）
- **MySQL 指标**：连接数、运行时长、慢查询、累计查询数（主 + 从）
- **负载趋势**：QPS（每秒查询数）、连接数变化（折线图）
- **宿主机资源**：CPU、内存使用率、Docker 数据盘可用空间

## 启动 / 停止

```bash
cd ~/projects/ops-scripts/observability
docker compose up -d     # 启动（首次会拉镜像）
docker compose down      # 停止
docker compose logs -f   # 看日志
```

## 关键文件

| 文件 | 作用 |
|------|------|
| `docker-compose.yml` | 5 个服务编排 + `unless-stopped` 开机自启 |
| `prometheus.yml` | 抓取目标（4 个 job，15s 间隔） |
| `grafana/provisioning/datasources/datasource.yml` | Prometheus 数据源自动预置 |
| `grafana/provisioning/dashboards/mysql-replication.json` | 监控大盘（自动加载） |
| `setup_exporter.sql` | 建 `exporter` 监控账号（主从库**各执行一次**） |

## 三个坑（重搭时注意）

1. **mysqld-exporter v0.17 移除了 `DATA_SOURCE_NAME`**，改用 `--mysqld.address` + `--mysqld.username` + 环境变量 `MYSQLD_EXPORTER_PASSWORD`。
2. **exporter 容器内部默认监听 9104**，从库映射到 9105 时要显式加 `--web.listen-address=:9105`。
3. **node-exporter 默认看不到宿主机文件系统**，需 `-v /:/host:ro` + `--path.rootfs=/host`；WSL2 下真正的 Docker 数据盘挂在 `/var/lib`（不是 `/`）。
