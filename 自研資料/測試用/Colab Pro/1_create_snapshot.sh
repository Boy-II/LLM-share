#!/bin/bash

##############################################
# ComfyUI 快照制作脚本
# 用途：打包本机 ComfyUI 环境为快照文件
##############################################

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.yaml"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   ComfyUI 快照制作工具${NC}"
echo -e "${BLUE}========================================${NC}\n"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ 错误: 找不到配置文件 config.yaml${NC}"
    echo -e "${YELLOW}请先编辑 config.yaml 文件并配置你的 ComfyUI 路径${NC}"
    exit 1
fi

# 读取配置（简单的 YAML 解析）
COMFYUI_PATH=$(grep "^comfyui_path:" "$CONFIG_FILE" | sed 's/.*: *"\(.*\)".*/\1/')

if [ -z "$COMFYUI_PATH" ] || [ "$COMFYUI_PATH" == "/path/to/your/ComfyUI" ]; then
    echo -e "${RED}❌ 错误: 请先在 config.yaml 中配置 comfyui_path${NC}"
    exit 1
fi

if [ ! -d "$COMFYUI_PATH" ]; then
    echo -e "${RED}❌ 错误: ComfyUI 目录不存在: $COMFYUI_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} 找到 ComfyUI 目录: ${COMFYUI_PATH}\n"

# 创建必要的目录
mkdir -p "${SCRIPT_DIR}/snapshots"
mkdir -p "${SCRIPT_DIR}/logs"

# 生成时间戳
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_TAG=$(date +"%Y%m%d")
SNAPSHOT_NAME="comfyui_snapshot_${TIMESTAMP}.tar.gz"
SNAPSHOT_PATH="${SCRIPT_DIR}/snapshots/${SNAPSHOT_NAME}"
LOG_FILE="${SCRIPT_DIR}/logs/snapshot_${TIMESTAMP}.log"

echo -e "${BLUE}📝 步骤 1/5: 导出依赖清单${NC}"
cd "$COMFYUI_PATH"

# 检查是否有虚拟环境
if [ -d "venv" ]; then
    echo "   检测到虚拟环境，激活中..."
    source venv/bin/activate
elif [ -d ".venv" ]; then
    echo "   检测到虚拟环境，激活中..."
    source .venv/bin/activate
fi

# 导出当前环境的所有依赖
echo "   导出 Python 依赖..."
if command -v pip &> /dev/null; then
    pip freeze > requirements_complete.txt
    echo -e "   ${GREEN}✓${NC} 已创建 requirements_complete.txt ($(wc -l < requirements_complete.txt) 个包)"
else
    echo -e "   ${YELLOW}⚠${NC}  警告: 未找到 pip，跳过依赖导出"
fi

echo -e "\n${BLUE}📝 步骤 2/5: 创建自定义节点清单${NC}"
# 创建节点清单
cat > custom_nodes_manifest.json << 'EOF'
{
  "created_at": "",
  "custom_nodes": []
}
EOF

# 使用 Python 脚本生成完整的节点清单
python3 << 'PYTHON_SCRIPT'
import os
import json
import subprocess
from datetime import datetime

manifest = {
    "created_at": datetime.now().isoformat(),
    "custom_nodes": []
}

custom_nodes_dir = "custom_nodes"
if os.path.exists(custom_nodes_dir):
    for node_name in os.listdir(custom_nodes_dir):
        node_path = os.path.join(custom_nodes_dir, node_name)
        if os.path.isdir(node_path) and os.path.exists(os.path.join(node_path, ".git")):
            try:
                # 获取 git 远程仓库地址
                result = subprocess.run(
                    ["git", "-C", node_path, "config", "--get", "remote.origin.url"],
                    capture_output=True, text=True, check=True
                )
                repo_url = result.stdout.strip()
                
                # 获取当前 commit hash
                result = subprocess.run(
                    ["git", "-C", node_path, "rev-parse", "HEAD"],
                    capture_output=True, text=True, check=True
                )
                commit_hash = result.stdout.strip()
                
                # 获取分支
                result = subprocess.run(
                    ["git", "-C", node_path, "rev-parse", "--abbrev-ref", "HEAD"],
                    capture_output=True, text=True, check=True
                )
                branch = result.stdout.strip()
                
                manifest["custom_nodes"].append({
                    "name": node_name,
                    "repo_url": repo_url,
                    "commit_hash": commit_hash,
                    "branch": branch,
                    "path": node_path
                })
                print(f"   ✓ {node_name}")
            except Exception as e:
                print(f"   ⚠ {node_name} (无法获取 git 信息)")

# 保存清单
with open("custom_nodes_manifest.json", "w") as f:
    json.dump(manifest, f, indent=2)

print(f"\n   发现 {len(manifest['custom_nodes'])} 个自定义节点")
PYTHON_SCRIPT

echo -e "\n${BLUE}📝 步骤 3/5: 创建快照元数据${NC}"
# 创建快照信息文件
cat > snapshot_info.json << EOF
{
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "hostname": "$(hostname)",
  "python_version": "$(python3 --version 2>&1 | cut -d' ' -f2)",
  "platform": "$(uname -s)",
  "architecture": "$(uname -m)",
  "snapshot_name": "${SNAPSHOT_NAME}",
  "comfyui_path": "${COMFYUI_PATH}",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'N/A')",
  "git_branch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
}
EOF

echo -e "   ${GREEN}✓${NC} 元数据已创建\n"

echo -e "${BLUE}📦 步骤 4/5: 打包 ComfyUI 环境${NC}"
echo "   这可能需要几分钟，请稍候..."

# 构建排除参数
EXCLUDE_ARGS=""
while IFS= read -r line; do
    # 移除 YAML 中的注释和空行
    line=$(echo "$line" | sed 's/#.*//' | xargs)
    if [ -n "$line" ] && [ "$line" != "-" ]; then
        # 移除前导的 "- " 和引号
        pattern=$(echo "$line" | sed 's/^- *//; s/^"//; s/"$//')
        if [ -n "$pattern" ]; then
            EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$pattern"
        fi
    fi
done < <(sed -n '/^  exclude:/,/^  [a-z]/p' "$CONFIG_FILE" | grep '^ *-')

# 打包（显示进度）
echo "   开始压缩..."
cd "$(dirname "$COMFYUI_PATH")"
COMFYUI_DIRNAME=$(basename "$COMFYUI_PATH")

# 使用 tar 打包并显示进度
tar -czf "$SNAPSHOT_PATH" \
    $EXCLUDE_ARGS \
    --exclude=".DS_Store" \
    "$COMFYUI_DIRNAME" 2>&1 | tee -a "$LOG_FILE"

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$SNAPSHOT_PATH" | cut -f1)
    echo -e "\n   ${GREEN}✓${NC} 快照已创建: ${SNAPSHOT_NAME}"
    echo -e "   文件大小: ${SIZE}"
else
    echo -e "\n   ${RED}✗${NC} 打包失败，请查看日志: ${LOG_FILE}"
    exit 1
fi

echo -e "\n${BLUE}📝 步骤 5/5: 创建符号链接${NC}"
# 创建 latest 符号链接
cd "${SCRIPT_DIR}/snapshots"
ln -sf "$SNAPSHOT_NAME" "comfyui_snapshot_latest.tar.gz"
echo -e "   ${GREEN}✓${NC} 已创建符号链接: comfyui_snapshot_latest.tar.gz\n"

# 生成版本说明文件
cat > "${SCRIPT_DIR}/snapshots/CHANGELOG_${DATE_TAG}.md" << EOF
# ComfyUI 快照 - ${DATE_TAG}

## 基本信息
- **创建时间**: $(date)
- **快照文件**: ${SNAPSHOT_NAME}
- **文件大小**: ${SIZE}

## 环境信息
- **Python 版本**: $(python3 --version 2>&1)
- **平台**: $(uname -s) $(uname -m)
- **ComfyUI 路径**: ${COMFYUI_PATH}

## 自定义节点
$(python3 << 'PYTHON_SCRIPT'
import json
with open("${COMFYUI_PATH}/custom_nodes_manifest.json", "r") as f:
    manifest = json.load(f)
    for node in manifest["custom_nodes"]:
        print(f"- **{node['name']}**")
        print(f"  - Repository: {node['repo_url']}")
        print(f"  - Branch: {node['branch']}")
        print(f"  - Commit: {node['commit_hash'][:8]}")
PYTHON_SCRIPT
)

## 使用方法

### 在 Colab 中下载
\`\`\`python
# 从 GitHub Release 下载
!wget https://github.com/YOUR-USERNAME/comfyui-snapshot/releases/download/v${DATE_TAG}/${SNAPSHOT_NAME}

# 解压
!tar -xzf ${SNAPSHOT_NAME} -C /content/drive/MyDrive/
\`\`\`

### 手动部署
1. 下载快照文件
2. 上传到 Google Drive
3. 在 Colab 中运行提供的笔记本

---
EOF

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 快照创建完成！${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}📄 快照信息:${NC}"
echo -e "   文件名: ${SNAPSHOT_NAME}"
echo -e "   路径: ${SNAPSHOT_PATH}"
echo -e "   大小: ${SIZE}"
echo -e "   日志: ${LOG_FILE}"
echo -e "   变更日志: ${SCRIPT_DIR}/snapshots/CHANGELOG_${DATE_TAG}.md\n"

echo -e "${BLUE}📤 下一步:${NC}"
echo -e "   1. 查看快照内容（可选）:"
echo -e "      ${YELLOW}tar -tzf ${SNAPSHOT_PATH} | head -n 20${NC}\n"
echo -e "   2. 上传到 GitHub Release:"
echo -e "      ${YELLOW}./2_upload_to_github.sh${NC}\n"
echo -e "   3. 或手动上传到 Google Drive\n"

# 提示检查文件大小
SIZE_MB=$(du -m "$SNAPSHOT_PATH" | cut -f1)
if [ $SIZE_MB -gt 2000 ]; then
    echo -e "${YELLOW}⚠️  警告: 快照文件大小超过 2GB (${SIZE})"
    echo -e "   GitHub Release 限制为 2GB，建议:"
    echo -e "   - 使用 Hugging Face（无大小限制）"
    echo -e "   - 或进一步优化排除规则${NC}\n"
fi

echo -e "${GREEN}完成！${NC}\n"
