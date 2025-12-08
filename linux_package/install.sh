#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# 3. 获取 Chrome extension ID
echo "=========================================="
echo "Chrome Extension Setup"
echo "=========================================="
echo ""
echo "Please provide your Chrome extension ID."
echo "You can find it in chrome://extensions/ (enable Developer mode)"
echo ""
read -p "Enter extension ID (or press Enter for default): " EXTENSION_ID

if [ -z "$EXTENSION_ID" ]; then
    EXTENSION_ID="nkbcigemlaglenoffcejlcokdjjffbpp"
    echo "Using default ID: $EXTENSION_ID"
fi

echo ""

# 4. 创建 NativeMessagingHosts 目录
MANIFEST_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
mkdir -p "$MANIFEST_DIR"

# 5. 替换模板中的占位符
sed \
    -e "s|__HOST_PATH__|$INSTALL_PATH|" \
    -e "s|__EXTENSION_ID__|$EXTENSION_ID|" \
    com.videodl.host.template.json \
    > "$MANIFEST_DIR/com.videodl.host.json"

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installation Summary:"
echo "  Native host: $INSTALL_PATH"
echo "  Tools directory: $TOOLS_DIR"
echo "  Downloads will be saved to: $HOME/Downloads/VideoDownloader"
echo "  Chrome config: $MANIFEST_DIR/com.videodl.host.json"
echo ""
echo "Next steps:"
echo "  1. Load the extension from: $(dirname "$SCRIPT_DIR")/plugin"
echo "  2. Copy the extension ID from chrome://extensions/"
echo "  3. If the ID is different from $EXTENSION_ID,"
echo "     run this script again with the correct ID"
echo ""
echo "Happy downloading!"
echo ""

