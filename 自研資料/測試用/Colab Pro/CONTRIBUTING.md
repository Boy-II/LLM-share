# 🤝 貢獻指南

感謝你對本項目的興趣！我們歡迎各種形式的貢獻。

---

## 🎯 貢獻方式

### 1. 報告問題（Bug Reports）

發現問題？請按以下格式提交 Issue：

```markdown
**問題描述**
簡要描述遇到的問題

**重現步驟**
1. 執行命令 xxx
2. 看到錯誤 xxx
3. ...

**預期行為**
應該發生什麼

**實際行為**
實際發生了什麼

**環境信息**
- 操作系統：macOS 14.1
- Python 版本：3.10.11
- ComfyUI 版本：（git commit hash）
- 腳本版本：1.0

**日誌輸出**
```bash
# 粘貼相關日誌
```

**截圖**（如果適用）
```

### 2. 功能建議（Feature Requests）

有好點子？請提交 Issue 並使用以下格式：

```markdown
**功能描述**
詳細描述你想要的功能

**使用場景**
這個功能解決什麼問題？

**建議實現**
如果有想法，可以簡述實現方式

**替代方案**
考慮過其他解決方案嗎？

**額外信息**
其他相關信息
```

### 3. 文檔改進

文檔有錯誤或不清楚？
- 修正拼寫/語法錯誤
- 改進說明清晰度
- 添加缺失的示例
- 翻譯成其他語言

### 4. 代碼貢獻

準備提交代碼？太棒了！

---

## 🔧 開發指南

### 準備工作

```bash
# 1. Fork 項目
# 2. Clone 到本地
git clone https://github.com/your-username/colab-pro.git
cd colab-pro

# 3. 創建新分支
git checkout -b feature/your-feature-name
# 或
git checkout -b fix/your-bug-fix
```

### 代碼規範

**Shell 腳本：**
```bash
#!/bin/bash

# 使用 set -e（遇到錯誤退出）
set -e

# 使用有意義的變量名
SNAPSHOT_NAME="comfyui_snapshot_${TIMESTAMP}.tar.gz"

# 添加註釋
# 檢查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "錯誤: 找不到配置文件"
    exit 1
fi

# 使用顏色輸出（如果適用）
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
```

**Python 腳本：**
```python
"""
模塊說明
"""

import os
import sys

def function_name(param: str) -> bool:
    """
    函數說明
    
    Args:
        param: 參數說明
        
    Returns:
        返回值說明
    """
    # 實現
    pass
```

### 測試

在提交之前，請測試你的修改：

```bash
# 1. 測試環境檢查
./0_check_environment.sh

# 2. 測試快照創建（使用測試環境）
./1_create_snapshot.sh

# 3. 驗證生成的文件
ls -lh snapshots/

# 4. 測試 Colab 筆記本（如果修改了）
# 在 Colab 中運行完整流程
```

### 提交代碼

```bash
# 1. 添加修改
git add .

# 2. 提交（使用清晰的提交信息）
git commit -m "feat: 添加 XXX 功能"
# 或
git commit -m "fix: 修復 XXX 問題"
# 或
git commit -m "docs: 更新 XXX 文檔"

# 3. 推送到 Fork
git push origin feature/your-feature-name

# 4. 創建 Pull Request
```

### Commit 訊息規範

使用以下前綴：

- `feat:` 新功能
- `fix:` Bug 修復
- `docs:` 文檔更新
- `style:` 代碼格式（不影響功能）
- `refactor:` 代碼重構
- `test:` 添加測試
- `chore:` 構建過程或輔助工具變更

**示例：**
```
feat: 添加 Hugging Face 上傳支持
fix: 修復快照文件大小檢查錯誤
docs: 更新 TROUBLESHOOTING.md 添加新問題
```

---

## 📝 Pull Request 指南

### PR 標題格式

```
[類型] 簡短描述

示例：
[Feature] 添加自動清理舊快照功能
[Fix] 修復 GitHub 上傳失敗問題
[Docs] 改進快速入門指南
```

### PR 描述模板

```markdown
## 變更類型
- [ ] Bug 修復
- [ ] 新功能
- [ ] 文檔更新
- [ ] 代碼重構
- [ ] 其他（請說明）

## 變更說明
詳細描述你的修改

## 相關 Issue
Fixes #123
Closes #456

## 測試
說明如何測試這些變更

## 檢查清單
- [ ] 代碼遵循項目規範
- [ ] 已添加必要的註釋
- [ ] 已更新相關文檔
- [ ] 已在本地測試
- [ ] 所有測試通過

## 截圖（如適用）
```

### 審核過程

1. 提交 PR 後，維護者會審核代碼
2. 可能會要求修改或提供更多信息
3. 審核通過後會合併到主分支

---

## 🎨 文檔貢獻

### 文檔結構

```
docs/
├── README.md           # 主文檔
├── QUICKSTART.md       # 快速開始
├── FILES.md            # 文件說明
├── TROUBLESHOOTING.md  # 故障排除
├── BEST_PRACTICES.md   # 最佳實踐
└── CONTRIBUTING.md     # 本文檔
```

### 文檔風格

- 使用清晰的標題層級
- 添加示例代碼
- 包含截圖（如果有幫助）
- 使用表格整理信息
- 添加提示和警告框

**示例：**
```markdown
### 功能說明

**用途：** 簡短說明

**使用方法：**
\```bash
# 命令示例
./script.sh
\```

**注意事項：**
⚠️ 重要提示

**示例：**
提供具體示例
```

---

## 🐛 Bug 修復流程

### 1. 確認問題

- 在 Issues 中搜索是否已有相同問題
- 重現問題並記錄步驟
- 確定問題的根本原因

### 2. 修復

- 創建分支：`fix/issue-number-description`
- 編寫修復代碼
- 添加註釋說明修復原因
- 更新相關文檔

### 3. 測試

```bash
# 測試修復是否有效
./test.sh

# 確保沒有引入新問題
./0_check_environment.sh
```

### 4. 提交

- 清晰的 commit 信息
- 在 PR 中引用 Issue
- 說明修復方法

---

## ✨ 新功能開發

### 1. 討論

在開始編碼前：
1. 在 Issues 中提出功能建議
2. 等待反饋和討論
3. 確認功能符合項目方向

### 2. 設計

- 考慮現有架構
- 保持代碼風格一致
- 確保向後兼容
- 更新配置示例

### 3. 實現

- 遵循代碼規範
- 添加充分的註釋
- 考慮錯誤處理
- 提供使用示例

### 4. 文檔

- 更新 README.md
- 添加到 QUICKSTART.md（如適用）
- 更新 CHANGELOG.md
- 考慮添加到 BEST_PRACTICES.md

---

## 📚 示例貢獻

### 示例 1: 添加新的排除規則

```yaml
# config.yaml
snapshot:
  exclude:
    - "models/*"
    - "output/*"
    - "*.pth"           # 新增：PyTorch 權重文件
    - "*.safetensors"   # 新增：SafeTensors 文件
```

**對應文檔更新：**
```markdown
# README.md 或 QUICKSTART.md

## 配置說明

### 排除規則
- `*.pth` - PyTorch 權重文件（通常很大）
- `*.safetensors` - SafeTensors 格式的模型文件
```

### 示例 2: 改進錯誤消息

**之前：**
```bash
echo "Error: File not found"
```

**之後：**
```bash
echo -e "${RED}❌ 錯誤: 找不到配置文件${NC}"
echo -e "${YELLOW}請確保 config.yaml 存在於項目目錄中${NC}"
echo -e "${BLUE}提示: 運行 ./init.sh 創建配置文件${NC}"
```

---

## ❓ 問題？

有疑問？可以：

1. **查看現有文檔**
   - README.md
   - TROUBLESHOOTING.md
   - BEST_PRACTICES.md

2. **搜索 Issues**
   - 可能已有人遇到相同問題

3. **提問**
   - 創建新 Issue
   - 使用 "Question" 標籤

4. **討論**
   - 在 GitHub Discussions 中討論

---

## 🎖️ 貢獻者

感謝所有貢獻者！

你的名字可能會出現在這裡：
- [contributor1] - 功能 X
- [contributor2] - 文檔改進
- [contributor3] - Bug 修復

---

## 📜 行為準則

### 我們的承諾

- 友善和尊重
- 接受建設性批評
- 專注於最佳解決方案
- 展現同理心

### 不可接受的行為

- 騷擾或攻擊性言論
- 發布他人隱私信息
- 其他不專業行為

---

## 📄 許可證

貢獻的代碼將使用項目的 MIT 許可證發布。

---

**感謝你的貢獻！** 🙏

每一個貢獻，無論大小，都讓這個項目變得更好。
