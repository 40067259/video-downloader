#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>
#include <unistd.h>
#include "json.hpp"   // nlohmann/json

using json = nlohmann::json;

/*
------------------------------------------------------
  读取 Chrome Native Message
------------------------------------------------------
*/
std::string readMessage() {
    uint32_t length = 0;
    if (!std::cin.read(reinterpret_cast<char*>(&length), 4)) {
        return "";
    }
    std::string msg(length, '\0');
    if (!std::cin.read(&msg[0], length)) {
        return "";
    }
    return msg;
}

/*
------------------------------------------------------
  发送消息给 Chrome 插件
------------------------------------------------------
*/
void sendMessage(const json& j) {
    std::string text = j.dump();
    uint32_t length = text.size();
    std::cout.write(reinterpret_cast<const char*>(&length), 4);
    std::cout.write(text.c_str(), length);
    std::cout.flush();
}

/*
------------------------------------------------------
  获取 Linux 下载目录（强兼容）
  1. 尝试解析 ~/.config/user-dirs.dirs
  2. 否则默认 ~/Downloads
------------------------------------------------------
*/
std::string getDownloadsFolder() {
    const char* home = getenv("HOME");
    if (!home) home = ".";

    std::string userDirs = std::string(home) + "/.config/user-dirs.dirs";
    std::ifstream file(userDirs);

    if (file) {
        std::string line;
        while (std::getline(file, line)) {
            if (line.find("XDG_DOWNLOAD_DIR") != std::string::npos) {
                size_t start = line.find('"') + 1;
                size_t end = line.find('"', start);
                std::string dir = line.substr(start, end - start);

                // 替换 $HOME -> 实际 home 路径
                size_t pos = dir.find("$HOME");
                if (pos != std::string::npos) {
                    dir.replace(pos, 5, home);
                }
                return dir;
            }
        }
    }

    // fallback
    return std::string(home) + "/Downloads";
}

/*
------------------------------------------------------
  执行命令并返回 exit code
------------------------------------------------------
*/
int runCommand(const std::string& cmd) {
    return system(cmd.c_str());
}

/*
------------------------------------------------------
  主处理逻辑：
  action = download_youtube
  action = download_m3u8
------------------------------------------------------
*/
int main() {
    while (true) {
        std::string msg = readMessage();
        if (msg.empty()) break;

        json request;
        try {
            request = json::parse(msg);
        } catch (...) {
            sendMessage({{"status", "error"}, {"message", "JSON parse error"}});
            continue;
        }

        std::string action = request.value("action", "");
        std::string downloads = getDownloadsFolder();

        if (action == "download_youtube") {
            std::string url = request.value("url", "");
            std::string save_name = request.value("save_name", "video.mp4");

            std::string outputPath = downloads + "/" + save_name;

            // yt-dlp 自动下载
            std::string cmd = "yt-dlp -o \"" + outputPath + "\" \"" + url + "\"";

            int code = runCommand(cmd);

            sendMessage({
                {"status", "done"},
                {"exit_code", code},
                {"output", outputPath}
            });
        }

        else if (action == "download_m3u8") {
            std::string url = request.value("url", "");
            std::string referer = request.value("referer", "");
            std::string save_name = request.value("save_name", "video.mp4");

            std::string outputPath = downloads + "/" + save_name;

            // Linux 下的 N_m3u8DL 命令
            std::string cmd =
                "./N_m3u8DL-RE \"" + url + "\" "
                "--header 'Referer: " + referer + "' "
                "-o \"" + outputPath + "\"";

            int code = runCommand(cmd);

            sendMessage({
                {"status", "done"},
                {"exit_code", code},
                {"output", outputPath}
            });
        }

        else {
            sendMessage({
                {"status", "error"},
                {"message", "Unknown action"}
            });
        }
    }

    return 0;
}

