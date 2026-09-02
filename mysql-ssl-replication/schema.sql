--==========================
-- 业务库表结构（shop 库 + orders 表）
-- 主库和从库各执行一次：binlog-do-db=shop 只复制 shop 库的数据，
-- 建库语句本身没有默认库上下文，可能不进 binlog，稳妥起见两边都建。
--==========================

CREATE DATABASE IF NOT EXISTS shop DEFAULT CHARACTER SET utf8mb4;

USE shop;

CREATE TABLE IF NOT EXISTS orders (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    amount     DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
