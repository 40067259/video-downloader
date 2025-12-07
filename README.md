# Video Downloader

A powerful Chrome extension for downloading YouTube videos and M3U8 streaming videos.

## ✨ Features

- 🎬 **YouTube Video Download** - Automatically download YouTube videos via yt-dlp
- 📺 **M3U8 Stream Download** - Auto-capture and download M3U8 format video streams
- 🔍 **Smart URL Detection** - Automatically detect and capture M3U8 playlist URLs
- 🖥️ **Cross-Platform** - Support for Linux, macOS, and Windows
- 🚀 **Native Performance** - High-performance downloads using Native Messaging Host

## 🏗️ Technical Architecture

### System Components

```
┌─────────────────────────────────────────────────────┐
│                  Chrome Extension                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Popup.js │  │Background│  │Chrome Debugger API│  │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│       │             │                  │            │
│       └─────────────┴──────────────────┘            │
└────────────────────┬────────────────────────────────┘
                     │ Native Messaging
                     ▼
┌────────────────────────────────────────────────────┐
│              Native Host (C++)                      │
│  ┌─────────────────┐  ┌──────────────────────┐    │
│  │ Message Handler │  │ Download Coordinator │    │
│  └────────┬────────┘  └──────────┬───────────┘    │
└───────────┼────────────────────────┼───────────────┘
            │                        │
            ▼                        ▼
    ┌──────────────┐        ┌──────────────┐
    │   yt-dlp     │        │ N_m3u8DL-RE  │
    │  (YouTube)   │        │   (M3U8)     │
    └──────────────┘        └──────────────┘
```

### Technical Flow

#### YouTube Download Flow:
```
1. User opens YouTube video page
2. Click extension icon → "Download Youtube"
3. Popup.js sends page URL to Background.js
4. Background.js sends to Native Host via Native Messaging
5. Native Host invokes yt-dlp to download video
6. Video saved to download directory
7. Native Host returns download result
```

#### M3U8 Download Flow:
```
1. User opens video website (e.g., iyf.tv)
2. Background.js automatically attaches Chrome Debugger API
3. Debugger monitors network requests, auto-captures .m3u8 URLs
4. User plays video → M3U8 URL is captured
5. Click extension icon → "Download M3U8"
6. Popup.js retrieves captured M3U8 URL from Background.js
7. Sends real M3U8 URL to Native Host
8. Native Host invokes N_m3u8DL-RE to download video stream
9. Video merged and saved
```

### Key Technologies

1. **Chrome Extension (Manifest V3)**
   - Service Worker (background.js)
   - Chrome Debugger API
   - Native Messaging API

2. **Native Messaging Host (C++)**
   - stdin/stdout communication
   - JSON message protocol
   - Child process management

3. **Download Tools**
   - [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube video downloader
   - [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE) - M3U8 stream downloader

## 📋 System Requirements

### General Requirements
- Google Chrome Browser (version 88+)
- Disk space: At least 500MB for video downloads

### Linux
- Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- GCC 7+ (for compilation)
- Dependencies: libstdc++

### macOS
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools (for compilation)
- Available for both Intel and Apple Silicon Macs

### Windows
- Windows 10/11
- Visual Studio 2019+ or MinGW-w64 (for compilation)

## 🚀 Installation

### Quick Start (Recommended)

#### Linux Installation

**One-command installation:**

```bash
./install.sh
```

The installer will:
- ✅ Compile the native messaging host
- ✅ Install all required files
- ✅ Set up Chrome/Chromium configuration
- ✅ Create download directory in `~/Downloads/VideoDownloader/`

**Detailed Steps:**

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/40067259/video-downloader.git
   cd video-downloader
   ```

2. **Run the installer**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Load the Chrome extension**
   - Open Chrome and navigate to `chrome://extensions/`
   - Enable "Developer mode" (top right toggle)
   - Click "Load unpacked"
   - Select the `plugin/` directory
   - **Copy the Extension ID** (looks like `nkbcigemlaglenoffcejlcokdjjffbpp`)

4. **Update configuration (if needed)**

   If your extension ID is different from the default, run the installer again:
   ```bash
   ./install.sh
   # Enter your extension ID when prompted
   ```

5. **Restart Chrome**
   ```bash
   pkill -f chrome
   # Reopen Chrome and test the extension
   ```

#### Installation Locations

After installation:
- Native Host: `~/.local/bin/videodl_host`
- Download Tools: `~/.local/share/video-downloader/tools/`
- Downloaded Videos: `~/Downloads/VideoDownloader/`
- Configuration: `~/.config/google-chrome/NativeMessagingHosts/`

#### Uninstallation

To remove the extension:

```bash
./uninstall.sh
```

### macOS Installation

**One-command installation:**

1. **Download or clone this repository**
   ```bash
   git clone https://github.com/40067259/video-downloader.git
   cd video-downloader/mac_package
   ```

2. **Install Xcode Command Line Tools** (if not already installed)
   ```bash
   xcode-select --install
   ```

3. **Run the installer**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   The installer will:
   - ✅ Compile the native messaging host
   - ✅ Install all required files
   - ✅ Set up Chrome configuration
   - ✅ Create download directory in `~/Downloads/VideoDownloader/`

4. **Download required tools** (if not included)
   - [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases) - Download the macOS version
     ```bash
     curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
     chmod +x yt-dlp
     ```
   - [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE/releases) - Download for your Mac:
     - Intel Mac: `N_m3u8DL-RE_Beta_osx-x64`
     - Apple Silicon: `N_m3u8DL-RE_Beta_osx-arm64`
     ```bash
     # For Intel Mac
     curl -L https://github.com/nilaoda/N_m3u8DL-RE/releases/latest/download/N_m3u8DL-RE_Beta_osx-x64 -o N_m3u8DL-RE
     chmod +x N_m3u8DL-RE

     # For Apple Silicon Mac
     curl -L https://github.com/nilaoda/N_m3u8DL-RE/releases/latest/download/N_m3u8DL-RE_Beta_osx-arm64 -o N_m3u8DL-RE
     chmod +x N_m3u8DL-RE
     ```

5. **Load the Chrome extension**
   - Open Chrome and navigate to `chrome://extensions/`
   - Enable "Developer mode" (top right toggle)
   - Click "Load unpacked"
   - Select the `plugin/` directory
   - **Copy the Extension ID**

6. **Update configuration (if needed)**

   If your extension ID is different from the default, run the installer again:
   ```bash
   ./install.sh
   # Enter your extension ID when prompted
   ```

7. **Restart Chrome**
   ```bash
   pkill -f Chrome
   # Reopen Chrome and test the extension
   ```

#### Installation Locations

After installation:
- Native Host: `~/.local/bin/videodl_host`
- Download Tools: `~/Library/Application Support/video-downloader/tools/`
- Downloaded Videos: `~/Downloads/VideoDownloader/`
- Configuration: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/`

#### Uninstallation

To remove the extension:

```bash
cd mac_package
./uninstall.sh
```

#### Requirements

- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools
- Chrome or Chromium-based browser

### Windows Installation

**One-command installation:**

1. **Download or clone this repository**
   ```cmd
   git clone https://github.com/40067259/video-downloader.git
   cd video-downloader\windows_package
   ```

2. **Run the installer** (Right-click → Run as Administrator)
   ```cmd
   install.bat
   ```

   The installer will:
   - ✅ Compile the native messaging host
   - ✅ Install all required files
   - ✅ Set up Chrome configuration
   - ✅ Create download directory in `%USERPROFILE%\Downloads\VideoDownloader\`

3. **Download required tools** (if not included)
   - [yt-dlp.exe](https://github.com/yt-dlp/yt-dlp/releases) - Place in `windows_package/`
   - [N_m3u8DL-RE.exe](https://github.com/nilaoda/N_m3u8DL-RE/releases) - Place in `windows_package/`

4. **Load the Chrome extension**
   - Open Chrome and navigate to `chrome://extensions/`
   - Enable "Developer mode" (top right toggle)
   - Click "Load unpacked"
   - Select the `plugin/` directory
   - **Copy the Extension ID**

5. **Update configuration (if needed)**

   If your extension ID is different from the default, run the installer again and enter your extension ID when prompted.

6. **Restart Chrome**

#### Installation Locations

After installation:
- Native Host: `%LOCALAPPDATA%\Programs\videodl_host.exe`
- Download Tools: `%LOCALAPPDATA%\video-downloader\tools\`
- Downloaded Videos: `%USERPROFILE%\Downloads\VideoDownloader\`
- Configuration: `%LOCALAPPDATA%\Google\Chrome\User Data\NativeMessagingHosts\`

#### Uninstallation

To remove the extension:

```cmd
cd windows_package
uninstall.bat
```

#### Requirements

- Windows 10/11
- MinGW-w64 or Visual Studio (for compilation)
- Chrome or Chromium-based browser

## 📖 Usage Guide

### Download YouTube Videos

1. **Open a YouTube video page**
   ```
   Example: https://www.youtube.com/watch?v=dQw4w9WgXcQ
   ```

2. **Click the extension icon** (VideoDL icon in toolbar)

3. **Click "Download Youtube" button**

4. **Wait for download to complete**
   - Status will show "Download started..."
   - Video saves to `linux_package/` or `windows_package/` directory
   - Filename format: `video_<timestamp>.mp4`

### Download M3U8 Videos

1. **Open video website** (e.g., iyf.tv)

2. **Play the video**
   - Extension automatically captures M3U8 URL in background
   - ⚠️ Chrome title bar will show "Chrome is being controlled by automated test software" (this is normal)

3. **Click the extension icon**

4. **Click "Download M3U8" button**
   - If M3U8 captured, status shows: "Using captured M3U8..."
   - If not captured, shows: "No M3U8 detected..."

5. **Wait for download to complete**
   - Video saves to download directory

### View Download Progress and Logs

```bash
# Monitor download logs in real-time
tail -f /tmp/native_host_debug.log

# View downloaded files
ls -lh linux_package/*.mp4
```

## 🔧 Configuration

### Download Directory

Default download location (configured in `native_host.cpp`):

**Linux:**
```cpp
const char* WORKDIR = "/home/zhangf/workplace/download_plugin/linux_package";
```

**To modify:**
1. Edit `linux_package/native_host.cpp` line 88
2. Change to your desired directory
3. Recompile and reinstall

### yt-dlp Download Format

Default format (`native_host.cpp` line 118):
```cpp
-f "bv*[vcodec^=avc1]+ba/b" --merge-output-format mp4
```

Alternative formats:
- `best` - Best quality
- `bestvideo+bestaudio` - Best video + audio
- `worst` - Smallest file size

## ❓ Troubleshooting

### Issue 1: "Specified native messaging host not found"

**Cause:** Native host not properly installed or Extension ID mismatch

**Solution:**
```bash
# 1. Check manifest configuration
cat ~/.config/google-chrome/NativeMessagingHosts/com.videodl.host.json

# 2. Verify Extension ID matches
# Go to chrome://extensions/ and check actual Extension ID

# 3. Reinstall with correct ID
cd linux_package
./install.sh <CORRECT_EXTENSION_ID>

# 4. Completely restart Chrome
pkill -f chrome
```

### Issue 2: M3U8 download fails (exit code = 1)

**Cause:** URL is not a real M3U8 playlist

**Solution:**
1. Ensure video has started playing (triggers M3U8 loading)
2. Check console logs for `[M3U8 Debugger] Captured M3U8`
3. If not captured, refresh page and replay video

### Issue 3: YouTube download fails

**Cause:** yt-dlp needs update or missing dependencies

**Solution:**
```bash
# Update yt-dlp
cd linux_package
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
chmod +x yt-dlp

# Test yt-dlp
./yt-dlp --version
```

### Issue 4: "Being controlled" message is intrusive

**Explanation:** This is an inherent Chrome Debugger API notification that cannot be hidden

**Scope of impact:**
- ✅ YouTube pages: No notification
- ⚠️ Other video sites: Shows notification (for M3U8 capture)

## 🛠️ Development

### Project Structure

```
video-downloader/
├── plugin/                    # Chrome Extension
│   ├── manifest.json         # Extension manifest
│   ├── background.js         # Background service worker
│   ├── popup.html/js         # Popup interface
│   └── icons/                # Icon resources
├── linux_package/            # Linux version
│   ├── native_host.cpp       # Native Host source
│   ├── native_host           # Compiled executable
│   ├── yt-dlp               # YouTube downloader
│   ├── N_m3u8DL-RE          # M3U8 downloader
│   ├── install.sh           # Installation script
│   └── com.videodl.host.template.json
├── mac_package/              # macOS version
│   ├── native_host.cpp       # Native Host source
│   ├── native_host           # Compiled executable
│   ├── yt-dlp               # YouTube downloader
│   ├── N_m3u8DL-RE          # M3U8 downloader
│   ├── install.sh           # Installation script
│   ├── uninstall.sh         # Uninstallation script
│   └── com.videodl.host.template.json
├── windows_package/          # Windows version
│   ├── native_host.cpp
│   ├── native_host.exe
│   ├── install.bat
│   ├── uninstall.bat
│   └── com.videodl.host.template.json
└── README.md
```

### Modify and Recompile

**Linux:**
```bash
# 1. Edit source code
vim linux_package/native_host.cpp

# 2. Recompile
cd linux_package
g++ -std=c++11 -o native_host native_host.cpp

# 3. Update installed version
cp native_host ~/.local/bin/videodl_host

# 4. Restart Chrome to test
pkill -f chrome
```

**macOS:**
```bash
# 1. Edit source code
vim mac_package/native_host.cpp

# 2. Recompile
cd mac_package
clang++ -std=c++11 -o native_host native_host.cpp
# or use g++ if you prefer
# g++ -std=c++11 -o native_host native_host.cpp

# 3. Update installed version
cp native_host ~/.local/bin/videodl_host

# 4. Restart Chrome to test
pkill -f Chrome
```

**Windows:**
```cmd
REM 1. Edit source code
notepad windows_package\native_host.cpp

REM 2. Recompile
cd windows_package
g++ -std=c++11 -o native_host.exe native_host.cpp -lws2_32

REM 3. Update installed version
copy native_host.exe %LOCALAPPDATA%\Programs\videodl_host.exe

REM 4. Restart Chrome to test
taskkill /F /IM chrome.exe
```

### Debugging Tips

**View Extension Logs:**
1. Navigate to `chrome://extensions/`
2. Find the extension, click "Service Worker"
3. View Console output

**View Native Host Logs:**
```bash
# Linux / macOS
tail -f /tmp/native_host_debug.log

# Windows
type %TEMP%\native_host_debug.log
```

**Test Native Messaging Communication:**
```bash
# Linux / macOS - Manually test native host
echo '{"action":"download_youtube","url":"https://youtube.com/watch?v=test","save_name":"test"}' | \
  ~/.local/bin/videodl_host

# Windows
echo {"action":"download_youtube","url":"https://youtube.com/watch?v=test","save_name":"test"} | %LOCALAPPDATA%\Programs\videodl_host.exe
```

## 📄 License

MIT License

## 🙏 Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube video downloader
- [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE) - M3U8 stream downloader
- [nlohmann/json](https://github.com/nlohmann/json) - JSON for Modern C++

---

**⚠️ Disclaimer:** Please comply with video sites' terms of service. Only download content you have permission to access. This tool is for educational and personal use only.
