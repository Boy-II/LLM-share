# 8B模型格式化判斷規則

## 規則0: 區域控制方法選擇 (COUPLE vs AREA)

### 優先使用 COUPLE!

**COUPLE 優勢:**
- ⚡ 性能更好 (基於attention,更快)
- 🎨 效果更佳 (軟邊界,無接縫)
- 💪 功能更強 (支援圓形、羽化、自定義遮罩)
- 📝 語法簡潔 (多區域時不需要大量AND)
- 🔧 可用於負面提示詞

**何時仍用AREA:**
- 需要絕對的硬邊界分割
- 極簡單的矩形區域(學習階段)

**默認策略: 使用 COUPLE,除非有特殊理由用AREA**

---

## 規則1: 人物畫面佔比判斷 (COUPLE/AREA設置)

### 判斷邏輯樹

```
判斷流程:
1. 統計人物數量
2. 分析位置描述詞
3. 計算畫面分割
4. 生成COUPLE語法(優先)或AREA座標(備選)
```

### 人物數量與佔比規則

#### 單人場景 (1girl/1boy)
```
規則: 通常不使用區域控制,除非明確指定畫面位置
判斷: 無"左"、"右"、"中"等位置詞
輸出: 直接描述,不加COUPLE或AREA
```

**範例:**
```
輸入: 紅髮女孩站立,全身
輸出: 1girl, (red hair:1.2), standing, full body shot
```

#### 雙人場景 (2girls/1girl 1boy等)
```
規則: 
- 有明確位置詞 → 使用COUPLE區域控制(優先)或AREA
- 無位置詞但有互動 → 不使用區域控制
- 主從關係(前景/背景) → 使用COUPLE配合羽化
```

**判斷關鍵詞:**
- **需要區域控制**: "左側"、"右側"、"左邊"、"右邊"、"對面"、"對峙"
- **不需區域控制**: "擁抱"、"親吻"、"握手"、"靠近"、"一起"

**範例:**
```
# 需要區域控制 - COUPLE版本(優先)
輸入: 左側紅髮女孩,右側藍髮男孩
輸出: 
<lora:illustrious:0.85>
:0
COUPLE(0 0.5, feather=0.05) 1girl, (red hair:1.2)
COUPLE(0.5 0.5, feather=0.05) 1boy, (blue hair:1.2)

# AREA版本(備選)
AREA(0,0,0.5,1) 1girl, (red hair:1.2) AND 
AREA(0.5,0,0.5,1) 1boy, (blue hair:1.2)

# 不需區域控制
輸入: 女孩和男孩擁抱
輸出: 1girl, 1boy, hugging, close together
```

**COUPLE 優勢:**
- `feather=0.05` 輕微羽化避免接縫
- 無需AND連接
- 性能更好

#### 三人場景
```
標準分割 - COUPLE版本(優先): 
:0
COUPLE(0 0.33, feather=0.05) 左側描述
COUPLE(0.33 0.34, feather=0.05) 中間描述  
COUPLE(0.67 0.33, feather=0.05) 右側描述

標準分割 - AREA版本(備選):
- 左: AREA(0,0,0.33,1)
- 中: AREA(0.33,0,0.34,1)
- 右: AREA(0.67,0,0.33,1)

特殊分割:
- 前中後: 使用COUPLE配合不同羽化程度
- 主角+配角: 中心區域可用更大範圍
```

**範例:**
```
# COUPLE版本 - 推薦!
輸入: 三個女孩並排,左邊金髮,中間粉紅髮,右邊黑髮
輸出:
<lora:illustrious:0.85>
:0
COUPLE(0 0.33, feather=0.05) 1girl, (blonde hair:1.2)
COUPLE(0.33 0.34, feather=0.05) 1girl, (pink hair:1.2)
COUPLE(0.67 0.33, feather=0.05) 1girl, (black hair:1.2)
BREAK
standing in row

# AREA版本 - 備選
AREA(0,0,0.33,1) 1girl, (blonde hair:1.2) AND
AREA(0.33,0,0.34,1) 1girl, (pink hair:1.2) AND
AREA(0.67,0,0.33,1) 1girl, (black hair:1.2)
```

#### 四人以上
```
規則: 
- 4人: 避免使用區域控制,或使用COUPLE的FILL()自動填充
- 5人+: 使用構圖描述,不用區域控制

原因: 過多區域控制會導致:
1. 計算負擔增加
2. 人物細節下降
3. 構圖僵硬
```

**範例:**
```
# 4人 - 使用COUPLE+FILL
輸入: 四個角色站成一排
輸出: 
background scene FILL()
COUPLE(0 0.25) 1girl, character1
COUPLE(0.25 0.25) 1girl, character2
COUPLE(0.5 0.25) 1girl, character3
COUPLE(0.75 0.25) 1girl, character4

# 5人+ - 避免區域控制
輸入: 七個學生在教室
輸出: 7girls, in classroom, group shot, (multiple characters:1.2)
```

### 垂直分割 (上下佈局)

```
使用時機:
- "上方"/"下方"/"天空"/"地面"
- "飛行"/"漂浮"配合"站立"人物
- 明確的樓層/高度差

座標格式: AREA(x, y, w, h)
- 上半部: AREA(0,0,1,0.5)
- 下半部: AREA(0,0.5,1,0.5)
```

**範例:**
```
輸入: 天使在天空飛翔,地面有惡魔
輸出:
AREA(0,0,1,0.5) 1girl, angel, flying, in sky AND
AREA(0,0.5,1,0.5) 1girl, demon, standing, on ground
```

### 複雜佈局 (九宮格)

```
使用時機: 極少! 僅當明確需要精確位置控制
警告: 非常消耗計算資源,且容易失敗

示例座標:
左上: (0,0,0.33,0.33)    中上: (0.33,0,0.34,0.33)    右上: (0.67,0,0.33,0.33)
左中: (0,0.33,0.33,0.34)  正中: (0.33,0.33,0.34,0.34)  右中: (0.67,0.33,0.33,0.34)
左下: (0,0.67,0.33,0.33)  中下: (0.33,0.67,0.34,0.33)  右下: (0.67,0.67,0.33,0.33)
```

### 特殊情況: 前景/背景

```
判斷詞: "前景"、"背景"、"遠處"、"近處"、"後方"

策略: 使用COUPLE配合羽化實現景深效果(推薦)
或使用權重+景深描述(簡單場景)
```

**範例:**
```
# COUPLE版本 - 推薦!
輸入: 前景是紅髮女孩特寫,背景是城市景觀
輸出:
<lora:illustrious:0.85>
(city landscape:1.0), buildings, skyline FILL()
COUPLE(0.25 0.2 0.5 0.7, feather=0.15)
1girl, (red hair:1.2), (portrait:1.3), (foreground focus:1.3)
BREAK
(depth of field:1.2), (bokeh:1.1)

# 簡單版本 - 備選
(1girl:1.3), (red hair:1.2), close-up portrait, (foreground focus:1.2) 
BREAK
(city landscape:0.8), (background:0.7), (depth of field:1.1)
```

---

### COUPLE 特有能力

#### 1. 圓形遮罩
```
用途: 聚焦中心、發光效果、特殊構圖

語法: COUPLE(center_x center_y radius, circle, feather=羽化)

範例:
dark environment, shadows FILL()
COUPLE(0.5 0.5 0.2, circle, feather=0.2)
(glowing orb:1.4), (magical light:1.3)
```

#### 2. FILL() 自動填充
```
用途: 複雜背景自動填充未遮罩區域

語法: background_description FILL() COUPLE(...) regions

範例:
detailed fantasy landscape, mountains, castle, trees FILL()
COUPLE(0.3 0.4) 1girl, warrior, (foreground:1.3)
```

#### 3. 可變羽化程度
```
feather=0.0   - 硬邊界(類似AREA)
feather=0.05  - 輕微羽化(推薦雙人)
feather=0.10  - 中度羽化
feather=0.15+ - 強羽化(景深效果)

範例:
:0
COUPLE(0 0.5, feather=0.05) sharp edges
COUPLE(0.5 0.5, feather=0.2) soft blend
```

#### 4. 負面區域控制
```
用途: 不同區域有不同禁止內容

範例:
正面: :0 COUPLE(0 0.5) girl COUPLE(0.5 0.5) boy
負面: bad quality COUPLE(0 0.5) avoid female features COUPLE(0.5 0.5) avoid male features
```

---

## 規則2: CUT使用時機判斷

### CUT的目的
防止**顏色汙染**和**屬性混淆**

### 判斷流程

```python
def need_cutoff(tags):
    # 1. 檢測是否有多個帶顏色的物體/人物
    color_objects = count_colored_objects(tags)
    if color_objects >= 2:
        return True
    
    # 2. 檢測是否有容易混淆的屬性
    if has_conflicting_attributes(tags):
        return True
    
    # 3. 檢測是否有多人且帶不同特徵
    if character_count >= 2 and has_distinct_features(tags):
        return True
    
    return False
```

### 使用場景

#### 場景1: 多個帶顏色的對象
```
觸發條件: 
- 2+人物有不同髮色/眼色
- 2+物品有不同顏色
- 人物顏色 vs 背景顏色衝突

範例:
輸入: 白貓,黑狗,紅色氣球
判斷: 3個顏色對象 → 需要CUT

輸出:
[CUT:white cat:white], [CUT:black dog:black], [CUT:red balloon:red]
```

#### 場景2: 容易混淆的屬性組合

**危險組合表:**
| 組合 | 容易汙染 | 是否用CUT |
|------|----------|-----------|
| 金髮+藍眼 vs 藍髮+金眼 | ✅ 是 | ✅ 用 |
| 紅裙+藍鞋 vs 藍裙+紅鞋 | ✅ 是 | ✅ 用 |
| 白貓+黑狗 | ✅ 是 | ✅ 用 |
| 綠樹+藍天 | ❌ 否 | ❌ 不用 |
| 紅髮女+金髮女(距離遠) | ⚠️ 可能 | 🔸 看情況 |

**範例:**
```
# 需要CUT
輸入: 金髮藍眼女孩和藍髮金眼女孩
判斷: 髮色和眼色交叉 → 高風險
輸出:
[CUT:blonde hair, blue eyes:blonde blue] AND 
[CUT:blue hair, golden eyes:blue golden]

# 不需要CUT
輸入: 紅髮女孩在綠色森林
判斷: 人物顏色 vs 背景顏色,不易混淆
輸出: 1girl, (red hair:1.2), in green forest
```

#### 場景3: 多人不同特徵

```
判斷規則:
IF 使用AREA分割 THEN
    通常不需要CUT (已經空間隔離)
ELSE IF 人物特徵對比強烈 THEN
    需要CUT
END IF
```

**範例:**
```
# 已用AREA,不需CUT
輸入: 左側紅髮女孩,右側藍髮男孩
輸出:
AREA(0,0,0.5,1) 1girl, (red hair:1.2) AND
AREA(0.5,0,0.5,1) 1boy, (blue hair:1.2)
# 無需CUT因為已經空間分離

# 未用AREA,需要CUT
輸入: 紅髮女孩和藍髮女孩擁抱
輸出:
[CUT:red-haired girl:red], [CUT:blue-haired girl:blue], hugging
# 需要CUT因為空間重疊
```

### CUT語法細節

#### 基本格式
```
[CUT:region_text:target_tokens:weight:strict_mask:start_from_masked:padding]

參數說明:
- region_text: 要隔離的描述
- target_tokens: 要遮罩的關鍵詞
- weight: 權重 (預設1.0)
- strict_mask: 嚴格度 (預設1.0)
- start_from_masked: 是否從遮罩開始 (預設1.0)
- padding: 填充token (預設+)
```

#### 關鍵詞處理

**單詞遮罩:**
```
[CUT:white cat:white]
結果: + cat (white被遮罩)
```

**詞組遮罩 (用下劃線):**
```
[CUT:red apple:red_apple]
結果: + + (整個red apple被遮罩)

[CUT:golden blonde hair:golden_blonde]
結果: + + hair (golden blonde被遮罩)
```

**常見錯誤:**
```
❌ 錯誤: [CUT:blue eyes girl:blue eyes]
   結果: + + girl (遮罩了blue和eyes)
   
✅ 正確: [CUT:blue eyes girl:blue_eyes]
   結果: + + girl (只遮罩blue eyes這個詞組)
```

### CUT決策表

| 場景 | 人數 | 顏色對象數 | 屬性衝突 | 使用AREA | 決策 |
|------|------|-----------|----------|----------|------|
| 單人單色 | 1 | 1 | 無 | - | 不用CUT |
| 單人多色配件 | 1 | 2-3 | 低 | - | 不用CUT |
| 雙人不同色 | 2 | 2 | 中 | 是 | 不用CUT |
| 雙人不同色 | 2 | 2 | 中 | 否 | 用CUT |
| 雙人交叉色 | 2 | 4 | 高 | - | 用CUT |
| 三人+ | 3+ | 3+ | 高 | 是 | 看情況 |
| 多彩物品 | - | 4+ | - | - | 用CUT |

### 實戰範例

```
# 案例1: 不需要CUT
輸入: 紅髮女孩,綠色背景
分析: 人物vs背景,低風險
輸出: 1girl, (red hair:1.2), green background

# 案例2: 需要CUT  
輸入: 白貓,黑貓,棕色狗
分析: 3個顏色動物,高風險
輸出: 
[CUT:white cat:white], [CUT:black cat:black], [CUT:brown dog:brown]

# 案例3: 複雜判斷
輸入: 金髮女孩穿藍裙,藍髮女孩穿金裙,在教室
分析: 顏色交叉+無AREA分割 = 極高風險
輸出:
[CUT:blonde hair girl, blue dress:blonde blue_dress] AND 
[CUT:blue hair girl, golden dress:blue golden_dress] AND
in classroom

# 案例4: AREA已隔離
輸入: 左側紅衣女孩,右側藍衣男孩
分析: 有AREA分割,中等風險但已空間隔離
輸出:
AREA(0,0,0.5,1) 1girl, (red dress:1.2) AND
AREA(0.5,0,0.5,1) 1boy, (blue suit:1.2)
# 不用CUT
```

---

## 規則3: 提示詞和LoRA插入點判斷

### 時間軸概念

```
Diffusion過程: 0.0 =======> 0.5 =======> 1.0
               噪聲        構圖形成      細節精煉
               
階段劃分:
0.0-0.2  : 初始階段 (建立基礎結構)
0.2-0.5  : 構圖階段 (確定主要元素)
0.5-0.8  : 細節階段 (添加細節)
0.8-1.0  : 精煉階段 (最終調整)
```

### LoRA插入點判斷表

#### 風格類LoRA
```
目的: 控制整體畫風
插入點: 0.0 (全程)
結束點: 1.0 (或0.8-0.9)

原因: 風格需要貫穿整個生成過程

格式: <lora:style_name:0.8>
或:   <lora:style_name:0.8::0.0,0.9>
```

**範例:**
```
<lora:anime_style:0.8>  # 全程動漫風格
<lora:realistic:0.7::0.0,0.8>  # 0.8前寫實,之後淡出
```

#### 構圖類LoRA
```
目的: 控制姿勢、角度、構圖
插入點: 0.0-0.1
結束點: 0.5-0.6

原因: 構圖在早期決定,後期介入會崩潰

格式: [<lora:pose_lora:0.9>::0.5]
```

**範例:**
```
[<lora:dynamic_pose:0.9>::0.5]  # 動態姿勢,0.5後退出
[<lora:full_body:0.8>::0.6]  # 全身構圖,0.6後退出
```

#### 角色/概念LoRA
```
目的: 特定角色或概念
插入點: 0.0
結束點: 0.7-0.8

原因: 需要在細節階段前建立特徵

格式: <lora:character:1.0::0.0,0.7>
```

**範例:**
```
<lora:hatsune_miku:1.0::0.0,0.7>  # 角色特徵到0.7
<lora:cat_ears:0.8::0.0,0.75>  # 貓耳特徵
```

#### 細節類LoRA (重點!)
```
目的: 眼睛、手部、服裝細節
插入點: 0.5-0.7
結束點: 1.0

原因: 細節在基礎結構完成後添加

關鍵詞: eye, hand, face detail, clothing detail
```

**判斷規則:**
```
IF LoRA名稱包含:
    "eye", "eyes", "detail", "face_detail" 
    → 插入點 0.6-0.7
    
IF LoRA名稱包含:
    "hand", "finger", "anatomy"
    → 插入點 0.5-0.6
    
IF LoRA名稱包含:
    "texture", "fabric", "material"
    → 插入點 0.7-0.8
```

**範例:**
```
# 眼睛細節LoRA - 最後加入!
[::<lora:eye_detail:0.8>:0.7]

# 手部修正LoRA
[::<lora:hand_fix:0.9>:0.6]

# 布料質感LoRA
[::<lora:fabric_texture:0.7>:0.75]

# 面部細節LoRA
[::<lora:face_detail:0.8>:0.7]
```

#### 光影/氛圍LoRA
```
目的: 照明、氛圍、特效
插入點: 0.3-0.5
結束點: 0.9-1.0

原因: 在構圖確定後添加,持續到最後
```

**範例:**
```
<lora:dramatic_lighting:0.7::0.4,1.0>
<lora:sunset_glow:0.6::0.3,0.9>
```

### LoRA組合策略

#### 標準組合模板
```
<lora:base_style:0.8> [<lora:pose:0.9>::0.5] 
<lora:character:1.0::0.0,0.7>
主要描述 BREAK
[::<lora:eye_detail:0.8>:0.7] [::<lora:hand_fix:0.9>:0.6]
```

#### 權重調整建議
```
風格LoRA: 0.7-0.9 (太高會過度風格化)
角色LoRA: 0.8-1.2 (取決於訓練質量)
細節LoRA: 0.6-0.9 (太高會過度銳化)
修正LoRA: 0.8-1.0 (手部修正可以到1.0)
```

### 提示詞插入點判斷

#### 基礎描述 (0.0全程)
```
- 角色數量: 1girl, 2boys
- 主要特徵: red hair, blue eyes
- 基礎動作: standing, sitting
- 基礎場景: in park, indoor

格式: 直接寫,不加時間限制
```

#### 構圖指令 (0.0-0.5)
```
- 視角: from above, from side
- 構圖: close-up, full body shot
- 鏡頭: wide shot, portrait

格式: [指令::0.5] 或 (指令:1.2:0.0:0.0,0.5)
```

**範例:**
```
[close-up portrait::0.5]  # 0.5前特寫,之後可能改變
(full body shot:1.2:0.0:0.0,0.5)  # 權重形式
```

#### 細節描述 (0.5-1.0)
```
- 精細特徵: detailed eyes, intricate patterns
- 質感: silk texture, leather material
- 小物件: jewelry, accessories

格式: [:描述:0.5] 或 (描述:1.1:0.5:0.5,1.0)
```

**範例:**
```
[:detailed eyes, long eyelashes:0.6]
(intricate dress pattern:1.1:0.5:0.5,1.0)
[:jewelry, earrings, necklace:0.7]
```

#### 氛圍/效果 (0.3-1.0)
```
- 光照: dramatic lighting, rim light
- 氛圍: moody, peaceful
- 特效: glowing, sparkles

格式: (效果:權重:時間)
```

**範例:**
```
(dramatic lighting:1.2::0.3,1.0)
(rim light:1.1::0.4,0.9)
[:sparkles, glowing effects:0.5]
```

### 完整範例

#### 範例1: 單人肖像
```
輸入: 紅髮女孩肖像,詳細的眼睛和手部,柔和光線

輸出:
<lora:anime_style:0.8> 1girl, (red hair:1.2), (blue eyes:1.1)
[close-up portrait::0.5], (looking at viewer:1.1)
(soft lighting:1.1::0.3,0.9) BREAK
[::<lora:eye_detail:0.8>:0.7], detailed eyes, long eyelashes
[::<lora:hand_fix:0.9>:0.6], detailed hands
```

#### 範例2: 動態場景
```
輸入: 女孩跳舞,使用動態姿勢LoRA,背景模糊,飄逸的裙子細節

輸出:
<lora:illustrious:0.85> [<lora:dynamic_pose:0.9>::0.5]
1girl, dancing, dynamic pose, (motion blur:1.1::0.3,0.8)
(flowing dress:1.2), (fabric motion:1.1::0.5,1.0) BREAK
[::<lora:fabric_detail:0.7>:0.7], (dress details:1.1)
(blurred background:0.8)
```

#### 範例3: 多人複雜場景
```
輸入: 三個女孩並排,中間的是主角需要更多細節

輸出:
<lora:anime:0.8> 3girls, standing in row BREAK
AREA(0,0,0.33,1) 1girl, (blonde hair:1.1) AND
AREA(0.33,0,0.34,1) 1girl, (pink hair:1.3), (detailed face:1.2), 
[::<lora:eye_detail:0.9>:0.7] AND
AREA(0.67,0,0.33,1) 1girl, (black hair:1.1) BREAK
(group shot:1.1), (studio lighting:1.1::0.3,0.9)
```

### 決策流程圖

```
接收LoRA/提示詞
    ↓
判斷類型
    ↓
├─ 風格? → 0.0, 全程
├─ 構圖? → 0.0-0.1, 到0.5-0.6
├─ 角色? → 0.0, 到0.7-0.8
├─ 細節? → 0.5-0.7開始, 到1.0
├─ 光影? → 0.3-0.5開始, 到0.9-1.0
└─ 修正? → 對應階段介入
    ↓
檢查名稱關鍵詞
    ↓
├─ "eye/face/detail" → 0.7開始
├─ "hand/finger" → 0.6開始
├─ "texture/fabric" → 0.7開始
└─ "pose/composition" → 0.0開始,0.5結束
    ↓
生成時間範圍語法
```

### 常見錯誤

```
❌ 錯誤: [::<lora:eye_detail:0.8>:0.2]
   問題: 太早介入,基礎結構未形成
   
✅ 正確: [::<lora:eye_detail:0.8>:0.7]

❌ 錯誤: [<lora:dynamic_pose:0.9>::0.8]
   問題: 太晚介入,構圖已固定
   
✅ 正確: [<lora:dynamic_pose:0.9>::0.5]

❌ 錯誤: <lora:style:1.5>
   問題: 權重過高導致過度風格化
   
✅ 正確: <lora:style:0.8>
```
