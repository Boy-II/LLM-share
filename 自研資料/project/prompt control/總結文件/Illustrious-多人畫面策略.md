# ComfyUI Prompt Control - Illustrious 多人畫面策略指南

> 適用於 Illustrious/NoobAI 等 SDXL 衍生動漫模型
> 
> 作者: Boy | 更新日期: 2025-11-11

---

## 目錄

1. [基礎概念](#基礎概念)
2. [2人場景策略](#2人場景策略)
3. [3人場景策略](#3人場景策略)
4. [4人場景策略](#4人場景策略)
5. [LoRA 使用策略](#lora-使用策略)
6. [提示詞污染防治](#提示詞污染防治)
7. [常見問題排除](#常見問題排除)

---

## 基礎概念

### 核心節點

- **PCLazyTextEncode** (PC: Schedule Prompt) - 主要提示詞編碼節點
- **PCLazyLoraLoader** (PC: Schedule LoRas) - LoRA 排程加載器
- **PPCAttentionCoupleBatchNegative** - Attention Couple 效能優化節點
- **PC: Attach Mask** - 自訂遮罩附加節點

### 關鍵語法

```
ATTN()          - Attention Couple 標記
MASK(x1 x2, y1 y2, weight)  - 區域遮罩 (0-1 百分比或像素值)
AREA(x1 x2, y1 y2, weight)  - 區域生成控制
FEATHER(l t r b)  - 羽化邊緣 (像素值)
CUT             - Token 隔離/Cutoff
AND             - 提示詞片段分隔符
TE(encoder=text) - SDXL 雙編碼器控制
```

### Illustrious 特性

- **雙編碼器**: CLIP-L (細節) + CLIP-G (整體風格)
- **Danbooru Tags**: 對標籤順序敏感
- **推薦 CFG**: 6-8 (不要過高)
- **Clip Skip**: 2
- **容易混淆**: 顏色、髮型、服裝細節

---

## 2人場景策略

### 策略 A: 左右分割 (最常用)

#### 基礎結構

```
基礎品質標籤 + 場景描述 BREAK
ATTN() 角色1提示詞 MASK(左半區域) FEATHER(...) AND
ATTN() 角色2提示詞 MASK(右半區域) FEATHER(...)
```

#### 完整範例 1: 標準左右站姿

```
# Positive Prompt
masterpiece, best quality, highly detailed, absurdres, 2girls, park, trees, blue sky, outdoor, day BREAK
ATTN() [CUT:blue blonde short:] 1girl, solo focus, red dress, long dress, frilled dress, ribbon, long hair, black hair, straight hair, blue eyes, standing, hand on hip, looking at viewer, serious, left side, from side MASK(0 0.4, 0 1, 1.0) FEATHER(30 0 30 0) AND
ATTN() [CUT:red black long:] 1girl, solo focus, blue dress, short dress, sleeveless dress, simple dress, short hair, blonde hair, wavy hair, green eyes, standing, arms up, waving, open mouth, smile, cheerful, right side, from side MASK(0.6 1, 0 1, 1.0) FEATHER(30 0 30 0)

# Negative Prompt
lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, merged bodies, color bleeding, mixed colors, fused clothes, same face, twins
```

**關鍵參數說明**:
- `MASK(0 0.4, 0 1)`: 左側角色佔 0-40%
- `MASK(0.6 1, 0 1)`: 右側角色佔 60-100%
- 中間 40-60% 為緩衝區,避免硬邊界
- `FEATHER(30 0 30 0)`: 左右羽化 30px,上下不羽化

#### 完整範例 2: 互動場景

```
# Positive Prompt
masterpiece, best quality, 2girls, cafe interior, table, chairs, window, afternoon light BREAK
ATTN() [CUT:blonde short standing:] 1girl, solo focus, white shirt, black skirt, long hair, brown hair, ponytail, sitting, drinking coffee, holding cup, relaxed expression, left side MASK(0 0.45, 0.2 1, 1.0) FEATHER(25 15 25 15) AND
ATTN() [CUT:brown long sitting:] 1girl, solo focus, pink sweater, blue jeans, short hair, blonde hair, bob cut, standing, leaning forward, hand on table, talking, happy, smiling, right side MASK(0.55 1, 0 1, 1.0) FEATHER(25 15 25 15)

# Negative Prompt
lowres, bad anatomy, merged bodies, same character, identical twins, color bleeding
```

**適用情境**:
- 日常互動場景
- 對話、喝茶、用餐等
- 需要桌子等道具分隔

### 策略 B: 前後景深

#### 基礎結構

```
基礎標籤 + depth of field BREAK
ATTN() 前景角色 MASK(中心大區域) AREA(前景, 權重>1) AND
ATTN() 後景角色 MASK(背景小區域) AREA(背景, 權重<1)
```

#### 完整範例: 教室場景

```
# Positive Prompt
masterpiece, best quality, depth of field, bokeh, 2girls, classroom, desks, window, blackboard BREAK
ATTN() [CUT:blonde standing background:] 1girl, solo focus, red sweater, pleated skirt, long hair, black hair, sitting, desk, chair, writing, notebook, foreground, close-up, looking at viewer, detailed face MASK(0.2 0.8, 0.3 1, 1.2) AREA(0.2 0.8, 0.3 1, 1.3) AND
ATTN() [CUT:black sitting foreground:] 1girl, solo focus, blue school uniform, sailor collar, short hair, blonde hair, standing, at blackboard, writing, chalk, background, blurry, blurry background MASK(0.3 0.7, 0 0.5, 0.7) AREA(0.3 0.7, 0 0.5, 0.6)

# Negative Prompt
lowres, bad anatomy, merged faces, same depth, flat image, no depth of field
```

**關鍵技巧**:
- 前景使用較大 MASK 和 AREA 權重 (>1.0)
- 後景使用較小權重 (<1.0)
- 加入 `depth of field`, `bokeh` 增強景深感
- 後景角色提示詞加 `blurry background`

### 策略 C: 上下分割

#### 適用情境
- 躺臥場景
- 樓梯、坡道場景
- 跳躍動作

#### 完整範例: 草地躺臥

```
# Positive Prompt
masterpiece, best quality, 2girls, grass field, flowers, blue sky, clouds, sunny BREAK
ATTN() [CUT:sitting standing:] 1girl, solo focus, white dress, sundress, long hair, brown hair, lying down, on back, relaxed, eyes closed, top of image, upper area MASK(0 1, 0 0.5, 1.0) FEATHER(0 25 0 25) AND
ATTN() [CUT:lying:] 1girl, solo focus, yellow dress, short sleeves, short hair, orange hair, sitting, hugging knees, looking at viewer, smiling, bottom of image, lower area MASK(0 1, 0.5 1, 1.0) FEATHER(0 25 0 25)

# Negative Prompt
lowres, bad anatomy, merged bodies, floating, unnatural pose
```

**參數調整**:
- `MASK(0 1, 0 0.5)`: 上半部 Y軸 0-50%
- `MASK(0 1, 0.5 1)`: 下半部 Y軸 50-100%
- `FEATHER(0 25 0 25)`: 上下羽化,左右不羽化

---

## 3人場景策略

### 策略 A: 三等分橫向排列

#### 基礎結構

```
基礎標籤 BREAK
ATTN() 左側角色 MASK(0 0.33) AND
ATTN() 中間角色 MASK(0.33 0.67) AND
ATTN() 右側角色 MASK(0.67 1)
```

#### 完整範例: 並排站姿

```
# Positive Prompt
masterpiece, best quality, highly detailed, 3girls, shopping mall, bright, modern interior BREAK
ATTN() [CUT:pink blue short medium:] 1girl, solo focus, red dress, long dress, long hair, black hair, straight hair, shopping bags, left hand raised, looking at viewer, left side, leftmost MASK(0 0.3, 0 1, 1.0) FEATHER(20 0 20 0) AND
ATTN() [CUT:red blue black blonde:] 1girl, solo focus, pink blouse, white skirt, medium hair, brown hair, wavy hair, hand on hip, confident, looking to side, center, middle MASK(0.35 0.65, 0 1, 1.0) FEATHER(20 0 20 0) AND
ATTN() [CUT:red pink black brown long medium:] 1girl, solo focus, blue jacket, jeans, short hair, blonde hair, bob cut, peace sign, winking, cheerful, right side, rightmost MASK(0.7 1, 0 1, 1.0) FEATHER(20 0 20 0)

# Negative Prompt
lowres, bad anatomy, merged bodies, same face, triplets, color bleeding, mixed hair colors
```

**注意事項**:
- 留 5-10% 緩衝區 (0.3-0.35, 0.65-0.7)
- 每個角色加 `leftmost`, `middle`, `rightmost` 強化位置
- CUT 要排除其他兩個角色的特徵

### 策略 B: 前中後三層景深

#### 完整範例: 走廊場景

```
# Positive Prompt
masterpiece, best quality, depth of field, 3girls, school hallway, lockers, windows, afternoon BREAK
ATTN() [CUT:background middle:] 1girl, solo focus, red cardigan, pleated skirt, long hair, black hair, walking towards viewer, looking at viewer, detailed face, foreground, close-up, sharp focus MASK(0.25 0.75, 0.4 1, 1.3) AREA(0.25 0.75, 0.4 1, 1.4) AND
ATTN() [CUT:foreground background:] 1girl, solo focus, blue vest, white shirt, medium hair, brown hair, standing, side view, talking, middle ground, slightly blurred MASK(0.1 0.4, 0.2 0.8, 0.9) AREA(0.1 0.4, 0.2 0.8, 0.9) AND
ATTN() [CUT:foreground middle:] 1girl, solo focus, green sweater, short hair, blonde hair, walking away, back view, distant, background, blurred, out of focus MASK(0.4 0.7, 0 0.4, 0.5) AREA(0.4 0.7, 0 0.4, 0.5)

# Negative Prompt
lowres, bad anatomy, same depth, no bokeh, sharp background
```

**景深控制**:
- 前景: MASK權重 1.3, AREA權重 1.4
- 中景: MASK權重 0.9, AREA權重 0.9
- 後景: MASK權重 0.5, AREA權重 0.5
- 加入 `sharp focus` / `slightly blurred` / `out of focus`

### 策略 C: 焦點+背景組合

#### 適用情境
- 主角突出,配角陪襯
- 表演、演講場景
- 一個人是重點的場景

#### 完整範例: 歌唱表演

```
# Positive Prompt
masterpiece, best quality, depth of field, 3girls, stage, microphone, spotlight, audience BREAK
ATTN() [CUT:audience background:] 1girl, solo focus, idol costume, pink dress, frills, long hair, twin tails, pink hair, singing, holding microphone, dynamic pose, center stage, foreground, detailed, sharp focus MASK(0.3 0.7, 0.2 1, 1.5) AREA(0.3 0.7, 0.2 1, 1.6) AND
ATTN() [CUT:center pink singing:] 1girl, backup dancer, blue outfit, short hair, brown hair, dancing, left side, background, blurred MASK(0 0.3, 0.3 0.9, 0.6) AREA(0 0.3, 0.3 0.9, 0.6) AND
ATTN() [CUT:center pink singing:] 1girl, backup dancer, purple outfit, medium hair, black hair, dancing, right side, background, blurred MASK(0.7 1, 0.3 0.9, 0.6) AREA(0.7 1, 0.3 0.9, 0.6)

# Negative Prompt
lowres, bad anatomy, same importance, equal focus, no depth
```

---

## 4人場景策略

### 策略 A: 2x2 網格排列

#### 基礎結構

```
基礎標籤 BREAK
ATTN() 左上角色 MASK(0 0.5, 0 0.5) AND
ATTN() 右上角色 MASK(0.5 1, 0 0.5) AND
ATTN() 左下角色 MASK(0 0.5, 0.5 1) AND
ATTN() 右下角色 MASK(0.5 1, 0.5 1)
```

#### 完整範例: 野餐場景

```
# Positive Prompt
masterpiece, best quality, 4girls, picnic, park, grass, picnic blanket, basket, food, sunny day BREAK
ATTN() [CUT:blue pink yellow short medium lying:] 1girl, solo focus, red dress, long hair, black hair, sitting, cross-legged, eating sandwich, upper left, top left corner MASK(0 0.45, 0 0.45, 1.0) FEATHER(25 25 25 25) AND
ATTN() [CUT:red pink yellow long medium lying:] 1girl, solo focus, blue shirt, shorts, short hair, blonde hair, sitting, legs extended, drinking juice, upper right, top right corner MASK(0.55 1, 0 0.45, 1.0) FEATHER(25 25 25 25) AND
ATTN() [CUT:red blue yellow long short:] 1girl, solo focus, pink sundress, medium hair, brown hair, lying down, on stomach, reading book, lower left, bottom left corner MASK(0 0.45, 0.55 1, 1.0) FEATHER(25 25 25 25) AND
ATTN() [CUT:red blue pink long short medium:] 1girl, solo focus, yellow t-shirt, skirt, short hair, orange hair, sitting, playing guitar, lower right, bottom right corner MASK(0.55 1, 0.55 1, 1.0) FEATHER(25 25 25 25)

# Negative Prompt
lowres, bad anatomy, merged bodies, same outfit, same hair, quadruplets, color bleeding
```

**網格參數**:
- 左上: `MASK(0 0.45, 0 0.45)`
- 右上: `MASK(0.55 1, 0 0.45)`
- 左下: `MASK(0 0.45, 0.55 1)`
- 右下: `MASK(0.55 1, 0.55 1)`
- 中間 45-55% 緩衝區

### 策略 B: 菱形/鑽石排列

#### 適用情境
- 樂隊、組合表演
- 戰鬥隊形
- 金字塔構圖

#### 完整範例: 偶像團體

```
# Positive Prompt
masterpiece, best quality, 4girls, stage, spotlights, concert, idol performance BREAK
ATTN() [CUT:back left right:] 1girl, solo focus, center leader, pink idol dress, long hair, pink hair, twin tails, microphone, singing, front center, detailed face, foreground MASK(0.35 0.65, 0.4 1, 1.2) AREA(0.35 0.65, 0.4 1, 1.3) AND
ATTN() [CUT:center right pink:] 1girl, solo focus, blue idol outfit, medium hair, blue hair, dancing, left position, mid-left, slightly behind MASK(0.05 0.4, 0.3 0.8, 0.9) AREA(0.05 0.4, 0.3 0.8, 0.9) AND
ATTN() [CUT:center left pink:] 1girl, solo focus, purple idol outfit, short hair, purple hair, dancing, right position, mid-right, slightly behind MASK(0.6 0.95, 0.3 0.8, 0.9) AREA(0.6 0.95, 0.3 0.8, 0.9) AND
ATTN() [CUT:front center pink blue purple:] 1girl, solo focus, yellow idol outfit, long hair, blonde hair, dancing, back center, background position, most distant MASK(0.4 0.6, 0 0.4, 0.7) AREA(0.4 0.6, 0 0.4, 0.6)

# Negative Prompt
lowres, bad anatomy, same costume, same position, flat formation
```

**菱形構圖權重**:
- 前方中心 (Leader): 權重 1.2-1.3
- 左右兩側: 權重 0.9
- 後方中心: 權重 0.6-0.7

### 策略 C: 橫排站立

#### 完整範例: 樂隊演出

```
# Positive Prompt
masterpiece, best quality, 4girls, live house, stage, instruments, band performance, energetic BREAK
ATTN() [CUT:drums bass keyboard:] 1girl, solo focus, red outfit, guitarist, long hair, black hair, playing guitar, electric guitar, leftmost, far left MASK(0 0.22, 0 1, 1.0) FEATHER(15 0 15 0) AND
ATTN() [CUT:guitar bass keyboard:] 1girl, solo focus, blue outfit, drummer, short hair, brown hair, playing drums, drumsticks, mid-left, second from left MASK(0.26 0.48, 0 1, 1.0) FEATHER(15 0 15 0) AND
ATTN() [CUT:guitar drums keyboard:] 1girl, solo focus, purple outfit, bassist, medium hair, purple hair, playing bass, bass guitar, mid-right, third from left MASK(0.52 0.74, 0 1, 1.0) FEATHER(15 0 15 0) AND
ATTN() [CUT:guitar drums bass:] 1girl, solo focus, yellow outfit, keyboardist, long hair, blonde hair, playing keyboard, synthesizer, rightmost, far right MASK(0.78 1, 0 1, 1.0) FEATHER(15 0 15 0)

# Negative Prompt
lowres, bad anatomy, merged instruments, same instrument, overlapping characters
```

**四等分參數**:
- 位置1: `MASK(0 0.22)`
- 位置2: `MASK(0.26 0.48)`
- 位置3: `MASK(0.52 0.74)`
- 位置4: `MASK(0.78 1)`
- 每段留 4% 緩衝區

---

## LoRA 使用策略

### 角色 LoRA 區域控制

#### 基本原則

1. **LoRA 在 MASK 之前宣告**
2. **每個區域只影響對應 LoRA**
3. **使用 PCLazyLoraLoader 節點**
4. **權重通常 0.7-1.0**

#### 語法結構

```
<lora:角色A:權重> 角色A提示詞 MASK(區域A) AND
<lora:角色B:權重> 角色B提示詞 MASK(區域B)
```

### 2人場景 LoRA 範例

```
# Positive Prompt (使用 PCLazyLoraLoader)
masterpiece, best quality, 2girls, beach, ocean, sunset BREAK
ATTN() <lora:Asuna:0.85> 1girl, asuna \(sao\), solo focus, white dress, long hair, orange hair, blue eyes, standing, looking at viewer, left side MASK(0 0.45, 0 1) FEATHER(30 0 30 0) AND
ATTN() <lora:Saber:0.8> 1girl, saber, artoria pendragon, solo focus, blue dress, ahoge, blonde hair, green eyes, braid, standing, smiling, right side MASK(0.55 1, 0 1) FEATHER(30 0 30 0)

# 在 PCLazyLoraLoader 節點
# 會自動解析 <lora:Asuna:0.85> 和 <lora:Saber:0.8>
# 並應用到對應的 MASK 區域
```

**重要提醒**:
- LoRA 觸發詞必須包含 (如 `asuna \(sao\)`)
- 角色特徵描述要完整
- 權重不要過高,避免過擬合

### 3人場景 LoRA 範例

```
# Positive Prompt
masterpiece, best quality, 3girls, school rooftop, blue sky, clouds BREAK
ATTN() <lora:Rem:0.8> [CUT:pink blue:] 1girl, rem \(re:zero\), solo focus, maid outfit, blue hair, short hair, hair clip, left side MASK(0 0.3, 0 1) FEATHER(20 0 20 0) AND
ATTN() <lora:Ram:0.8> [CUT:blue red:] 1girl, ram \(re:zero\), solo focus, maid outfit, pink hair, short hair, hair clip, center MASK(0.35 0.65, 0 1) FEATHER(20 0 20 0) AND
ATTN() <lora:Emilia:0.75> [CUT:blue pink:] 1girl, emilia \(re:zero\), solo focus, white dress, long hair, silver hair, purple eyes, right side MASK(0.7 1, 0 1) FEATHER(20 0 20 0)
```

### 風格 LoRA + 角色 LoRA 混合

#### 策略: 全局風格 + 區域角色

```
# 方法1: 風格放在基礎提示詞
<lora:anime_style:0.5> masterpiece, best quality, 2girls BREAK
ATTN() <lora:CharacterA:0.8> 1girl, ... MASK(0 0.45, 0 1) AND
ATTN() <lora:CharacterB:0.8> 1girl, ... MASK(0.55 1, 0 1)

# 方法2: 使用 AND 但不加 MASK (全局應用)
<lora:watercolor_style:0.6> watercolor, soft colors AND
ATTN() <lora:CharacterA:0.8> 1girl, ... MASK(0 0.45, 0 1) AND
ATTN() <lora:CharacterB:0.8> 1girl, ... MASK(0.55 1, 0 1)
```

**權重建議**:
- 風格 LoRA: 0.3-0.6 (較低,避免蓋過角色)
- 角色 LoRA: 0.7-1.0 (較高,確保特徵)

### 服裝 LoRA 區域控制

```
# 不同角色穿不同服裝 LoRA
ATTN() <lora:school_uniform:0.7> 1girl, school uniform, black hair MASK(0 0.45, 0 1) AND
ATTN() <lora:maid_outfit:0.7> 1girl, maid dress, blonde hair MASK(0.55 1, 0 1)
```

### LoRA 權重排程 (進階)

```
# 前期強化角色A,後期強化角色B
ATTN() <lora:CharacterA:[1.0:0.7:0.3]> 1girl, ... MASK(0 0.45, 0 1) AND
ATTN() <lora:CharacterB:[0.7:1.0:0.3]> 1girl, ... MASK(0.55 1, 0 1)
```

**語法說明**: `[起始權重:結束權重:切換時間點]`
- `[1.0:0.7:0.3]`: 從 1.0 開始,在生成進度 30% 時降到 0.7
- 適用於需要動態平衡的場景

### LoRA 衝突處理

#### 問題: 兩個 LoRA 有相似觸發詞

```
# 錯誤示範
<lora:CharA_school:0.8> 1girl, school uniform, black hair MASK(...) AND
<lora:CharB_school:0.8> 1girl, school uniform, blonde hair MASK(...)
# 兩個都有 "school uniform" 可能互相影響

# 正確方法: 使用 CUT 隔離
ATTN() <lora:CharA_school:0.8> [CUT:blonde:] 1girl, school uniform, black hair MASK(...) AND
ATTN() <lora:CharB_school:0.8> [CUT:black:] 1girl, school uniform, blonde hair MASK(...)
```

### LoRA 加載順序

在 **PCLazyLoraLoader** 節點中:

1. **全局 LoRA** (風格、畫質增強)
2. **角色 LoRA** (按區域順序)
3. **特效 LoRA** (光影、背景)

```
# 提示詞順序
<lora:quality_boost:0.3> <lora:anime_style:0.5> masterpiece BREAK
ATTN() <lora:Character1:0.8> ... MASK(...) AND
ATTN() <lora:Character2:0.8> ... MASK(...) AND
<lora:lighting_effect:0.4> dramatic lighting
```

### 4人場景 LoRA 最佳實踐

```
# Positive Prompt
<lora:quality_enhancer:0.3> masterpiece, best quality, 4girls, concert stage BREAK
ATTN() <lora:Idol_A:0.8> [CUT:B C D:] 1girl, idol_a, pink dress, position1 MASK(0 0.22, 0 1) AND
ATTN() <lora:Idol_B:0.8> [CUT:A C D:] 1girl, idol_b, blue dress, position2 MASK(0.26 0.48, 0 1) AND
ATTN() <lora:Idol_C:0.75> [CUT:A B D:] 1girl, idol_c, purple dress, position3 MASK(0.52 0.74, 0 1) AND
ATTN() <lora:Idol_D:0.75> [CUT:A B C:] 1girl, idol_d, yellow dress, position4 MASK(0.78 1, 0 1)
```

**多人場景 LoRA 技巧**:
- 後方角色降低權重 (0.75 vs 0.8)
- CUT 排除其他角色觸發詞
- 使用簡化的角色代號 (A/B/C/D)

---

## 提示詞污染防治

### 污染類型與解決方案

#### 1. 顏色污染

**問題**: 紅色裙子角色讓藍色裙子角色也變紅

**解決方案**:

```
# 方法A: CUT 隔離顏色詞
ATTN() [CUT:blue green yellow:red] 1girl, red dress MASK(0 0.45, 0 1) AND
ATTN() [CUT:red green yellow:blue] 1girl, blue dress MASK(0.55 1, 0 1)

# 方法B: 增強對比色描述
ATTN() 1girl, (red dress:1.2), (not blue:1.1) MASK(0 0.45, 0 1) AND
ATTN() 1girl, (blue dress:1.2), (not red:1.1) MASK(0.55 1, 0 1)

# 方法C: 加大緩衝區 + 強羽化
ATTN() 1girl, red dress MASK(0 0.35, 0 1) FEATHER(40 0 40 0) AND
ATTN() 1girl, blue dress MASK(0.65 1, 0 1) FEATHER(40 0 40 0)
# 中間 35-65% 留空
```

#### 2. 髮型/髮色污染

**問題**: 長黑髮和短金髮混淆

**解決方案**:

```
# 完整髮型描述 + CUT
ATTN() [CUT:short blonde wavy:] 1girl, (long hair:1.3), (straight hair:1.2), (black hair:1.3), very long hair MASK(0 0.4, 0 1) AND
ATTN() [CUT:long black straight:] 1girl, (short hair:1.3), (bob cut:1.2), (blonde hair:1.3), wavy hair MASK(0.6 1, 0 1)

# 加入對比描述
ATTN() 1girl, extremely long black straight hair, hair down to waist MASK(0 0.4, 0 1) AND
ATTN() 1girl, extremely short blonde bob cut hair, hair above shoulders MASK(0.6 1, 0 1)
```

#### 3. 服裝細節污染

**問題**: 蕾絲裙和簡單裙互相影響

**解決方案**:

```
# 詳細服裝描述 + CUT
ATTN() [CUT:simple plain sleeveless:] 1girl, red dress, (frilled dress:1.2), (lace trim:1.2), (long sleeves:1.2), ornate, detailed dress MASK(0 0.45, 0 1) AND
ATTN() [CUT:frilled lace sleeves ornate:] 1girl, blue dress, (simple dress:1.2), (plain dress:1.2), (sleeveless:1.2), casual MASK(0.55 1, 0 1)
```

#### 4. 姿勢動作污染

**問題**: 站立和坐下姿勢混淆

**解決方案**:

```
# 明確動作 + 空間位置
ATTN() 1girl, (standing:1.3), (upright:1.2), arms at sides, standing straight, left side of image MASK(0 0.45, 0 1) AND
ATTN() 1girl, (sitting:1.3), (on chair:1.2), legs crossed, sitting pose, right side of image MASK(0.55 1, 0 1)
```

#### 5. 表情混淆

**問題**: 微笑和嚴肅表情互相影響

**解決方案**:

```
ATTN() [CUT:smile happy cheerful:] 1girl, (serious:1.2), (closed mouth:1.2), stern expression, no smile MASK(0 0.45, 0 1) AND
ATTN() [CUT:serious stern closed:] 1girl, (smile:1.2), (open mouth:1.2), cheerful, happy expression MASK(0.55 1, 0 1)
```

### 進階污染防治技巧

#### A. 多層 CUT 策略

```
# 對容易污染的標籤使用多層隔離
ATTN() 
[CUT:blonde blue:black] [CUT:short:long] [CUT:wavy:straight]
1girl, long straight black hair, red dress 
MASK(0 0.45, 0 1) AND
ATTN() 
[CUT:black red:blonde] [CUT:long:short] [CUT:straight:wavy]
1girl, short wavy blonde hair, blue dress 
MASK(0.55 1, 0 1)
```

#### B. 權重微調法

```
# 降低容易污染區域的權重
ATTN() 1girl, red dress, black hair MASK(0 0.4, 0 1, 1.0) AND
neutral:0.5 MASK(0.4 0.6, 0 1, 0.3) AND  # 低權重緩衝區
ATTN() 1girl, blue dress, blonde hair MASK(0.6 1, 0 1, 1.0)
```

#### C. Solo Focus 強化

```
# 每個角色加 solo focus 強化獨立性
ATTN() 1girl, solo focus, only one girl, individual character, red dress MASK(0 0.45, 0 1) AND
ATTN() 1girl, solo focus, only one girl, individual character, blue dress MASK(0.55 1, 0 1)
```

#### D. 負面提示詞強化

```
# Negative Prompt 針對性排除污染
lowres, bad anatomy,
color bleeding, mixed colors, wrong hair color, wrong dress color,
merged bodies, fused clothes, same outfit, same hairstyle,
twins, identical characters, same face,
attribute transfer, feature mixing
```

### 污染檢測清單

生成後檢查以下項目:

- [ ] 髮色是否正確無混淆
- [ ] 服裝顏色是否各自獨立
- [ ] 髮型長度是否符合描述
- [ ] 姿勢動作是否清晰分離
- [ ] 表情是否符合各自設定
- [ ] 配件道具是否出現在正確角色上
- [ ] 背景元素是否正確分布

### 污染嚴重時的終極方案

#### 方案 1: 分批生成 + 後期合成

```
# 生成角色1 (全圖)
1girl, red dress, black hair, left side, (right side empty:1.3)

# 生成角色2 (全圖)
1girl, blue dress, blonde hair, right side, (left side empty:1.3)

# 使用 Photoshop/GIMP 合成
```

#### 方案 2: 使用 ControlNet 輔助

```
# 使用 OpenPose/Depth ControlNet 固定姿勢和位置
# 再配合 Regional Prompting 控制細節
```

#### 方案 3: 降低角色數量

```
# 如果 4 人污染嚴重,改為 3 人或 2+2 分批
# 複雜場景優先保證質量而非數量
```

---

## 常見問題排除

### Q1: 角色位置不對,總是擠在一起

**原因**: MASK 區域重疊或緩衝區不足

**解決**:
```
# 錯誤
MASK(0 0.5, 0 1) AND MASK(0.5 1, 0 1)  # 邊界重疊

# 正確
MASK(0 0.4, 0 1) AND MASK(0.6 1, 0 1)  # 留 20% 緩衝區

# 加強
ATTN() left side, leftmost position MASK(0 0.4, 0 1) AND
ATTN() right side, rightmost position MASK(0.6 1, 0 1)
```

### Q2: 臉部特徵混合 (同樣的臉)

**原因**: Illustrious 容易生成相似臉型

**解決**:
```
# 加入明確的臉部差異描述
ATTN() 1girl, mature face, sharp eyes, thin lips, serious MASK(...) AND
ATTN() 1girl, young face, round eyes, full lips, cute MASK(...)

# Negative 加入
same face, identical faces, twins, similar features
```

### Q3: LoRA 不生效或效果弱

**原因**: 權重不足或 MASK 區域太小

**解決**:
```
# 提高 LoRA 權重
<lora:character:0.7> → <lora:character:0.9>

# 擴大 MASK 區域
MASK(0 0.3, 0 1) → MASK(0 0.4, 0 1)

# 確保觸發詞完整
<lora:asuna:0.8> asuna \(sao\), orange hair, blue eyes, KoB uniform
```

### Q4: 羽化效果太明顯,邊緣模糊

**原因**: FEATHER 值過大

**解決**:
```
# 降低羽化值
FEATHER(50 0 50 0) → FEATHER(20 0 20 0)

# 或只羽化需要的邊
FEATHER(25 0 0 0)  # 只羽化左邊
```

### Q5: 背景元素出現在錯誤位置

**原因**: 背景沒有獨立控制

**解決**:
```
# 方法A: 背景單獨一層
park, trees, bench:0.8 AND
ATTN() 1girl, red dress MASK(0 0.45, 0 1, 1.0) AND
ATTN() 1girl, blue dress MASK(0.55 1, 0 1, 1.0)

# 方法B: 背景用低權重 MASK
ATTN() trees, bench MASK(0 0.3, 0 0.5, 0.5) AND
ATTN() 1girl, red dress MASK(0 0.45, 0 1, 1.0) AND
ATTN() 1girl, blue dress MASK(0.55 1, 0 1, 1.0)
```

### Q6: 生成速度很慢

**原因**: 多個 ATTN() 增加計算量

**優化**:
```
# 使用 PPCAttentionCoupleBatchNegative 節點
# 啟用負面提示批次處理,提升約 20-30% 速度

# 降低不必要的羽化
FEATHER(30 30 30 30) → FEATHER(20 0 20 0)

# 減少 MASK 複雜度
# 避免過多小區域分割
```

### Q7: Cutoff 不生效

**原因**: 語法錯誤或 target tokens 不正確

**解決**:
```
# 檢查語法
[CUT:region_text:target_tokens]

# 正確範例
[CUT:red dress, blue dress:red]  # 從 "red dress, blue dress" 中遮蔽 "red"

# 多個 tokens 用底線連接
[CUT:long black hair:long_black]  # 遮蔽 "long black" 整體
```

### Q8: 3-4人場景總是失敗

**建議**:
```
# 策略1: 降低解析度測試
1024x1024 → 768x768
確認構圖後再 upscale

# 策略2: 簡化提示詞
去除不必要的細節描述
只保留核心特徵

# 策略3: 增加 Steps
28 steps → 35-40 steps
給模型更多時間理解複雜構圖

# 策略4: 調整 CFG
CFG 7 → CFG 6
降低過度引導

# 策略5: 分批生成
先生成 2+2,再合成
```

---

## 推薦工作流程

### 1. 規劃階段
- 確定角色數量和位置
- 列出每個角色的關鍵特徵
- 識別容易污染的屬性 (顏色、髮型)

### 2. 構建提示詞
- 基礎品質標籤 + 場景
- 使用本文檔對應的策略範本
- 為每個角色添加 CUT 隔離
- 計算 MASK 座標,留足緩衝區

### 3. 測試生成
- 低解析度快速測試 (512x512 或 768x768)
- 檢查位置和污染情況
- 調整 MASK 範圍和 FEATHER 值

### 4. 精細調整
- 提高解析度到目標尺寸
- 微調權重和 CFG
- 增加 Steps 如需要

### 5. 批次生成
- 使用相同參數生成多張
- 挑選最佳結果
- 必要時局部修復 (inpaint)

---

## 參數速查表

### 推薦生成參數 (Illustrious)

| 參數 | 2人 | 3人 | 4人 | 說明 |
|------|-----|-----|-----|------|
| Resolution | 1024x1024 | 1024x1024 | 1216x832 | 4人建議橫構圖 |
| Steps | 28-32 | 32-36 | 35-40 | 人數越多越高 |
| CFG Scale | 7-8 | 6.5-7.5 | 6-7 | 避免過度引導 |
| Sampler | DPM++ 2M Karras | DPM++ 2M Karras | Euler a | - |
| Clip Skip | 2 | 2 | 2 | Illustrious 固定 |
| Denoise | 1.0 | 1.0 | 1.0 | txt2img 固定 |

### MASK 座標速查

#### 2人左右分割
```
左側: MASK(0 0.4, 0 1)
右側: MASK(0.6 1, 0 1)
緩衝: 40-60% (20%)
```

#### 3人橫排
```
左: MASK(0 0.3, 0 1)
中: MASK(0.35 0.65, 0 1)
右: MASK(0.7 1, 0 1)
緩衝: 5%
```

#### 4人網格
```
左上: MASK(0 0.45, 0 0.45)
右上: MASK(0.55 1, 0 0.45)
左下: MASK(0 0.45, 0.55 1)
右下: MASK(0.55 1, 0.55 1)
緩衝: 10%
```

### FEATHER 值建議

| 場景 | 左 | 上 | 右 | 下 | 說明 |
|------|-----|-----|-----|-----|------|
| 左右分割 | 25-30 | 0 | 25-30 | 0 | 只羽化中間邊界 |
| 上下分割 | 0 | 25-30 | 0 | 25-30 | 只羽化中間邊界 |
| 網格 | 20 | 20 | 20 | 20 | 四邊均勻羽化 |
| 景深 | 15 | 15 | 15 | 15 | 較小值保持清晰度 |

---

## 版本記錄

- **v1.0** (2025-11-11): 初版發布
  - 2/3/4人場景策略
  - LoRA 使用指南
  - 污染防治方案
  - 常見問題解答

---

## 參考資源

- [ComfyUI Prompt Control GitHub](https://github.com/asagi4/comfyui-prompt-control)
- [Attention Couple 文檔](https://github.com/asagi4/comfyui-prompt-control/blob/master/doc/attention_couple.md)
- [Regional Prompts 文檔](https://github.com/asagi4/comfyui-prompt-control/blob/master/doc/regional_prompts.md)
- [Illustrious Model](https://civitai.com/models/795765/illustrious-xl)

---

**注意**: 本文檔持續更新中,如有任何問題或建議,歡迎回饋!
