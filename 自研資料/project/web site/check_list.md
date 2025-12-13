# LLM 網頁設計檢查清單

此清單用於確保在交付 LLM 進行網頁設計任務時，所有必要的元素都已考慮周全。

---

## 初始需求定義

- [ ] 定義目標使用者
- [ ] 確定網站核心功能
- [ ] 收集品牌風格指南（顏色、字體等）
- [ ] 準備內容或內容結構
- [ ] 收集或定義所需的圖片素材（或決定使用佔位圖）。
- [ ] 收集或定義所需的 SVG 圖示/圖形（或決定使用圖示庫）。

---

## 資產準備最佳實踐

- [ ] 從 URL 提取配色時，確保使用視覺分析而非原始碼，以防汙染。
- [ ] 錄製動畫範例時，應縮短時長、降低幀率（10-16 fps）和解析度（480p-720p）以節省 Token。

---

## 待辦事項 (To-Do Items)

- [ ] 建立 `color_schemes.md` 文件，並定義基礎配色方案。
- [ ] 建立 `effects_library.md` 文件，並定義基礎特效。
- [ ] 將 `sample_templates.md` 更名為 `template_samples.md`。
- [ ] 在 `effects_library.md` 中新增一個 SVG 局部動畫的範例。
- [ ] 建立 `work_progress.md` 檔案來追蹤專案狀態。
- [ ] 每次操作前讀取 `work_progress.md`，操作後更新。
- [ ] 在 `template_samples.md` 中定義 `standard-page-layout` 的具體區塊順序。
- [ ] 建立 `js_templates.md` 檔案，並加入如「行動選單切換」等常用腳本範例。
- [ ] 建立 `shorthand_syntax.md` 檔案，定義 `<box>` 等簡寫語法的規則與對應的 HTML 框架。
- [ ] 生成網站核心檔案後，額外生成 `theme-editor.html` 及其對應的 JS，用於即時調整 CSS 變數，並支援透過 `FileReader` API 上傳圖片。
