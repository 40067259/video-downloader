# 手动创建 GitHub Release 步骤

由于没有安装 gh CLI，这里是手动创建 Release 的详细步骤：

## 📝 步骤说明

### 1. 访问 GitHub Release 页面

打开浏览器，访问：
```
https://github.com/40067259/video-downloader/releases/new
```

或者：
1. 进入你的仓库：https://github.com/40067259/video-downloader
2. 点击右侧的 "Releases"
3. 点击 "Draft a new release"

### 2. 填写 Release 信息

**Choose a tag:**
- 从下拉列表选择 `v1.0.0`（刚才推送的 tag）

**Release title:**
```
Video Downloader v1.0.0
```

**Describe this release:**

复制以下内容（或从 RELEASE_NOTES.md 复制）：

```markdown
# Video Downloader v1.0.0

## 🎉 首次发布

这是 Video Downloader 的第一个正式版本！一个功能强大的 Chrome 扩展，用于下载 YouTube 视频和 M3U8 流媒体视频。

## ✨ 主要功能

- 🎬 **YouTube 视频下载** - 通过 yt-dlp 自动下载 YouTube 视频
- 📺 **M3U8 流媒体下载** - 自动捕获并下载 M3U8 格式的视频流
- 🔍 **智能 URL 检测** - 自动检测并捕获 M3U8 播放列表 URL
- 🖥️ **跨平台支持** - 支持 Linux、macOS 和 Windows
- 🚀 **原生性能** - 使用 Native Messaging Host 实现高性能下载

## 📦 下载

根据你的操作系统选择对应的安装包：

### Linux
- 要求：Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- 安装：解压后运行 `./install.sh`

### macOS
- 要求：macOS 10.15+ (Catalina 或更高版本)
- 支持：Intel 和 Apple Silicon Mac
- 安装：解压后运行 `./install.sh`
- **注意**：需要自行下载 [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases) 和 [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE/releases)

### Windows
- 要求：Windows 10/11
- 安装：解压后以管理员身份运行 `install.bat`
- **注意**：需要自行下载 [yt-dlp.exe](https://github.com/yt-dlp/yt-dlp/releases) 和 [N_m3u8DL-RE.exe](https://github.com/nilaoda/N_m3u8DL-RE/releases)

## 🚀 快速开始

1. 下载并解压对应平台的安装包
2. 运行安装脚本（`install.sh` 或 `install.bat`）
3. 在 Chrome 中加载 `plugin/` 目录作为未打包的扩展
4. 复制扩展 ID 并重新运行安装脚本配置
5. 重启 Chrome，开始使用！

详细安装指南请参阅 README.md

## 📝 校验和

下载后请验证文件完整性，查看 `checksums.txt` 文件获取 SHA256 校验和。

## ⚠️ 免责声明

请遵守视频网站的服务条款。仅下载您有权访问的内容。此工具仅供教育和个人使用。
```

### 3. 上传文件

在 "Attach binaries" 区域，拖拽或点击上传以下文件：

```bash
releases/v1.0.0/video-downloader-linux-v1.0.0.zip
releases/v1.0.0/video-downloader-macos-v1.0.0.zip
releases/v1.0.0/video-downloader-windows-v1.0.0.zip
releases/v1.0.0/checksums.txt
```

### 4. 发布选项

- ✅ 勾选 "Set as the latest release"
- ⬜ 不要勾选 "Set as a pre-release"

### 5. 点击 "Publish release"

---

## 🎯 完成！

Release 创建后，你的 Release 页面将是：
```
https://github.com/40067259/video-downloader/releases/tag/v1.0.0
```

用户可以从这里直接下载安装包！
