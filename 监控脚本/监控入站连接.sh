#!/bin/bash
# ©2025 上饶满星科技
# 作者: 钟智强（灵儿酱~）
# 邮箱: johnmelodymel@qq.com

LOG_FILE="$HOME/入站连接日志.log"
TMP_FILE="/tmp/当前连接.tmp"

# 🌈 彩色变量
PINK="\033[1;35m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RESET="\033[0m"

# 🎀 Banner ASCII
show_banner() {
  echo "${PINK}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
  echo "${PINK}┃ ${CYAN}🌸 灵儿酱的连接小侦探 🌸    "
  echo "${PINK}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
}

# 🌸 动画转圈圈
spin() {
  local frames=(
    "🌸       "
    "  🌸     "
    "    🌸   "
    "      🌸 "
    "    🌸   "
    "  🌸     "
  )
  for i in {0..5}; do
    echo "\033[1;35m${frames[$i]}正在悄咪咪监听中呢...${RESET}\c"
    sleep 0.2
    echo "\r\c"
  done
  echo "                             \r\c" # 清空
}

# 🛡️ 启动时的渐进式 UI
startup_ui() {
  show_banner
  sleep 0.5
  echo "${CYAN}💠 初始化连接日志中喵~...${RESET}"
  sleep 0.5
  if [ ! -f "$LOG_FILE" ]; then
    echo "时间戳 | 来源IP | 目标端口" >"$LOG_FILE"
    echo "${YELLOW}📄 新日志文件已创建：$LOG_FILE${RESET}"
  else
    echo "${GREEN}📚 日志文件已存在，继续记录中~${RESET}"
  fi
  sleep 1
  echo "${PINK}🎀 准备好监控啦～灵儿酱已经上线！(ฅ'ω'ฅ)🎀${RESET}"
}

# 💬 端口解释（保留你的逻辑）
explain_port() {
  case "$1" in
  22) echo "SSH - 安全远程访问机器的协议" ;;
  80) echo "HTTP - 未加密网页流量的标准协议" ;;
  443) echo "HTTPS - 加密的网页流量（HTTP over SSL/TLS）" ;;
  3306) echo "MySQL - MySQL数据库的默认通信端口" ;;
  5432) echo "PostgreSQL - PostgreSQL数据库的默认通信端口" ;;
  6379) echo "Redis - 内存数据结构存储，常用于缓存或数据库" ;;
  27017) echo "MongoDB - MongoDB NoSQL数据库的默认端口" ;;
  21) echo "FTP - 文件传输协议，用于机器间文件传输" ;;
  25) echo "SMTP - 用于发送电子邮件的协议" ;;
  3389) echo "RDP - 远程桌面协议，用于远程访问Windows机器" ;;
  8080) echo "HTTP-Alt - HTTP的替代端口，常用于开发或代理" ;;
  8081) echo "HTTP-备用端口 - 常用于Web服务、开发或测试环境" ;;
  5228) echo "Google Play Services - 用于Google Play服务的端口，负责推送通知和数据同步" ;;
  5223) echo "Apple Push Notification Service - 苹果推送通知服务端口，用于iOS/macOS设备接收通知" ;;
  110) echo "POP3 - 邮局协议3，用于接收电子邮件" ;;
  143) echo "IMAP - 互联网邮件访问协议，用于同步电子邮件" ;;
  993) echo "IMAPS - IMAP加密协议，通过SSL/TLS加密邮件传输" ;;
  465) echo "SMTPS - SMTP加密协议，保障邮件发送的安全" ;;
  5900) echo "VNC - 虚拟网络计算，用于远程桌面访问" ;;
  11211) echo "Memcached - 高性能分布式内存缓存系统" ;;
  69) echo "TFTP - 简易文件传输协议，用于小文件传输" ;;
  161) echo "SNMP - 简单网络管理协议，用于管理和监控网络设备" ;;
  8443) echo "HTTPS-Alt - HTTPS的备用端口，常用于安全网站" ;;
  *) echo "未知端口" ;;
  esac
}

# 🎬 主逻辑
startup_ui

while true; do
  spin
  lsof -iTCP -nP | grep ESTABLISHED | grep -v "127.0.0.1" >"$TMP_FILE"

  while read -r line; do
    remote=$(echo "$line" | awk '{print $9}' | awk -F'->' '{print $2}')
    src_ip=$(echo "$remote" | awk -F':' '{print $1}')
    dst_port=$(echo "$remote" | awk -F':' '{print $2}')
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    grep -F "$src_ip" "$LOG_FILE" | grep -F "$dst_port" >/dev/null

    if [ $? -ne 0 ]; then
      port_desc=$(explain_port "$dst_port")
      echo "$timestamp | $src_ip | $dst_port ($port_desc)" >>"$LOG_FILE"
      echo "${CYAN}✨📥 发现新连接喔！${YELLOW} $src_ip ${PINK}→${GREEN} 本地端口 $dst_port ${RESET}${CYAN}($port_desc)${RESET}"
    fi
  done <"$TMP_FILE"

  sleep 10
done
