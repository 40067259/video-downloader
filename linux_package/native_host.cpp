#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include "json.hpp"

using json = nlohmann::json;

// ---------------------------------------------------------
// Read 4-byte little-endian length header
// ---------------------------------------------------------
uint32_t readLen() {
    unsigned char buf[4];
    size_t n = fread(buf, 1, 4, stdin);
    if (n != 4) {
        std::fprintf(stderr, "[Host] readLen(): EOF or broken header (n=%zu)\n", n);
        return 0;
    }
    return buf[0] | (buf[1] << 8) | (buf[2] << 16) | (buf[3] << 24);
}

// ---------------------------------------------------------
// Read JSON message from Chrome
// ---------------------------------------------------------
json readMessage() {
    uint32_t len = readLen();
    if (len == 0) {
        std::fprintf(stderr, "[Host] readMessage(): length=0 → will exit\n");
        return json();
    }

    std::string buf(len, '\0');
    size_t n = fread(&buf[0], 1, len, stdin);

    if (n != len) {
        std::fprintf(stderr, "[Host] readMessage(): fread mismatch (got %zu, expected %u)\n", n, len);
        return json();
    }

    std::fprintf(stderr, "[Host] Raw incoming JSON: %s\n", buf.c_str());

    try {
        return json::parse(buf);
    } catch (const std::exception& e) {
        std::fprintf(stderr, "[Host] JSON parse error: %s\n", e.what());
        return json();
    }
}

// ---------------------------------------------------------
// Send JSON back to Chrome (stdout ONLY)
// ---------------------------------------------------------
void sendMessage(const json& msg) {
    std::string text = msg.dump();
    uint32_t len = text.size();

    unsigned char header[4] = {
        (unsigned char)(len & 0xFF),
        (unsigned char)((len >> 8) & 0xFF),
        (unsigned char)((len >> 16) & 0xFF),
        (unsigned char)((len >> 24) & 0xFF)
    };

    fwrite(header, 1, 4, stdout);
    fwrite(text.data(), 1, text.size(), stdout);
    fflush(stdout);

    std::fprintf(stderr, "[Host] Sent response JSON: %s\n", text.c_str());
}

// ---------------------------------------------------------
// Execute external command safely
// ---------------------------------------------------------
int run(const std::string& cmd) {
    std::fprintf(stderr, "[Host] Running command: %s\n", cmd.c_str());
    int ret = system(cmd.c_str());
    int code = WEXITSTATUS(ret);
    std::fprintf(stderr, "[Host] Command exit code = %d\n", code);
    return code;
}

// ---------------------------------------------------------
// MAIN LOOP
// ---------------------------------------------------------
int main() {
    // Force working directory
    const char* WORKDIR = "/home/zhangf/workplace/download_plugin/linux_package";
    if (chdir(WORKDIR) != 0) {
        std::fprintf(stderr, "[Host] ERROR: chdir failed => %s\n", WORKDIR);
    } else {
        std::fprintf(stderr, "[Host] chdir OK => %s\n", WORKDIR);
    }

    std::fprintf(stderr, "[Host] Native host started and waiting for messages...\n");

    while (true) {

        json msg = readMessage();
        std::fprintf(stderr, "[Host] readMessage() returned: %s\n", msg.dump().c_str());

        if (msg.is_null() || msg.empty()) {
            std::fprintf(stderr, "[Host] NULL/EMPTY message received → host exiting.\n");
            break;
        }

        std::string action = msg.value("action", "");
        std::fprintf(stderr, "[Host] Action = %s\n", action.c_str());

        //-----------------------------------------------------------------
        // 1. YouTube download
        //-----------------------------------------------------------------
        if (action == "download_youtube") {
            std::string url  = msg.value("url", "");
            std::string save = msg.value("save_name", "youtube_video");

            std::string cmd =
                "./yt-dlp -f \"bv*[vcodec^=avc1]+ba/b\" "
                "--merge-output-format mp4 "
                "-o \"" + save + ".mp4\" "
                "\"" + url + "\" "
                ">/dev/null 2>&1";

            int ret = run(cmd);

            sendMessage({
                {"status", ret == 0 ? "done" : "error"},
                {"exit_code", ret},
                {"file", save + ".mp4"}
            });
            continue;
        }

        //-----------------------------------------------------------------
        // 2. M3U8 download
        //-----------------------------------------------------------------
        if (action == "download_m3u8") {
            std::string url  = msg.value("url", "");
            std::string ref  = msg.value("referer", "");
            std::string save = msg.value("save_name", "video");

            std::string cmd =
                "./N_m3u8DL-RE \"" + url + "\" "
                "-H \"Referer: " + ref + "\" "
                "--save-name \"" + save + "\" "
                ">/dev/null 2>&1";

            int ret = run(cmd);

            sendMessage({
                {"status", ret == 0 ? "done" : "error"},
                {"exit_code", ret},
                {"file", save + ".mp4"}
            });
            continue;
        }

        //-----------------------------------------------------------------
        // 3. Unknown action
        //-----------------------------------------------------------------
        sendMessage({
            {"status", "error"},
            {"msg", "Unknown action: " + action}
        });
    }

    std::fprintf(stderr, "[Host] Exited main loop.\n");
    return 0;
}

