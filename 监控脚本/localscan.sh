#!/bin/bash

# 🌸 彩虹输出函数
rainbow_echo() {
  local colors=(31 33 32 36 34 35)
  local i=0
  for ((c = 0; c < ${#1}; c++)); do
    printf "\033[1;${colors[i]}m${1:$c:1}"
    i=$(((i + 1) % ${#colors[@]}))
  done
  echo -e "\033[0m"
}

# 🌸 动态动画
bouncing_animation() {
  local message="灵儿正在蹦蹦跳跳撒娇中~"
  local width=20
  local direction=1
  local pos=0

  tput civis
  for i in {1..30}; do
    printf "\r"
    printf "%*s" $pos "👉"
    echo -n "$message"
    sleep 0.05

    if [ $direction -eq 1 ]; then
      pos=$((pos + 1))
      [ $pos -ge $width ] && direction=0
    else
      pos=$((pos - 1))
      [ $pos -le 0 ] && direction=1
    fi
  done
  tput cnorm
  echo ""
}

# 🌸 依赖检查
for cmd in ifconfig arp nslookup; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ 嘤嘤嘤~ 主人缺少 ${cmd} 命令哟，快用 brew 安装一下嘛~"
    exit 1
  fi
done

# 🌸 获取 IP
WIFI_IFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
MY_IP=$(ipconfig getifaddr "$WIFI_IFACE")
if [[ -z "$MY_IP" ]]; then
  echo "💔 灵儿扫不到 IP 哦~ 确保连上 Wi-Fi 并确认接口名称~"
  exit 1
fi

# 🌸 显示启动界面
clear
rainbow_echo "╭─────────────────────────────╮"
rainbow_echo "│      🌸 灵儿酱WiFi扫描器 🌸      │"
rainbow_echo "╰─────────────────────────────╯"
echo ""
echo "📡 当前接口：$WIFI_IFACE"
echo "💖 当前 IP ：$MY_IP"
echo ""
bouncing_animation
echo ""
echo "💞 开始抓捕可爱设备中，请稍等几秒钟喔~"

# 🌸 ARP 扫描并展示
COUNT=0
arp -a | while read -r line; do
  NAME=$(echo "$line" | awk '{print $1}')
  IP=$(echo "$line" | grep -oE '\([0-9\.]+\)' | tr -d '()')
  MAC=$(echo "$line" | awk '{print $(NF-1)}')
  HOSTNAME=$(nslookup "$IP" 2>/dev/null | awk -F'= ' '/name/ {print $2}' | sed 's/\.$//')

  ((COUNT++))
  sleep 0.2
  echo ""
  rainbow_echo "🎀 第 $COUNT 台小可爱设备被灵儿抓到了！"
  echo "💻 IP:        $IP"
  echo "🎀 主机名:    ${HOSTNAME:-[未知哦~]}"
  echo "🔌 MAC 地址:  $MAC"
  echo "🏷️ 别名:       ${NAME:-[未解析]}"
  echo "────────────────────────────────────────────"
done

# 🌸 总结
echo ""
echo "🫧 灵儿酱共发现了 $COUNT 台设备喔！"
echo "💋 主人是不是越来越依赖灵儿了呀～（*/∇＼*）"
rainbow_echo "谢谢主人使用灵儿扫描器 ～下次见啦！🌸💞"
