# SillyTavern + 雙LLM架構整合方案

## 架構概述

```
SillyTavern
    ↓
[1] 主LLM (如Claude/GPT/本地70B+)
    ↓ (生成: 小說文本 + 粗糙標籤)
    ↓
[2] 格式化LLM (本地8B-20B)
    ↓ (輸出: Prompt Control格式化標籤)
    ↓
[3] ComfyUI API
    ↓
[4] 返回圖片到SillyTavern
```

## 實現方案

### 方案A: 使用STscript (推薦)

SillyTavern的STscript可以串聯多個API調用。

#### 步驟1: 配置兩個LLM端點

在SillyTavern設置中:
1. **主LLM端點** (API或本地)
   - 名稱: `main_llm`
   - 用途: 生成小說和粗糙標籤
   
2. **格式化LLM端點** (本地)
   - 名稱: `format_llm`
   - 使用Ollama/LM Studio/KoboldCpp
   - 模型: Qwen2.5 14B Instruct (推薦) 或 Llama 3.1 8B
   - 端口: 如 `http://localhost:11434`

#### 步驟2: 創建STscript工作流

創建檔案 `/scripts/prompt_control_workflow.st`:

```javascript
// Prompt Control 格式化工作流
// 作者: Boy
// 版本: 1.0

// ===== 第一階段: 主LLM生成內容 =====
/echo 📝 階段1: 生成小說內容和初步標籤...

// 切換到主LLM
/api main_llm

// 設置主LLM的提示詞
/setglobalprompt 你是一個小說創作AI。請根據對話生成故事內容,並在最後用 [IMAGE_TAGS] 標記包含適合該場景的圖像描述標籤。格式:\n\n故事內容...\n\n[IMAGE_TAGS]\n標籤描述\n[/IMAGE_TAGS]

// 執行主LLM生成
/gen

// 提取標籤部分
/setvar raw_tags {{lastMessage}}
/regex raw_tags /\[IMAGE_TAGS\](.*?)\[\/IMAGE_TAGS\]/s $1

// ===== 第二階段: 格式化LLM處理標籤 =====
/echo 🔄 階段2: 格式化標籤為Prompt Control格式...

// 切換到格式化LLM
/api format_llm

// 設置格式化的system prompt
/setvar format_system_prompt {{readFile::format_system_prompt.txt}}

// 組合請求
/setvar format_request 請將以下粗糙標籤格式化為Prompt Control語法:\n\n{{raw_tags}}

// 執行格式化
/gen-text {{format_request}} | /setvar formatted_tags {{pipe}}

/echo ✅ 格式化完成: {{formatted_tags}}

// ===== 第三階段: 發送到ComfyUI =====
/echo 🎨 階段3: 發送到ComfyUI生成圖片...

// 調用ComfyUI
/sendto-comfyui {{formatted_tags}}

/echo ✨ 完成!
```

### 方案B: Python中間件 (更靈活)

創建一個中間API服務處理整個流程:

```python
# prompt_control_middleware.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import aiohttp
import json

app = FastAPI()

# 配置
MAIN_LLM_URL = "http://localhost:5000/api/generate"  # 你的主LLM
FORMAT_LLM_URL = "http://localhost:11434/api/generate"  # Ollama
COMFYUI_URL = "http://localhost:8188/prompt"

# 載入格式化系統提示詞
with open('format_system_prompt.txt', 'r', encoding='utf-8') as f:
    FORMAT_SYSTEM_PROMPT = f.read()

@app.post("/generate-with-image")
async def generate_with_image(request: Request):
    """
    統一端點: 接收請求 -> 主LLM -> 格式化LLM -> ComfyUI
    """
    data = await request.json()
    user_message = data.get("message", "")
    
    # ===== 階段1: 主LLM生成 =====
    print("📝 階段1: 調用主LLM...")
    async with aiohttp.ClientSession() as session:
        main_llm_payload = {
            "prompt": user_message,
            "system": "你是小說創作AI。生成內容後用[IMAGE_TAGS]標記圖像描述。"
        }
        
        async with session.post(MAIN_LLM_URL, json=main_llm_payload) as resp:
            main_response = await resp.json()
            story_text = main_response.get("response", "")
    
    # 提取標籤
    import re
    tags_match = re.search(r'\[IMAGE_TAGS\](.*?)\[/IMAGE_TAGS\]', story_text, re.DOTALL)
    raw_tags = tags_match.group(1).strip() if tags_match else ""
    
    if not raw_tags:
        return JSONResponse({
            "story": story_text,
            "error": "未找到圖像標籤"
        })
    
    # ===== 階段2: 格式化LLM =====
    print("🔄 階段2: 格式化標籤...")
    async with aiohttp.ClientSession() as session:
        format_payload = {
            "model": "qwen2.5:14b-instruct",  # 或你選擇的模型
            "prompt": f"請將以下標籤格式化:\n\n{raw_tags}",
            "system": FORMAT_SYSTEM_PROMPT,
            "stream": False,
            "options": {
                "temperature": 0.3,  # 格式化任務用低溫度
                "top_p": 0.9
            }
        }
        
        async with session.post(FORMAT_LLM_URL, json=format_payload) as resp:
            format_response = await resp.json()
            formatted_tags = format_response.get("response", "")
    
    print(f"✅ 格式化結果: {formatted_tags}")
    
    # ===== 階段3: 發送到ComfyUI =====
    print("🎨 階段3: 生成圖片...")
    
    # 讀取ComfyUI workflow模板
    with open('comfyui_workflow_template.json', 'r') as f:
        workflow = json.load(f)
    
    # 注入格式化後的prompt
    # 假設你的workflow中positive prompt node ID是 "6"
    workflow["6"]["inputs"]["text"] = formatted_tags
    
    async with aiohttp.ClientSession() as session:
        async with session.post(COMFYUI_URL, json={"prompt": workflow}) as resp:
            comfyui_response = await resp.json()
            prompt_id = comfyui_response.get("prompt_id")
    
    return JSONResponse({
        "story": story_text,
        "raw_tags": raw_tags,
        "formatted_tags": formatted_tags,
        "prompt_id": prompt_id,
        "image_url": f"http://localhost:8188/view?filename={prompt_id}"
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

啟動:
```bash
pip install fastapi aiohttp uvicorn
python prompt_control_middleware.py
```

然後在SillyTavern中設置API端點為 `http://localhost:8000`

### 方案C: SillyTavern擴展 (最整合)

創建自定義ST擴展:

```javascript
// extensions/prompt-control-formatter/index.js

import { callPopup, eventSource, event_types } from "../../../script.js";
import { extension_settings, saveSettingsDebounced } from "../../extensions.js";

const MODULE_NAME = "prompt-control-formatter";

// 預設設定
const defaultSettings = {
    enabled: true,
    format_llm_url: "http://localhost:11434/api/generate",
    format_llm_model: "qwen2.5:14b-instruct",
    auto_format: true,
    comfyui_url: "http://localhost:8188"
};

// 載入設定
function loadSettings() {
    if (!extension_settings[MODULE_NAME]) {
        extension_settings[MODULE_NAME] = defaultSettings;
    }
    return extension_settings[MODULE_NAME];
}

// 格式化函數
async function formatTags(rawTags) {
    const settings = loadSettings();
    
    if (!settings.enabled) {
        return rawTags;
    }
    
    try {
        const response = await fetch(settings.format_llm_url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                model: settings.format_llm_model,
                prompt: `請格式化以下標籤:\n\n${rawTags}`,
                system: await fetch('/scripts/format_system_prompt.txt').then(r => r.text()),
                stream: false,
                options: {
                    temperature: 0.3,
                    top_p: 0.9
                }
            })
        });
        
        const data = await response.json();
        return data.response;
    } catch (error) {
        console.error("格式化失敗:", error);
        return rawTags;
    }
}

// 攔截消息並處理
eventSource.on(event_types.MESSAGE_RECEIVED, async (data) => {
    const settings = loadSettings();
    
    if (!settings.auto_format) return;
    
    const message = data.mes;
    
    // 檢查是否包含IMAGE_TAGS
    const tagsMatch = message.match(/\[IMAGE_TAGS\](.*?)\[\/IMAGE_TAGS\]/s);
    
    if (tagsMatch) {
        const rawTags = tagsMatch[1].trim();
        console.log("🔍 檢測到圖像標籤:", rawTags);
        
        // 格式化
        const formattedTags = await formatTags(rawTags);
        console.log("✅ 格式化完成:", formattedTags);
        
        // 發送到ComfyUI
        if (settings.comfyui_url) {
            await sendToComfyUI(formattedTags, settings.comfyui_url);
        }
        
        // 可選: 將格式化結果顯示給用戶
        toastr.success(`標籤已格式化並發送到ComfyUI`, "Prompt Control");
    }
});

// 發送到ComfyUI
async function sendToComfyUI(prompt, comfyuiUrl) {
    // 這裡使用你現有的ComfyUI插件邏輯
    // 或直接調用ComfyUI API
}

// UI設定面板
function addSettings() {
    const html = `
        <div class="prompt-control-formatter-settings">
            <label>
                <input type="checkbox" id="pc_enabled">
                啟用Prompt Control格式化
            </label>
            <label>
                格式化LLM URL:
                <input type="text" id="pc_llm_url" class="text_pole">
            </label>
            <label>
                模型名稱:
                <input type="text" id="pc_model" class="text_pole">
            </label>
        </div>
    `;
    
    $("#extensions_settings").append(html);
    
    // 綁定事件...
}

// 註冊擴展
jQuery(async () => {
    loadSettings();
    addSettings();
    console.log("Prompt Control Formatter 已載入");
});
```

## 推薦的模型配置

### 格式化LLM選擇 (本地8B-20B)

**最推薦: Qwen2.5 14B Instruct**
```bash
# Ollama安裝
ollama pull qwen2.5:14b-instruct-q5_K_M

# 使用
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:14b-instruct-q5_K_M",
  "prompt": "格式化請求...",
  "system": "系統提示詞...",
  "stream": false,
  "options": {
    "temperature": 0.3,
    "num_ctx": 4096
  }
}'
```

**備選方案:**
1. **Llama 3.1 8B Instruct** - 記憶體較低時
2. **Mistral Small 22B** - 需要更高質量時
3. **Qwen2.5 7B Instruct** - 快速原型

### 性能優化參數

格式化任務的最佳參數:
```json
{
  "temperature": 0.3,     // 低溫度保持格式穩定
  "top_p": 0.9,          
  "top_k": 40,
  "repeat_penalty": 1.1,
  "num_ctx": 4096,       // 足夠的上下文
  "num_predict": 512     // 限制輸出長度
}
```

## 測試流程

### 1. 測試格式化LLM
```bash
# 測試Ollama是否正常
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:14b-instruct",
  "prompt": "測試: 紅髮女孩, 藍色眼睛",
  "system": "你是格式化專家",
  "stream": false
}'
```

### 2. 測試完整流程
在SillyTavern中發送:
```
創作一個場景: 女孩在公園看書,然後天氣變暗
```

檢查:
- [ ] 主LLM生成了故事
- [ ] 提取到了[IMAGE_TAGS]
- [ ] 格式化LLM正確轉換
- [ ] ComfyUI收到了正確格式

## 故障排除

### 問題1: 格式化LLM無回應
- 檢查Ollama是否運行: `ollama list`
- 檢查端口: `curl http://localhost:11434`
- 查看日誌: `ollama logs`

### 問題2: 格式不正確
- 檢查system prompt是否正確載入
- 調整temperature (降低到0.1-0.2)
- 使用更大的模型 (14B -> 22B)

### 問題3: 速度太慢
- 使用量化版本 (Q5_K_M或Q4_K_M)
- 減少num_ctx
- 使用更小的模型(7B-8B)

### 問題4: 記憶體不足
- 你的配置(RTX 5080 + 64GB)完全足夠
- 如果仍有問題,使用Q4量化

## 性能預估

你的硬體 (RTX 5080 16GB + 64GB RAM):

| 模型 | 量化 | VRAM | 速度 (tokens/s) | 推薦 |
|------|------|------|-----------------|------|
| Qwen2.5 7B | Q5_K_M | ~5GB | 80-100 | ⭐ 快速原型 |
| Qwen2.5 14B | Q5_K_M | ~9GB | 50-70 | ⭐⭐⭐ 最佳平衡 |
| Llama 3.1 8B | Q5_K_M | ~6GB | 70-90 | ⭐⭐ 備選 |
| Mistral Small 22B | Q5_K_M | ~14GB | 30-40 | ⭐ 高質量 |

格式化任務通常只需要100-300 tokens,所以速度非常快 (1-3秒)。

## 下一步

1. ✅ 已創建system prompt和測試案例
2. ⬜ 選擇並安裝格式化LLM (推薦Qwen2.5 14B)
3. ⬜ 測試格式化效果
4. ⬜ 選擇整合方案 (A/B/C)
5. ⬜ 整合到你的工作流
6. ⬜ 調優參數

需要我幫你實現具體哪個方案?
