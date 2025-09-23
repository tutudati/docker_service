# Elasticsearch & Kibana Docker Compose 部署指南

## 服务版本
- Elasticsearch: 8.1.3
- Kibana: 8.1.3

## 安全配置
- **Elasticsearch 管理员账号**: elastic
- **Elasticsearch 管理员密码**: elastic123456
- **Kibana 系统账号**: kibana_system
- **Kibana 系统密码**: kibana123456

## 快速启动

### 1. 启动服务
```bash
docker-compose up -d
```

### 2. 等待服务完全启动
```bash
# 等待约 1-2 分钟让服务完全启动
docker-compose logs -f elasticsearch
```

### 3. 设置密码（首次启动时执行）
```bash
# 给脚本执行权限
chmod +x setup-passwords.sh

# 运行密码设置脚本
./setup-passwords.sh
```

### 4. 重启 Kibana 服务
```bash
# 重启 Kibana 使新密码生效
docker-compose restart kibana
```

### 5. 检查服务状态
```bash
docker-compose ps
```

### 6. 查看日志
```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs elasticsearch
docker-compose logs kibana
```

## 访问地址
- Elasticsearch: http://localhost:9200 （需要账号密码：elastic/elastic123456）
- Kibana: http://localhost:5601 （需要账号密码：elastic/elastic123456）

## 验证服务

### 验证 Elasticsearch
```bash
# 使用账号密码访问
curl -u elastic:elastic123456 http://localhost:9200

# 查看集群健康状态
curl -u elastic:elastic123456 http://localhost:9200/_cluster/health
```

### 验证 Kibana
访问 http://localhost:5601 
- 用户名: elastic
- 密码: elastic123456

## 配置说明

### Elasticsearch 配置
- **内存限制**: 512MB (可根据需要调整)
- **安全功能**: 已启用，需要账号密码访问
- **集群模式**: 单节点模式
- **数据持久化**: 使用 Docker volume (elk_elasticsearch-data)
- **默认管理员**: elastic/elastic123456

### Kibana 配置
- **连接地址**: 自动连接到 elasticsearch 服务
- **安全功能**: 已启用，使用 elastic 账号登录
- **系统账号**: kibana_system/kibana123456（内部通信）
- **数据持久化**: 使用 Docker volume (elk_kibana-data)
- **健康检查**: 已配置

## 数据持久化说明

### Docker Volumes 方式
为了避免文件权限问题，本配置使用 Docker volumes 进行数据持久化：

- **elasticsearch-data**: Elasticsearch 数据存储
- **kibana-data**: Kibana 数据存储

### 查看 Volume 信息
```bash
# 查看所有 volumes
docker volume ls

# 查看特定 volume 详情
docker volume inspect elk_elasticsearch-data
docker volume inspect elk_kibana-data
```

### 备份和还原
```bash
# 备份 Elasticsearch 数据
docker run --rm -v elk_elasticsearch-data:/data -v $(pwd):/backup alpine tar czf /backup/elasticsearch-backup.tar.gz -C /data .

# 还原 Elasticsearch 数据
docker run --rm -v elk_elasticsearch-data:/data -v $(pwd):/backup alpine tar xzf /backup/elasticsearch-backup.tar.gz -C /data
```

## API 调用示例

### 创建索引
```bash
curl -X PUT -u elastic:elastic123456 "http://localhost:9200/my-index" \
  -H "Content-Type: application/json" \
  -d '{
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }'
```

### 插入文档
```bash
curl -X POST -u elastic:elastic123456 "http://localhost:9200/my-index/_doc/1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试文档",
    "timestamp": "2024-01-01T00:00:00Z"
  }'
```

### 搜索文档
```bash
curl -X GET -u elastic:elastic123456 "http://localhost:9200/my-index/_search"
```

## 停止服务
```bash
docker-compose down
```

## 清理数据 (谨慎操作)
```bash
# 停止服务并删除卷
docker-compose down -v
```

## 生产环境注意事项
1. 更改默认密码为强密码
2. 启用 SSL/TLS 加密 (xpack.security.http.ssl.enabled=true)
3. 配置 SSL 证书
4. 调整内存和资源限制
5. 配置集群模式
6. 设置适当的数据备份策略
7. 配置防火墙和网络安全
8. 定期更新和打补丁

## 常见问题

### 1. Kibana 无法连接到 Elasticsearch
- 确保 Elasticsearch 服务已完全启动
- 检查密码设置是否正确
- 查看 docker-compose logs kibana

### 2. 密码认证失败
- 确保已运行 setup-passwords.sh 脚本
- 重启 Kibana 服务使密码生效

### 3. 内存不足
- 调整 ES_JAVA_OPTS 中的内存设置
- 确保系统有足够的可用内存

### 4. 数据目录权限问题
已解决：使用 Docker volumes 代替本地挂载避免权限问题

### 5. 数据丢失问题
- 数据已持久化到 Docker volumes
- 容器删除后数据仍然保存
- 备份数据：参考上面的备份命令