# Video Downloader v1.0.1

## 🔧 Bug 修复版本

修复 macOS 用户无法运行下载工具的关键问题。

## 🆕 本次更新

### 修复的问题

- **修复 macOS Gatekeeper 阻止问题** - 解决了 macOS 上出现 "yt-dlp can't be opened because Apple cannot check it for malicious software" 的错误
  - 自动移除 yt-dlp、N_m3u8DL-RE、ffmpeg 和 ffprobe 的隔离属性
  - 现在 YouTube 和 M3U8 下载都可以在 macOS 上正常工作
  - 用户只需重新运行 `install.sh` 即可修复

### 影响的平台

- ✅ macOS - 修复关键问题
- ➖ Linux - 无变化
- ➖ Windows - 无变化

## ✨ 主要功能

- 🎬 **YouTube 视频下载** - 通过 yt-dlp 自动下载 YouTube 视频，支持音视频自动合并
- 📺 **M3U8 流媒体下载** - 自动捕获并下载 M3U8 格式的视频流
- 🔍 **智能 URL 检测** - 自动检测并捕获 M3U8 播放列表 URL
- 🖥️ **跨平台支持** - 支持 Linux、macOS 和 Windows
- 🚀 **原生性能** - 使用 Native Messaging Host 实现高性能下载
- 🎵 **FFmpeg 集成** - 自动合并视频和音频流，确保完整的下载体验
- 📦 **一键安装** - 所有工具已预打包，无需额外下载

## 📦 下载

根据你的操作系统选择对应的安装包：

### Linux
- 下载：`video-downloader-linux-v1.0.1.zip` (68MB)
- 要求：Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- 包含：yt-dlp, N_m3u8DL-RE, ffmpeg, ffprobe
- 安装：解压后运行 `./install.sh`

### macOS
- 下载：`video-downloader-macos-v1.0.1.zip` (94MB) **[推荐更新]**
- 要求：macOS 10.15+ (Catalina 或更高版本)
- 支持：Intel Mac（Apple Silicon 通过 Rosetta 2 运行）
- 包含：yt-dlp, N_m3u8DL-RE, ffmpeg, ffprobe
- 安装：解压后运行 `./install.sh`
- **重要**：已修复 Gatekeeper 阻止问题，强烈建议 macOS 用户更新

### Windows
- 下载：`video-downloader-windows-v1.0.1.zip` (95MB)
- 要求：Windows 10/11
- 包含：yt-dlp.exe, N_m3u8DL-RE.exe, ffmpeg.exe, ffprobe.exe
- 安装：解压后以管理员身份运行 `install.bat`
- **注意**：Windows Defender 可能误报，需添加到排除列表

## 🚀 快速开始

1. 下载并解压对应平台的安装包
2. 运行安装脚本（`install.sh` 或 `install.bat`）
3. 在 Chrome 中加载 `plugin/` 目录作为未打包的扩展
4. 复制扩展 ID 并重新运行安装脚本配置
5. 重启 Chrome，开始使用！

详细安装指南请参阅 README.md

## 🔧 技术架构

- **Chrome Extension (Manifest V3)** - Service Worker、Chrome Debugger API
- **Native Messaging Host (C++)** - 高性能本地消息处理
- **下载工具**
  - [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube 视频下载器
  - [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE) - M3U8 流媒体下载器
  - [FFmpeg](https://ffmpeg.org/) - 视频/音频处理和合并

## 📝 校验和

下载后请验证文件完整性：

```bash
sha256sum video-downloader-*.zip
```

查看 `checksums.txt` 文件获取正确的校验和。

## 🐛 已知问题

- M3U8 下载时 Chrome 会显示"正在被自动化测试软件控制"的提示（这是 Chrome Debugger API 的正常行为）
- Windows Defender 可能将 native_host.exe 误报为病毒，需添加到排除列表

## 📄 许可证

MIT License

## ⚠️ 免责声明

请遵守视频网站的服务条款。仅下载您有权访问的内容。此工具仅供教育和个人使用。

---

**完整文档**：[README.md](https://github.com/你的用户名/项目名)
**问题反馈**：[GitHub Issues](https://github.com/你的用户名/项目名/issues)
**变更日志**：[CHANGELOG.md](https://github.com/你的用户名/项目名/blob/main/CHANGELOG.md)
