#!/bin/bash

# Video Downloader Chrome Extension Installer
# This script installs the native messaging host for the Video Downloader extension

set -e

echo "=========================================="
echo "Video Downloader Extension Installer"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}Error: This installer is for Linux only${NC}"
    echo "For Windows, please use install.bat"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installation directory: $SCRIPT_DIR"
echo ""

# Check for required commands
echo "Checking dependencies..."
for cmd in g++ chmod mkdir; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Create installation directories
echo "Creating directories..."
INSTALL_DIR="$HOME/.local/share/video-downloader"
TOOLS_DIR="$INSTALL_DIR/tools"
BIN_DIR="$HOME/.local/bin"
CHROME_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
CHROMIUM_DIR="$HOME/.config/chromium/NativeMessagingHosts"

mkdir -p "$TOOLS_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$CHROME_DIR"
mkdir -p "$CHROMIUM_DIR" 2>/dev/null || true
mkdir -p "$HOME/Downloads/VideoDownloader"

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Compile native_host
echo "Compiling native messaging host..."
cd "$SCRIPT_DIR/linux_package"
if ! g++ -std=c++11 -o native_host native_host.cpp; then
    echo -e "${RED}Error: Compilation failed${NC}"
    echo "Please make sure json.hpp is in the linux_package directory"
    exit 1
fi
echo -e "${GREEN}✓ Compilation successful${NC}"
echo ""

# Copy files
echo "Installing files..."
cp native_host "$BIN_DIR/videodl_host"
chmod +x "$BIN_DIR/videodl_host"

# Copy download tools
if [ -f "yt-dlp" ]; then
    cp yt-dlp "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/yt-dlp"
    echo -e "${GREEN}✓ yt-dlp installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: yt-dlp not found, YouTube downloads won't work${NC}"
fi

if [ -f "N_m3u8DL-RE" ]; then
    cp N_m3u8DL-RE "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/N_m3u8DL-RE"
    echo -e "${GREEN}✓ N_m3u8DL-RE installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: N_m3u8DL-RE not found, M3U8 downloads won't work${NC}"
fi

echo ""

# Get Chrome extension ID
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

# Create native messaging host manifest
echo "Creating native messaging configuration..."
MANIFEST_FILE="$CHROME_DIR/com.videodl.host.json"
cat > "$MANIFEST_FILE" << EOF
{
  "name": "com.videodl.host",
  "description": "Native host for Video Downloader extension",
  "path": "$BIN_DIR/videodl_host",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXTENSION_ID/"
  ]
}
EOF

# Also create for Chromium if directory exists
if [ -d "$CHROMIUM_DIR" ]; then
    cp "$MANIFEST_FILE" "$CHROMIUM_DIR/"
    echo -e "${GREEN}✓ Configuration created for Chrome and Chromium${NC}"
else
    echo -e "${GREEN}✓ Configuration created for Chrome${NC}"
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installation Summary:"
echo "  Native host: $BIN_DIR/videodl_host"
echo "  Tools directory: $TOOLS_DIR"
echo "  Downloads will be saved to: ~/Downloads/VideoDownloader/"
echo ""
echo "Next steps:"
echo "  1. Load the extension from: $SCRIPT_DIR/plugin"
echo "  2. Copy the extension ID from chrome://extensions/"
echo "  3. If the ID is different from $EXTENSION_ID,"
echo "     run this script again with the correct ID"
echo ""
echo -e "${GREEN}Happy downloading!${NC}"
echo ""
