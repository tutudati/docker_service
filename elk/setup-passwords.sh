#!/bin/bash

echo "等待 Elasticsearch 启动..."
until curl -s -u elastic:elastic123456 http://localhost:9200/_cluster/health > /dev/null; do
    echo "等待 Elasticsearch 启动..."
    sleep 5
done

echo "Elasticsearch 已启动，开始设置密码..."

# 设置 kibana_system 用户密码
curl -X POST -u elastic:elastic123456 "http://localhost:9200/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "kibana123456"
  }'

echo ""
echo "密码设置完成！"
echo "Elasticsearch 账号: elastic, 密码: elastic123456"
echo "Kibana 系统账号: kibana_system, 密码: kibana123456"