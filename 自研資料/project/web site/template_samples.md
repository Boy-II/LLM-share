# 範本庫 (Template Library)

> **版本**: v2.0
> **更新日期**: 2025-11-20
> **格式**: 標籤 → HTML 映射規則

本文件定義所有可用的 HTML 範本，包含標籤格式、HTML 輸出、響應式行為和 CSS 變數依賴。

---

## 📖 使用說明

### 標籤格式
LLM 生成標籤清單，後端引擎使用正則表達式將標籤替換為實際 HTML。

### 範本類型
- **Hero 範本（5 種）**: 第一屏設計，80% 的重點
- **內容區塊範本（8 種）**: 頁面主體內容

### 替換流程
```
LLM 輸出標籤 → 正則匹配 → 替換為 HTML → 注入 CSS 變數 → 完整頁面
```

---

# 🎨 Hero 範本（第一屏）

## 1. `hero-centered` - 居中式 Hero

### 描述
經典的居中式設計，適合強調單一訊息和行動呼籲。文字置中，背景可選圖片或純色。

### 適用場景
- 產品發布頁
- 活動報名頁
- 簡潔的品牌展示

### 標籤格式
```xml
<HERO type="centered">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題}}</SUBTITLE>
  <CTA text="{{按鈕文字}}" link="{{連結}}"/>
  <BACKGROUND image="{{圖片URL}}" />
</HERO>
```

### 替換為 HTML
```html
<section class="hero hero--centered">
  <div class="hero__background">
    <img src="{{圖片URL}}" alt="" class="hero__bg-image" />
  </div>
  <div class="hero__content">
    <h1 class="hero__title">{{主標題}}</h1>
    <p class="hero__subtitle">{{副標題}}</p>
    <a href="{{連結}}" class="btn btn--primary btn--large">{{按鈕文字}}</a>
  </div>
</section>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.hero--centered {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.hero__content {
  max-width: 800px;
  padding: 0 2rem;
}

.hero__title {
  font-size: 3.5rem;
  margin-bottom: 1.5rem;
}

.hero__subtitle {
  font-size: 1.5rem;
  margin-bottom: 2.5rem;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .hero__title {
    font-size: 2rem;
  }

  .hero__subtitle {
    font-size: 1.125rem;
  }

  .hero__content {
    padding: 0 1rem;
  }
}
```

### CSS 變數依賴
```css
--hero-bg-color
--hero-text-color
--hero-overlay-opacity
--btn-primary-bg
--btn-primary-color
--btn-primary-hover
```

### 設計建議
- **標題長度**: 30-50 字元（中文約 15-25 字）
- **副標題長度**: 80-120 字元（中文約 40-60 字）
- **CTA 文字**: 簡短有力（2-4 字）
- **背景圖片**: 1920x1080px，檔案 < 500KB

---

## 2. `hero-split` - 分割式 Hero

### 描述
左右分割設計，一側為文字內容，另一側為產品圖片或視覺元素。適合需要展示視覺的產品。

### 適用場景
- SaaS 產品頁
- App 下載頁
- 實體產品展示

### 標籤格式
```xml
<HERO type="split" imagePosition="right">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題}}</SUBTITLE>
  <CTA text="{{按鈕文字}}" link="{{連結}}"/>
  <IMAGE url="{{圖片URL}}" alt="{{圖片描述}}"/>
</HERO>
```

### 替換為 HTML
```html
<section class="hero hero--split">
  <div class="hero__text">
    <h1 class="hero__title">{{主標題}}</h1>
    <p class="hero__subtitle">{{副標題}}</p>
    <a href="{{連結}}" class="btn btn--primary btn--large">{{按鈕文字}}</a>
  </div>
  <div class="hero__image">
    <img src="{{圖片URL}}" alt="{{圖片描述}}" />
  </div>
</section>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.hero--split {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  gap: 4rem;
  padding: 0 4rem;
}

.hero__text {
  text-align: left;
}

.hero__title {
  font-size: 3rem;
  margin-bottom: 1.5rem;
}

.hero__subtitle {
  font-size: 1.25rem;
  margin-bottom: 2rem;
}

.hero__image img {
  width: 100%;
  height: auto;
  border-radius: 8px;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .hero--split {
    grid-template-columns: 1fr;
    padding: 3rem 1rem;
    min-height: auto;
  }

  /* 圖片在上，文字在下 */
  .hero__image {
    order: 1;
    margin-bottom: 2rem;
  }

  .hero__text {
    order: 2;
    text-align: center;
  }

  .hero__title {
    font-size: 2rem;
  }

  .hero__subtitle {
    font-size: 1.125rem;
  }
}
```

### CSS 變數依賴
```css
--hero-text-color
--btn-primary-bg
--btn-primary-color
--bg-primary
```

### 設計建議
- **圖片比例**: 正方形（1:1）或縱向（3:4）效果佳
- **圖片尺寸**: 至少 800x800px
- **文字對齊**: Desktop 左對齊，Mobile 置中
- **imagePosition**: 可選 "left" 或 "right"（預設 right）

---

## 3. `hero-video` - 影片背景式 Hero

### 描述
全螢幕影片背景，文字覆蓋於影片上方。適合需要動態視覺吸引的頁面。

### 適用場景
- 品牌形象頁
- 旅遊/美食展示
- 活動宣傳

### 標籤格式
```xml
<HERO type="video">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題}}</SUBTITLE>
  <CTA text="{{按鈕文字}}" link="{{連結}}"/>
  <VIDEO url="{{影片URL}}" fallback="{{備用圖片URL}}"/>
</HERO>
```

### 替換為 HTML
```html
<section class="hero hero--video">
  <video class="hero__bg-video" autoplay muted loop playsinline>
    <source src="{{影片URL}}" type="video/mp4">
  </video>
  <img src="{{備用圖片URL}}" alt="" class="hero__fallback-image" style="display:none;" />
  <div class="hero__overlay"></div>
  <div class="hero__content">
    <h1 class="hero__title">{{主標題}}</h1>
    <p class="hero__subtitle">{{副標題}}</p>
    <a href="{{連結}}" class="btn btn--primary btn--large">{{按鈕文字}}</a>
  </div>
</section>

<script>
// 影片載入失敗時的降級處理
document.addEventListener('DOMContentLoaded', function() {
  const video = document.querySelector('.hero__bg-video');
  const fallback = document.querySelector('.hero__fallback-image');

  video.addEventListener('error', function() {
    video.style.display = 'none';
    fallback.style.display = 'block';
  });
});
</script>
```

### 響應式行為
```css
/* Desktop & Mobile 共通 */
.hero--video {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.hero__bg-video,
.hero__fallback-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  z-index: 1;
}

.hero__overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4); /* 半透明遮罩 */
  z-index: 2;
}

.hero__content {
  position: relative;
  z-index: 3;
  text-align: center;
  color: white;
  max-width: 900px;
  padding: 0 2rem;
}

.hero__title {
  font-size: 3.5rem;
  text-shadow: 0 2px 8px rgba(0,0,0,0.3);
}

.hero__subtitle {
  font-size: 1.5rem;
  text-shadow: 0 2px 8px rgba(0,0,0,0.3);
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .hero__title {
    font-size: 2.25rem;
  }

  .hero__subtitle {
    font-size: 1.125rem;
  }

  .hero__content {
    padding: 0 1rem;
  }
}
```

### CSS 變數依賴
```css
--hero-overlay-opacity
--btn-primary-bg
--btn-primary-color
```

### 設計建議
- **影片格式**: MP4（H.264 編碼）
- **影片長度**: 10-30 秒循環
- **檔案大小**: < 5MB（壓縮！）
- **備用圖片**: 必須提供，影片載入失敗時使用
- **文字顏色**: 固定為白色（配深色遮罩）
- **遮罩透明度**: 可透過 CSS 變數調整

### 注意事項
⚠️ **若使用者未提供影片 URL，此範本不可使用**，應引導選擇其他 Hero 範本。

---

## 4. `hero-minimal` - 極簡式 Hero

### 描述
大量留白，超大標題，極少文字。適合高端品牌或設計導向的頁面。

### 適用場景
- 時尚品牌
- 設計工作室
- 藝術展覽
- 高端產品

### 標籤格式
```xml
<HERO type="minimal">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題（選填）}}</SUBTITLE>
  <CTA text="{{按鈕文字}}" link="{{連結}}"/>
</HERO>
```

### 替換為 HTML
```html
<section class="hero hero--minimal">
  <div class="hero__content">
    <h1 class="hero__title hero__title--huge">{{主標題}}</h1>
    {{如果有副標題}}
    <p class="hero__subtitle hero__subtitle--minimal">{{副標題}}</p>
    {{結束如果}}
    <a href="{{連結}}" class="btn btn--text">{{按鈕文字}}</a>
  </div>
</section>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.hero--minimal {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4rem;
}

.hero__content {
  max-width: 1200px;
  text-align: center;
}

.hero__title--huge {
  font-size: 5rem; /* 超大！ */
  font-weight: 300; /* 細體 */
  line-height: 1.1;
  letter-spacing: -0.02em;
  margin-bottom: 2rem;
}

.hero__subtitle--minimal {
  font-size: 1.25rem;
  font-weight: 300;
  margin-bottom: 3rem;
  opacity: 0.8;
}

.btn--text {
  background: transparent;
  color: var(--text-primary);
  border-bottom: 2px solid currentColor;
  padding: 0.5rem 0;
  border-radius: 0;
}

.btn--text:hover {
  background: transparent;
  border-bottom-width: 3px;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .hero--minimal {
    padding: 3rem 1.5rem;
  }

  .hero__title--huge {
    font-size: 3rem;
  }

  .hero__subtitle--minimal {
    font-size: 1.125rem;
  }
}
```

### CSS 變數依賴
```css
--text-primary
--bg-primary
```

### 設計建議
- **標題長度**: 15-30 字元（越短越好）
- **副標題**: 可選，若使用則 40-60 字元
- **字體**: 建議使用細體（font-weight: 300）
- **顏色**: 黑白或極簡配色
- **留白**: 大量留白是關鍵
- **CTA**: 使用文字連結而非按鈕

---

## 5. `hero-form` - 表單式 Hero

### 描述
包含表單的 Hero，適合 Lead 收集、電子報訂閱等轉換導向的頁面。

### 適用場景
- Email 訂閱頁
- 產品試用申請
- 活動報名
- Newsletter

### 標籤格式
```xml
<HERO type="form">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題}}</SUBTITLE>
  <FORM action="{{提交URL}}" submitText="{{送出按鈕文字}}">
    <FIELD type="email" placeholder="{{提示文字}}" required="true"/>
  </FORM>
  <PRIVACY>{{隱私權聲明（選填）}}</PRIVACY>
</HERO>
```

### 替換為 HTML
```html
<section class="hero hero--form">
  <div class="hero__content">
    <h1 class="hero__title">{{主標題}}</h1>
    <p class="hero__subtitle">{{副標題}}</p>

    <form class="hero__form" action="{{提交URL}}" method="POST">
      <div class="form-group">
        <input
          type="email"
          name="email"
          placeholder="{{提示文字}}"
          required
          class="form-input form-input--large"
        />
        <button type="submit" class="btn btn--primary btn--large">
          {{送出按鈕文字}}
        </button>
      </div>
      {{如果有隱私權聲明}}
      <p class="form-privacy">{{隱私權聲明}}</p>
      {{結束如果}}
    </form>
  </div>
</section>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.hero--form {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 0 2rem;
}

.hero__content {
  max-width: 600px;
  width: 100%;
}

.hero__title {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.hero__subtitle {
  font-size: 1.25rem;
  margin-bottom: 2.5rem;
  opacity: 0.9;
}

.hero__form {
  width: 100%;
}

.form-group {
  display: flex;
  gap: 1rem;
}

.form-input--large {
  flex: 1;
  padding: 1rem 1.5rem;
  font-size: 1rem;
  border: 2px solid var(--border-color);
  border-radius: 4px;
}

.form-input--large:focus {
  outline: none;
  border-color: var(--primary-color);
}

.btn--large {
  padding: 1rem 2.5rem;
  white-space: nowrap;
}

.form-privacy {
  margin-top: 1rem;
  font-size: 0.875rem;
  opacity: 0.7;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .hero__title {
    font-size: 2rem;
  }

  .hero__subtitle {
    font-size: 1.125rem;
  }

  .form-group {
    flex-direction: column;
  }

  .btn--large {
    width: 100%;
  }
}
```

### CSS 變數依賴
```css
--text-primary
--bg-primary
--border-color
--primary-color
--btn-primary-bg
--btn-primary-color
```

### 設計建議
- **表單欄位**: 建議只有 1 個（email），越簡單轉換率越高
- **CTA 文字**: 明確（如「立即訂閱」「免費試用」「開始使用」）
- **隱私權聲明**: 建議加入（提高信任度）
- **提交 URL**: 必須提供（連接到 Email 服務如 Mailchimp）

### 表單整合
- **Mailchimp**: `action="https://...us1.list-manage.com/subscribe/post"`
- **ConvertKit**: `action="https://app.convertkit.com/forms/..."`
- **自訂後端**: 提供 API endpoint

---

# 📦 內容區塊範本

## 6. `features-3col` - 三欄特色介紹

### 描述
三欄式特色展示，每欄包含圖示、標題和說明文字。

### 標籤格式
```xml
<SECTION type="features-3col">
  <HEADING>{{區塊大標題（選填）}}</HEADING>
  <FEATURE>
    <ICON>{{圖示名稱或emoji}}</ICON>
    <TITLE>{{特色標題}}</TITLE>
    <TEXT>{{特色說明}}</TEXT>
  </FEATURE>
  <FEATURE>...</FEATURE>
  <FEATURE>...</FEATURE>
</SECTION>
```

### 替換為 HTML
```html
<section class="features features--3col">
  <div class="container">
    {{如果有大標題}}
    <h2 class="section-heading">{{區塊大標題}}</h2>
    {{結束如果}}

    <div class="features__grid">
      <div class="feature">
        <div class="feature__icon">{{圖示}}</div>
        <h3 class="feature__title">{{特色標題}}</h3>
        <p class="feature__text">{{特色說明}}</p>
      </div>
      <!-- 重複其他 FEATURE -->
    </div>
  </div>
</section>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.features--3col {
  padding: 5rem 0;
}

.features__grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 3rem;
}

.feature {
  text-align: center;
}

.feature__icon {
  font-size: 3rem;
  margin-bottom: 1.5rem;
}

.feature__title {
  font-size: 1.5rem;
  margin-bottom: 1rem;
}

.feature__text {
  font-size: 1rem;
  opacity: 0.8;
  line-height: 1.6;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .features__grid {
    grid-template-columns: 1fr;
    gap: 2.5rem;
  }
}
```

### 設計建議
- **特色數量**: 3 個（可 6 個，兩排）
- **圖示**: 使用 emoji 或 Font Awesome
- **標題長度**: 10-20 字元
- **說明長度**: 60-100 字元

---

## 7. `features-2col` - 兩欄特色介紹

### 描述
兩欄式，適合特色較多或需要更多說明文字的情況。

### 標籤格式
```xml
<SECTION type="features-2col">
  <HEADING>{{區塊大標題（選填）}}</HEADING>
  <FEATURE>
    <ICON>{{圖示}}</ICON>
    <TITLE>{{特色標題}}</TITLE>
    <TEXT>{{特色說明}}</TEXT>
  </FEATURE>
  <FEATURE>...</FEATURE>
</SECTION>
```

### 響應式行為
```css
/* Desktop (≥ 768px) */
.features--2col .features__grid {
  grid-template-columns: repeat(2, 1fr);
  gap: 3rem;
}

/* Mobile (< 768px) */
@media (max-width: 767px) {
  .features--2col .features__grid {
    grid-template-columns: 1fr;
  }
}
```

---

## 8. `testimonials` - 客戶見證（輪播）

### 描述
客戶評價展示，可輪播。

### 標籤格式
```xml
<SECTION type="testimonials">
  <HEADING>{{區塊大標題}}</HEADING>
  <TESTIMONIAL>
    <QUOTE>{{評價內容}}</QUOTE>
    <AUTHOR>{{客戶姓名}}</AUTHOR>
    <ROLE>{{客戶身份（選填）}}</ROLE>
    <AVATAR>{{頭像URL（選填）}}</AVATAR>
  </TESTIMONIAL>
  <TESTIMONIAL>...</TESTIMONIAL>
</SECTION>
```

### 替換為 HTML
```html
<section class="testimonials">
  <div class="container">
    <h2 class="section-heading">{{區塊大標題}}</h2>

    <div class="testimonials__slider">
      <div class="testimonial">
        <blockquote class="testimonial__quote">「{{評價內容}}」</blockquote>
        <div class="testimonial__author">
          {{如果有頭像}}
          <img src="{{頭像URL}}" alt="{{客戶姓名}}" class="testimonial__avatar" />
          {{結束如果}}
          <div>
            <p class="testimonial__name">{{客戶姓名}}</p>
            {{如果有身份}}
            <p class="testimonial__role">{{客戶身份}}</p>
            {{結束如果}}
          </div>
        </div>
      </div>
      <!-- 重複其他見證 -->
    </div>

    <!-- 輪播控制（選填） -->
    <div class="testimonials__nav">
      <button class="testimonials__prev">←</button>
      <button class="testimonials__next">→</button>
    </div>
  </div>
</section>
```

### 響應式行為
```css
.testimonials {
  padding: 5rem 0;
  background: var(--bg-secondary);
}

.testimonial {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
}

.testimonial__quote {
  font-size: 1.5rem;
  line-height: 1.6;
  margin-bottom: 2rem;
  font-style: italic;
}

.testimonial__author {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.testimonial__avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
}

@media (max-width: 767px) {
  .testimonial__quote {
    font-size: 1.125rem;
  }
}
```

---

## 9. `pricing` - 價格方案（卡片式）

### 描述
價格方案展示，卡片式佈局。

### 標籤格式
```xml
<SECTION type="pricing">
  <HEADING>{{區塊大標題}}</HEADING>
  <PLAN featured="false">
    <NAME>{{方案名稱}}</NAME>
    <PRICE currency="NT$">{{價格}}</PRICE>
    <PERIOD>{{計價週期}}</PERIOD>
    <FEATURES>
      <ITEM>{{功能項目1}}</ITEM>
      <ITEM>{{功能項目2}}</ITEM>
    </FEATURES>
    <CTA text="{{按鈕文字}}" link="{{連結}}"/>
  </PLAN>
  <PLAN featured="true">...</PLAN>
</SECTION>
```

### 替換為 HTML
```html
<section class="pricing">
  <div class="container">
    <h2 class="section-heading">{{區塊大標題}}</h2>

    <div class="pricing__grid">
      <div class="pricing-card {{如果featured}}pricing-card--featured{{結束}}">
        {{如果featured}}
        <div class="pricing-card__badge">推薦</div>
        {{結束}}

        <h3 class="pricing-card__name">{{方案名稱}}</h3>
        <div class="pricing-card__price">
          <span class="pricing-card__currency">{{貨幣}}</span>
          <span class="pricing-card__amount">{{價格}}</span>
          <span class="pricing-card__period">/{{計價週期}}</span>
        </div>

        <ul class="pricing-card__features">
          <li>{{功能項目1}}</li>
          <li>{{功能項目2}}</li>
        </ul>

        <a href="{{連結}}" class="btn {{如果featured}}btn--primary{{否則}}btn--secondary{{結束}}">
          {{按鈕文字}}
        </a>
      </div>
    </div>
  </div>
</section>
```

### 響應式行為
```css
.pricing {
  padding: 5rem 0;
}

.pricing__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  max-width: 1000px;
  margin: 0 auto;
}

.pricing-card {
  border: 2px solid var(--border-color);
  border-radius: 8px;
  padding: 2.5rem;
  text-align: center;
  transition: transform 0.3s;
}

.pricing-card:hover {
  transform: translateY(-8px);
}

.pricing-card--featured {
  border-color: var(--primary-color);
  position: relative;
  transform: scale(1.05);
}

.pricing-card__badge {
  position: absolute;
  top: -12px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--primary-color);
  color: white;
  padding: 0.25rem 1rem;
  border-radius: 999px;
  font-size: 0.875rem;
}

.pricing-card__price {
  font-size: 3rem;
  font-weight: bold;
  margin: 1.5rem 0;
}

.pricing-card__features {
  list-style: none;
  padding: 0;
  margin: 2rem 0;
  text-align: left;
}

.pricing-card__features li {
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--border-color);
}

.pricing-card__features li:before {
  content: "✓ ";
  color: var(--primary-color);
  font-weight: bold;
}
```

---

## 10. `gallery` - 圖庫（Grid 佈局）

### 標籤格式
```xml
<SECTION type="gallery" columns="3">
  <HEADING>{{區塊大標題（選填）}}</HEADING>
  <IMAGE url="{{圖片URL}}" alt="{{描述}}"/>
  <IMAGE url="{{圖片URL}}" alt="{{描述}}"/>
  <IMAGE url="{{圖片URL}}" alt="{{描述}}"/>
</SECTION>
```

### 替換為 HTML
```html
<section class="gallery">
  <div class="container">
    {{如果有大標題}}
    <h2 class="section-heading">{{區塊大標題}}</h2>
    {{結束}}

    <div class="gallery__grid gallery__grid--{{columns}}col">
      <div class="gallery__item">
        <img src="{{圖片URL}}" alt="{{描述}}" loading="lazy" />
      </div>
      <!-- 重複 -->
    </div>
  </div>
</section>
```

### 響應式行為
```css
.gallery {
  padding: 5rem 0;
}

.gallery__grid--3col {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.gallery__item {
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: 8px;
}

.gallery__item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.gallery__item:hover img {
  transform: scale(1.05);
}

@media (max-width: 767px) {
  .gallery__grid--3col {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

---

## 11. `video-embed` - 影片嵌入

### 標籤格式
```xml
<SECTION type="video-embed">
  <HEADING>{{區塊大標題（選填）}}</HEADING>
  <VIDEO
    platform="youtube"
    videoId="{{影片ID}}"
    aspectRatio="16:9"
  />
</SECTION>
```

### 替換為 HTML
```html
<section class="video-section">
  <div class="container">
    {{如果有大標題}}
    <h2 class="section-heading">{{區塊大標題}}</h2>
    {{結束}}

    <div class="video-container video-container--16-9">
      <iframe
        src="https://www.youtube.com/embed/{{影片ID}}"
        frameborder="0"
        allowfullscreen
        loading="lazy"
      ></iframe>
    </div>
  </div>
</section>
```

### 響應式行為
```css
.video-section {
  padding: 5rem 0;
}

.video-container {
  position: relative;
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
}

.video-container--16-9 {
  padding-bottom: 56.25%; /* 16:9 比例 */
}

.video-container iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 8px;
}
```

---

## 12. `text-section` - 純文字段落

### 標籤格式
```xml
<SECTION type="text">
  <HEADING>{{區塊標題}}</HEADING>
  <CONTENT>
    {{Markdown 格式文字內容}}
  </CONTENT>
</SECTION>
```

### 替換為 HTML
```html
<section class="text-section">
  <div class="container container--narrow">
    <h2 class="section-heading">{{區塊標題}}</h2>
    <div class="text-content">
      {{將 Markdown 轉為 HTML}}
    </div>
  </div>
</section>
```

### 響應式行為
```css
.text-section {
  padding: 5rem 0;
}

.container--narrow {
  max-width: 800px;
}

.text-content {
  font-size: 1.125rem;
  line-height: 1.8;
}

.text-content p {
  margin-bottom: 1.5rem;
}

.text-content h3 {
  margin-top: 2.5rem;
  margin-bottom: 1rem;
}
```

---

## 13. `cta-footer` - 底部行動呼籲

### 描述
頁面底部的最後一次行動呼籲，通常顏色醒目。

### 標籤格式
```xml
<SECTION type="cta-footer">
  <TITLE>{{主標題}}</TITLE>
  <SUBTITLE>{{副標題（選填）}}</SUBTITLE>
  <CTA text="{{按鈕文字}}" link="{{連結}}"/>
</SECTION>
```

### 替換為 HTML
```html
<section class="cta-footer">
  <div class="container">
    <div class="cta-footer__content">
      <h2 class="cta-footer__title">{{主標題}}</h2>
      {{如果有副標題}}
      <p class="cta-footer__subtitle">{{副標題}}</p>
      {{結束}}
      <a href="{{連結}}" class="btn btn--large btn--primary">{{按鈕文字}}</a>
    </div>
  </div>
</section>
```

### 響應式行為
```css
.cta-footer {
  padding: 5rem 0;
  background: var(--primary-color);
  color: white;
  text-align: center;
}

.cta-footer__title {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.cta-footer__subtitle {
  font-size: 1.25rem;
  margin-bottom: 2rem;
  opacity: 0.9;
}

@media (max-width: 767px) {
  .cta-footer__title {
    font-size: 2rem;
  }
}
```

---

## 🔧 通用 CSS 基礎

### Container
```css
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.5rem;
}
```

### Section Heading
```css
.section-heading {
  font-size: 2.5rem;
  text-align: center;
  margin-bottom: 3rem;
}

@media (max-width: 767px) {
  .section-heading {
    font-size: 2rem;
  }
}
```

### 按鈕基礎
```css
.btn {
  display: inline-block;
  padding: 0.75rem 2rem;
  border-radius: 4px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
  border: none;
  cursor: pointer;
}

.btn--primary {
  background: var(--btn-primary-bg);
  color: var(--btn-primary-color);
}

.btn--primary:hover {
  background: var(--btn-primary-hover);
}

.btn--secondary {
  background: transparent;
  color: var(--primary-color);
  border: 2px solid var(--primary-color);
}

.btn--large {
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
}
```

---

## 📝 範本使用統計

| 類型 | 數量 | 重要度 |
|------|------|--------|
| Hero 範本 | 5 | ⭐⭐⭐⭐⭐ |
| 內容區塊 | 8 | ⭐⭐⭐⭐ |
| **總計** | **13** | - |

---

## ✅ 範本完整性檢查清單

每個範本都必須包含：
- [ ] 標籤格式定義
- [ ] HTML 輸出範例
- [ ] Desktop 響應式行為
- [ ] Mobile 響應式行為
- [ ] CSS 變數依賴清單
- [ ] 設計建議

---

**版本更新記錄**:
- v2.0 (2025-11-20): 全新格式，改為標籤→HTML 映射
- v1.0 (2025-11-18): 初版（已廢棄）
