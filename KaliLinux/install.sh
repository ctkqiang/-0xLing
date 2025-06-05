#!/bin/bash

# 🌈 Kali NetHunter Termux 自动安装脚本 by 灵儿 🍓
# ⚠️ 仅适用于 Termux（arm64 架构）。不是给原生 Linux 用的哦！
# 🛠️ 作用：自动下载并安装 FULL 版 Kali NetHunter rootfs，适合搞渗透的妳！

set -e # 一旦出错就退出

echo "[1/7] 🧼 更换 Termux 镜像源..."
termux-change-repo
apt update && apt upgrade -y

echo "[2/7] 📂 开启共享存储访问权限..."
termux-setup-storage

echo "[3/7] 📦 安装 wget 下载工具..."
pkg install wget -y

echo "[4/7] 🌐 下载 NetHunter 安装器..."
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux

echo "[5/7] 🚀 启动安装器！⚠️请选择选项 [1] 安装 FULL 完整版 Kali"
# ┌──────────── 可选项说明 ───────────────────────────────────
# │ [1] FULL版    → 包含 GUI、常用渗透工具和网络组件（约4GB+）
# │ [2] MINIMAL版 → 精简版，仅含基础系统，适合低配机（约700MB）
# │ [3] NOMETA版  → 不安装元包，仅基本 Debian 环境，适合 DIY 用户
# └─────────────────────────────────────────────────────────

./install-nethunter-termux

echo "[6/7] 🔍 检查是否遇到 SHA 校验 404 错误..."

# 如果原始下载脚本失败了 SHA 校验，可以用这个命令手动算出哈希值
if [ -f kali-nethunter-rootfs-full-arm64.tar.xz ]; then
    echo "✅ 找到 rootfs 文件，准备手动生成 SHA-512 校验值..."
    sha512sum kali-nethunter-rootfs-full-arm64.tar.xz >kali-nethunter-rootfs-full-arm64.tar.xz.sha512sum
    echo "✨ 手动 SHA 校验已生成，文件名：kali-nethunter-rootfs-full-arm64.tar.xz.sha512sum"
    echo "⚠️ 请将该校验值手动替换原脚本中自动下载失败的部分（或 patch 脚本）"
else
    echo "❌ 未找到 rootfs 文件，请先确保 FULL 镜像下载完成再运行 SHA 校验！"
fi

echo "[7/7] 🎉 安装流程结束～欢迎妳进入 Kali 的世界！💀"
