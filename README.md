# 运维脚本集

## 项目 1：Linux 服务器环境搭建
- VirtualBox + CentOS 7 虚拟机
- 网络配置（桥接模式，IP: 192.168.89.129）
- MySQL 8.0 安装配置（DataGrip 远程连接）
- Nginx 安装配置（浏览器访问验证）
- 解决 MySQL socket 认证故障

## 脚本
- `check_services.sh`：服务巡检脚本（Nginx + MySQL + 磁盘），配合 crontab 每天自动跑
- （以后继续加）
