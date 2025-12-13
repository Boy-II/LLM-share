# n8n 文字校正 Workflow 說明

此專案提供了一個 n8n workflow 的組件，用於執行繁體中文的文字校正。它分為兩個主要部分：一個 `system_prompt.md` 檔案作為 AI 助手的系統提示，以及一個 `regex_replacements.js` 檔案，其中包含用於精準字詞替換的 JavaScript 程式碼。

## 檔案內容

1.  **`system_prompt.md`**
    *   此檔案包含了更新後的文字校正 prompt 內容，定義了 AI 助手的角色、處理流程、智能模糊比對項目、常見錯誤檢查清單、核心約束條件和標準輸出格式。**「第一階段：精準字詞替換規則」部分已刪除，因為這部分現在完全由 Code 節點處理。**
    *   在 n8n workflow 中，此內容應作為 LLM 節點（例如 OpenAI Chat 或 Custom LLM）的系統提示 (System Prompt) 輸入。

2.  **`regex_replacements.js`**
    *   此檔案包含一個 JavaScript 物件 `replacements`，其中定義了部分「精準字詞替換」的鍵值對（原始詞彙: 替換詞彙）。
    *   它還包含一個 Code 節點的範例程式碼，該程式碼會遍歷輸入文本並根據 `replacements` 物件執行正則表達式替換。**請注意，一些可能導致語境錯誤的替換（例如「型」與「形」、「周」與「週」的區分）已從此檔案中移除，並應由 LLM 節點在第二階段的智能模糊比對中處理。**

## 如何在 n8n Workflow 中使用

1.  **建立一個新的 n8n Workflow。**

2.  **新增一個觸發節點 (Trigger Node)**
    *   例如，可以使用 `Webhook` 節點來接收要校正的文本，或者使用 `Manual Trigger` 進行手動測試。

3.  **新增一個 Code 節點 (Code Node)**
    *   將 `regex_replacements.js` 檔案中的 JavaScript 程式碼複製並貼到此 Code 節點中。
    *   確保 Code 節點的輸入資料包含要校正的文本，例如，如果 Webhook 接收 JSON `{ "text": "要校正的文字" }`，則 Code 節點中的 `text` 變數應從 `$input.first().json.text` 獲取。
    *   此 Code 節點將執行第一階段的「精準字詞替換」。

4.  **新增一個 LLM 節點 (例如 OpenAI Chat Node)**
    *   將 `system_prompt.md` 檔案的內容作為此 LLM 節點的「系統提示 (System Prompt)」輸入。
    *   將 Code 節點的輸出（即經過第一階段精準替換後的文本）作為此 LLM 節點的「用戶訊息 (User Message)」輸入。
    *   此 LLM 節點將執行第二階段的「智能模糊比對」。

5.  **新增一個輸出節點 (Output Node)**
    *   例如，可以使用 `Respond to Webhook` 節點將最終校正後的文本返回，或者使用 `Write to File` 節點將結果保存。

## Workflow 結構示意圖

```
[Trigger Node]
    ↓
[Code Node (執行 regex_replacements.js)]
    ↓
[LLM Node (使用 system_prompt.md 作為 System Prompt)]
    ↓
[Output Node]
```

透過這種方式，您可以將文字校正的兩個階段（精準替換和智能模糊比對）有效地整合到 n8n workflow 中。
