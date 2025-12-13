# n8n 網頁內容自動生成系統說明

本系統使用 n8n 工作流程，自動將使用者輸入的文字內容填入 HTML 範本，並透過大型語言模型（LLM）進行處理，最終生成一個新的 HTML 檔案。

## 前置作業

1.  **安裝 n8n**：請確保您的系統已安裝 n8n。
2.  **匯入 Workflow**：將本資料夾中的 `n8n_workflow.json` 檔案匯入到您的 n8n 實例中。
3.  **設定 OpenAI API 金鑰**：在 n8n 的 `OpenAI Chat Model` 節點中，設定您的 OpenAI API 金鑰。請將 `YOUR_OPENAI_CREDENTIALS_ID` 替換成您自己的憑證 ID。
4.  **確認檔案路徑**：請確認 `Read Binary File` 節點中的 `filePath` 參數，與您存放 `template.html` 的實際路徑相符。目前的預設路徑為 `/Users/n2120008891/Documents/project/n8n_trade_web/template.html`。

## 使用流程

1.  **啟動 Workflow**：在 n8n 中啟動這個 workflow。
2.  **觸發 Webhook**：使用任何可以發送 POST 請求的工具（例如 Postman、curl 或您自己的前端表單），將資料傳送到 n8n 提供的 Webhook URL。

    請求的 `body` 必須是 JSON 格式，且包含以下欄位：
    *   `issueNumber` (期數)
    *   `unitName` (單元名)
    *   `mainTitle` (主標)
    *   `subTitle` (副標)
    *   `credits` (作者、攝影及圖片來源)
    *   `preface` (前言)
    *   `articleBody` (內文)

    **範例 `curl` 指令：**
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{
      "issueNumber": "412",
      "unitName": "產業動態",
      "mainTitle": "AI 賦能，智慧製造新紀元",
      "subTitle": "傳統產業的數位轉型之路",
      "credits": "◎撰文／王小明　圖片來源／Unsplash",
      "preface": "隨著人工智慧技術的飛速發展，製造業正迎來一場前所未有的變革。",
      "articleBody": "第一段內文...\n第二段內文...\n第三段內文..."
    }' [您的 n8n Webhook URL]
    ```

3.  **產出檔案**：當 workflow 執行完畢後，會在 n8n 執行個體所在的伺服器上，根據您輸入的 `mainTitle` 動態生成一個新的 HTML 檔案（例如 `AI 賦能，智慧製造新紀元.html`）。

## LLM 提示說明

在 `OpenAI Chat Model` 節點中，我們使用了以下的提示（Prompt）來指示 LLM 處理 HTML 內容：

```
請分析以下的HTML內文，並在適當的位置插入圖片標籤。圖片的`src`請使用`img/`路徑，並根據前後文給予一個有意義的檔名，例如`img/trade-forum.jpg`。同時，請將內文中所有的換行符號轉換為`<br>`標籤。

{{ $json.html }}
```

這個提示會引導 LLM 完成兩項主要任務：
1.  **自動插入圖片**：LLM 會閱讀文章的上下文，並在它認為合適的地方插入 `<img>` 標籤。圖片的路徑會被設定為 `img/` 開頭，檔名則由 LLM 根據語意生成。
2.  **格式修正**：將使用者輸入的純文字內文中的換行符號（`\n`），轉換成 HTML 中的換行標籤（`<br>`），以確保在網頁上能正確顯示段落。
