#!/bin/bash

# 1. 安装程序到用户目录
INSTALL_PATH="$HOME/.local/bin/videodl_host"
TOOLS_DIR="$HOME/.local/share/video-downloader/tools"

mkdir -p "$HOME/.local/bin"
cp native_host "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# 2. 创建工具目录并复制工具
echo "Installing download tools..."
mkdir -p "$TOOLS_DIR"

if [ -f "yt-dlp" ]; then
    cp yt-dlp "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/yt-dlp"
    echo "[OK] yt-dlp installed"
else
    echo "[WARNING] yt-dlp not found"
fi

if [ -f "N_m3u8DL-RE" ]; then
    cp N_m3u8DL-RE "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/N_m3u8DL-RE"
    echo "[OK] N_m3u8DL-RE installed"
else
    echo "[WARNING] N_m3u8DL-RE not found"
fi

if [ -f "ffmpeg" ]; then
    cp ffmpeg "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/ffmpeg"
    echo "[OK] ffmpeg installed"
else
    echo "[WARNING] ffmpeg not found - video/audio merging won't work"
fi

if [ -f "ffprobe" ]; then
    cp ffprobe "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/ffprobe"
    echo "[OK] ffprobe installed"
else
    echo "[WARNING] ffprobe not found"
fi

echo ""

# 3. 创建 NativeMessagingHosts 目录
MANIFEST_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
mkdir -p "$MANIFEST_DIR"

# 3. 替换模板中的占位符
sed \
    -e "s|__HOST_PATH__|$INSTALL_PATH|" \
    -e "s|__EXTENSION_ID__|$1|" \
    com.videodl.host.template.json \
    > "$MANIFEST_DIR/com.videodl.host.json"

echo "Install OK!"
echo "Installed host: $INSTALL_PATH"
echo "Manifest created: $MANIFEST_DIR/com.videodl.host.json"

