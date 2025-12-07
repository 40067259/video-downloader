#!/bin/bash

# Video Downloader Chrome Extension Uninstaller for macOS

set -e

echo "=========================================="
echo "Video Downloader Extension Uninstaller"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Confirm uninstallation
read -p "Are you sure you want to uninstall Video Downloader? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled"
    exit 0
fi

echo ""
echo "Removing installed files..."

# Remove directories and files (macOS-specific paths)
INSTALL_DIR="$HOME/Library/Application Support/video-downloader"
BIN_FILE="$HOME/.local/bin/videodl_host"
CHROME_MANIFEST="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.videodl.host.json"

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓ Removed installation directory${NC}"
fi

if [ -f "$BIN_FILE" ]; then
    rm -f "$BIN_FILE"
    echo -e "${GREEN}✓ Removed native host binary${NC}"
fi

if [ -f "$CHROME_MANIFEST" ]; then
    rm -f "$CHROME_MANIFEST"
    echo -e "${GREEN}✓ Removed Chrome configuration${NC}"
fi

echo ""
read -p "Do you want to remove downloaded files in ~/Downloads/VideoDownloader? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/Downloads/VideoDownloader" ]; then
        rm -rf "$HOME/Downloads/VideoDownloader"
        echo -e "${GREEN}✓ Removed downloaded files${NC}"
    fi
fi

echo ""
echo "=========================================="
echo "Uninstallation Complete!"
echo "=========================================="
echo ""
echo "The extension files in the plugin/ directory were not removed."
echo "You can manually delete them if needed."
echo ""
echo -e "${GREEN}Thank you for using Video Downloader!${NC}"
echo ""
