#!/bin/bash

##############################################
# GitHub Release 上传脚本
# 用途：将快照上传到 GitHub Release
##############################################

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.yaml"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   GitHub Release 上传工具${NC}"
echo -e "${BLUE}========================================${NC}\n"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ 错误: 找不到配置文件${NC}"
    exit 1
fi

# 读取配置
GITHUB_USER=$(grep "^  username:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')
GITHUB_REPO=$(grep "^  repo:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')

if [ -z "$GITHUB_USER" ] || [ "$GITHUB_USER" == "your-github-username" ]; then
    echo -e "${RED}❌ 错误: 请先在 config.yaml 中配置 GitHub 用户名${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} GitHub 用户: ${GITHUB_USER}"
echo -e "${GREEN}✓${NC} GitHub 仓库: ${GITHUB_REPO}\n"

# 检查是否安装了 gh CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  未检测到 GitHub CLI (gh)${NC}\n"
    echo -e "请选择安装方式:\n"
    echo -e "1. Homebrew (推荐):"
    echo -e "   ${BLUE}brew install gh${NC}\n"
    echo -e "2. 手动下载:"
    echo -e "   ${BLUE}https://github.com/cli/cli/releases${NC}\n"
    
    read -p "是否现在使用 Homebrew 安装? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\n${BLUE}正在安装 GitHub CLI...${NC}"
        brew install gh
    else
        echo -e "${RED}已取消${NC}"
        exit 1
    fi
fi

# 检查是否已登录
echo -e "${BLUE}检查 GitHub 登录状态...${NC}"
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}未登录 GitHub，开始登录流程...${NC}\n"
    gh auth login
else
    echo -e "${GREEN}✓${NC} 已登录 GitHub\n"
fi

# 查找最新的快照
SNAPSHOT_DIR="${SCRIPT_DIR}/snapshots"
if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo -e "${RED}❌ 错误: 快照目录不存在${NC}"
    echo -e "请先运行: ${YELLOW}./1_create_snapshot.sh${NC}"
    exit 1
fi

# 获取最新快照（排除符号链接）
LATEST_SNAPSHOT=$(ls -t "$SNAPSHOT_DIR"/comfyui_snapshot_*.tar.gz 2>/dev/null | grep -v "latest" | head -1)

if [ -z "$LATEST_SNAPSHOT" ]; then
    echo -e "${RED}❌ 错误: 未找到快照文件${NC}"
    echo -e "请先运行: ${YELLOW}./1_create_snapshot.sh${NC}"
    exit 1
fi

SNAPSHOT_NAME=$(basename "$LATEST_SNAPSHOT")
SNAPSHOT_SIZE=$(du -h "$LATEST_SNAPSHOT" | cut -f1)
DATE_TAG=$(echo "$SNAPSHOT_NAME" | grep -oE "[0-9]{8}" | head -1)

echo -e "${BLUE}📦 找到快照文件:${NC}"
echo -e "   名称: ${SNAPSHOT_NAME}"
echo -e "   大小: ${SNAPSHOT_SIZE}"
echo -e "   路径: ${LATEST_SNAPSHOT}\n"

# 检查文件大小警告
SIZE_MB=$(du -m "$LATEST_SNAPSHOT" | cut -f1)
if [ $SIZE_MB -gt 2000 ]; then
    echo -e "${YELLOW}⚠️  警告: 文件大小超过 2GB！${NC}"
    echo -e "GitHub Release 限制为 2GB，上传可能失败。"
    echo -e "建议使用 Hugging Face 替代。\n"
    read -p "是否继续? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消${NC}"
        exit 0
    fi
fi

# 生成版本标签
VERSION_TAG="v${DATE_TAG}"

echo -e "${BLUE}📝 Release 信息:${NC}"
echo -e "   版本标签: ${VERSION_TAG}"
echo -e "   仓库: ${GITHUB_USER}/${GITHUB_REPO}\n"

# 读取变更日志
CHANGELOG_FILE="${SNAPSHOT_DIR}/CHANGELOG_${DATE_TAG}.md"
if [ -f "$CHANGELOG_FILE" ]; then
    RELEASE_NOTES=$(cat "$CHANGELOG_FILE")
else
    RELEASE_NOTES="ComfyUI 快照 - ${DATE_TAG}

## 快照信息
- 文件名: ${SNAPSHOT_NAME}
- 文件大小: ${SNAPSHOT_SIZE}
- 创建时间: $(date)

## 使用方法
下载快照并在 Google Colab 中解压使用。详见项目 README。
"
fi

# 确认上传
echo -e "${YELLOW}即将创建 Release 并上传快照...${NC}"
read -p "确认继续? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}已取消${NC}"
    exit 0
fi

echo -e "\n${BLUE}🚀 开始上传...${NC}\n"

# 检查仓库是否存在
echo "检查仓库..."
if ! gh repo view "${GITHUB_USER}/${GITHUB_REPO}" &> /dev/null; then
    echo -e "${YELLOW}仓库不存在，正在创建...${NC}"
    
    read -p "创建私有仓库? (y/n, 默认 y): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        REPO_VISIBILITY="public"
    else
        REPO_VISIBILITY="private"
    fi
    
    gh repo create "${GITHUB_USER}/${GITHUB_REPO}" \
        --${REPO_VISIBILITY} \
        --description "ComfyUI environment snapshots for Google Colab" \
        --confirm
    
    echo -e "${GREEN}✓${NC} 仓库已创建\n"
fi

# 检查是否已存在相同版本的 Release
if gh release view "$VERSION_TAG" -R "${GITHUB_USER}/${GITHUB_REPO}" &> /dev/null; then
    echo -e "${YELLOW}⚠️  版本 ${VERSION_TAG} 已存在${NC}"
    read -p "是否删除现有版本并重新创建? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "删除现有版本..."
        gh release delete "$VERSION_TAG" -R "${GITHUB_USER}/${GITHUB_REPO}" -y
    else
        echo -e "${YELLOW}已取消${NC}"
        exit 0
    fi
fi

# 创建 Release 并上传文件
echo -e "创建 Release: ${VERSION_TAG}..."
gh release create "$VERSION_TAG" \
    "$LATEST_SNAPSHOT" \
    -R "${GITHUB_USER}/${GITHUB_REPO}" \
    --title "ComfyUI Snapshot - ${DATE_TAG}" \
    --notes "$RELEASE_NOTES"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 上传成功！${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    # 获取下载 URL
    DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/download/${VERSION_TAG}/${SNAPSHOT_NAME}"
    
    echo -e "${BLUE}📦 Release 信息:${NC}"
    echo -e "   版本: ${VERSION_TAG}"
    echo -e "   仓库: https://github.com/${GITHUB_USER}/${GITHUB_REPO}"
    echo -e "   Release: https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${VERSION_TAG}\n"
    
    echo -e "${BLUE}📥 下载 URL:${NC}"
    echo -e "   ${DOWNLOAD_URL}\n"
    
    # 生成 Colab 代码片段
    echo -e "${BLUE}💡 在 Colab 中使用（复制以下代码）:${NC}\n"
    echo -e "${YELLOW}# 下载快照"
    echo -e "!wget \"${DOWNLOAD_URL}\" -O /tmp/comfyui.tar.gz"
    echo -e ""
    echo -e "# 解压到 Google Drive"
    echo -e "!mkdir -p /content/drive/MyDrive/ComfyUI"
    echo -e "!tar -xzf /tmp/comfyui.tar.gz -C /content/drive/MyDrive/"
    echo -e "!rm /tmp/comfyui.tar.gz${NC}\n"
    
    # 保存信息到文件
    INFO_FILE="${SNAPSHOT_DIR}/release_info_${DATE_TAG}.txt"
    cat > "$INFO_FILE" << EOF
GitHub Release 信息
==================

版本标签: ${VERSION_TAG}
创建时间: $(date)
仓库: ${GITHUB_USER}/${GITHUB_REPO}
快照文件: ${SNAPSHOT_NAME}
文件大小: ${SNAPSHOT_SIZE}

Release URL:
https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${VERSION_TAG}

下载 URL:
${DOWNLOAD_URL}

Colab 使用代码:
--------------
# 下载并解压
!wget "${DOWNLOAD_URL}" -O /tmp/comfyui.tar.gz
!mkdir -p /content/drive/MyDrive/ComfyUI
!tar -xzf /tmp/comfyui.tar.gz -C /content/drive/MyDrive/
!rm /tmp/comfyui.tar.gz
EOF
    
    echo -e "${GREEN}✓${NC} Release 信息已保存到: ${INFO_FILE}\n"
    
else
    echo -e "\n${RED}❌ 上传失败${NC}"
    echo -e "请检查:"
    echo -e "  1. GitHub 登录状态: ${YELLOW}gh auth status${NC}"
    echo -e "  2. 仓库权限"
    echo -e "  3. 网络连接\n"
    exit 1
fi

echo -e "${BLUE}下一步:${NC}"
echo -e "   打开 Colab 笔记本 ${YELLOW}3_colab_quick_start.ipynb${NC}"
echo -e "   更新其中的下载 URL 为上面的 URL\n"
