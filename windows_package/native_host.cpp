#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <cstdlib>
#include <ctime>
#include "json.hpp"

using json = nlohmann::json;

// ============ 工具函数：读取 Chrome 发来的 JSON ============
json readMessage() {
    uint32_t length = 0;

    if (!std::cin.read(reinterpret_cast<char*>(&length), sizeof(length))) {
        return json(); // empty / invalid
    }

    std::vector<char> buffer(length);
    std::cin.read(buffer.data(), length);

    // 使用 buffer.data() 才合法
    return json::parse(buffer.data(), buffer.data() + length, nullptr, false);
}

// ============ 工具函数：将 JSON 回传给 Chrome ============
void sendMessage(const json& message) {
    std::string dump = message.dump();
    uint32_t length = dump.size();

    std::cout.write(reinterpret_cast<char*>(&length), sizeof(length));
    std::cout.write(dump.c_str(), dump.size());
    std::cout.flush();
}

// ============ 清理非法文件名（Windows + Linux 通用） ============
std::string sanitizeFilename(std::string name) {
    std::string forbidden = "\\/:*?\"<>|";

    for (char &c : name) {
        if (forbidden.find(c) != std::string::npos) {
            c = '_';
        }
    }

    if (name.empty()) {
        name = "video_" + std::to_string(time(nullptr));
    }

    if (name.size() > 120) {
        name = name.substr(0, 120);
    }

    return name;
}

// ============ 执行外部命令 ============
int runCommand(const std::string& cmd) {
    return system(cmd.c_str());
}

// ============ 主循环 =============
int main() {
    while (true) {
        json msg = readMessage();
        if (msg.is_discarded() || msg.is_null()) {
            continue;
        }

        std::string action = msg.value("action", "");

        // -------------------- TEST --------------------
        if (action == "test") {
            json resp;
            resp["status"] = "OK";
            resp["msg"] = "Native host is working";
            sendMessage(resp);
            continue;
        }

        // -------------------- DOWNLOAD M3U8 --------------------
        if (action == "download_m3u8") {

            std::string url = msg.value("url", "");
            std::string referer = msg.value("referer", "");
            std::string saveName = msg.value("save_name", "");

            // 文件名清理
            saveName = sanitizeFilename(saveName);

            if (url.empty()) {
                json resp;
                resp["status"] = "error";
                resp["msg"] = "URL is empty";
                sendMessage(resp);
                continue;
            }

            // -------------------- 新版 N_m3u8DL-RE 命令 --------------------

            // 保存名不需要 .mp4 后缀，新版工具自动处理
#ifdef _WIN32
            std::string command =
                "N_m3u8DL-RE.exe \"" + url + "\" " +
                "-H \"Referer: " + referer + "\" " +
                "--save-name \"" + saveName + "\"";
#else
            std::string command =
                "./N_m3u8DL-RE \"" + url + "\" " +
                "-H \"Referer: " + referer + "\" " +
                "--save-name \"" + saveName + "\"";
#endif

            std::cerr << "Running: " << command << std::endl;

            int exitCode = runCommand(command);

            json resp;
            resp["status"] = "done";
            resp["exit_code"] = exitCode;
            resp["file"] = saveName;

            sendMessage(resp);
            continue;
        }

        // -------------------- UNKNOWN --------------------
        json resp;
        resp["status"] = "error";
        resp["msg"] = "Unknown action: " + action;
        sendMessage(resp);
    }

    return 0;
}

