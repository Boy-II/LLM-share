# 🔧 故障排除指南

本文檔列出常見問題及解決方案。

---

## 🚨 快照創建問題

### 問題 1: 快照文件太大（>2GB）

**症狀：**
```
快照文件大小: 2.3GB
警告: GitHub Release 限制為 2GB
```

**解決方案：**

**方法 1: 優化排除規則**
```bash
# 編輯 config.yaml，添加更多排除項
nano config.yaml

# 常見的大文件目錄：
exclude:
  - "models/*"              # 所有模型
  - "output/*"              # 輸出文件
  - "input/*"               # 輸入文件
  - ".git"                  # Git 歷史
  - "*.pth"                 # PyTorch 權重
  - "*.safetensors"         # 模型權重
  - "*.ckpt"                # Checkpoint
  - "venv/*"                # 虛擬環境
  - "__pycache__/*"         # Python 緩存
```

**方法 2: 使用 Hugging Face**
```yaml
# 在 config.yaml 中啟用 HF
huggingface:
  enabled: true
  username: "your-username"
  repo: "comfyui-snapshot"
```

**方法 3: 分割壓縮包**
```bash
# 創建分割壓縮包（每個 1.5GB）
cd snapshots
split -b 1500M comfyui_snapshot_latest.tar.gz "snapshot_part_"
```

### 問題 2: 找不到 ComfyUI 目錄

**症狀：**
```
❌ 錯誤: ComfyUI 目錄不存在: /path/to/your/ComfyUI
```

**解決方案：**
```bash
# 1. 確認 ComfyUI 實際路徑
ls -la /Users/yourname/ComfyUI

# 2. 編輯 config.yaml
nano config.yaml

# 3. 更新正確路徑
comfyui_path: "/正確/的/路徑/ComfyUI"

# 4. 重新運行環境檢查
./0_check_environment.sh
```

### 問題 3: 依賴導出失敗

**症狀：**
```
⚠️ 警告: 未找到 pip，跳過依賴導出
```

**解決方案：**
```bash
# 1. 確保在正確的虛擬環境中
cd /path/to/ComfyUI
source venv/bin/activate  # 或 source .venv/bin/activate

# 2. 驗證 pip
which pip
pip --version

# 3. 重新運行快照創建
./1_create_snapshot.sh
```

---

## 🐙 GitHub 上傳問題

### 問題 1: GitHub CLI 未登錄

**症狀：**
```
❌ 錯誤: GitHub CLI 未登錄
```

**解決方案：**
```bash
# 登錄 GitHub CLI
gh auth login

# 選擇選項：
# 1. GitHub.com
# 2. HTTPS
# 3. Login with a web browser
# 4. 按照瀏覽器提示完成登錄

# 驗證登錄狀態
gh auth status
```

### 問題 2: 權限被拒絕

**症狀：**
```
HTTP 403: Resource not accessible by integration
```

**解決方案：**
```bash
# 1. 檢查 Token 權限
gh auth refresh -s repo

# 2. 或重新登錄
gh auth logout
gh auth login

# 3. 確保勾選了 "repo" 權限
```

### 問題 3: Release 已存在

**症狀：**
```
⚠️ 版本 v20250104 已存在
```

**解決方案：**
```bash
# 選項 1: 刪除並重新創建（腳本會提示）
# 選項 2: 手動刪除
gh release delete v20250104 -R username/repo -y

# 選項 3: 創建新版本（修改日期）
./1_create_snapshot.sh  # 會生成新的時間戳
```

### 問題 4: 上傳速度慢

**解決方案：**
```bash
# 1. 使用代理（如果需要）
export https_proxy=http://127.0.0.1:7890

# 2. 或使用 GitHub Desktop 上傳
# 下載: https://desktop.github.com/

# 3. 或使用 Git LFS
git lfs install
git lfs track "*.tar.gz"
```

---

## 🚀 Colab 部署問題

### 問題 1: 下載失敗

**症狀：**
```python
❌ 下載失敗！請檢查 URL
```

**解決方案：**

**檢查 1: URL 是否正確**
```python
# 正確格式
SNAPSHOT_URL = "https://github.com/username/repo/releases/download/v20250104/comfyui_snapshot_20250104.tar.gz"

# 錯誤格式（缺少 /download/）
❌ "https://github.com/username/repo/releases/v20250104/..."
```

**檢查 2: Release 是否公開**
```bash
# 在本機確認 Release 可訪問
curl -I "https://github.com/username/repo/releases/download/v20250104/snapshot.tar.gz"

# 應該返回 200 或 302
```

**檢查 3: 使用直接鏈接**
```python
# 從 GitHub Release 頁面複製直接下載鏈接
# 右鍵點擊下載按鈕 -> 複製鏈接地址
```

### 問題 2: 解壓失敗

**症狀：**
```
tar: Error is not recoverable: exiting now
```

**解決方案：**
```python
# 檢查下載的文件
!ls -lh /tmp/comfyui_snapshot.tar.gz
!file /tmp/comfyui_snapshot.tar.gz

# 如果文件損壞，重新下載
!rm /tmp/comfyui_snapshot.tar.gz
!wget "{SNAPSHOT_URL}" -O /tmp/comfyui_snapshot.tar.gz

# 驗證文件完整性（如果有 checksum）
!sha256sum /tmp/comfyui_snapshot.tar.gz
```

### 問題 3: CUDA 版本不匹配

**症狀：**
```python
RuntimeError: CUDA error: no kernel image is available
```

**解決方案：**
```python
# 檢查 Colab 的 CUDA 版本
!nvcc --version

# CUDA 11.8
!pip uninstall torch torchvision torchaudio -y
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1
!pip uninstall torch torchvision torchaudio -y
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# CUDA 12.4
!pip uninstall torch torchvision torchaudio -y
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

### 問題 4: 依賴衝突

**症狀：**
```
ERROR: pip's dependency resolver does not currently take into account all the packages
```

**解決方案：**
```python
# 方法 1: 強制重新安裝
!pip install --force-reinstall --no-cache-dir -r requirements.txt

# 方法 2: 使用 pip-tools
!pip install pip-tools
!pip-compile requirements.txt
!pip-sync

# 方法 3: 創建新環境
!rm -rf /content/drive/MyDrive/ComfyUI
# 重新運行筆記本
```

### 問題 5: 內存不足（OOM）

**症狀：**
```
RuntimeError: CUDA out of memory
```

**解決方案：**
```python
# 方法 1: 使用低顯存模式
GPU_MODE = 'lowvram'

# 方法 2: 使用超低顯存模式
GPU_MODE = 'novram'

# 方法 3: 清理緩存
import torch
torch.cuda.empty_cache()

# 方法 4: 減小批次大小
# 在 ComfyUI 工作流中調整 batch_size 參數
```

### 問題 6: Cloudflared 連接失敗

**症狀：**
```
ERR  error="Unable to reach the origin service"
```

**解決方案：**

**方法 1: 重啟 ComfyUI**
```python
# 停止當前運行（Ctrl+C）
# 重新運行啟動單元格
```

**方法 2: 使用 Colab 內置端口轉發**
```python
from google.colab import output
output.serve_kernel_port_as_window(8188)
```

**方法 3: 使用 Ngrok**
```python
# 安裝 ngrok
!pip install pyngrok

# 設置 authtoken（從 ngrok.com 獲取）
from pyngrok import ngrok
ngrok.set_auth_token("YOUR_AUTH_TOKEN")

# 創建隧道
public_url = ngrok.connect(8188)
print(f"訪問: {public_url}")
```

---

## 🎨 自定義節點問題

### 問題 1: 節點不顯示

**症狀：**
ComfyUI 啟動後某些自定義節點不出現

**解決方案：**
```python
# 檢查節點目錄
!ls -la /content/drive/MyDrive/ComfyUI/custom_nodes

# 檢查節點的 __init__.py
!cat /content/drive/MyDrive/ComfyUI/custom_nodes/節點名稱/__init__.py

# 重新安裝節點依賴
%cd /content/drive/MyDrive/ComfyUI/custom_nodes/節點名稱
!pip install -r requirements.txt

# 查看 ComfyUI 日誌中的錯誤信息
```

### 問題 2: 節點版本衝突

**症狀：**
```
ModuleNotFoundError: No module named 'xxx'
```

**解決方案：**
```python
# 查看節點的 Git 歷史
%cd /content/drive/MyDrive/ComfyUI/custom_nodes/節點名稱
!git log --oneline -10

# 回退到工作版本
!git checkout <commit-hash>

# 重新安裝依賴
!pip install -r requirements.txt
```

---

## 📊 性能問題

### 問題 1: 生成速度慢

**原因可能：**
1. GPU 模式設置不當
2. 批次大小太小
3. 使用了不適合的採樣器

**解決方案：**
```python
# 1. 檢查 GPU 使用率
!nvidia-smi

# 2. 優化 GPU 模式
# A100/V100 使用 highvram
# T4 使用 lowvram

# 3. 在工作流中：
# - 增加 batch_size
# - 使用更快的採樣器（如 DPM++ 2M Karras）
# - 減少採樣步數
```

### 問題 2: Drive 空間不足

**症狀：**
```
OSError: [Errno 28] No space left on device
```

**解決方案：**
```python
# 檢查空間使用
!df -h /content/drive/MyDrive

# 清理輸出文件
!rm -rf /content/drive/MyDrive/ComfyUI/output/*

# 清理臨時文件
!rm -rf /content/drive/MyDrive/ComfyUI/temp/*

# 升級 Google One（更多空間）
```

---

## 🛠️ 調試技巧

### 啟用詳細日誌

```python
# 在啟動 ComfyUI 時添加參數
!python main.py --listen 0.0.0.0 --port 8188 --verbose
```

### 檢查完整環境

```python
# 創建診斷報告
print("=== 系統信息 ===")
!uname -a
!python --version

print("\n=== GPU 信息 ===")
!nvidia-smi

print("\n=== Python 包 ===")
!pip list | grep -i torch

print("\n=== ComfyUI 結構 ===")
!ls -la /content/drive/MyDrive/ComfyUI

print("\n=== 自定義節點 ===")
!ls -la /content/drive/MyDrive/ComfyUI/custom_nodes

print("\n=== 磁盤空間 ===")
!df -h
```

---

## 📞 獲取幫助

如果問題仍未解決：

1. **檢查日誌**
   ```bash
   # 本機
   cat logs/snapshot_*.log
   
   # Colab
   # 查看 ComfyUI 啟動日誌
   ```

2. **搜索問題**
   - ComfyUI GitHub Issues
   - ComfyUI Discord
   - Reddit r/StableDiffusion

3. **提問時提供**
   - 錯誤信息完整輸出
   - 操作步驟
   - 系統信息（GPU, Python 版本等）
   - 快照版本

---

## 📝 報告 Bug

如果發現腳本本身的問題：

```bash
# 收集診斷信息
./0_check_environment.sh > diagnosis.txt 2>&1

# 包含以下信息：
# 1. 問題描述
# 2. 重現步驟
# 3. 預期行為
# 4. 實際行為
# 5. diagnosis.txt 內容
# 6. 相關日誌
```

提交到 GitHub Issues。

---

**最後更新：** 2025-01-04
