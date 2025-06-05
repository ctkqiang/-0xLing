#include <curl/curl.h>  // 引入 libcurl 库用于 HTTP 请求
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>  // 用于调用 kill、access 等系统函数

// 🔑 替换为你实际分发给用户的 License Key
#define LICENSE_KEY "abc123"

// 🌐 替换为你的授权服务器 URL，接受 GET 请求校验
#define LICENSE_SERVER_URL \
    "https://your-license-server.com/verify?key=" LICENSE_KEY

// 🛑 如果授权失败，尝试终止这个进程名的主程序（模糊匹配）
#define TARGET_PROCESS_NAME "your_app_name"

// 🔒 授权失败时创建的锁文件路径，主程序可用于自我检测
#define LOCK_FILE "/tmp/license_invalid.lock"

// 🔪 杀死主程序进程（根据进程名模糊匹配）
int kill_target_process() {
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "pkill -f %s", TARGET_PROCESS_NAME);
    return system(cmd);
}

// ✍️ 写一个锁文件，作为标志告诉主程序授权无效
int write_lock_file() {
    FILE *fp = fopen(LOCK_FILE, "w");
    if (fp == NULL) return 0;
    fprintf(fp, "INVALID_LICENSE\n");
    fclose(fp);
    return 1;
}

// 🌐 使用 libcurl 进行 HTTP 请求来校验授权
int check_license() {
    CURL *curl;
    CURLcode res;
    long response_code = 0;

    curl = curl_easy_init();  // 初始化 curl
    if (!curl) {
        fprintf(stderr, "💥 初始化 libcurl 失败\n");
        return 0;
    }

    curl_easy_setopt(curl, CURLOPT_URL, LICENSE_SERVER_URL);  // 设置验证地址
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);  // 请求超时 5 秒
    curl_easy_setopt(curl, CURLOPT_NOBODY, 1L);  // 只获取响应头，不拉取正文

    res = curl_easy_perform(curl);  // 发起请求
    if (res == CURLE_OK) {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE,
                          &response_code);  // 获取状态码
    } else {
        fprintf(stderr, "🚨 curl 请求失败: %s\n", curl_easy_strerror(res));
    }

    curl_easy_cleanup(curl);      // 清理资源
    return response_code == 200;  // 如果状态码是 200 说明授权通过
}

int main() {
    if (!check_license()) {
        printf("❌ 授权失败，记录并终止主程序。\n");
        write_lock_file();      // 写入锁文件
        kill_target_process();  // 终止主程序

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
            "┃  —— 温馨提示，拒付者休怪断网断服 ——  ┃\n"
            "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n\n");

        return 1;
    }

    printf("✅ 授权正常。\n");
    return 0;
}
