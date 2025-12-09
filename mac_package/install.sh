#!/bin/bash

# Video Downloader Chrome Extension Installer for macOS

set -e

echo "=========================================="
echo "Video Downloader Extension Installer"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Installation directory: $SCRIPT_DIR"
echo ""

# Check for required tools
echo "Checking dependencies..."

# Check for compiler (prefer clang++ on macOS, fallback to g++)
if command -v clang++ &> /dev/null; then
    CXX=clang++
    echo -e "${GREEN}✓ clang++ found${NC}"
elif command -v g++ &> /dev/null; then
    CXX=g++
    echo -e "${GREEN}✓ g++ found${NC}"
else
    echo -e "${RED}✗ Error: C++ compiler not found${NC}"
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi
echo ""

# Create installation directories (macOS-specific paths)
echo "Creating directories..."
INSTALL_DIR="$HOME/Library/Application Support/video-downloader"
TOOLS_DIR="$INSTALL_DIR/tools"
BIN_DIR="$HOME/.local/bin"
CHROME_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
DOWNLOADS_DIR="$HOME/Downloads/VideoDownloader"

mkdir -p "$INSTALL_DIR"
mkdir -p "$TOOLS_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$CHROME_DIR"
mkdir -p "$DOWNLOADS_DIR"

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Copy json.hpp if not present
if [ ! -f "$SCRIPT_DIR/json.hpp" ]; then
    if [ -f "../linux_package/json.hpp" ]; then
        echo "Copying json.hpp from linux_package..."
        cp "../linux_package/json.hpp" "$SCRIPT_DIR/"
    else
        echo -e "${RED}✗ Error: json.hpp not found${NC}"
        echo "Please download nlohmann/json.hpp to mac_package/"
        echo "  curl -L https://github.com/nlohmann/json/releases/download/v3.11.2/json.hpp -o json.hpp"
        exit 1
    fi
fi

# Compile native_host
echo "Compiling native messaging host..."
cd "$SCRIPT_DIR"
$CXX -std=c++11 -o native_host native_host.cpp

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Compilation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Compilation successful${NC}"
echo ""

# Copy files
echo "Installing files..."
cp native_host "$BIN_DIR/videodl_host"
chmod +x "$BIN_DIR/videodl_host"
echo -e "${GREEN}✓ Native host installed to: $BIN_DIR/videodl_host${NC}"

# Copy download tools if they exist
if [ -f "yt-dlp" ]; then
    cp yt-dlp "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/yt-dlp"
    # Remove macOS quarantine attribute to allow execution
    xattr -d com.apple.quarantine "$TOOLS_DIR/yt-dlp" 2>/dev/null || true
    echo -e "${GREEN}✓ yt-dlp installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: yt-dlp not found, YouTube downloads won't work${NC}"
    echo "  Download from: https://github.com/yt-dlp/yt-dlp/releases"
    echo "  Command: curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp"
fi

if [ -f "N_m3u8DL-RE" ]; then
    cp N_m3u8DL-RE "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/N_m3u8DL-RE"
    # Remove macOS quarantine attribute to allow execution
    xattr -d com.apple.quarantine "$TOOLS_DIR/N_m3u8DL-RE" 2>/dev/null || true
    echo -e "${GREEN}✓ N_m3u8DL-RE installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: N_m3u8DL-RE not found, M3U8 downloads won't work${NC}"
    echo "  Download from: https://github.com/nilaoda/N_m3u8DL-RE/releases"
    echo "  Look for: N_m3u8DL-RE_Beta_osx-x64 (for Intel Mac)"
    echo "  or: N_m3u8DL-RE_Beta_osx-arm64 (for Apple Silicon)"
fi

if [ -f "ffmpeg" ]; then
    cp ffmpeg "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/ffmpeg"
    # Remove macOS quarantine attribute to allow execution
    xattr -d com.apple.quarantine "$TOOLS_DIR/ffmpeg" 2>/dev/null || true
    echo -e "${GREEN}✓ ffmpeg installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: ffmpeg not found, video/audio merging won't work${NC}"
    echo "  Download from: https://evermeet.cx/ffmpeg/"
fi

if [ -f "ffprobe" ]; then
    cp ffprobe "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/ffprobe"
    # Remove macOS quarantine attribute to allow execution
    xattr -d com.apple.quarantine "$TOOLS_DIR/ffprobe" 2>/dev/null || true
    echo -e "${GREEN}✓ ffprobe installed${NC}"
else
    echo -e "${YELLOW}⚠ Warning: ffprobe not found${NC}"
    echo "  Download from: https://evermeet.cx/ffmpeg/"
fi

echo ""

# Recursively remove quarantine attributes from all files in tools directory
# This is necessary for tools with embedded frameworks (like yt-dlp with Python.framework)
echo "Removing quarantine attributes from all tools..."
xattr -dr com.apple.quarantine "$TOOLS_DIR" 2>/dev/null || true
echo -e "${GREEN}✓ All quarantine attributes removed${NC}"
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

echo -e "${GREEN}✓ Configuration created${NC}"
echo ""

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Installation Summary:"
echo "  Native host: $BIN_DIR/videodl_host"
echo "  Tools directory: $TOOLS_DIR"
echo "  Downloads will be saved to: $DOWNLOADS_DIR"
echo "  Chrome config: $MANIFEST_FILE"
echo ""
echo "Next steps:"
echo "  1. Load the extension from: $SCRIPT_DIR/../plugin"
echo "  2. Copy the extension ID from chrome://extensions/"
echo "  3. If the ID is different from $EXTENSION_ID,"
echo "     run this script again with the correct ID"
echo ""
echo -e "${GREEN}Happy downloading!${NC}"
echo ""
