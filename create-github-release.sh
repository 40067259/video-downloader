#!/bin/bash

# GitHub Release 创建脚本
# 使用 GitHub API 创建 Release 并上传文件

set -e

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
VERSION=${1:-"v1.0.0"}
REPO_OWNER="40067259"
REPO_NAME="video-downloader"
RELEASE_DIR="releases/${VERSION}"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  GitHub Release Creator${NC}"
echo -e "${BLUE}  Version: ${VERSION}${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# 检查 GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}错误：未设置 GITHUB_TOKEN 环境变量${NC}"
    echo ""
    echo "请先设置你的 GitHub Personal Access Token："
    echo "  export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "如何获取 token："
    echo "  1. 访问 https://github.com/settings/tokens"
    echo "  2. 点击 'Generate new token' → 'Generate new token (classic)'"
    echo "  3. 勾选 'repo' 权限"
    echo "  4. 生成并复制 token"
    echo ""
    exit 1
fi

# 检查 release 文件是否存在
if [ ! -d "$RELEASE_DIR" ]; then
    echo -e "${RED}错误：Release 目录不存在: $RELEASE_DIR${NC}"
    echo "请先运行: ./create-release.sh ${VERSION}"
    exit 1
fi

# 读取 Release Notes
if [ ! -f "RELEASE_NOTES.md" ]; then
    echo -e "${YELLOW}警告：RELEASE_NOTES.md 不存在，使用默认描述${NC}"
    RELEASE_BODY="Release ${VERSION}"
else
    RELEASE_BODY=$(cat RELEASE_NOTES.md)
fi

# 创建 Release
echo -e "${YELLOW}正在创建 GitHub Release...${NC}"

# 创建 JSON payload
cat > /tmp/release_payload.json <<EOF
{
  "tag_name": "${VERSION}",
  "target_commitish": "main",
  "name": "Video Downloader ${VERSION}",
  "body": $(echo "$RELEASE_BODY" | jq -Rs .),
  "draft": false,
  "prerelease": false
}
EOF

# 发送 API 请求创建 Release
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" \
  -d @/tmp/release_payload.json)

# 检查是否成功
RELEASE_ID=$(echo "$RESPONSE" | grep -o '"id": [0-9]*' | head -1 | grep -o '[0-9]*')

if [ -z "$RELEASE_ID" ]; then
    echo -e "${RED}创建 Release 失败！${NC}"
    echo "$RESPONSE" | grep -o '"message": "[^"]*"' || echo "$RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Release 创建成功！ID: ${RELEASE_ID}${NC}"
echo ""

# 上传文件
echo -e "${YELLOW}上传 Release 文件...${NC}"
echo ""

upload_file() {
    local file=$1
    local filename=$(basename "$file")

    echo -ne "  上传 ${filename}... "

    UPLOAD_RESPONSE=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/zip" \
      --data-binary @"$file" \
      "https://uploads.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/${RELEASE_ID}/assets?name=${filename}")

    if echo "$UPLOAD_RESPONSE" | grep -q '"state": "uploaded"'; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo "  错误: $(echo $UPLOAD_RESPONSE | grep -o '"message": "[^"]*"')"
    fi
}

# 上传所有 ZIP 文件
for file in ${RELEASE_DIR}/*.zip; do
    upload_file "$file"
done

# 上传 checksums.txt
if [ -f "${RELEASE_DIR}/checksums.txt" ]; then
    echo -ne "  上传 checksums.txt... "

    UPLOAD_RESPONSE=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: text/plain" \
      --data-binary @"${RELEASE_DIR}/checksums.txt" \
      "https://uploads.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/${RELEASE_ID}/assets?name=checksums.txt")

    if echo "$UPLOAD_RESPONSE" | grep -q '"state": "uploaded"'; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ GitHub Release 创建完成！${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Release URL: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${VERSION}"
echo ""
