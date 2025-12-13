# 🌟 最佳實踐指南

本文檔整理使用本項目的最佳實踐和優化技巧。

---

## 📦 快照管理

### 定期創建快照

**建議頻率：**
- ✅ **每週一次** - 如果頻繁添加新節點
- ✅ **每月一次** - 穩定使用期
- ✅ **重大更新後** - 添加關鍵節點或更新依賴

**自動化快照：**
```bash
# 創建 cron 任務（每週日凌晨 2 點）
crontab -e

# 添加以下內容：
0 2 * * 0 cd "/Volumes/M200/project/Colab Pro" && ./1_create_snapshot.sh && ./2_upload_to_github.sh
```

### 版本命名規範

**推薦格式：**
```
v[YYYYMMDD] - 日期版本（自動生成）
v[YYYYMMDD]-[tag] - 帶標籤版本
```

**示例：**
```bash
v20250104          # 基礎版本
v20250104-video    # 視頻生成專用
v20250104-img2img  # 圖像轉換專用
v20250104-stable   # 穩定版本
```

### 快照說明文檔

**每次快照都應記錄：**

```yaml
# 在 CHANGELOG.md 中記錄
## [v20250104] - 2025-01-04

### 新增
- ComfyUI-AnimateDiff-Evolved (v1.2.0)
- ComfyUI-VideoHelperSuite (latest)

### 變更
- 更新 PyTorch 到 2.1.2
- 優化 xformers 版本

### 測試環境
- Python 3.10.11
- CUDA 12.1
- GPU: RTX 4090

### 已知問題
- 某個節點在低顯存模式下可能失敗

### 推薦用途
- 視頻生成工作流
- AnimateDiff 動畫製作
```

---

## 🎯 環境優化

### ComfyUI 本機配置

**目錄結構：**
```
ComfyUI/
├── custom_nodes/        # 自定義節點
├── models/
│   ├── checkpoints/     # 只保留常用模型
│   ├── loras/          # 只保留常用 LoRA
│   └── ...
├── workflows/          # 工作流備份
├── output/             # 定期清理
└── requirements.txt    # 依賴記錄
```

**定期清理：**
```bash
# 清理輸出（保留最近 7 天）
find ComfyUI/output -type f -mtime +7 -delete

# 清理臨時文件
rm -rf ComfyUI/temp/*
rm -rf ComfyUI/__pycache__

# 清理 Python 緩存
find ComfyUI -type d -name "__pycache__" -exec rm -rf {} +
```

### Git 最佳實踐

```bash
# 1. 為 ComfyUI 初始化 Git（如果未初始化）
cd /path/to/ComfyUI
git init

# 2. 添加 .gitignore
cat > .gitignore << EOF
models/*
output/*
input/*
temp/*
*.log
__pycache__/
.DS_Store
venv/
.venv/
EOF

# 3. 提交基礎結構
git add .
git commit -m "Initial commit"

# 4. 添加節點時記錄
git add custom_nodes/new_node
git commit -m "Add: new_node for xxx功能"
```

---

## 🚀 Colab 優化

### GPU 選擇策略

**GPU 性能排序：**
```
A100 40GB > V100 16GB > T4 16GB
```

**根據任務選擇：**

| 任務類型 | 推薦 GPU | 顯存模式 | 預期速度 |
|---------|---------|---------|---------|
| SD 1.5 基礎生成 | T4 | normal | 3-5s/張 |
| SDXL 生成 | V100/A100 | normal | 8-12s/張 |
| AnimateDiff 視頻 | A100 | highvram | 30-60s/視頻 |
| ControlNet + SDXL | A100 | highvram | 15-20s/張 |
| 批量生成 | A100 | highvram | 最快 |

**獲取 A100 技巧：**
```python
# 1. 高峰期外使用（美國時區晚上/凌晨）
# 2. 重新連接運行時多次嘗試
# 3. 使用 Colab Pro+（更高優先級）

# 檢查分配的 GPU
!nvidia-smi --query-gpu=name --format=csv
```

### Drive 使用優化

**目錄結構：**
```
Google Drive/
└── ComfyUI/
    ├── (快照內容)
    ├── models/
    │   ├── checkpoints/
    │   │   ├── sd15/          # SD 1.5 模型
    │   │   ├── sdxl/          # SDXL 模型
    │   │   └── specialized/   # 特殊用途模型
    │   ├── loras/
    │   │   ├── character/     # 角色 LoRA
    │   │   ├── style/         # 風格 LoRA
    │   │   └── concept/       # 概念 LoRA
    │   └── ...
    ├── workflows/
    │   ├── basic/             # 基礎工作流
    │   ├── video/             # 視頻工作流
    │   └── advanced/          # 高級工作流
    ├── output/
    │   └── 2025-01/           # 按月整理
    └── input/                 # 輸入素材
```

**模型管理：**
```python
# 使用符號鏈接避免重複
!ln -s /content/drive/MyDrive/Shared_Models /content/drive/MyDrive/ComfyUI/models/checkpoints/shared

# 定期清理舊輸出
!find /content/drive/MyDrive/ComfyUI/output -type f -mtime +30 -delete
```

### 啟動時間優化

**優化清單：**

✅ **1. 保持環境在 Drive**
- 不要每次刪除 ComfyUI 目錄
- 只在更新時重新下載

✅ **2. 使用快照而非 Git Clone**
- 快照包含所有依賴
- 避免重新安裝節點

✅ **3. 緩存 PyTorch**
```python
# 不要每次卸載重裝
# 只在 CUDA 版本不匹配時重裝
```

✅ **4. 並行安裝依賴**
```python
# 在筆記本中添加
!pip install -q package1 package2 package3
# 而不是分多次運行
```

---

## 💰 成本優化

### Colab Pro 使用策略

**計算單元（Compute Units）管理：**

✅ **節省計算單元：**
1. 只在需要時運行
2. 完成後立即斷開
3. 不要讓筆記本空跑
4. 使用背景執行而非一直佔用

✅ **何時使用免費版：**
- 測試工作流
- 簡單的 SD 1.5 生成
- 學習和實驗

✅ **何時使用 Pro：**
- SDXL 生成
- AnimateDiff 視頻
- 批量生成任務
- 需要 A100 的場景

✅ **何時使用 Pro+：**
- 長時間運行任務
- 需要保證 A100 訪問
- 商業項目

### GitHub Release 空間管理

**策略：**
1. **只保留最近 3 個版本**
```bash
# 刪除舊版本
gh release delete v20250101 -R username/repo
```

2. **使用 Git LFS（如需要）**
```bash
git lfs install
git lfs track "*.tar.gz"
```

3. **考慮 Hugging Face**
- 無文件大小限制
- 免費無限存儲
- 更好的版本管理

---

## 🔒 安全最佳實踐

### Token 管理

**❌ 不要：**
```yaml
# 不要在 config.yaml 中硬編碼 token
github:
  token: "ghp_xxxxxxxxxxxx"
```

**✅ 應該：**
```bash
# 使用環境變量
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# 或使用 gh CLI 登錄
gh auth login
```

### 私密文件

**.gitignore 必須包含：**
```gitignore
# 配置中的敏感信息
config.local.yaml
*.secret
*.key

# 個人工作流（如果包含提示詞）
workflows/personal/

# API keys
.env
.env.local
```

---

## 📊 工作流最佳實踐

### 工作流組織

**命名規範：**
```
[用途]-[模型]-[風格]-[版本].json

示例：
portrait-sdxl-realistic-v1.json
video-sd15-anime-v2.json
batch-sdxl-product-v1.json
```

**備份策略：**
```bash
# 1. 保存到 Google Drive
workflows/
├── production/      # 生產環境工作流
├── testing/         # 測試中的工作流
└── archive/         # 歸檔的舊工作流

# 2. 定期提交到 Git
cd workflows
git add .
git commit -m "Update: improved portrait workflow"
```

### 提示詞管理

**建立提示詞庫：**
```
prompts/
├── positive/
│   ├── character.txt
│   ├── environment.txt
│   └── quality.txt
├── negative/
│   └── common.txt
└── templates/
    └── portrait-template.txt
```

**使用佔位符：**
```
Template:
{character_description}, {environment}, {quality_tags}

Example:
a young woman, in a modern office, masterpiece, best quality, ultra detailed
```

---

## 🎨 模型管理

### 模型下載策略

**推薦來源：**
1. **Civitai** - 社區模型，質量高
2. **Hugging Face** - 官方模型，穩定
3. **自訓練** - 特殊用途

**下載工具：**
```python
# 在 Colab 中使用 aria2c（更快）
!apt-get install -y aria2

# 從 Civitai 下載
!aria2c -x 16 -s 16 "https://civitai.com/api/download/models/xxxxx" \
    -d /content/drive/MyDrive/ComfyUI/models/checkpoints \
    -o model.safetensors

# 從 HuggingFace 下載
!wget -c "https://huggingface.co/xxx/model.safetensors" \
    -P /content/drive/MyDrive/ComfyUI/models/checkpoints
```

### 模型分類

**按用途分類：**
```
models/checkpoints/
├── general/         # 通用模型（SD 1.5, SDXL）
├── realistic/       # 寫實風格
├── anime/          # 動漫風格
├── artistic/       # 藝術風格
└── specialized/    # 特殊用途（如產品攝影）
```

---

## 🚦 性能監控

### 追蹤指標

**在 Colab 中監控：**
```python
# 創建監控函數
def monitor_gpu():
    import subprocess
    result = subprocess.run(
        ['nvidia-smi', '--query-gpu=utilization.gpu,memory.used,memory.total', 
         '--format=csv,noheader,nounits'],
        capture_output=True, text=True
    )
    return result.stdout.strip()

# 每次生成後檢查
print(monitor_gpu())
```

### 性能基準

**記錄你的設置基準：**
```yaml
# benchmark.yaml
setups:
  - name: "SD 1.5 基礎"
    model: "sd-v1-5.safetensors"
    gpu: "T4"
    resolution: "512x512"
    steps: 20
    time: "3.2s"
  
  - name: "SDXL 標準"
    model: "sd_xl_base_1.0.safetensors"
    gpu: "A100"
    resolution: "1024x1024"
    steps: 30
    time: "11.5s"
```

---

## 📚 學習資源

### 推薦閱讀

1. **ComfyUI 官方文檔**
   - https://github.com/comfyanonymous/ComfyUI

2. **社區工作流**
   - https://comfyworkflows.com/
   - https://openart.ai/workflows

3. **教學視頻**
   - YouTube: "ComfyUI Tutorial"
   - Bilibili: "ComfyUI 教程"

### 社區參與

**活躍社區：**
- Discord: ComfyUI Official
- Reddit: r/StableDiffusion
- GitHub: ComfyUI Issues & Discussions

**貢獻方式：**
1. 分享工作流
2. 報告 Bug
3. 提交 Pull Request
4. 編寫教程

---

## ✅ 檢查清單

### 每次使用前

- [ ] 檢查 GPU 類型
- [ ] 確認 Drive 空間充足
- [ ] 確認快照版本正確
- [ ] 測試啟動是否正常

### 每週維護

- [ ] 清理輸出文件
- [ ] 檢查模型是否需要更新
- [ ] 備份重要工作流
- [ ] 檢查快照是否需要更新

### 每月審查

- [ ] 評估成本使用情況
- [ ] 清理不用的模型
- [ ] 更新文檔和記錄
- [ ] 創建穩定版本快照

---

## 🎯 進階技巧

### 批量處理

```python
# 在 ComfyUI 中實現批量處理
# 1. 使用 Load Image Batch 節點
# 2. 設置循環處理
# 3. 自動保存結果
```

### API 集成

```python
# 使用 ComfyUI API（需要先啟動 ComfyUI）
import requests
import json

# 發送工作流
workflow = json.load(open('workflow.json'))
response = requests.post('http://127.0.0.1:8188/prompt', json=workflow)
```

### 自動化工作流

```bash
# 創建自動化腳本
#!/bin/bash
# auto_generate.sh

# 1. 啟動 ComfyUI
# 2. 等待啟動完成
# 3. 發送 API 請求
# 4. 等待完成
# 5. 下載結果
```

---

**最後更新：** 2025-01-04
**版本：** 1.0
