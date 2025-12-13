#!/bin/bash

##############################################
# 一键初始化脚本
# 用途：帮助新用户快速配置环境
##############################################

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear

echo -e "${BLUE}"
echo "========================================"
echo "   ComfyUI Colab 快照工具 - 初始化向导"
echo "========================================"
echo -e "${NC}\n"

echo "欢迎使用 ComfyUI Colab 快照工具！"
echo "此向导将帮助你完成初始配置。\n"

read -p "按 Enter 继续..."
clear

# 步骤 1: 配置 ComfyUI 路径
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}步骤 1/4: 配置 ComfyUI 路径${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo "请输入你本机 ComfyUI 的完整路径"
echo "例如: /Users/yourname/ComfyUI"
echo ""
read -p "ComfyUI 路径: " COMFYUI_PATH

# 验证路径
if [ ! -d "$COMFYUI_PATH" ]; then
    echo -e "\n${RED}错误: 目录不存在！${NC}"
    echo "请检查路径是否正确"
    exit 1
fi

if [ ! -f "$COMFYUI_PATH/main.py" ]; then
    echo -e "\n${YELLOW}警告: 未找到 main.py，这可能不是一个有效的 ComfyUI 目录${NC}"
    read -p "是否继续? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo -e "\n${GREEN}✓${NC} ComfyUI 路径已确认\n"

# 步骤 2: 配置 GitHub
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}步骤 2/4: 配置 GitHub${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo "请输入你的 GitHub 用户名"
read -p "GitHub 用户名: " GITHUB_USER

echo ""
echo "请输入用于存储快照的仓库名称"
echo "（如果不存在，脚本会自动创建）"
read -p "仓库名称 (默认: comfyui-snapshot): " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-comfyui-snapshot}

echo -e "\n${GREEN}✓${NC} GitHub 配置完成\n"

# 步骤 3: 写入配置文件
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}步骤 3/4: 保存配置${NC}"
echo -e "${BLUE}========================================${NC}\n"

cat > "${SCRIPT_DIR}/config.yaml" << EOF
# ComfyUI 快照配置文件
# 由初始化向导自动生成

# ============================================
# ComfyUI 本机路径配置
# ============================================
comfyui_path: "${COMFYUI_PATH}"

# ============================================
# GitHub 配置
# ============================================
github:
  username: "${GITHUB_USER}"
  repo: "${GITHUB_REPO}"
  token: ""  # 可选，使用 gh CLI 登录即可

# ============================================
# 快照配置
# ============================================
snapshot:
  output_dir: "./snapshots"
  
  exclude:
    - "models/*"
    - "output/*"
    - "input/*"
    - "temp/*"
    - ".git"
    - ".git/*"
    - "__pycache__"
    - "__pycache__/*"
    - "*.pyc"
    - "*.pyo"
    - ".DS_Store"
    - "*.log"
    - ".venv"
    - ".venv/*"
    - "venv"
    - "venv/*"
  
  include:
    - "models/.gitkeep"
    - "output/.gitkeep"
    - "input/.gitkeep"
  
  compression_level: 6

# ============================================
# Hugging Face 配置（可选）
# ============================================
huggingface:
  enabled: false
  username: ""
  repo: "${GITHUB_REPO}"
  token: ""

# ============================================
# 日志配置
# ============================================
logging:
  enabled: true
  log_dir: "./logs"
  log_level: "INFO"

# ============================================
# Colab 配置
# ============================================
colab:
  drive_mount_path: "/content/drive"
  drive_comfyui_path: "/content/drive/MyDrive/ComfyUI"
  port: 8188
  launch_args:
    - "--listen"
    - "0.0.0.0"
    - "--port"
    - "8188"

# ============================================
# 通知配置（可选）
# ============================================
notifications:
  enabled: false
  slack_webhook: ""
  discord_webhook: ""
  email:
    enabled: false
    smtp_server: "smtp.gmail.com"
    smtp_port: 587
    from_address: ""
    to_address: ""
    password: ""
EOF

echo -e "${GREEN}✓${NC} 配置文件已保存: config.yaml\n"

# 步骤 4: 检查依赖
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}步骤 4/4: 检查依赖${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo "正在检查所需工具..."
echo ""

MISSING_TOOLS=()

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗${NC} Python 3 未安装"
    MISSING_TOOLS+=("python3")
else
    echo -e "${GREEN}✓${NC} Python 3 已安装"
fi

# 检查 Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗${NC} Git 未安装"
    MISSING_TOOLS+=("git")
else
    echo -e "${GREEN}✓${NC} Git 已安装"
fi

# 检查 GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}  GitHub CLI 未安装（推荐）"
    echo ""
    read -p "是否现在安装 GitHub CLI? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            echo "使用 Homebrew 安装..."
            brew install gh
            echo -e "${GREEN}✓${NC} GitHub CLI 已安装"
        else
            echo -e "${YELLOW}未检测到 Homebrew${NC}"
            echo "请访问 https://cli.github.com/ 手动安装"
        fi
    fi
else
    echo -e "${GREEN}✓${NC} GitHub CLI 已安装"
    
    # 检查登录状态
    if gh auth status &> /dev/null; then
        echo -e "${GREEN}✓${NC} GitHub CLI 已登录"
    else
        echo ""
        echo -e "${YELLOW}GitHub CLI 未登录${NC}"
        read -p "是否现在登录? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
        fi
    fi
fi

echo ""

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${RED}缺少以下工具: ${MISSING_TOOLS[*]}${NC}"
    echo "请安装这些工具后再继续"
    exit 1
fi

# 创建必要的目录
echo "创建目录结构..."
mkdir -p "${SCRIPT_DIR}/snapshots"
mkdir -p "${SCRIPT_DIR}/logs"
echo -e "${GREEN}✓${NC} 目录结构已创建\n"

# 完成
clear
echo -e "${GREEN}"
echo "========================================"
echo "   ✅ 初始化完成！"
echo "========================================"
echo -e "${NC}\n"

echo -e "${BLUE}📋 配置摘要:${NC}"
echo "   ComfyUI 路径: ${COMFYUI_PATH}"
echo "   GitHub 用户: ${GITHUB_USER}"
echo "   GitHub 仓库: ${GITHUB_REPO}"
echo ""

echo -e "${BLUE}📌 下一步操作:${NC}\n"
echo "1️⃣  运行环境检查（推荐）:"
echo -e "   ${YELLOW}./0_check_environment.sh${NC}\n"
echo "2️⃣  创建第一个快照:"
echo -e "   ${YELLOW}./1_create_snapshot.sh${NC}\n"
echo "3️⃣  上传到 GitHub:"
echo -e "   ${YELLOW}./2_upload_to_github.sh${NC}\n"
echo "4️⃣  在 Colab 中使用:"
echo "   - 打开 3_colab_quick_start.ipynb"
echo "   - 上传到 Google Colab"
echo "   - 修改 SNAPSHOT_URL"
echo "   - 运行所有单元格"
echo ""

echo -e "${BLUE}📚 文档:${NC}"
echo "   - README.md - 完整文档"
echo "   - QUICKSTART.md - 快速入门"
echo "   - CHANGELOG.md - 版本记录"
echo ""

read -p "按 Enter 退出..."
