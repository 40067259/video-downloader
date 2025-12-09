#!/bin/bash

# Quick fix for yt-dlp Python.framework issue on macOS

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "yt-dlp Python.framework Fix Tool"
echo "=========================================="
echo ""

TOOLS_DIR="$HOME/Library/Application Support/video-downloader/tools"

if [ ! -f "$TOOLS_DIR/yt-dlp" ]; then
    echo -e "${RED}Error: yt-dlp not found${NC}"
    echo "Expected location: $TOOLS_DIR/yt-dlp"
    exit 1
fi

echo "Found yt-dlp at: $TOOLS_DIR/yt-dlp"
echo ""

# Method 1: Clear quarantine attributes with sudo
echo "Method 1: Clearing quarantine attributes..."
sudo xattr -cr "$TOOLS_DIR/yt-dlp"
echo -e "${GREEN}✓ Quarantine cleared${NC}"
echo ""

# Method 2: Test if it works
echo "Testing yt-dlp..."
if "$TOOLS_DIR/yt-dlp" --version; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "✓ SUCCESS! yt-dlp is now working"
    echo "==========================================${NC}"
else
    echo ""
    echo -e "${YELLOW}=========================================="
    echo "Still having issues?"
    echo "==========================================${NC}"
    echo ""
    echo "Try these additional steps:"
    echo ""
    echo "1. Right-click on yt-dlp in Finder:"
    echo "   open -R '$TOOLS_DIR/yt-dlp'"
    echo "   Then right-click → Open → Confirm"
    echo ""
    echo "2. Or run with sudo:"
    echo "   sudo '$TOOLS_DIR/yt-dlp' --version"
    echo ""
    echo "3. Check System Settings → Privacy & Security"
    echo "   for any blocked items"
fi

echo ""
