#!/bin/bash

##############################################
# 环境检查脚本
# 用途：检查所需工具和配置是否正确
##############################################

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.yaml"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   环境检查工具${NC}"
echo -e "${BLUE}========================================${NC}\n"

ERRORS=0
WARNINGS=0

# 检查配置文件
echo -e "${BLUE}📝 检查配置文件...${NC}"
if [ -f "$CONFIG_FILE" ]; then
    echo -e "   ${GREEN}✓${NC} config.yaml 存在"
    
    # 读取配置
    COMFYUI_PATH=$(grep "^comfyui_path:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')
    GITHUB_USER=$(grep "^  username:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')
    GITHUB_REPO=$(grep "^  repo:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')
    
    # 检查 ComfyUI 路径
    if [ -z "$COMFYUI_PATH" ] || [ "$COMFYUI_PATH" == "/path/to/your/ComfyUI" ]; then
        echo -e "   ${RED}✗${NC} comfyui_path 未配置"
        ERRORS=$((ERRORS + 1))
    elif [ ! -d "$COMFYUI_PATH" ]; then
        echo -e "   ${RED}✗${NC} ComfyUI 目录不存在: $COMFYUI_PATH"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "   ${GREEN}✓${NC} ComfyUI 路径: $COMFYUI_PATH"
    fi
    
    # 检查 GitHub 配置
    if [ -z "$GITHUB_USER" ] || [ "$GITHUB_USER" == "your-github-username" ]; then
        echo -e "   ${YELLOW}⚠${NC}  GitHub username 未配置"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "   ${GREEN}✓${NC} GitHub 用户: $GITHUB_USER"
    fi
    
    if [ -z "$GITHUB_REPO" ]; then
        echo -e "   ${YELLOW}⚠${NC}  GitHub repo 未配置"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "   ${GREEN}✓${NC} GitHub 仓库: $GITHUB_REPO"
    fi
else
    echo -e "   ${RED}✗${NC} config.yaml 不存在"
    ERRORS=$((ERRORS + 1))
fi

# 检查必需工具
echo -e "\n${BLUE}🛠️  检查必需工具...${NC}"

# Python
if command -v python3 &> /dev/null; then
    PY_VERSION=$(python3 --version)
    echo -e "   ${GREEN}✓${NC} $PY_VERSION"
else
    echo -e "   ${RED}✗${NC} Python 3 未安装"
    ERRORS=$((ERRORS + 1))
fi

# Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "   ${GREEN}✓${NC} $GIT_VERSION"
else
    echo -e "   ${RED}✗${NC} Git 未安装"
    ERRORS=$((ERRORS + 1))
fi

# tar
if command -v tar &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} tar 已安装"
else
    echo -e "   ${RED}✗${NC} tar 未安装"
    ERRORS=$((ERRORS + 1))
fi

# GitHub CLI（可选）
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1)
    echo -e "   ${GREEN}✓${NC} $GH_VERSION"
    
    # 检查登录状态
    if gh auth status &> /dev/null; then
        echo -e "   ${GREEN}✓${NC} GitHub CLI 已登录"
    else
        echo -e "   ${YELLOW}⚠${NC}  GitHub CLI 未登录（运行: gh auth login）"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "   ${YELLOW}⚠${NC}  GitHub CLI 未安装（建议安装: brew install gh）"
    WARNINGS=$((WARNINGS + 1))
fi

# 检查 ComfyUI 环境
if [ -n "$COMFYUI_PATH" ] && [ -d "$COMFYUI_PATH" ]; then
    echo -e "\n${BLUE}🎨 检查 ComfyUI 环境...${NC}"
    
    # 检查主文件
    if [ -f "$COMFYUI_PATH/main.py" ]; then
        echo -e "   ${GREEN}✓${NC} main.py 存在"
    else
        echo -e "   ${RED}✗${NC} main.py 不存在"
        ERRORS=$((ERRORS + 1))
    fi
    
    # 检查 requirements.txt
    if [ -f "$COMFYUI_PATH/requirements.txt" ]; then
        echo -e "   ${GREEN}✓${NC} requirements.txt 存在"
    else
        echo -e "   ${YELLOW}⚠${NC}  requirements.txt 不存在"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # 检查自定义节点
    if [ -d "$COMFYUI_PATH/custom_nodes" ]; then
        NODE_COUNT=$(find "$COMFYUI_PATH/custom_nodes" -maxdepth 1 -type d | wc -l)
        NODE_COUNT=$((NODE_COUNT - 1))  # 减去 custom_nodes 自己
        echo -e "   ${GREEN}✓${NC} 自定义节点目录存在 (${NODE_COUNT} 个节点)"
    else
        echo -e "   ${YELLOW}⚠${NC}  自定义节点目录不存在"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # 检查 Git 仓库
    if [ -d "$COMFYUI_PATH/.git" ]; then
        echo -e "   ${GREEN}✓${NC} Git 仓库已初始化"
    else
        echo -e "   ${YELLOW}⚠${NC}  不是 Git 仓库（某些功能可能受限）"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 检查目录结构
echo -e "\n${BLUE}📁 检查项目目录...${NC}"

if [ -d "${SCRIPT_DIR}/snapshots" ]; then
    echo -e "   ${GREEN}✓${NC} snapshots 目录存在"
else
    echo -e "   ${YELLOW}⚠${NC}  snapshots 目录不存在（首次运行会自动创建）"
fi

if [ -d "${SCRIPT_DIR}/logs" ]; then
    echo -e "   ${GREEN}✓${NC} logs 目录存在"
else
    echo -e "   ${YELLOW}⚠${NC}  logs 目录不存在（首次运行会自动创建）"
fi

# 检查脚本权限
echo -e "\n${BLUE}🔐 检查脚本权限...${NC}"

for script in "1_create_snapshot.sh" "2_upload_to_github.sh" "0_check_environment.sh"; do
    if [ -f "${SCRIPT_DIR}/${script}" ]; then
        if [ -x "${SCRIPT_DIR}/${script}" ]; then
            echo -e "   ${GREEN}✓${NC} ${script} 可执行"
        else
            echo -e "   ${YELLOW}⚠${NC}  ${script} 不可执行（运行: chmod +x ${script}）"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# 总结
echo -e "\n${BLUE}========================================${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 环境检查通过！${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    echo -e "${BLUE}📌 下一步:${NC}"
    echo -e "   1. 确认 config.yaml 配置正确"
    echo -e "   2. 运行: ${YELLOW}./1_create_snapshot.sh${NC}"
    echo -e "   3. 运行: ${YELLOW}./2_upload_to_github.sh${NC}\n"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  环境检查完成，但有 ${WARNINGS} 个警告${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    echo -e "${YELLOW}警告不会阻止脚本运行，但建议修复以获得最佳体验。${NC}\n"
else
    echo -e "${RED}❌ 环境检查失败！${NC}"
    echo -e "${RED}   发现 ${ERRORS} 个错误和 ${WARNINGS} 个警告${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    echo -e "${RED}请修复上述错误后再运行脚本。${NC}\n"
    exit 1
fi
