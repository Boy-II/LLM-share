# Todo List - PPT自動化生成與發送系統

## 📋 專案資訊
- **專案名稱**: CLI操作LLM發送JSON API給ComfyUI生成圖片/影片
- **PPT規格**: 16:9 8頁
- **背景風格**: 技術/AI主題，創意視覺藝術
- **ComfyUI伺服器**: http://192.168.1.180:8188
- **輸出目錄**: /Volumes/SSD資料中心/ComfyUI_output/2025-12-18/
- **簡報存檔**: /Volumes/M200/project/prompt/ppt/

---

## 🔄 自動化工作流程

### 步驟1：讀取任務清單
- [ ] 讀取 `todo_list.md` 文件
- [ ] 解析任務列表和配置參數

### 步驟2：發送ComfyUI請求
- [ ] 依序發送 ppt1.json ~ ppt8.json 配置文件
- [ ] 發送HTTP POST請求到 `http://192.168.1.180:8188`
- [ ] 記錄請求ID和時間戳

### 步驟3：等待與監控
- [ ] 輪詢檢查任務狀態 60秒監控一次
- [ ] 監控生成進度

### 步驟4：驗證輸出圖片
- [ ] 查詢 `/Volumes/SSD資料中心/ComfyUI_output/2005-12-11/` 目錄
- [ ] 檢查圖片數量是否達到8張
- [ ] 如未達數量，返回步驟3繼續等待

### 步驟5：打開PowerPoint
- [ ] 打開 PowerPoint
- [ ] 創建新簡報 尺寸為16：9

### 步驟6：填入圖片到簡報
- [ ] 打依序將8張圖片填入8頁簡報
- [ ] 設置圖片為滿版背景
- [ ] 存檔至 `/Volumes/M200/project/prompt/ppt/file/`

#### 📝 PPT 生成指令
使用 Python 腳本自動生成 16:9 簡報（自動搜尋 banana 開頭的檔案）：

```python
#!/usr/bin/env python3
from pptx import Presentation
from pptx.util import Inches
import glob
import os

# 設定圖片目錄（根據日期動態調整）
image_dir = "/Volumes/SSD資料中心/ComfyUI_output/2025-12-11/"

# 動態搜尋 banana 開頭的 PNG 檔案
image_pattern = os.path.join(image_dir, "banana*.png")
images = sorted(glob.glob(image_pattern))

# 確認找到 8 張圖片
if len(images) != 8:
    print(f"警告：找到 {len(images)} 張圖片，預期為 8 張")
    print(f"找到的檔案：{images}")
else:
    print(f"找到 {len(images)} 張圖片，準備生成簡報...")

# 建立新簡報
prs = Presentation()

# 設定投影片尺寸為 16:9 橫式
prs.slide_width = Inches(13.333)  # 16:9 寬螢幕標準寬度
prs.slide_height = Inches(7.5)     # 16:9 寬螢幕標準高度

# 為每張圖片建立一張投影片
for img_path in images:
    # 新增空白投影片
    blank_slide_layout = prs.slide_layouts[6]  # 6 是空白版面
    slide = prs.slides.add_slide(blank_slide_layout)

    # 將圖片設為滿版背景
    left = top = Inches(0)
    pic = slide.shapes.add_picture(
        img_path,
        left,
        top,
        width=prs.slide_width,
        height=prs.slide_height
    )

    # 將圖片移到最下層（作為背景）
    slide.shapes._spTree.remove(pic._element)
    slide.shapes._spTree.insert(2, pic._element)

# 儲存簡報
output_path = "/Volumes/M200/project/prompt/ppt/file/AI_presentation.pptx"
prs.save(output_path)
print(f"簡報已建立：{output_path}")
```

**執行指令：**
```bash
# 安裝依賴（首次執行）
pip3 install python-pptx

# 執行腳本
python3 /tmp/create_ppt.py
```

**注意事項：**
- 📅 執行前請將腳本中的 `image_dir` 日期改為當天日期（格式：YYYY-MM-DD）
- 🍌 腳本會自動搜尋該目錄下所有 `banana*.png` 檔案
- ✅ 會驗證找到的圖片數量是否為 8 張
- 📂 如果檔案數量不符，會顯示警告訊息和實際找到的檔案列表

### 步驟7：發送郵件
- [ ] 打開 outlook.app
- [ ] 填入收件人地址susan_tung@bwnet.com.tw
- [ ] 填入郵件主旨:AI全自動簡報
- [ ] 填入郵件內容：附件內容為全自動AI生成（含設計）
- [ ] 附加 `/Volumes/M200/project/prompt/ppt/file/` 資料夾中的全部文件
- [ ] 發送郵件


### API與端點
- ComfyUI API: `http://192.168.1.180:8188`
- 輸出目錄: `/Volumes/SSD資料中心/ComfyUI_output/2025-12-11/`


