
#!/bin/bash
#读写分离验证： 主库写-> 从库读

echo "========写操作 ->主库（3307） ========"
MSYS_NO_PATHSONV=1 docker exec mysql-master mysql -uroot -p123456 -e "
INSERT INTO shop.orders (user_id, product_id,quantity, amount) VALUES (1, 2, 1, 14999.00);
SELECT '---主库最新数据 ---' AS '';
SELECT * FROM shop.orders ORDER BY id DESC LIMIT 3;
" 2>/dev/null

sleep 1

echo ""
echo "=======读操作 -> 从库(3308) ========"
MSYS_NO_PATHCONV=1 docker exec mysql-slave mysql -uroot -p123456 -e "
SELECT '---从库已同步---'AS'';
SELECT * FROM shop.orders ORDER BY id DESC LIMIT 3;
" 2>/dev/null

