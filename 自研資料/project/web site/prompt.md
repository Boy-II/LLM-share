# LLM 網頁設計 Prompt 範例

此文件用於存放我們設計和迭代的各類 Prompt 範例。

---

## 階段二：結構與佈局生成 (組裝藍圖)

**目標**: 生成 `index.html` 檔案。

**範例 Prompt**:
> 「請根據以下指令生成 `index.html` 檔案：
> 1.  **頁面結構**: 依序為 `header`, `hero-section`, `features-list`, `footer`。
> 2.  **範本對應**:
>     *   `header` 使用 `header` 範本。
>     *   `features-list` 是一個 `<div>`，其中包含三個 `feature-card` 範本。
>     *   `footer` 使用 `footer` 範本。
> 3.  **內容**: `header` 的導覽連結為 'Home', 'About', 'Contact'。
> 4.  **連結**: 在 `<head>` 中連結至 `css/style.css` 和 `js/script.js` 檔案。」

---

## 階段三：視覺風格設計 (樣式指令書)

**目標**: 生成 `css/style.css` 檔案。

**範例 Prompt**:
> 「請為 `css/style.css` 檔案生成內容：
> 1.  **導入設計權杖**: 在 `:root` 中定義來自 `corporate-blue` 配色方案的 CSS 變數。
> 2.  **設定全域樣式**: 設定 `body` 的 `font-family` 為 'Helvetica Neue', 'Arial', sans-serif，並設定 `box-sizing` 為 `border-box`。
> 3.  **元件樣式**:
>     *   對於 `.header` 區塊，設定其背景色為 `var(--primary-color)`，`padding` 為 `1rem`。
>     *   讓 `.features-list` 區塊使用 `display: grid`，設定為三欄等寬佈局，`gap` 為 `2rem`。」

---

## 階段四：互動功能實現 (行為指令書)

**目標**: 生成 `js/script.js` 檔案。

**範例 Prompt**:
> 「請為 `js/script.js` 檔案生成內容：
> 1.  **行動裝置選單切換**: 當 `id='mobile-menu-toggle'` 的按鈕被點擊時，切換 `id='main-nav'` 元素的 `active` class。
> 2.  **引用 JS 範本**: 為頁面中的 `id='contact-form'` 套用 `form-validator` 的 JS 功能範本。」

---

## 動態資產生成

### 從 URL 提取配色

> 「請分析此網站截圖（[附上圖片]），提取其配色方案。將其命名為 `example-site-theme` 並提議加入 `color_schemes.md`。」

### 從影片定義特效

> 「這是一段 2 秒、15fps 的影片，展示了一個卡片翻轉的效果。請分析它並生成對應的 CSS 動畫程式碼，命名為 `card-flip-effect`。」

---

## 自定義簡寫語法

**目標**: 高效生成重複性內容。

**範例 Prompt**:
> 「請解析以下簡寫語法，並使用對應的 `news-card` HTML 框架生成三個新聞卡片：
> ```
> <news-card>
> 標題一
> /n 這是第一篇新聞的摘要...
> /n /img/news1.jpg
> </news-card>
>
> <news-card>
> 標題二
> /n 這是第二篇新聞的摘要...
> /n /img/news2.jpg
> </news-card>
> ```
> 」
