#!/bin/bash

# 1. 安装程序到用户目录
INSTALL_PATH="$HOME/.local/bin/videodl_host"

mkdir -p "$HOME/.local/bin"
cp native_host "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# 2. 创建 NativeMessagingHosts 目录
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

