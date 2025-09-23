#!/bin/bash

echo "创建数据和日志目录..."

# 创建 Elasticsearch 目录
mkdir -p data/elasticsearch
mkdir -p logs/elasticsearch

# 创建 Kibana 目录
mkdir -p data/kibana
mkdir -p logs/kibana

# 设置权限 (Elasticsearch 需要 UID:GID 1000:1000)
echo "设置目录权限..."
sudo chown -R 1000:1000 data/elasticsearch
sudo chown -R 1000:1000 logs/elasticsearch

# Kibana 通常使用 UID:GID 1000:1000
sudo chown -R 1000:1000 data/kibana
sudo chown -R 1000:1000 logs/kibana

# 设置适当的权限
chmod -R 755 data
chmod -R 755 logs

echo "目录结构创建完成："
echo "- ./data/elasticsearch (Elasticsearch 数据目录)"
echo "- ./logs/elasticsearch (Elasticsearch 日志目录)"
echo "- ./data/kibana (Kibana 数据目录)"
echo "- ./logs/kibana (Kibana 日志目录)"
echo ""
echo "注意：数据将持久化到宿主机的这些目录中"