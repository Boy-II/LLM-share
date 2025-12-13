# 主LLM結構化輸出指南

## 標準輸出格式

```
[IMAGE_COUNT] 人數 [/IMAGE_COUNT]
[ASPECT_RATIO] 比例 [/ASPECT_RATIO]
[SCENE_SUMMARY]
簡短情境描述(1-2句話)
[/SCENE_SUMMARY]
[TAGS]
完整的圖像描述標籤
[/TAGS]
```

---

## 各部分詳細說明

### 1. IMAGE_COUNT (必需)

**格式:**
```
[IMAGE_COUNT] 1girl [/IMAGE_COUNT]
[IMAGE_COUNT] 2girls [/IMAGE_COUNT]
[IMAGE_COUNT] 1girl 1boy [/IMAGE_COUNT]
[IMAGE_COUNT] 3girls [/IMAGE_COUNT]
[IMAGE_COUNT] 5girls 2boys [/IMAGE_COUNT]
```

**用途:**
- 8B模型快速判斷是否需要區域控制
- 避免手動計算人數錯誤
- 決策樹的第一個判斷點

**注意事項:**
- 只包含人物數量
- 使用標準格式 (1girl, 2boys等)
- 不包含動物或物品

---

### 2. ASPECT_RATIO (必需)

**格式:**
```
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
```

**判斷規則:** (參考main_llm_guide.md)
- 1人默認: 3:4 豎版
- 2人默認: 4:3 橫版或1:1
- 3人+: 16:9 寬橫版
- 特例: 躺臥→橫版, 景觀→橫版

**用途:**
- ComfyUI設置圖片尺寸
- 輔助判斷構圖方式

---

### 3. SCENE_SUMMARY (強烈建議)

**目的:**
為8B模型提供情境理解,輔助格式化決策。

**內容:**
- 整體氛圍和情感
- 關鍵互動關係
- 特殊效果或需求
- 構圖重點

**長度:** 1-2句話,最多3句

**範例:**

#### 範例1: 簡單場景
```
[SCENE_SUMMARY]
一個紅髮女孩獨自站在公園,微笑看向鏡頭,
陽光明媚的下午,需要清晰的眼睛細節
[/SCENE_SUMMARY]
```

#### 範例2: 雙人互動
```
[SCENE_SUMMARY]
兩個女孩在咖啡廳左右並排坐著,正在愉快交談,
左側女孩在傾聽,右側女孩在講述,溫馨氛圍
[/SCENE_SUMMARY]
```

#### 範例3: 多人複雜
```
[SCENE_SUMMARY]
三個女孩idol組合在舞台上從左到右並排表演,
中間是隊長需要更突出,絢麗的舞台燈光,
電影感的寬幅構圖
[/SCENE_SUMMARY]
```

#### 範例4: 特殊效果
```
[SCENE_SUMMARY]
前景是女孩的特寫肖像,背景是模糊的城堡景觀,
強烈的景深效果,夕陽光線,夢幻氛圍
[/SCENE_SUMMARY]
```

#### 範例5: 動態場景
```
[SCENE_SUMMARY]
女孩在跳舞,動態姿勢,裙子隨風飄動,
舞台聚光燈下,需要動作流暢感和布料質感
[/SCENE_SUMMARY]
```

**8B模型可以從中提取:**
- 是否需要COUPLE: "左右並排" → 需要
- 是否需要景深: "前景...背景模糊" → 需要feather=0.15+
- 是否需要特定LoRA: "跳舞" → dynamic_pose
- 光影設置: "夕陽光線" → sunset lighting 0.3-0.9
- 權重調整: "中間是隊長需要更突出" → 權重1.3

---

### 4. TAGS (必需)

**完整的5要素:**

#### 4.1 人物基本信息
```
必需:
- 數量性別: 1girl, 2boys, 3girls
- 對應IMAGE_COUNT的內容
```

#### 4.2 外觀特徵
```
每個人物必需:
- 髮色髮型: long red hair, short black hair
- 眼睛顏色: blue eyes, green eyes

建議:
- 身高體型: tall, petite
- 特殊特徵: cat ears, wings
```

#### 4.3 服裝
```
必需:
- 服裝類型: white dress, school uniform
- 顏色: 明確標註

建議:
- 配飾: hat, glasses
- 細節: frills, ribbons
```

#### 4.4 動作姿勢
```
必需:
- 基本動作: standing, sitting, lying
- 表情: smiling, surprised
- 視線: looking at viewer

建議:
- 手部動作: holding book, waving
- 互動: hugging, chatting
```

#### 4.5 場景背景
```
必需:
- 位置: in park, at beach, indoor

建議:
- 環境元素: trees, buildings
- 天氣時間: sunny day, sunset
- 氛圍: warm, peaceful
```

**多人場景的TAGS結構:**

```
格式:
人物總數,
位置關係,
first/left person: 特徵描述
second/right person: 特徵描述
(如有第三人...)
共同動作或互動,
場景環境,
光照氛圍
```

**範例:**
```
[TAGS]
2girls, side by side,
left girl: long blonde hair, blue eyes, pink dress, 
listening attentively, gentle smile
right girl: short black hair, brown eyes, white blouse,
talking animatedly, expressive
sitting at café table, coffee cups on table,
chatting, friendly atmosphere,
in cozy café, afternoon sunlight through window,
warm lighting, plants in background
[/TAGS]
```

---

## 完整範例

### 範例1: 單人簡單場景

```
[IMAGE_COUNT] 1girl [/IMAGE_COUNT]
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
[SCENE_SUMMARY]
一個紅髮女孩站在花園中,微笑著看向鏡頭,
春天的陽光,溫暖寧靜的氛圍
[/SCENE_SUMMARY]
[TAGS]
1girl, long red hair, green eyes,
white sundress, 
standing, smiling, looking at viewer,
in garden, flowers blooming, trees,
spring day, soft sunlight, peaceful atmosphere
[/TAGS]
```

### 範例2: 雙人互動

```
[IMAGE_COUNT] 2girls [/IMAGE_COUNT]
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
[SCENE_SUMMARY]
兩個女孩在海邊並肩站立,左側金髮女孩指向遠方,
右側粉髮女孩在看向她,夕陽時分,溫暖的友誼氛圍
[/SCENE_SUMMARY]
[TAGS]
2girls, standing side by side,
left girl: long blonde hair, blue eyes, yellow sundress,
pointing towards horizon, excited expression
right girl: short pink hair, green eyes, white t-shirt and shorts,
looking at her friend, gentle smile
at beach, ocean in background, sand,
sunset, golden hour lighting, warm colors,
friendship moment
[/TAGS]
```

### 範例3: 三人複雜場景

```
[IMAGE_COUNT] 3girls [/IMAGE_COUNT]
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
[SCENE_SUMMARY]
三個學生在教室並排坐著,從左到右,
左邊女孩在寫筆記,中間女孩在看書,右邊女孩在思考,
安靜的自習時光,下午的明亮教室
[/SCENE_SUMMARY]
[TAGS]
3girls, sitting in a row at desks,
left girl: short brown hair, glasses, school uniform,
writing notes, focused expression
center girl: long black hair, school uniform,
reading textbook, concentrated
right girl: twin tails blonde hair, school uniform,
hand on chin, thinking, looking up
in classroom, desks and chairs, blackboard in background,
quiet study time, bright afternoon light through windows,
peaceful academic atmosphere
[/TAGS]
```

### 範例4: 前景背景景深

```
[IMAGE_COUNT] 1girl [/IMAGE_COUNT]
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
[SCENE_SUMMARY]
前景是女孩的特寫肖像,背景是模糊的城堡和山脈,
強烈的景深效果,夕陽金色光線,夢幻氛圍,
需要詳細的眼睛和臉部細節
[/SCENE_SUMMARY]
[TAGS]
1girl, close-up portrait,
long silver hair, blue eyes, detailed face,
elegant dress,
foreground focus, looking at viewer, serene expression,
background: blurred castle, mountains, sunset sky,
strong depth of field, bokeh effect,
golden hour lighting, dreamy atmosphere,
need detailed eyes and face
[/TAGS]
```

### 範例5: 動態戰鬥場景

```
[IMAGE_COUNT] 3girls [/IMAGE_COUNT]
[ASPECT_RATIO] 21:9 [/ASPECT_RATIO]
[SCENE_SUMMARY]
史詩級戰鬥場景,三個女孩從左到右並排戰鬥姿態,
左邊戰士揮劍,中間法師施法,右邊弓箭手拉弓,
廢墟背景,火焰和煙霧,電影感超寬幅構圖,
需要動態姿勢和手部細節
[/SCENE_SUMMARY]
[TAGS]
3girls, epic battle formation, standing in row,
left warrior: red hair, armor, wielding sword,
aggressive stance, determined expression
center mage: blonde hair, robes, casting spell,
magic effects around hands, focused expression
right archer: black hair, light armor, drawing bow,
aiming, concentrated expression
in ruins, crumbling walls, debris,
fire effects, smoke, dramatic lighting,
cinematic ultra-wide composition,
need dynamic poses and detailed hands
[/TAGS]
```

---

## 8B模型的解析流程

### 步驟1: 提取結構化信息
```python
image_count = extract("[IMAGE_COUNT]", "[/IMAGE_COUNT]")
aspect_ratio = extract("[ASPECT_RATIO]", "[/ASPECT_RATIO]")
scene_summary = extract("[SCENE_SUMMARY]", "[/SCENE_SUMMARY]")
raw_tags = extract("[TAGS]", "[/TAGS]")
```

### 步驟2: 基於IMAGE_COUNT判斷
```python
if image_count == "1girl" or image_count == "1boy":
    use_regional_control = False
elif "2girls" in image_count or "1girl 1boy" in image_count:
    if "side by side" in scene_summary or "left" in scene_summary:
        use_couple = True
        regions = 2
    else:
        use_regional_control = False
elif count_people(image_count) >= 3:
    use_couple = True
    regions = count_people(image_count)
```

### 步驟3: 基於SCENE_SUMMARY優化
```python
# 判斷特殊效果
if "景深" in scene_summary or "foreground" in scene_summary:
    need_strong_feather = True  # feather=0.15+
    
if "動態" in scene_summary or "dynamic" in scene_summary:
    need_dynamic_lora = True  # 0.0-0.5
    
if "詳細的眼睛" in scene_summary or "detailed eyes" in scene_summary:
    need_eye_detail_lora = True  # 0.7-1.0
```

### 步驟4: 格式化TAGS
```python
formatted_output = format_prompt_control(
    raw_tags=raw_tags,
    use_couple=use_couple,
    regions=regions,
    aspect_ratio=aspect_ratio,
    special_effects=extract_from_summary(scene_summary)
)
```

---

## 優勢分析

### ✅ 有結構化標記的好處

1. **清晰解析**
   - 8B模型容易提取各部分
   - 減少解析錯誤
   - 不依賴自然語言理解

2. **快速決策**
   - IMAGE_COUNT → 立即知道是否需要區域控制
   - ASPECT_RATIO → 直接設置ComfyUI
   - SCENE_SUMMARY → 理解整體意圖

3. **錯誤檢查**
   - 如果缺少某個標記,8B模型可以提示
   - 驗證格式正確性
   - 減少後續處理錯誤

4. **可擴展性**
   - 未來可以加入更多標記
   - 例: [STYLE], [MOOD], [TIME_OF_DAY]
   - 不影響現有結構

### ❌ 沒有結構化標記的問題

如果只給一大段文字:
```
兩個女孩在咖啡廳,左邊紅髮,右邊藍髮...
```

**問題:**
1. 8B模型需要自己判斷人數 → 可能出錯
2. 需要理解自然語言提取信息 → 增加複雜度
3. 比例判斷不明確 → 可能用錯比例
4. 整體意圖不清晰 → 可能錯過重要需求

---

## 主LLM提示詞模板

### 給主LLM的指令

```
你是一個為AI圖像生成準備描述標籤的助手。
當用戶描述一個場景時,你需要生成結構化的輸出。

輸出格式:
[IMAGE_COUNT] 人物數量(如: 1girl, 2girls, 1girl 1boy) [/IMAGE_COUNT]
[ASPECT_RATIO] 圖片比例 [/ASPECT_RATIO]
[SCENE_SUMMARY]
1-2句話描述整體情境、氛圍、關鍵互動和特殊需求
[/SCENE_SUMMARY]
[TAGS]
完整的圖像描述標籤,包含:
- 人物數量和性別
- 每個人物的外觀(髮色髮型、眼色)
- 服裝描述
- 動作姿勢和表情
- 場景環境
- 光照氛圍
[/TAGS]

圖片比例判斷規則:
- 1人: 3:4 豎版 (躺臥或景觀→橫版)
- 2人: 4:3 橫版或1:1方形
- 3人以上: 16:9 寬橫版

多人場景TAGS格式:
人物總數, 位置關係,
first/left person: 完整描述
second/right person: 完整描述
共同動作, 場景環境, 光照氛圍

範例見上方完整範例。
```

---

## 總結

### 推薦結構 (最佳!)

```
[IMAGE_COUNT] ... [/IMAGE_COUNT]      ← 必需
[ASPECT_RATIO] ... [/ASPECT_RATIO]    ← 必需  
[SCENE_SUMMARY] ... [/SCENE_SUMMARY]  ← 強烈建議
[TAGS] ... [/TAGS]                    ← 必需
```

### 為什麼這樣設計?

1. **IMAGE_COUNT** - 快速判斷區域控制策略
2. **ASPECT_RATIO** - 直接設置圖片尺寸
3. **SCENE_SUMMARY** - 提供情境理解,輔助決策
4. **TAGS** - 完整的描述信息

### 優勢

- ✅ 結構清晰,易於解析
- ✅ 減少8B模型的推理負擔
- ✅ 提高格式化準確度
- ✅ 可擴展性強
- ✅ 錯誤檢查容易

### 工作流程

```
用戶輸入
    ↓
主LLM (生成結構化輸出)
    ↓
[IMAGE_COUNT] + [ASPECT_RATIO] + [SCENE_SUMMARY] + [TAGS]
    ↓
8B模型 (解析並格式化)
    ↓
Prompt Control 格式
    ↓
ComfyUI
```

這個結構在你的實際使用中應該會很高效! 🎯
