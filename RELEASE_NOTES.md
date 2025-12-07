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
- 下载：[video-downloader-linux-v1.0.0.zip](链接)
- 要求：Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- 安装：解压后运行 `./install.sh`

### macOS
- 下载：[video-downloader-macos-v1.0.0.zip](链接)
- 要求：macOS 10.15+ (Catalina 或更高版本)
- 支持：Intel 和 Apple Silicon Mac
- 安装：解压后运行 `./install.sh`
- **注意**：需要自行下载 [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases) 和 [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE/releases)

### Windows
- 下载：[video-downloader-windows-v1.0.0.zip](链接)
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

## 🔧 技术架构

- **Chrome Extension (Manifest V3)** - Service Worker、Chrome Debugger API
- **Native Messaging Host (C++)** - 高性能本地消息处理
- **下载工具**
  - [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube 视频下载器
  - [N_m3u8DL-RE](https://github.com/nilaoda/N_m3u8DL-RE) - M3U8 流媒体下载器

## 📝 校验和

下载后请验证文件完整性：

```bash
sha256sum video-downloader-*.zip
```

查看 `checksums.txt` 文件获取正确的校验和。

## 🐛 已知问题

- M3U8 下载时 Chrome 会显示"正在被自动化测试软件控制"的提示（这是 Chrome Debugger API 的正常行为）
- macOS 和 Windows 版本需要手动下载 yt-dlp 和 N_m3u8DL-RE 工具

## 📄 许可证

MIT License

## ⚠️ 免责声明

请遵守视频网站的服务条款。仅下载您有权访问的内容。此工具仅供教育和个人使用。

---

**完整文档**：[README.md](https://github.com/你的用户名/项目名)
**问题反馈**：[GitHub Issues](https://github.com/你的用户名/项目名/issues)
**变更日志**：[CHANGELOG.md](https://github.com/你的用户名/项目名/blob/main/CHANGELOG.md)
