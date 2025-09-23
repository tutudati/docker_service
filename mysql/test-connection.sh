#!/bin/bash

echo "=== MySQL Docker 服务测试 ==="

# 检查容器状态
echo "1. 检查容器状态:"
docker-compose ps

echo ""
echo "2. 测试 MySQL 连接:"
docker-compose exec mysql mysql -u admin -padmin123456 testdb -e "SELECT 'MySQL 连接成功!' as status; SELECT VERSION() as mysql_version;"

echo ""
echo "3. 测试数据查询:"
docker-compose exec mysql mysql -u admin -padmin123456 testdb -e "
SELECT 'users表数据:' as info;
SELECT id, username, email, created_at FROM users LIMIT 3;

SELECT '' as separator;
SELECT 'articles表数据:' as info;
SELECT id, title, status, created_at FROM articles LIMIT 3;
"

echo ""
echo "4. phpMyAdmin 访问测试:"
echo "请打开浏览器访问: http://localhost:8080"
echo "用户名: admin"
echo "密码: admin123456"

echo ""
echo "=== 测试完成 ==="