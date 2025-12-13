#!/bin/bash

##############################################
# 最終驗證腳本
# 用途：驗證所有文件是否完整
##############################################

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   項目完整性驗證${NC}"
echo -e "${BLUE}========================================${NC}\n"

TOTAL=0
PASSED=0
FAILED=0

check_file() {
    local file=$1
    local description=$2
    TOTAL=$((TOTAL + 1))
    
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "   ${GREEN}✓${NC} $description"
        PASSED=$((PASSED + 1))
    else
        echo -e "   ${RED}✗${NC} $description ${RED}(缺失)${NC}"
        FAILED=$((FAILED + 1))
    fi
}

check_executable() {
    local file=$1
    local description=$2
    TOTAL=$((TOTAL + 1))
    
    if [ -f "$SCRIPT_DIR/$file" ]; then
        if [ -x "$SCRIPT_DIR/$file" ]; then
            echo -e "   ${GREEN}✓${NC} $description ${GREEN}(可執行)${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "   ${YELLOW}⚠${NC}  $description ${YELLOW}(需要執行權限)${NC}"
            echo -e "      修復: ${BLUE}chmod +x $file${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "   ${RED}✗${NC} $description ${RED}(缺失)${NC}"
        FAILED=$((FAILED + 1))
    fi
}

echo -e "${BLUE}📚 文檔文件:${NC}"
check_file "README.md" "主文檔"
check_file "QUICKSTART.md" "快速入門指南"
check_file "FILES.md" "文件說明"
check_file "CHANGELOG.md" "版本變更記錄"
check_file "TROUBLESHOOTING.md" "故障排除指南"
check_file "BEST_PRACTICES.md" "最佳實踐指南"
check_file "CONTRIBUTING.md" "貢獻指南"
check_file "PROJECT_SUMMARY.md" "項目總結"
check_file "LICENSE" "許可證"

echo -e "\n${BLUE}🔧 腳本文件:${NC}"
check_executable "START_HERE.sh" "快速開始腳本"
check_executable "init.sh" "初始化向導"
check_executable "0_check_environment.sh" "環境檢查"
check_executable "1_create_snapshot.sh" "快照創建"
check_executable "2_upload_to_github.sh" "GitHub 上傳"
check_executable "verify_installation.sh" "本驗證腳本"

echo -e "\n${BLUE}⚙️  配置文件:${NC}"
check_file "config.yaml" "配置文件"
check_file ".gitignore" "Git 忽略規則"

echo -e "\n${BLUE}📓 Colab 文件:${NC}"
check_file "3_colab_quick_start.ipynb" "Colab 筆記本"

echo -e "\n${BLUE}📁 目錄結構:${NC}"
TOTAL=$((TOTAL + 2))
if [ -d "$SCRIPT_DIR/snapshots" ]; then
    echo -e "   ${GREEN}✓${NC} snapshots 目錄"
    PASSED=$((PASSED + 1))
else
    echo -e "   ${YELLOW}⚠${NC}  snapshots 目錄 ${YELLOW}(將自動創建)${NC}"
    mkdir -p "$SCRIPT_DIR/snapshots"
    PASSED=$((PASSED + 1))
fi

if [ -d "$SCRIPT_DIR/logs" ]; then
    echo -e "   ${GREEN}✓${NC} logs 目錄"
    PASSED=$((PASSED + 1))
else
    echo -e "   ${YELLOW}⚠${NC}  logs 目錄 ${YELLOW}(將自動創建)${NC}"
    mkdir -p "$SCRIPT_DIR/logs"
    PASSED=$((PASSED + 1))
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}驗證結果${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "總檢查項: $TOTAL"
echo -e "${GREEN}通過: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}失敗: $FAILED${NC}"
fi

echo -e "\n"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 項目完整性驗證通過！${NC}\n"
    echo -e "${BLUE}📌 下一步操作:${NC}"
    echo -e "   1. 運行初始化向導: ${YELLOW}./init.sh${NC}"
    echo -e "   2. 或查看快速開始: ${YELLOW}./START_HERE.sh${NC}"
    echo -e "   3. 或直接開始: ${YELLOW}./1_create_snapshot.sh${NC}\n"
    exit 0
else
    echo -e "${RED}❌ 發現 $FAILED 個問題${NC}\n"
    echo -e "${YELLOW}請檢查並修復上述問題後再次運行驗證。${NC}\n"
    exit 1
fi
