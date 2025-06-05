#!/bin/bash

# 💡 自动识别系统并监控 MySQL general log（可跨 Mac 和 Linux）

# 🍰 检测系统
OS=$(uname)

# 设置默认日志路径
if [[ "$OS" == "Darwin" ]]; then
    # macOS
    DEFAULT_LOG="/tmp/mysql.log"
elif [[ "$OS" == "Linux" ]]; then
    # Ubuntu / Debian
    DEFAULT_LOG="/var/log/mysql/mysql.log"
else
    echo "❌ 不支持的系统：$OS"
    exit 1
fi

# 可手动覆盖日志路径
LOG_FILE=${1:-$DEFAULT_LOG}

# 检查日志文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    echo "🚫 找不到日志文件：$LOG_FILE"
    echo "👉 请确认已启用 general_log，MySQL 设置如下："
    echo ""
    echo "   SET GLOBAL general_log = 'ON';"
    echo "   SET GLOBAL general_log_file = '$LOG_FILE';"
    exit 1
fi

# ✅ 开始监听
echo "📡 正在监听 SQL 日志文件：$LOG_FILE"
echo "按 Ctrl+C 停止"

tail -n 20 -F "$LOG_FILE" | while read -r line; do
    if echo "$line" | grep -Ei 'delete|drop|update|insert|alter|grant' >/dev/null; then
        echo "🔥 $(date '+%F %T') [高危] $line"
    elif echo "$line" | grep -Ei 'select' >/dev/null; then
        echo "🔍 $(date '+%F %T') [查询] $line"
    else
        echo "📄 $(date '+%F %T') $line"
    fi
done
