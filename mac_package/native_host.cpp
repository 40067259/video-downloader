#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include "json.hpp"

using json = nlohmann::json;

// Global variable for downloads directory
std::string g_downloadsDir;

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
// Parse yt-dlp progress line
// ---------------------------------------------------------
void parseYtDlpProgress(const std::string& line, const std::string& filename) {
    // yt-dlp format: [download]  45.2% of 123.45MiB at 2.34MiB/s ETA 00:32
    if (line.find("[download]") != std::string::npos && line.find("%") != std::string::npos) {
        float percent = 0.0f;
        char speed[64] = {0};
        char eta[32] = {0};

        // Try to extract percentage
        size_t pct_pos = line.find("%");
        if (pct_pos != std::string::npos) {
            // Find start of number before %
            size_t start = pct_pos;
            while (start > 0 && (isdigit(line[start-1]) || line[start-1] == '.')) start--;
            std::string pct_str = line.substr(start, pct_pos - start);
            percent = std::stof(pct_str);
        }

        // Try to extract speed
        size_t at_pos = line.find(" at ");
        if (at_pos != std::string::npos) {
            size_t speed_end = line.find(" ", at_pos + 4);
            if (speed_end != std::string::npos) {
                std::string speed_str = line.substr(at_pos + 4, speed_end - (at_pos + 4));
                snprintf(speed, sizeof(speed), "%s", speed_str.c_str());
            }
        }

        // Try to extract ETA
        size_t eta_pos = line.find("ETA ");
        if (eta_pos != std::string::npos) {
            std::string eta_str = line.substr(eta_pos + 4, 5); // HH:MM format
            snprintf(eta, sizeof(eta), "%s", eta_str.c_str());
        }

        // Send progress message
        json progress = {
            {"type", "progress"},
            {"percent", percent},
            {"speed", speed},
            {"eta", eta},
            {"filename", filename}
        };
        sendMessage(progress);
    }
}

// ---------------------------------------------------------
// Parse N_m3u8DL-RE progress line
// ---------------------------------------------------------
void parseM3u8Progress(const std::string& line, const std::string& filename) {
    // N_m3u8DL-RE format: Vid Kbps ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 132/492 26.83% 230.66MB/907.87MB 25.98MBps 00:00:24
    if (line.find("Vid") != std::string::npos && line.find("%") != std::string::npos && line.find("MBps") != std::string::npos) {
        float percent = 0.0f;
        char speed[64] = {0};
        char eta[32] = {0};

        // Extract percentage
        size_t pct_pos = line.find("%");
        if (pct_pos != std::string::npos) {
            size_t start = pct_pos;
            while (start > 0 && (isdigit(line[start-1]) || line[start-1] == '.')) start--;
            std::string pct_str = line.substr(start, pct_pos - start);
            percent = std::stof(pct_str);
        }

        // Extract speed (look for MBps)
        size_t mbps_pos = line.find("MBps");
        if (mbps_pos != std::string::npos) {
            size_t start = mbps_pos;
            while (start > 0 && line[start-1] == ' ') start--;
            while (start > 0 && (isdigit(line[start-1]) || line[start-1] == '.')) start--;
            std::string speed_str = line.substr(start, mbps_pos - start) + "MBps";
            snprintf(speed, sizeof(speed), "%s", speed_str.c_str());
        }

        // Extract ETA (last time format XX:XX:XX or XX:XX)
        size_t last_colon = line.rfind(":");
        if (last_colon != std::string::npos && last_colon > 0) {
            // Find start of time (look back for space or another colon)
            size_t start = last_colon;
            while (start > 0 && line[start-1] != ' ') start--;
            std::string eta_str = line.substr(start, line.length() - start);
            // Trim trailing whitespace
            eta_str.erase(eta_str.find_last_not_of(" \n\r\t") + 1);
            snprintf(eta, sizeof(eta), "%s", eta_str.c_str());
        }

        // Send progress message
        json progress = {
            {"type", "progress"},
            {"percent", percent},
            {"speed", speed},
            {"eta", eta},
            {"filename", filename}
        };
        sendMessage(progress);
    }
}

// ---------------------------------------------------------
// Execute command and capture progress
// ---------------------------------------------------------
int run(const std::string& cmd, const std::string& filename = "") {
    std::fprintf(stderr, "[Host] Running command: %s\n", cmd.c_str());

    FILE* pipe = popen((cmd + " 2>&1").c_str(), "r");
    if (!pipe) {
        std::fprintf(stderr, "[Host] Failed to open pipe\n");
        return -1;
    }

    char buffer[1024];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        std::string line(buffer);
        std::fprintf(stderr, "%s", line.c_str());

        // Parse progress (try both formats - they won't conflict)
        if (!filename.empty()) {
            parseYtDlpProgress(line, filename);
            parseM3u8Progress(line, filename);
        }
    }

    int status = pclose(pipe);
    int code = WEXITSTATUS(status);
    std::fprintf(stderr, "[Host] Command exit code = %d\n", code);
    return code;
}

// ---------------------------------------------------------
// MAIN LOOP
// ---------------------------------------------------------
int main() {
    // Get user's home directory
    const char* home = getenv("HOME");
    if (!home) {
        std::fprintf(stderr, "[Host] ERROR: HOME environment variable not set\n");
        return 1;
    }

    // Set working directory to where tools are located (macOS-specific path)
    std::string toolsDir = std::string(home) + "/Library/Application Support/video-downloader/tools";
    if (chdir(toolsDir.c_str()) != 0) {
        std::fprintf(stderr, "[Host] ERROR: chdir failed => %s\n", toolsDir.c_str());
        std::fprintf(stderr, "[Host] Please run install.sh first\n");
        return 1;
    }
    std::fprintf(stderr, "[Host] Working directory: %s\n", toolsDir.c_str());

    // Create downloads directory if needed
    g_downloadsDir = std::string(home) + "/Downloads/VideoDownloader";
    std::string mkdirCmd = "mkdir -p \"" + g_downloadsDir + "\"";
    system(mkdirCmd.c_str());

    std::fprintf(stderr, "[Host] Downloads will be saved to: %s\n", g_downloadsDir.c_str());
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
            std::string filename = save + ".mp4";
            std::string fullPath = g_downloadsDir + "/" + filename;

            std::string cmd =
                "./yt-dlp -f \"bv*[vcodec^=avc1]+ba/b\" "
                "--merge-output-format mp4 "
                "--newline "
                "-o \"" + fullPath + "\" "
                "\"" + url + "\"";

            int ret = run(cmd, filename);

            sendMessage({
                {"status", ret == 0 ? "done" : "error"},
                {"exit_code", ret},
                {"file", filename},
                {"path", fullPath}
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
            std::string filename = save + ".mp4";
            std::string fullPath = g_downloadsDir + "/" + filename;

            std::string cmd =
                "./N_m3u8DL-RE \"" + url + "\" "
                "-H \"Referer: " + ref + "\" "
                "--save-name \"" + save + "\" "
                "--save-dir \"" + g_downloadsDir + "\"";

            int ret = run(cmd, filename);

            sendMessage({
                {"status", ret == 0 ? "done" : "error"},
                {"exit_code", ret},
                {"file", filename},
                {"path", fullPath}
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
