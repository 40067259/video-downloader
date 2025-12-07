# 发布指南

本指南说明如何创建和发布新版本的 Video Downloader。

## 📋 发布前检查清单

- [ ] 所有功能已测试并正常工作
- [ ] 更新 CHANGELOG.md 记录本次更改
- [ ] 更新 README.md（如有必要）
- [ ] 在 Linux、macOS、Windows 上测试安装流程
- [ ] 确保没有测试文件或临时文件在代码库中

## 🚀 发布步骤

### 1. 创建 Release 包

运行打包脚本，指定版本号（遵循语义化版本）：

```bash
./create-release.sh v1.0.0
```

这将在 `releases/v1.0.0/` 目录下创建：
- `video-downloader-linux-v1.0.0.zip`
- `video-downloader-macos-v1.0.0.zip`
- `video-downloader-windows-v1.0.0.zip`
- `checksums.txt` (SHA256 校验和)

### 2. 测试 Release 包

在各平台上测试安装包：

**Linux:**
```bash
cd /tmp
unzip video-downloader-linux-v1.0.0.zip
cd video-downloader-linux-v1.0.0
./install.sh
# 测试扩展功能
```

**macOS:**
```bash
cd /tmp
unzip video-downloader-macos-v1.0.0.zip
cd video-downloader-macos-v1.0.0
./install.sh
# 测试扩展功能
```

**Windows:**
```cmd
# 解压 ZIP 文件
# 以管理员身份运行 install.bat
# 测试扩展功能
```

### 3. 创建 Git Tag

```bash
# 创建带注释的标签
git tag -a v1.0.0 -m "Release v1.0.0 - First stable release"

# 推送标签到远程仓库
git push origin v1.0.0
```

### 4. 在 GitHub 创建 Release

1. 访问 GitHub 仓库页面
2. 点击 "Releases" → "Draft a new release"
3. 选择刚才创建的 tag (v1.0.0)
4. 填写 Release 标题：`Video Downloader v1.0.0`
5. 复制 `RELEASE_NOTES.md` 的内容到描述框
6. 上传 Release 包：
   - video-downloader-linux-v1.0.0.zip
   - video-downloader-macos-v1.0.0.zip
   - video-downloader-windows-v1.0.0.zip
   - checksums.txt
7. 勾选 "Set as the latest release"（如果是最新版本）
8. 点击 "Publish release"

### 5. 更新 README

在 README.md 中添加下载链接：

```markdown
## 📦 快速下载

**最新版本：v1.0.0**

- [Linux](https://github.com/你的用户名/项目名/releases/download/v1.0.0/video-downloader-linux-v1.0.0.zip)
- [macOS](https://github.com/你的用户名/项目名/releases/download/v1.0.0/video-downloader-macos-v1.0.0.zip)
- [Windows](https://github.com/你的用户名/项目名/releases/download/v1.0.0/video-downloader-windows-v1.0.0.zip)

或访问 [Releases 页面](https://github.com/你的用户名/项目名/releases) 查看所有版本。
```

### 6. 发布后验证

- [ ] 从 GitHub Releases 页面下载 ZIP 文件
- [ ] 验证 SHA256 校验和
- [ ] 在新环境测试安装
- [ ] 检查所有下载链接是否正常工作

## 🔄 版本号规范

遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)：

- **主版本号 (MAJOR)**：不兼容的 API 修改
  - 例：v1.0.0 → v2.0.0
- **次版本号 (MINOR)**：向下兼容的功能性新增
  - 例：v1.0.0 → v1.1.0
- **修订号 (PATCH)**：向下兼容的问题修正
  - 例：v1.0.0 → v1.0.1

## 📝 版本发布示例

### 补丁版本（Bug 修复）

```bash
# 修复了一些 bug
./create-release.sh v1.0.1
git tag -a v1.0.1 -m "Release v1.0.1 - Bug fixes"
git push origin v1.0.1
```

### 次版本（新功能）

```bash
# 添加了新功能
./create-release.sh v1.1.0
git tag -a v1.1.0 -m "Release v1.1.0 - New features"
git push origin v1.1.0
```

### 主版本（重大更新）

```bash
# 重大架构变更
./create-release.sh v2.0.0
git tag -a v2.0.0 -m "Release v2.0.0 - Major update"
git push origin v2.0.0
```

## 🛠️ 故障排除

### 打包失败

```bash
# 检查是否安装了 rsync 和 zip
which rsync zip

# 如果未安装
# Ubuntu/Debian:
sudo apt-get install rsync zip

# macOS:
brew install rsync zip

# 清理并重试
rm -rf releases
./create-release.sh v1.0.0
```

### Git Tag 已存在

```bash
# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin :refs/tags/v1.0.0

# 重新创建
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## 📧 发布后通知

考虑通过以下渠道通知用户：
- GitHub Discussions
- 项目 README 更新
- 社交媒体
- 邮件列表（如有）

---

**注意**：首次发布后，请保持版本号的连续性和一致性。
