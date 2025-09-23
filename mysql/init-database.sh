#!/bin/bash

echo "等待 MySQL 服务启动..."

# 等待 MySQL 服务健康检查通过
until docker-compose exec mysql mysqladmin ping -h localhost -u root -proot123456 --silent; do
    echo "等待 MySQL 启动..."
    sleep 3
done

echo "MySQL 服务已启动！"

# 创建示例表和数据
echo "创建示例数据..."

docker-compose exec mysql mysql -u root -proot123456 -e "
USE testdb;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入示例数据
INSERT INTO users (username, email, password) VALUES 
('admin', 'admin@example.com', 'hashed_password_1'),
('user1', 'user1@example.com', 'hashed_password_2'),
('user2', 'user2@example.com', 'hashed_password_3')
ON DUPLICATE KEY UPDATE username=username;

-- 创建文章表
CREATE TABLE IF NOT EXISTS articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INT,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入示例文章
INSERT INTO articles (title, content, author_id, status) VALUES 
('第一篇文章', '这是第一篇文章的内容...', 1, 'published'),
('第二篇文章', '这是第二篇文章的内容...', 2, 'draft'),
('第三篇文章', '这是第三篇文章的内容...', 1, 'published')
ON DUPLICATE KEY UPDATE title=title;

-- 显示创建结果
SELECT '数据库表创建完成' as status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as article_count FROM articles;
"

echo ""
echo "数据库初始化完成！"
echo "访问信息："
echo "- MySQL: localhost:3306"
echo "  - root用户: root/root123456"
echo "  - 管理用户: admin/admin123456"
echo "  - 默认数据库: testdb"
echo "- phpMyAdmin: http://localhost:8080"
echo ""
echo "测试连接："
echo "mysql -h localhost -P 3306 -u admin -padmin123456 testdb"