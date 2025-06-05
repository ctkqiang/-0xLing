#!/usr/bin/env bash
#./tor.sh start   # 启动 Tor 服务
#./tor.sh stop    # 停止 Tor 服务

set -e

ACTION=$1 # 读取第一个参数：start or stop
OS="$(uname -s)"

echo "🎮 操作系统识别为: $OS"
echo "🌀 正在尝试执行操作: $ACTION"

start_tor_mac() {
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew 未安装。请先安装： https://brew.sh/"
    exit 1
  fi
  if ! brew list | grep -q '^tor$'; then
    echo "🛠️ Tor 未安装，正在安装..."
    brew install tor
  fi
  echo "🚀 启动 Tor..."
  brew services start tor
}

stop_tor_mac() {
  echo "🛑 停止 Tor..."
  brew services stop tor
}

start_tor_linux() {
  if ! command -v tor &>/dev/null; then
    echo "🛠️ Tor 未安装，正在安装..."
    sudo apt update
    sudo apt install -y tor
  fi
  echo "🚀 启动 Tor..."
  sudo systemctl start tor
  sudo systemctl enable tor
}

stop_tor_linux() {
  echo "🛑 停止 Tor..."
  sudo systemctl stop tor
}

start_tor_windows() {
  echo "⚠️ Windows 下建议使用 Tor Expert Bundle 或者 Tor 浏览器启动。"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    start_tor_linux
  else
    echo "❌ 无法在原生 Windows Bash 中启动 Tor。"
    exit 1
  fi
}

stop_tor_windows() {
  echo "⚠️ Windows 下的停止操作需要手动执行，或者在 WSL 中操作。"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    stop_tor_linux
  else
    echo "❌ 无法在原生 Windows Bash 中停止 Tor。"
    exit 1
  fi
}

case "$OS" in
Darwin)
  [[ "$ACTION" == "start" ]] && start_tor_mac || stop_tor_mac
  ;;
Linux)
  [[ "$ACTION" == "start" ]] && start_tor_linux || stop_tor_linux
  ;;
MINGW* | MSYS* | CYGWIN*)
  [[ "$ACTION" == "start" ]] && start_tor_windows || stop_tor_windows
  ;;
*)
  echo "❌ 不支持的系统：$OS"
  exit 1
  ;;
esac

echo "✅ 操作完成：$ACTION Tor"
