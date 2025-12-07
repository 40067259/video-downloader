#!/bin/bash

# Release packaging script for Video Downloader
# Creates platform-specific release packages

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get version from user or use default
VERSION=${1:-"v1.0.0"}

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Video Downloader Release Packager${NC}"
echo -e "${BLUE}  Version: ${VERSION}${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Create release directory
RELEASE_DIR="releases/${VERSION}"
mkdir -p "${RELEASE_DIR}"

echo -e "${YELLOW}Creating release packages in ${RELEASE_DIR}/${NC}"
echo ""

# Function to create a release package
create_package() {
    local platform=$1
    local package_dir=$2
    local package_name="video-downloader-${platform}-${VERSION}"
    local temp_dir="/tmp/${package_name}"

    echo -e "${GREEN}📦 Creating ${platform} package...${NC}"

    # Clean up temp directory if exists
    rm -rf "${temp_dir}"
    mkdir -p "${temp_dir}"

    # Copy common files
    cp README.md "${temp_dir}/"
    cp -r plugin "${temp_dir}/"

    # Copy platform-specific files (excluding unnecessary files)
    rsync -av --exclude='*.mp4' --exclude='*.mkv' --exclude='*.avi' \
              --exclude='Logs/' --exclude='*.log' \
              --exclude='test.sh' --exclude='test_*' \
              --exclude='downloads/' --exclude='generate_cmd' \
              "${package_dir}/" "${temp_dir}/$(basename ${package_dir})/"

    # Copy platform-specific install scripts (if they exist in root)
    if [ "${platform}" = "linux" ] || [ "${platform}" = "macos" ]; then
        if [ -f "install.sh" ] && [ ! -f "${package_dir}/install.sh" ]; then
            cp install.sh "${temp_dir}/"
        fi
        if [ -f "uninstall.sh" ] && [ ! -f "${package_dir}/uninstall.sh" ]; then
            cp uninstall.sh "${temp_dir}/"
        fi
    fi

    # Create ZIP archive
    cd /tmp
    zip -r "${package_name}.zip" "${package_name}" > /dev/null
    mv "${package_name}.zip" "${OLDPWD}/${RELEASE_DIR}/"
    cd "${OLDPWD}"

    # Clean up
    rm -rf "${temp_dir}"

    # Show file size
    local size=$(du -h "${RELEASE_DIR}/${package_name}.zip" | cut -f1)
    echo -e "${GREEN}✓ Created: ${package_name}.zip (${size})${NC}"
    echo ""
}

# Create packages for each platform
create_package "linux" "linux_package"
create_package "macos" "mac_package"
create_package "windows" "windows_package"

# Create checksums
echo -e "${YELLOW}Creating checksums...${NC}"
cd "${RELEASE_DIR}"
sha256sum *.zip > checksums.txt
cd - > /dev/null
echo -e "${GREEN}✓ Created checksums.txt${NC}"
echo ""

# Display summary
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Release packages created successfully!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Location: ${RELEASE_DIR}/"
echo ""
echo "Files created:"
ls -lh "${RELEASE_DIR}" | tail -n +2 | awk '{print "  - " $9 " (" $5 ")"}'
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Test the packages on each platform"
echo "  2. Create a git tag: git tag -a ${VERSION} -m 'Release ${VERSION}'"
echo "  3. Push the tag: git push origin ${VERSION}"
echo "  4. Go to GitHub and create a new Release"
echo "  5. Upload the ZIP files from ${RELEASE_DIR}/"
echo "  6. Copy the release notes from RELEASE_NOTES.md"
echo ""
