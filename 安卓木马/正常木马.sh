#!/bin/bash

set -e

# 🎨 配色
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 💬 封装打印函数
print() { echo "${CYAN}➤ $1${NC}"; }
error() {
    echo "${RED}✖ $1${NC}"
    exit 1
}
success() { echo "${GREEN}✔ $1${NC}"; }

# 📦 全局变量
apk_path=""
output_dir=""

# 🧰 检查 apktool 是否安装
check_apktool() {
    if ! command -v apktool &>/dev/null; then
        error "未检测到 apktool，请先安装： https://ibotpeaches.github.io/Apktool/"
    fi
    success "【Apktool】已安装 ✅"
}

# 📂 获取 .apk 文件路径
get_apk_path() {
    echo "${YELLOW}📦 请输入你的 .apk 文件路径（支持拖入）:${NC}"
    read -e apk_path

    if [[ ! -f "$apk_path" || "${apk_path##*.}" != "apk" ]]; then
        error "不是有效的 .apk 文件路径！"
    fi

    success "已收到 APK: $apk_path"
}

# 🔨 反编译 APK
decompile_apk() {
    output_dir="apktool_out_$(basename "$apk_path" .apk)_$(date +%s)"

    print "准备反编译 ➜ 输出目录为: ${output_dir}"

    if [[ -d "$output_dir" ]]; then
        error "输出目录已存在: $output_dir"
    fi

    apktool d "$apk_path" -o "$output_dir" >/dev/null
    success "反编译成功！输出目录：$output_dir"
}

# 🔍 查找 MainActivity.smali
search_main_activity() {
    print "正在查找 MainActivity.smali ..."
    smali_file=$(find "$output_dir" -type f -name "*MainActivity*.smali" | head -n 1)

    if [[ -z "$smali_file" ]]; then
        error "未找到 MainActivity.smali 文件！"
    fi

    success "找到 MainActivity ✅"
    print "路径：$smali_file"
    echo "${YELLOW}📖 正在预览内容（前 50 行）...${NC}"
    head -n 50 "$smali_file"
}

# 🧭 CLI 引导
show_help() {
    echo "${CYAN}Usage:${NC} ./script.sh"
    echo "  自动反编译 APK 并提取 MainActivity.smali"
}

# 🧠 主流程
main() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    check_apktool
    get_apk_path
    decompile_apk
    search_main_activity
}

main "$@"
