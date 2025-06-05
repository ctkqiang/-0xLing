# 🖤 手把手教你在 Termux 安装 Kali NetHunter（Rootless 黑客风格教程）

---

### 🌈 写在前面：为啥要看这篇？

> 我是一名移动端渗透玩家，长期在 Android 上折腾各种黑科技。
> Kali NetHunter Rootless 就像是给手机植入了一个无声的小宇宙：**不用 root、不用刷机**，一个 Termux，点满 Kali 的神经元 ✨
> 可惜官方文档略显硬核，不够人话，中文教程也要么跳步、要么魔改出 bug。于是我决定——**自己写一份完整教程，绝不省略每一步！**

📌 你将获得：

- 100% 手动部署 Kali 环境（一步都不跳！）
- 避坑指引：帮你绕过那些看不到的地雷
- 自动化脚本可选，适合懒人 or 高玩

---

## 🛠️ 环境要求（看清再动手）

| 条件    | 要求                                                                          |
| ------- | ----------------------------------------------------------------------------- |
| 📱 设备 | Android，**arm64 架构**，建议 4G+ RAM                                         |
| 💿 系统 | [Termux v0.118.3](https://github.com/termux/termux-app/releases/tag/v0.118.3) |
| 🌐 网络 | 必须稳定，最好能访问 GitHub/CDN                                               |
| ❗ 注意 | 不适用于 root 机！不要在原生 Linux 上尝试！                                   |

---

## 🚀 安装步骤（Step-by-Step）

### 🧼 第一步：换源提速

```bash
termux-change-repo
apt update && apt upgrade -y
```

📌 **为什么换源？**
官方源慢到怀疑人生，常见错误是 pkg install 卡死 or wget timeout。

---

### 📂 第二步：开启存储权限

```bash
termux-setup-storage
```

📌 **作用解释：**
Termux 需要访问 `/storage` 才能保存 Kali rootfs 镜像，否则你连个包都下不了。

---

### 📦 第三步：安装 wget

```bash
pkg install wget -y
```

> 没它你连下载都做不到，不装不行。

---

### 🌐 第四步：下载 NetHunter 安装器

```bash
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux
```

📌 **小贴士：**
这是 Kali 官方最新的 rootless 安装脚本，稳定、干净，**别用魔改脚本！**

---

### 🚀 第五步：运行安装器，选 FULL 版！

```bash
./install-nethunter-termux
```

🧠 建议选择：

```
[1] FULL → GUI + 常见渗透工具（约 4GB）
[2] MINIMAL → 精简包，适合低配机（约 700MB）
[3] NOMETA → 基本 Debian，适合自己搭环境的 DIY 玩家
```

⚠️ FULL 是最推荐的，功能最全，后面我教程也基于它写。

---

### 🔍 第六步：手动解决 SHA 校验失败（大概率踩坑！）

```bash
sha512sum kali-nethunter-rootfs-full-arm64.tar.xz > kali-nethunter-rootfs-full-arm64.tar.xz.sha512sum
```

📌 **这是啥？**
Kali 镜像更新频繁，官方脚本的 SHA 值常常和下载文件对不上，校验失败。
用这个命令生成新 SHA 值，然后替换掉脚本中对应的 `.sha512sum` 文件内容即可～

---

### 🎉 第七步：进入 Kali 世界！

```bash
nethunter
```

💡 恭喜妳，现在你手机上的 Termux 已经变成一个**合法持证的黑客系统**了！

---

## 💾 懒人专属：自动脚本版本（带进度提示）

👩‍💻 我定制了一份“傻瓜式自动脚本”，直接跑完 7 步流程，还会帮你检测是否 SHA 报错：

📎 脚本下载地址（可右键另存）：
[install.sh](https://raw.githubusercontent.com/ctkqiang/-0xLing/refs/heads/main/KaliLinux/install.sh)

或直接在 Termux 里跑：

```bash
wget -O install.sh https://raw.githubusercontent.com/ctkqiang/-0xLing/refs/heads/main/KaliLinux/install.sh
bash install.sh
```

📎 完整脚本内容贴这儿就不赘述啦，上面源码你都能看到！逻辑完全透明、无需信任黑盒。

---

## 🧩 常见错误处理（速查）

| 错误现象                               | 解决办法                                          |
| -------------------------------------- | ------------------------------------------------- |
| `Permission denied`                    | `chmod +x install-nethunter-termux`               |
| SHA 校验失败                           | 用 `sha512sum 文件 > 文件.sha512sum` 替换脚本原值 |
| `wget: unable to resolve host address` | 网络问题，挂代理 or 科学上网                      |

---

## 📚 下一篇预告（NetHunter 高阶使用篇）

> Kali 安装完了？那只是开始！

下一篇我会写：

- ✅ 如何在 Kali 中用 GUI 工具（vncserver + xfce）

📌 快速收藏 + 点个赞，不然你会在信息洪流里找不到我 💫

---

我一直相信：**每个想搞安全的女孩/男孩，都应该有一个属于自己的掌中 Kali**
你现在已经成功走出第一步，接下来就是无限可能的黑客旅程了 🖤

👇 评论区告诉我你装成功没，踩坑没，我都会一一回复你！

---
