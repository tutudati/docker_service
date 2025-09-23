#!/bin/bash

echo "创建 MySQL 数据和配置目录..."

# 创建目录
mkdir -p data
mkdir -p config

# 设置权限（MySQL 容器使用 UID:GID 999:999）
echo "设置目录权限..."

# macOS 上设置权限
chmod 755 data config

# 创建自定义配置文件
echo "创建自定义 MySQL 配置文件..."
cat > config/custom.cnf << 'EOF'
[mysqld]
# 字符集配置
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB 配置
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 2

# 连接配置
max_connections = 200
max_connect_errors = 100000

# 查询缓存
query_cache_type = 1
query_cache_size = 32M

# 日志配置
slow_query_log = 1
slow_query_log_file = /var/lib/mysql/mysql-slow.log
long_query_time = 2

# 二进制日志
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7

# 安全配置
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO

[mysql]
default-character-set = utf8mb4

[client]
default-character-set = utf8mb4
EOF

echo "目录结构创建完成："
echo "- ./data (MySQL 数据目录)"
echo "- ./config (MySQL 配置目录)"
echo "- ./config/custom.cnf (自定义配置文件)"
echo ""
echo "注意：数据将持久化到本地 data 目录中"
echo "配置文件位于 config 目录，可以直接编辑"