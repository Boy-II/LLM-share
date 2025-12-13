# 主LLM標籤生成指南

## 目標
主LLM負責分析情境並生成**語義完整的粗糙標籤**,供8B模型格式化。

---

## 必需元素清單

### 核心必需元素 (每次都要)

#### 1. 人物基本信息
```
必需:
- 數量: 1girl, 2boys, 3girls, etc.
- 性別: girl/boy/man/woman

可選但重要:
- 年齡層: child, teen, adult (可省略,默認young adult)
```

**範例:**
```
✅ 正確: 1girl
✅ 正確: 2girls 1boy
❌ 錯誤: 紅髮的人 (沒有明確性別和數量)
```

#### 2. 外觀特徵
```
必需至少包含:
- 髮色: red hair, blonde hair, black hair
- 髮型: long hair, short hair, twin tails, ponytail

強烈建議:
- 眼睛顏色: blue eyes, green eyes, heterochromia
- 膚色(非默認時): dark skin, pale skin, tan

加分項:
- 身高/體型: tall, short, petite, curvy
- 特殊特徵: cat ears, wings, horns, tattoo
```

**範例:**
```
✅ 完整: 紅色長髮, 藍色眼睛, 貓耳
✅ 最小: 金色短髮
❌ 不足: 女孩 (缺少外觀)
```

#### 3. 服裝
```
必需:
- 服裝類型: dress, suit, school uniform, casual clothes

建議:
- 顏色: white dress, black suit
- 風格: Victorian dress, modern casual
- 關鍵配件: hat, glasses, gloves

可選:
- 細節: frills, ribbons, buttons
```

**範例:**
```
✅ 完整: 白色連衣裙,有蕾絲邊,戴帽子
✅ 簡單: 黑色西裝
✅ 最小: 休閒服裝
❌ 不足: (沒有服裝描述)
```

#### 4. 動作/姿勢
```
必需(擇一):
- 靜態: standing, sitting, lying down, kneeling
- 動態: running, jumping, dancing, fighting
- 互動: hugging, holding hands, looking at each other

建議補充:
- 手部動作: holding book, waving, pointing
- 表情: smiling, surprised, angry, calm
- 視線: looking at viewer, looking away, eyes closed
```

**範例:**
```
✅ 完整: 站立,微笑,看向鏡頭,手拿書
✅ 簡單: 坐著看書
✅ 最小: 站立
❌ 不足: (沒有動作描述,人物會很僵硬)
```

#### 5. 場景/背景
```
必需(擇一):
- 具體場所: in park, in classroom, at beach, indoor/outdoor
- 環境類型: urban, nature, fantasy setting
- 簡單背景: white background, simple background

建議補充:
- 環境元素: trees, buildings, furniture
- 天氣/時間: sunny day, night, sunset, rainy
```

**範例:**
```
✅ 完整: 在公園,櫻花樹下,陽光明媚
✅ 簡單: 教室內
✅ 最小: 室內
❌ 可接受: (純白背景時可省略)
```

---

## 可選增強元素

### 構圖相關
```
何時需要:
- 需要特定視角: from above, from side, bird's eye view
- 需要特定取景: close-up, full body, upper body, portrait
- 特殊鏡頭: dutch angle, wide shot, fisheye

默認: 不指定時AI會自動決定合適構圖
```

**範例:**
```
特寫人物 → "close-up portrait"
全身照 → "full body shot"
多人場景 → "wide shot"
```

### 光影氛圍
```
何時需要:
- 特定時間: sunset, golden hour, night
- 特定光源: dramatic lighting, rim light, backlight
- 特殊氛圍: moody, bright, dark

默認: 不指定時使用標準光照
```

**範例:**
```
戲劇性場景 → "dramatic lighting, strong shadows"
柔和肖像 → "soft lighting, gentle glow"
夜晚場景 → "night, moonlight, dim lighting"
```

### 藝術風格
```
何時需要:
- 明確風格要求: anime, realistic, oil painting
- 特定藝術家風格: in the style of [artist]

默認: 模型會使用訓練時的主要風格
```

**範例:**
```
寫實照片 → "realistic, photorealistic"
動漫風格 → "anime style, cel shading"
水彩畫 → "watercolor painting"
```

### 質量標籤
```
建議加入(尤其是illustrious模型):
- masterpiece, best quality, high resolution
- detailed, intricate

位置: 通常放在最前面或最後面
```

---

## 圖片比例判斷規則

### 判斷邏輯

```
判斷流程:
1. 統計人物數量
2. 檢查場景類型
3. 分析構圖需求
4. 決定比例
```

### 人物數量規則

#### 單人 (1girl/1boy)
```
默認: 3:4 (豎版) 或 2:3
理由: 
- 肖像取向
- 適合全身/半身
- 更多垂直細節空間

例外 → 橫版:
- 躺臥姿勢: lying down, on bed
- 橫向動作: running sideways, reaching across
- 環境重要: in vast landscape, panoramic view
```

**判斷關鍵詞:**
```
豎版關鍵詞:
- standing, sitting, walking toward
- portrait, upper body
- tall, looking up/down

橫版關鍵詞:
- lying, reclining, on side
- reaching, stretching horizontally
- panoramic, wide landscape
```

**範例:**
```
輸入: 女孩站立,全身
判斷: 站立+全身 → 豎版
輸出: 比例 3:4 或 2:3

輸入: 女孩躺在床上
判斷: 躺臥 → 橫版
輸出: 比例 4:3 或 16:9

輸入: 女孩在廣闊草原
判斷: 環境強調 → 橫版
輸出: 比例 16:9
```

#### 雙人 (2girls/1girl 1boy等)
```
默認: 4:3 (橫版) 或 1:1 (方形)
理由: 需要橫向空間容納兩人

特殊情況 → 豎版:
- 上下排列: one above another
- 擁抱/親密: hugging, very close
- 縱向構圖: stacked composition
```

**判斷關鍵詞:**
```
橫版關鍵詞 (優先):
- side by side, next to each other
- facing each other, confrontation
- left and right, 左右, 對面

方形關鍵詞:
- together, hugging, embracing
- close together, intimate
- dancing together, interacting

豎版關鍵詞 (少見):
- one above another, vertical
- piggyback, carrying
- stacked, layered
```

**範例:**
```
輸入: 兩個女孩並排站立
判斷: 並排 → 橫版
輸出: 比例 4:3

輸入: 兩個女孩擁抱
判斷: 親密互動 → 方形
輸出: 比例 1:1

輸入: 男孩背著女孩
判斷: 縱向排列 → 豎版
輸出: 比例 3:4
```

#### 三人
```
默認: 4:3 或 16:9 (橫版)
理由: 需要更多橫向空間

極少例外 → 豎版/方形:
- 三層堆疊: stacked vertically
- 特殊縱向構圖: pyramid formation (底部2人,頂部1人可能還是橫版)
```

**範例:**
```
輸入: 三個女孩並排
判斷: 並排 → 寬橫版
輸出: 比例 16:9

輸入: 三個女孩圍成一圈
判斷: 環形 → 方形
輸出: 比例 1:1
```

#### 四人以上
```
固定: 16:9 或 4:3 (橫版)
理由: 群體場景需要寬幅
例外: 幾乎沒有
```

### 場景類型規則

```
場景類型影響比例:

自然景觀 → 橫版優先
- landscape, mountain, ocean view, vast field
- 推薦: 16:9, 21:9

建築內部 → 根據空間
- 寬敞大廳: 橫版 16:9
- 走廊/樓梯: 豎版 3:4
- 房間: 方形 1:1

特殊環境 → 特定比例
- 天空/飛行: 豎版 2:3 或橫版 16:9 (看視角)
- 水下: 橫版 16:9
- 森林: 豎版 3:4 (樹木垂直)
```

### 構圖類型規則

```
肖像特寫 → 豎版
- close-up, portrait, face focus
- 推薦: 3:4, 2:3

全身照 → 豎版
- full body, standing pose
- 推薦: 3:4, 9:16

半身照 → 彈性
- upper body, cowboy shot
- 推薦: 1:1, 3:4

環境照 → 橫版
- wide shot, establishing shot
- 推薦: 16:9, 4:3

動作場景 → 看動作方向
- 橫向: 橫版
- 縱向: 豎版
```

### 決策表

| 人物 | 默認比例 | 場景 | 調整後 | 關鍵詞觸發 |
|------|----------|------|--------|------------|
| 1人 | 3:4 豎 | 站/坐 | 3:4 | standing, portrait |
| 1人 | 3:4 豎 | 躺 | 4:3 橫 | lying, reclining |
| 1人 | 3:4 豎 | 景觀 | 16:9 橫 | landscape, vast |
| 2人 | 4:3 橫 | 並排 | 4:3 | side by side |
| 2人 | 4:3 橫 | 擁抱 | 1:1 | hugging, close |
| 3人 | 4:3 橫 | 並排 | 16:9 | in a row |
| 4人+ | 16:9 橫 | 任何 | 16:9 | group |

### 標準比例代碼

```
豎版:
- 2:3   (portrait, 適合單人半身/全身)
- 3:4   (standard portrait, 最常用豎版)
- 9:16  (mobile portrait, 極端豎版)

方形:
- 1:1   (square, 適合雙人互動)

橫版:
- 4:3   (standard landscape, 最常用橫版)
- 16:9  (widescreen, 適合多人/景觀)
- 21:9  (ultra-wide, 極端橫版/電影感)
```

### 輸出格式

主LLM應該在標籤中包含:
```
[ASPECT_RATIO] 比例代碼 [/ASPECT_RATIO]

範例:
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
一個紅髮女孩站立,全身,在公園...

[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
三個女孩並排站立,在海邊...
```

---

## 主LLM標籤生成完整模板

### 基礎模板

```
[ASPECT_RATIO] 比例 [/ASPECT_RATIO]

[人物數量+性別], 
[髮色+髮型], [眼睛顏色],
[服裝描述],
[動作姿勢], [表情], [手部動作],
[場景位置], [環境元素],
[可選: 光照], [可選: 氛圍]

[可選: 特殊指令如視角、構圖]
```

### 範例1: 單人簡單場景
```
輸入: 創作一個女孩在咖啡廳看書的場景

主LLM輸出:
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long brown hair, green eyes, 
wearing casual sweater and jeans,
sitting at table, reading book, calm expression,
in cafe, coffee cup on table, 
warm lighting, cozy atmosphere
```

### 範例2: 雙人互動場景
```
輸入: 兩個女孩在公園草地上野餐

主LLM輸出:
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
2girls,
first girl: blonde long hair, blue eyes, white sundress
second girl: black short hair, brown eyes, pink t-shirt and shorts
sitting on grass, having picnic, smiling, chatting with each other
in park, under tree, picnic basket and food,
sunny day, dappled sunlight
```

### 範例3: 多人複雜場景
```
輸入: 三個學生在教室,老師在講課

主LLM輸出:
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
3girls 1woman,
students: varied hair colors, school uniforms, sitting at desks
teacher: adult woman, professional attire, standing at blackboard
teaching scene, students taking notes, listening attentively
in classroom, desks and chairs, blackboard with writing,
daylight through windows
```

### 範例4: 動態場景
```
輸入: 女孩在跳舞,裙子飄逸

主LLM輸出:
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long flowing red hair, blue eyes,
wearing flowing white dress,
dancing, dynamic pose, dress flowing with movement, joyful expression
on stage or open space, 
dramatic lighting, spotlight, motion blur on dress edges
```

---

## 主LLM與8B模型的分工

### 主LLM負責 (語義層)
```
✅ 分析情境和情感
✅ 確定人物數量和關係
✅ 描述外觀和服裝
✅ 確定動作和互動
✅ 設定場景和氛圍
✅ 判斷合適的圖片比例
✅ 決定是否需要特定LoRA (語義層面,如"需要詳細的眼睛")
```

### 8B模型負責 (語法層)
```
✅ 轉換為Prompt Control語法
✅ 添加權重 (red hair:1.2)
✅ 設置AREA/MASK座標
✅ 決定CUT使用
✅ 確定LoRA的精確插入點 (0.7開始)
✅ 添加時間調度 [before:after:0.5]
✅ 組織BREAK分段
✅ 添加技術性細節標籤 (masterpiece, best quality)
```

---

## 主LLM標籤生成檢查清單

生成標籤後,自我檢查:

```
□ 人物數量明確 (1girl, 2boys, etc.)
□ 外觀特徵至少包含髮色髮型
□ 服裝有基本描述
□ 動作/姿勢明確
□ 場景/背景設定清楚
□ 圖片比例已判斷
□ 沒有使用Prompt Control語法 (留給8B模型)
□ 描述清晰,沒有歧義
□ 多人時人物區分清楚
□ 特殊需求已註明 (如"需要眼睛細節")
```

---

## 錯誤範例與修正

### 錯誤1: 信息不足
```
❌ 錯誤:
一個女孩

✅ 修正:
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long black hair, brown eyes,
wearing school uniform,
standing, smiling, looking at viewer,
simple background
```

### 錯誤2: 過度格式化
```
❌ 錯誤 (這是8B模型的工作):
1girl, (red hair:1.2), [::<lora:eye_detail:0.8>:0.7]

✅ 修正:
1girl, red hair, blue eyes, detailed eyes
```

### 錯誤3: 人物區分不清
```
❌ 錯誤:
兩個女孩,一個紅髮一個藍髮

✅ 修正:
2girls,
first girl: red long hair, green eyes, white dress
second girl: blue short hair, brown eyes, black dress
```

### 錯誤4: 比例判斷錯誤
```
❌ 錯誤:
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
三個女孩並排站立

✅ 修正:
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
3girls, standing in a row, side by side
```

---

## 快速參考

### 最小必需元素 (5要素)
1. 人物數量性別
2. 髮色髮型
3. 服裝類型
4. 動作姿勢
5. 場景背景

### 圖片比例速記
- 1人 → 3:4 (豎)
- 2人 → 4:3 (橫) 或 1:1
- 3人+ → 16:9 (橫)
- 躺臥 → 橫版
- 景觀 → 橫版

### 提高質量的加分項
- 眼睛顏色
- 表情
- 手部動作
- 視線方向
- 光照氛圍
- 環境細節

記住: **主LLM專注語義,8B模型專注語法!**
