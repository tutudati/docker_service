# MySQL 8.0 Docker Compose 部署指南

## ✅ 当前状态
- MySQL 8.0 容器：正常运行，状态健康
- phpMyAdmin：正常运行，可通过 http://localhost:8080 访问
- 数据持久化：已启用，数据保存在 `./data` 目录
- 自定义配置：已加载，兼容 MySQL 8.0
- 配置文件挂载：已修复，`./config/custom.cnf` 正常挂载

## 服务版本
- MySQL: 8.0 (最新稳定版)
- phpMyAdmin: latest

## 服务配置

### MySQL 配置
- **端口**: 3306
- **root 密码**: root123456
- **默认数据库**: testdb
- **管理员用户**: admin
- **管理员密码**: admin123456
- **字符集**: utf8mb4
- **时区**: Asia/Shanghai
- **数据持久化**: 挂载到宿主机 `./data` 目录
- **配置持久化**: 挂载到宿主机 `./config` 目录

### phpMyAdmin 配置
- **端口**: 8080
- **访问地址**: http://localhost:8080
- **自动连接**: MySQL 服务

## 快速启动

### 1. 初始化目录结构
```bash
# 创建数据和配置目录
./init-dirs.sh
```

### 2. 启动服务
```bash
docker-compose up -d
```

### 3. 等待服务启动完成
```bash
# 查看服务状态
docker-compose ps

# 查看启动日志
docker-compose logs mysql
```

### 4. 检查服务健康状态
```bash
# 等待健康检查通过
docker-compose logs mysql | grep "ready for connections"
```

## 访问方式

### 命令行连接
```bash
# 使用 root 用户连接
mysql -h localhost -P 3306 -u root -proot123456

# 使用 admin 用户连接
mysql -h localhost -P 3306 -u admin -padmin123456 testdb
```

### 应用程序连接
```
主机: localhost
端口: 3306
用户名: admin (或 root)
密码: admin123456 (或 root123456)
数据库: testdb
```

### phpMyAdmin Web 界面
- **访问地址**: http://localhost:8080
- **用户名**: root 或 admin
- **密码**: root123456 或 admin123456

## 数据持久化说明

### Docker Volumes 方式
为避免文件权限问题，本配置使用 Docker volumes：

- **mysql-data**: MySQL 数据存储
- **mysql-config**: MySQL 配置文件存储

### 查看 Volume 信息
```bash
# 查看所有 volumes
docker volume ls

# 查看特定 volume 详情
docker volume inspect mysql_mysql-data
docker volume inspect mysql_mysql-config
```

### 本地目录挂载说明

### 目录结构
```
mysql/
├── docker-compose.yml
├── init-dirs.sh
├── init-database.sh
├── test-connection.sh
├── data/                 # MySQL 数据目录
└── config/               # MySQL 配置目录
    └── custom.cnf        # 自定义配置文件
```

### 挂载点
- **MySQL 数据**: `./data` → `/var/lib/mysql`
- **MySQL 配置**: `./config` → `/etc/mysql/conf.d`

### 优势
- ✅ **直接访问**: 可以直接查看和编辑数据文件
- ✅ **配置管理**: 可以直接修改 MySQL 配置文件
- ✅ **备份方便**: 可以直接复制 data 目录进行备份
- ✅ **跨项目共享**: 可以在多个项目中共享数据

### 注意事项
- 确保在启动服务前运行 `./init-dirs.sh`
- data 目录包含所有 MySQL 数据文件
- config 目录包含自定义配置文件

### 自定义配置文件
`./config/custom.cnf` 包含了优化的 MySQL 配置：
- 字符集配置 (utf8mb4)
- InnoDB 性能优化
- 连接数限制
- 慢查询日志
- 二进制日志配置

## 备份和还原
```bash
# 直接复制数据目录进行备份
cp -r data data_backup_$(date +%Y%m%d_%H%M%S)

# 还原数据（停止服务后）
docker-compose down
cp -r data_backup_20240101_120000 data
docker-compose up -d

# 数据库备份（推荐）
docker exec mysql8 mysqldump -u root -proot123456 --all-databases > backup.sql

# 数据库还原
docker exec -i mysql8 mysql -u root -proot123456 < backup.sql
```

## 性能优化配置

当前配置包含以下优化参数：
- `innodb-buffer-pool-size=256M`: InnoDB 缓冲池大小
- `max-connections=200`: 最大连接数
- `character-set-server=utf8mb4`: 默认字符集
- `collation-server=utf8mb4_unicode_ci`: 默认排序规则
- `default-authentication-plugin=mysql_native_password`: 兼容性认证插件

## 自定义配置

### 修改密码
在 docker-compose.yml 中修改以下环境变量：
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=your_root_password
  - MYSQL_PASSWORD=your_admin_password
```

### 添加自定义配置
1. 编辑 `./config/custom.cnf` 文件
2. 重启服务使配置生效：`docker-compose restart mysql`

### 调整性能参数
根据服务器资源修改 `command` 部分的参数：
```yaml
command: >
  --innodb-buffer-pool-size=512M
  --max-connections=500
```

## 停止和清理

### 停止服务
```bash
docker-compose down
```

### 完全清理（谨慎操作）
```bash
# 停止服务并删除 volumes（会丢失所有数据）
docker-compose down -v
```

## 常见问题

### 1. 连接被拒绝
- 等待容器完全启动（约 30-60 秒）
- 检查端口是否被占用：`lsof -i :3306`

### 2. 认证失败
- 确认用户名和密码正确
- MySQL 8.0 默认使用 `caching_sha2_password`，已配置为 `mysql_native_password` 提高兼容性

### 3. 字符集问题
- 已配置 utf8mb4 字符集，支持完整 Unicode
- 创建表时建议明确指定字符集

### 4. 性能问题
- 根据实际内存调整 `innodb-buffer-pool-size`
- 监控连接数，必要时调整 `max-connections`

## 生产环境注意事项

1. **更改默认密码**为强密码
2. **移除 phpMyAdmin** 或限制访问
3. **配置防火墙**限制 3306 端口访问
4. **定期备份**数据库
5. **监控资源使用**情况
6. **启用 SSL/TLS**加密连接
7. **设置适当的日志级别**
8. **配置慢查询日志**用于性能分析