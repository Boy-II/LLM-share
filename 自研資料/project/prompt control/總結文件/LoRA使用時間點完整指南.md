# LoRA 使用時間點完整指南 - Latent Upscale 工作流

> 在不同階段使用不同類型 LoRA 的完整策略
> 
> 作者: Boy | 更新日期: 2025-11-11

---

## 目錄

1. [工作流程時間軸](#工作流程時間軸)
2. [各階段 LoRA 使用策略](#各階段-lora-使用策略)
3. [Base 生成階段](#base-生成階段)
4. [FaceDetailer 階段](#facedetailer-階段)
5. [HandDetailer 階段](#handdetailer-階段)
6. [完整範例](#完整範例)
7. [常見問題](#常見問題)

---

## 工作流程時間軸

### 完整流程拆解

```
階段 0: Empty Latent 832x1216
        ↓
階段 1: Latent Upscale → 1248x1824
        ↓
階段 2: Base 生成 (Main KSampler, denoise: 0.6)  ← 使用角色/風格/場景 LoRA
        ↓
階段 3: VAE Decode → 1248x1824 圖像
        ↓
階段 4: FaceDetailer                            ← 使用五官/表情 LoRA
        ↓
階段 5: HandDetailer (可選)                      ← 使用手部 LoRA
        ↓
階段 6: 最終 Upscale (可選)
        ↓
最終輸出
```

### 時間點與 LoRA 對應

| 階段 | 節點 | 使用的 LoRA 類型 | 作用 | 權重範圍 |
|------|------|------------------|------|----------|
| **2** | Main KSampler | 角色、風格、服裝、姿勢、場景 | 確立整體構圖和特徵 | 0.6-1.0 |
| **4** | FaceDetailer | 五官細節、表情、臉部風格 | 精修臉部 | 0.5-0.8 |
| **5** | HandDetailer | 手部細節 | 修復手部 | 0.6-0.9 |

---

## 各階段 LoRA 使用策略

### 總體原則

```
✅ Base 生成階段 (Main KSampler):
   - 使用「結構性」LoRA
   - 確立角色外觀、風格、構圖
   - 權重較高,確保特徵

✅ FaceDetailer 階段:
   - 使用「細節性」LoRA
   - 專注五官精修
   - 權重中等,避免過度改變

✅ HandDetailer 階段:
   - 使用「修復性」LoRA
   - 矯正手部結構
   - 權重較高,因為手部難度大
```

### LoRA 分類速查表

| LoRA 類型 | Base 階段 | Face 階段 | Hand 階段 | 典型權重 |
|-----------|-----------|-----------|-----------|----------|
| 角色外觀 | ✅ 必須 | 🟡 可選 | ❌ 不用 | 0.7-1.0 |
| 整體風格 | ✅ 必須 | ❌ 不用 | ❌ 不用 | 0.4-0.7 |
| 服裝細節 | ✅ 推薦 | ❌ 不用 | ❌ 不用 | 0.6-0.9 |
| 姿勢動作 | ✅ 必須 | ❌ 不用 | 🟡 可選 | 0.7-1.0 |
| 場景背景 | ✅ 推薦 | ❌ 不用 | ❌ 不用 | 0.4-0.6 |
| 五官細節 | 🟡 可選 | ✅ 必須 | ❌ 不用 | Face: 0.5-0.8 |
| 表情風格 | 🟡 可選 | ✅ 推薦 | ❌ 不用 | Face: 0.4-0.7 |
| 手部修復 | ❌ 不用 | ❌ 不用 | ✅ 必須 | 0.6-0.9 |
| 品質增強 | 🟡 可選 | 🟡 可選 | ❌ 不用 | 0.3-0.5 |

---

## Base 生成階段

### 階段 2: Main KSampler

```
[PCLazyTextEncode] → [Main KSampler (denoise: 0.6)]
        ↑
    在這裡使用 LoRA
```

### LoRA 使用清單

#### 1. 角色外觀 LoRA ⭐⭐⭐⭐⭐ (最重要)

**作用**: 確立角色的基本外觀、髮型、臉型、體型

**權重排程**:
```
<lora:character_name:[1.0:0.6:0.3]>
```

**參數解析**:
- `1.0 起始`: 最高權重確保角色特徵在構圖階段確立
- `0.6 結束`: 降低權重讓模型有自由度處理細節
- `0.3 切換`: 約 8-9 步(28步總數)完成特徵確立

**為什麼這樣設定**:
```
Latent Upscale 後解析度: 1248x1824
臉部約: 150x180px ← 已經足夠生成基本五官

配合 denoise: 0.6:
• 前 40% (約11步) 使用 LoRA 權重 1.0 確立角色
• 後 60% (約17步) 使用 LoRA 權重 0.6 + 模型自由發揮
• 結果: 角色特徵明確但不僵硬
```

**單人範例**:
```
<lora:asuna:[1.0:0.6:0.3]> 1girl, asuna \(sao\), orange hair, 
blue eyes, white dress, standing, full body
```

**多人範例** (2人):
```
ATTN() <lora:char_A:[1.0:0.7:0.3]> 1girl, char_A, red dress, 
black hair MASK(0 0.45, 0 1) AND
ATTN() <lora:char_B:[0.7:1.0:0.3]> 1girl, char_B, blue dress, 
blonde hair MASK(0.55 1, 0 1)
```

**注意**: 多人時使用交錯峰值,避免兩個角色同時高權重干擾

#### 2. 整體風格 LoRA ⭐⭐⭐⭐

**作用**: 統一畫面風格 (水彩、油畫、賽博朋克等)

**權重排程**:
```
<lora:style_name:[0.4:0.6:0.4]>
```

**參數解析**:
- `0.4 起始`: 較低起始,不干擾角色構圖
- `0.6 結束`: 中後期提高,統一整體風格
- `0.4 切換`: 約 11步後開始強化風格

**為什麼這樣設定**:
```
風格 LoRA 在 Latent Upscale 後:
• 初期低權重 (0.4) → 讓角色 LoRA 主導構圖
• 中期開始提高 (0.6) → 在細節生成階段統一風格
• 避免風格過早影響導致角色特徵偏移
```

**範例**:
```
<lora:watercolor_style:[0.4:0.6:0.4]> 
<lora:character:[1.0:0.6:0.3]> 
masterpiece, watercolor painting, soft colors, 1girl, ...
```

**推薦風格 LoRA 權重**:
- 水彩/油畫風格: 0.4-0.6
- 賽博朋克/科幻風格: 0.5-0.7
- 復古/膠片風格: 0.3-0.5

#### 3. 服裝細節 LoRA ⭐⭐⭐⭐

**作用**: 確保服裝款式、細節正確

**權重排程**:
```
<lora:outfit_name:[0.7:0.9:0.5]>
```

**參數解析**:
- `0.7 起始`: 中等起始,避免與角色 LoRA 衝突
- `0.9 結束`: 高權重確保服裝細節豐富
- `0.5 切換`: 中期切換,在角色確立後強化服裝

**為什麼這樣設定**:
```
服裝 LoRA 時間軸:
步驟 0-14 (50%): 權重 0.7
    ↓
  角色外觀和基本構圖確立
    ↓
步驟 14-28 (50%): 權重 0.9
    ↓
  服裝細節、褶皺、紋理生成

高解析度 (1248x1824) 讓服裝細節更豐富
權重 0.9 確保蕾絲、刺繡等細節清晰
```

**範例**:
```
<lora:character:[1.0:0.6:0.3]> 
<lora:wedding_dress:[0.7:0.9:0.5]> 
1girl, char_name, wedding dress, white dress, veil, 
lace details, long train
```

**多人場景服裝 LoRA**:
```
ATTN() <lora:char_A:[1.0:0.7:0.3]> 
       <lora:dress_A:[0.7:0.9:0.5]> 
       1girl, red dress MASK(0 0.45, 0 1) AND
ATTN() <lora:char_B:[0.7:1.0:0.3]> 
       <lora:dress_B:[0.7:0.9:0.5]> 
       1girl, blue dress MASK(0.55 1, 0 1)
```

#### 4. 姿勢動作 LoRA ⭐⭐⭐⭐⭐

**作用**: 確保特定姿勢或動作正確

**權重排程**:
```
<lora:pose_name:[1.0:0.4:0.2]>
```

**參數解析**:
- `1.0 起始`: 最高權重,姿勢必須最早確立
- `0.4 結束`: 大幅降低,避免動作僵硬
- `0.2 切換`: 非常早期切換 (約 5-6步)

**為什麼這樣設定**:
```
姿勢是最基礎的構圖要素:
步驟 0-6 (20%): 權重 1.0
    ↓
  骨架、肢體位置確立
    ↓
步驟 6-28 (80%): 權重 0.4
    ↓
  模型自然調整細節、肌肉、衣物順應姿勢

⚠️ 過晚切換會導致:
  • 姿勢僵硬
  • 衣物不自然
  • 缺乏動態感
```

**範例**:
```
<lora:character:[1.0:0.6:0.3]> 
<lora:dancing_pose:[1.0:0.4:0.2]> 
1girl, char_name, dancing, dynamic pose, one leg raised, 
arms extended, flowing dress
```

**全身照必用**:
```
全身照 (832x1216 → 1248x1824):
  • 肢體佔比大
  • 姿勢是畫面重點
  • 必須使用姿勢 LoRA 或 ControlNet OpenPose
```

#### 5. 場景背景 LoRA ⭐⭐⭐

**作用**: 添加特定場景元素(城市、森林、室內等)

**權重排程**:
```
<lora:background_name:[0.3:0.6:0.6]>
```

**參數解析**:
- `0.3 起始`: 低權重,角色優先
- `0.6 結束`: 中等權重,背景清晰但不搶眼
- `0.6 切換`: 較晚切換,角色確立後才強化背景

**為什麼這樣設定**:
```
背景處理優先級最低:
步驟 0-17 (60%): 權重 0.3
    ↓
  角色、姿勢、服裝優先
    ↓
步驟 17-28 (40%): 權重 0.6
    ↓
  背景細節補充

避免背景過早干擾:
  • 背景高權重會搶走角色注意力
  • 可能導致角色與背景融合
  • 低權重確保層次分明
```

**範例**:
```
<lora:character:[1.0:0.6:0.3]> 
<lora:cyberpunk_city:[0.3:0.6:0.6]> 
1girl, char_name, standing, cyberpunk city, neon lights, 
rain, night, skyscrapers
```

**與角色 LoRA 協調**:
```
角色 LoRA: 高權重 → 中權重 (前期強化)
背景 LoRA: 低權重 → 中權重 (後期補充)

時間軸:
0%        30%         60%         100%
├──────────┼────────────┼────────────┤
角色 1.0 →→→ 0.6 →→→→→→→→→→→→→→→ 0.6
背景 0.3 →→→→→→→→→→→→→ 0.3 →→→→→ 0.6
```

#### 6. 品質增強 LoRA ⭐⭐

**作用**: 提升整體畫質、細節豐富度

**權重排程**:
```
<lora:quality_boost:[0.3:0.5:0.6]>
```

**參數解析**:
- `0.3 起始`: 低權重,不干擾主要生成
- `0.5 結束`: 中低權重,提升但不過度
- `0.6 切換`: 後期啟用

**為什麼這樣設定**:
```
品質 LoRA 是輔助性質:
• 不影響構圖和角色特徵
• 只在後期增強細節和質感
• 權重過高會導致過度銳化或噪點

在 Latent Upscale + denoise 0.6 的情況下:
  • 模型本身已經有較好的細節生成能力
  • 品質 LoRA 只需適度增強
  • 0.5 權重已經足夠
```

**範例**:
```
<lora:add_detail:[0.3:0.5:0.6]> 
<lora:character:[1.0:0.6:0.3]> 
masterpiece, best quality, highly detailed, 1girl, ...
```

**可選**:
```
品質 LoRA 是否需要:
✅ 需要: 模型細節不足時
✅ 需要: 追求極致品質
❌ 不需要: Illustrious 本身細節已經很好
❌ 不需要: 避免流程過於複雜
```

### Base 階段 LoRA 組合範例

#### 單人全身照 (標準配置)

```
<lora:character:[1.0:0.6:0.3]>        # 角色外觀
<lora:outfit:[0.7:0.9:0.5]>           # 服裝細節
<lora:pose:[1.0:0.4:0.2]>             # 姿勢動作
<lora:style:[0.4:0.6:0.4]>            # 整體風格
1girl, character_name, full body, red dress, standing, 
park background, detailed
```

**權重時間軸**:
```
0%    20%   30%   40%   50%   60%        100%
├──────┼─────┼─────┼─────┼─────┼───────────┤
姿勢  1.0→0.4
角色  1.0──→0.6─────────────────────────→0.6
風格      0.4───→0.6──────────────────────→0.6
服裝            0.7──→0.9─────────────────→0.9
```

#### 多人場景 (2人)

```
<lora:style:[0.4:0.6:0.4]>            # 全局風格
park, trees, outdoor BREAK

ATTN() <lora:char_A:[1.0:0.7:0.3]> 
       <lora:dress_A:[0.7:0.9:0.5]> 
       [CUT:blue blonde short:] 
       1girl, char_A, red dress, black hair, left side 
       MASK(0 0.45, 0 1) FEATHER(30 0 30 0) AND

ATTN() <lora:char_B:[0.7:1.0:0.3]> 
       <lora:dress_B:[0.7:0.9:0.5]> 
       [CUT:red black long:] 
       1girl, char_B, blue dress, blonde hair, right side 
       MASK(0.55 1, 0 1) FEATHER(30 0 30 0)
```

**交錯峰值策略**:
```
角色A: [1.0:0.7:0.3]  ← 前期優先確立
角色B: [0.7:1.0:0.3]  ← 後期強化

避免同時高權重干擾
```

---

## FaceDetailer 階段

### 階段 4: FaceDetailer

```
[Image from Base] → [FaceDetailer]
                         ↑
                    在這裡使用 LoRA
```

### 為什麼需要不同的 LoRA?

```
Base 階段:
  • 解析度: 1248x1824
  • 臉部大小: 約 150x180px
  • 能生成基本五官但細節不足

FaceDetailer 階段:
  • Guide size: 512
  • 臉部放大到: 512x612px (3.4x放大)
  • 足夠空間生成精細五官

需要專門的五官 LoRA:
  • Base 的角色 LoRA 側重整體
  • Face 的 LoRA 側重眼睛、鼻子、嘴巴、皮膚細節
```

### FaceDetailer LoRA 使用清單

#### 1. 五官細節 LoRA ⭐⭐⭐⭐⭐ (最重要)

**作用**: 精修眼睛、鼻子、嘴唇、皮膚質感

**權重**:
```
<lora:face_detail:[0.6:0.7]>
```

**為什麼不用排程**:
```
FaceDetailer 步驟較少 (通常 20 步):
  • 短時間內需要穩定權重
  • 使用固定權重或簡單排程
  • [起始:結束] 而非 [起始:結束:切換點]

推薦寫法:
  固定權重: <lora:face_detail:0.7>
  簡單排程: <lora:face_detail:[0.6:0.7]>
               (線性從 0.6 漸變到 0.7)
```

**參數建議**:
```
通用五官 LoRA: 0.5-0.7
角色專屬臉部 LoRA: 0.6-0.8
極致細節 LoRA: 0.7-0.9 (謹慎使用)
```

**範例**:
```
# FaceDetailer Positive Prompt
<lora:detailed_face:0.7> 
masterpiece, best quality, highly detailed face, 
detailed eyes, beautiful detailed eyes, perfect eyes,
detailed skin, smooth skin, detailed lips, 
perfect face, symmetrical face, sharp focus
```

#### 2. 角色臉部 LoRA ⭐⭐⭐⭐

**作用**: 確保修復後的臉仍然是該角色

**權重**:
```
<lora:character_face:0.6>
```

**為什麼需要**:
```
問題: FaceDetailer 可能改變角色特徵
  • 重繪會根據通用提示詞生成臉部
  • 可能丟失角色獨特特徵
  • 導致"換臉"效果

解決: 加入角色 LoRA
  • 確保五官符合角色設定
  • 但權重比 Base 階段低 (0.6 vs 1.0)
  • 避免過度僵硬
```

**範例**:
```
# 如果 Base 使用了角色 LoRA
# FaceDetailer 也應該使用

# Base 階段
<lora:asuna:[1.0:0.6:0.3]> 1girl, asuna \(sao\), ...

# FaceDetailer 階段
<lora:asuna:0.6> 
<lora:face_detail:0.7> 
1girl, asuna \(sao\), detailed face, orange hair, 
blue eyes, ...
```

**權重對比**:
```
Base 角色 LoRA:      [1.0:0.6:0.3]  (確立角色)
FaceDetailer 角色 LoRA:  0.6         (保持角色,但更自然)

降低權重原因:
  • FaceDetailer denoise 已經較低 (0.35)
  • 不需要過強的角色特徵引導
  • 避免五官過於「模板化」
```

#### 3. 表情風格 LoRA ⭐⭐⭐

**作用**: 控制表情類型(微笑、嚴肅、害羞等)

**權重**:
```
<lora:expression_style:0.5>
```

**範例**:
```
# 甜美笑容
<lora:character:0.6> 
<lora:sweet_smile:0.5> 
<lora:face_detail:0.7> 
1girl, char_name, smiling, happy expression, 
gentle smile, bright eyes

# 嚴肅表情
<lora:character:0.6> 
<lora:serious_face:0.5> 
<lora:face_detail:0.7> 
1girl, char_name, serious expression, closed mouth, 
stern look, focused eyes
```

**注意事項**:
```
⚠️ 表情 LoRA 容易過度:
  • 權重不要超過 0.6
  • 可能導致表情僵硬、誇張
  • 優先使用文字描述,LoRA 輔助

優先級:
  文字描述 > 表情 LoRA
  
  例如: "gentle smile, slightly open mouth, 
         cheerful expression"
  比單純用 <lora:smile:0.8> 效果更自然
```

### FaceDetailer 提示詞完整範例

#### 通用模板

```
# Positive
<lora:character:0.6> 
<lora:face_detail:0.7> 
masterpiece, best quality, highly detailed face,
(beautiful detailed eyes:1.2), (perfect eyes:1.1),
detailed pupils, eye highlights, 
detailed skin texture, smooth skin, natural skin,
detailed lips, perfect lips,
[表情描述], [髮色眼色],
sharp focus, perfect lighting, soft lighting

# Negative
lowres, bad face, deformed face, ugly face, 
bad anatomy, bad proportions,
(bad eyes:1.2), (deformed eyes:1.2), (asymmetric eyes:1.1),
crossed eyes, uneven eyes,
bad skin, rough skin, pores, acne,
blurry face, out of focus, jpeg artifacts
```

#### 角色特定範例 (Asuna)

```
# Positive
<lora:asuna:0.6> 
<lora:anime_face_detail:0.7> 
1girl, asuna \(sao\), 
highly detailed face, beautiful detailed eyes, 
orange hair, long hair, blue eyes, detailed pupils,
smiling, gentle expression, looking at viewer,
smooth anime skin, detailed lips, 
perfect face, symmetrical face

# Negative
lowres, bad face, ugly, bad anatomy,
bad eyes, crossed eyes, asymmetric eyes,
blurry, out of focus, deformed
```

#### 多人場景 FaceDetailer

```
⚠️ 重要: FaceDetailer 會自動偵測所有臉部

問題: 無法為不同角色使用不同 LoRA

解決方案 A: 使用通用 LoRA
  <lora:face_detail:0.7> 
  masterpiece, detailed face, 2girls, ...
  (適用於大多數情況)

解決方案 B: 分別處理 (進階)
  1. 使用 Crop 裁切出每個角色
  2. 分別對每個角色使用 FaceDetailer + 專屬 LoRA
  3. Paste 回原圖
  (耗時但品質最佳)
```

---

## HandDetailer 階段

### 階段 5: HandDetailer (可選)

```
[Image from FaceDetailer] → [HandDetailer]
                                  ↑
                             在這裡使用 LoRA
```

### HandDetailer LoRA 使用

#### 1. 手部修復 LoRA ⭐⭐⭐⭐⭐

**作用**: 矯正手指數量、手部結構、手勢

**權重**:
```
<lora:hand_fix:0.8>
```

**為什麼權重較高**:
```
手部是最難生成的部分:
  • Illustrious 對手部處理較弱
  • 全身照中手部通常很小 (<40px)
  • 需要更強的 LoRA 引導

權重建議:
  • 輕微問題: 0.6-0.7
  • 中等問題: 0.7-0.8
  • 嚴重問題: 0.8-0.9
  
⚠️ 即使 0.9 也不一定能完全修復
```

**範例**:
```
# HandDetailer Positive
<lora:perfect_hands:0.8> 
masterpiece, best quality, highly detailed hands,
perfect hands, 5 fingers, correct fingers,
natural hand pose, detailed fingers, 
detailed fingernails, proper hand anatomy,
no extra fingers, no missing fingers

# HandDetailer Negative
bad hands, mutated hands, extra fingers, 
fewer fingers, fused fingers, missing fingers,
extra digit, fewer digits, deformed hands,
ugly hands, bad anatomy, bad proportions
```

#### 2. 姿勢/動作 LoRA ⭐⭐⭐

**作用**: 確保手部姿勢配合整體動作

**權重**:
```
<lora:hand_pose:0.7>
```

**範例**:
```
# 揮手動作
<lora:perfect_hands:0.8> 
<lora:waving_pose:0.7> 
waving hand, raised hand, open palm, 5 fingers visible,
natural waving gesture

# 握拳動作
<lora:perfect_hands:0.8> 
<lora:fist_pose:0.7> 
clenched fist, closed hand, proper fist structure,
4 fingers curled, thumb visible
```

### HandDetailer 參數配置

```
[HandDetailer]
  guide_size: 512
  guide_size_for: bbox
  max_size: 1024
  steps: 20-25  (比 FaceDetailer 稍多)
  cfg: 7
  denoise: 0.45-0.55  (比 FaceDetailer 高)
  feather: 15-20
  
[BBOX Detector]
  model_name: bbox/hand_yolov8n.pt
  threshold: 0.5
  dilation: 15  (比臉部大,確保包含整隻手)
```

**denoise 較高的原因**:
```
手部修復需要更大改動:
  • FaceDetailer: 0.35 (五官通常只需輕微修復)
  • HandDetailer: 0.5  (手部可能需要重建結構)

但也不能太高:
  • >0.6 可能改變手部位置和姿勢
  • 導致與身體脫節
```

### 手部修復成功率

```
現實情況:
✅ 輕微問題 (姿勢不自然): 修復率 70-80%
🟡 中等問題 (手指模糊): 修復率 50-60%
❌ 嚴重問題 (6根手指): 修復率 20-30%

建議:
• 如果 Base 生成的手部已經嚴重錯誤
  → 重新生成比修復更有效
• 如果只是細節不足
  → HandDetailer 效果很好
• 可以配合 ControlNet OpenPose Hands 使用
  → 大幅提升成功率
```

---

## 完整範例

### 範例 1: 單人全身照 (標準流程)

```
📍 階段 2: Base 生成 (Main KSampler)

Positive:
<lora:asuna:[1.0:0.6:0.3]>           # 角色
<lora:wedding_dress:[0.7:0.9:0.5]>   # 服裝
<lora:standing_pose:[1.0:0.4:0.2]>   # 姿勢
<lora:anime_style:[0.4:0.6:0.4]>     # 風格
masterpiece, best quality, highly detailed,
1girl, asuna \(sao\), full body,
white wedding dress, long dress, veil, lace details,
long orange hair, blue eyes,
standing, elegant pose, hand on dress,
garden background, flowers, sunlight

Negative:
lowres, bad anatomy, bad hands, bad face, 
worst quality, low quality

Sampler:
  Steps: 28
  CFG: 7
  Denoise: 0.6


📍 階段 4: FaceDetailer

Positive:
<lora:asuna:0.6>                     # 保持角色特徵
<lora:anime_face_detail:0.7>         # 五官細節
1girl, asuna \(sao\),
highly detailed face, beautiful detailed eyes,
orange hair, blue eyes, detailed pupils,
gentle smile, happy expression,
smooth anime skin, detailed lips,
perfect face, looking at viewer

Negative:
lowres, bad face, ugly face, bad eyes,
asymmetric eyes, blurry face

FaceDetailer:
  Guide size: 512
  Steps: 20
  Denoise: 0.35


📍 階段 5: HandDetailer

Positive:
<lora:perfect_hands:0.8>             # 手部修復
masterpiece, detailed hands, perfect hands,
5 fingers, natural hand pose, hand on dress,
detailed fingers, perfect fingers

Negative:
bad hands, extra fingers, missing fingers,
deformed hands

HandDetailer:
  Guide size: 512
  Steps: 22
  Denoise: 0.50
```

### 範例 2: 雙人場景

```
📍 階段 2: Base 生成

Positive:
<lora:anime_style:[0.4:0.6:0.4]>     # 全局風格
masterpiece, best quality, 2girls, park, trees, 
outdoor, sunny day BREAK

ATTN() <lora:char_A:[1.0:0.7:0.3]> 
       <lora:red_dress:[0.7:0.9:0.5]> 
       [CUT:blue blonde short:] 
       1girl, char_A, red dress, long dress,
       long black hair, blue eyes,
       standing, left side, looking at viewer
       MASK(0 0.45, 0 1) FEATHER(30 0 30 0) AND

ATTN() <lora:char_B:[0.7:1.0:0.3]> 
       <lora:blue_dress:[0.7:0.9:0.5]> 
       [CUT:red black long:] 
       1girl, char_B, blue dress, short dress,
       short blonde hair, green eyes,
       standing, right side, waving, smiling
       MASK(0.55 1, 0 1) FEATHER(30 0 30 0)

Negative:
lowres, bad anatomy, bad hands, bad face,
merged bodies, color bleeding, same face

Sampler:
  Steps: 28
  CFG: 7
  Denoise: 0.65  (稍高,因為兩個角色)


📍 階段 4: FaceDetailer

Positive:
<lora:anime_face_detail:0.7>         # 通用五官 LoRA
masterpiece, highly detailed face,
beautiful detailed eyes, detailed pupils,
smooth anime skin, detailed lips,
perfect face, 2girls

Negative:
lowres, bad face, bad eyes, 
same face, identical faces

FaceDetailer:
  Guide size: 512
  Steps: 20
  Denoise: 0.40  (稍高,因為小臉多)
  
  # 會自動處理兩張臉
  # 無法分別使用不同角色 LoRA
  # 所以只用通用五官 LoRA


📍 階段 5: HandDetailer (兩隻手都處理)

Positive:
<lora:perfect_hands:0.8>
masterpiece, detailed hands, perfect hands,
5 fingers, natural hand pose

Negative:
bad hands, extra fingers, deformed hands

HandDetailer:
  Guide size: 512
  Steps: 22
  Denoise: 0.50
```

### 範例 3: 4人場景 (高難度)

```
📍 Base 階段建議使用更高解析度

[Empty Latent]: 832x1216
[Latent Upscale]: 1664x2432 (2x instead of 1.5x)
[KSampler]: Denoise 0.70 (更高)

原因:
  • 4張臉需要更多分辨率
  • 每張臉約 100-120px (2x 後才夠)
  • denoise 提高讓模型有更多自由度處理複雜構圖


📍 階段 2: Base 生成

Positive:
<lora:style:[0.4:0.6:0.4]>
masterpiece, 4girls, stage, concert, spotlights BREAK

ATTN() <lora:idol_A:[1.0:0.6:0.3]> 
       [CUT:B C D:] 
       1girl, pink dress, long pink hair, center
       MASK(0.35 0.65, 0.4 1, 1.2) AND

ATTN() <lora:idol_B:[0.9:0.6:0.3]> 
       [CUT:A C D:] 
       1girl, blue outfit, blue hair, left
       MASK(0.05 0.4, 0.3 0.8, 0.9) AND

ATTN() <lora:idol_C:[0.9:0.6:0.3]> 
       [CUT:A B D:] 
       1girl, purple outfit, purple hair, right
       MASK(0.6 0.95, 0.3 0.8, 0.9) AND

ATTN() <lora:idol_D:[0.7:0.8:0.4]> 
       [CUT:A B C:] 
       1girl, yellow outfit, blonde hair, back
       MASK(0.4 0.6, 0 0.4, 0.7)

Sampler:
  Steps: 32  (更多步數)
  CFG: 7
  Denoise: 0.70


📍 階段 4: FaceDetailer

Positive:
<lora:face_detail:0.7>
masterpiece, highly detailed face, 4girls

FaceDetailer:
  Guide size: 512
  Denoise: 0.45  (提高,因為小臉多)
  bbox_threshold: 0.4  (降低,確保偵測小臉)
  
  # 會處理 4 張臉
  # 總時間: ~60秒


📍 HandDetailer: 視情況決定是否使用
  • 4人場景手部通常很小
  • 修復成功率低
  • 可以選擇放棄或只修復前景角色的手
```

---

## 常見問題

### Q1: Base 階段使用了角色 LoRA,FaceDetailer 還要用嗎?

```
A: 建議要用,但權重降低

原因:
  • Base 的角色 LoRA 側重整體構圖
  • FaceDetailer 重繪時可能偏離角色特徵
  • 低權重的角色 LoRA 確保臉部仍符合角色

配置:
  Base:          <lora:character:[1.0:0.6:0.3]>
  FaceDetailer:  <lora:character:0.6>
```

### Q2: 可以在 FaceDetailer 用和 Base 不同的角色 LoRA 嗎?

```
A: 不建議,會導致「換臉」效果

例如:
  Base: <lora:char_A:[1.0:0.6:0.3]> ...
  Face: <lora:char_B:0.7> ...
  結果: A 的身體 + B 的臉 ❌

用途:
  • 除非你故意要做「換臉」效果
  • 否則保持一致
```

### Q3: 多人場景 FaceDetailer 能分別使用不同 LoRA 嗎?

```
A: 標準流程不行,但有進階方法

問題:
  • FaceDetailer 自動偵測所有臉
  • 一次只能用一組 LoRA
  • 無法針對不同角色

解決方案:
  1. 使用通用五官 LoRA (推薦,80% 情況夠用)
  2. 分別裁切 + 分別 FaceDetailer (進階,品質最佳)
  
方案 2 流程:
  原圖 → Crop 左半 → FaceDetailer(LoRA_A) → Paste
      → Crop 右半 → FaceDetailer(LoRA_B) → Paste
```

### Q4: HandDetailer 為什麼權重要這麼高?

```
A: 因為手部是最難生成的部分

數據對比:
  臉部修復成功率: 80-90%
  手部修復成功率: 40-60%

原因:
  • 模型對手部訓練數據較少
  • 手部結構複雜 (19個關節)
  • 全身照中手部通常很小

高權重 (0.8) 提升成功率:
  • 但仍然不保證 100% 修復
  • 嚴重錯誤 (6指) 建議重新生成
```

### Q5: LoRA 太多會不會互相衝突?

```
A: 會,需要注意數量和順序

安全範圍:
  • Base 階段: 3-5 個 LoRA
  • FaceDetailer: 1-3 個 LoRA
  • HandDetailer: 1-2 個 LoRA

衝突情況:
  ❌ 兩個風格 LoRA (水彩 + 油畫)
  ❌ 兩個姿勢 LoRA (站立 + 坐下)
  ❌ 多個高權重角色 LoRA

避免方法:
  • 每類 LoRA 只用一個
  • 總權重和 < 3.5
  • 測試後再批量生產
```

### Q6: 為什麼姿勢 LoRA 切換點這麼早 (0.2)?

```
A: 姿勢是最基礎的構圖要素

構圖層級:
  1. 姿勢/骨架 (0-20% 確立)
  2. 角色外觀 (0-30% 確立)
  3. 服裝細節 (20-50% 生成)
  4. 質感光影 (50-100% 精修)

如果姿勢 LoRA 切換太晚:
  • 動作僵硬,不自然
  • 衣物不順應姿勢
  • 缺乏動態感
  
[1.0:0.4:0.2] 的意義:
  • 前 20% 高權重確立骨架
  • 後 80% 低權重讓模型自然調整
```

### Q7: Latent Upscale 後還需要品質增強 LoRA 嗎?

```
A: 看情況,通常不需要

Latent Upscale + denoise 0.6:
  • 模型在高解析度下重新生成
  • 細節已經較豐富
  • 品質 LoRA 作用有限

需要的情況:
  • 模型本身細節不足
  • 追求極致銳化
  • 特定風格需求

不需要的情況:
  • Illustrious 本身細節很好
  • 避免過度銳化
  • 保持流程簡潔
```

### Q8: 所有 LoRA 的權重總和有限制嗎?

```
A: 沒有硬性限制,但有經驗值

建議範圍:
  • Base 階段總權重和: 2.5-3.5
  • FaceDetailer 總權重: 1.5-2.0
  • HandDetailer 總權重: 1.5-2.0

計算方式:
  • 使用結束權重計算
  • 排程的話用結束權重
  
範例:
  Base:
    <lora:char:[1.0:0.6:0.3]>      → 0.6
    <lora:outfit:[0.7:0.9:0.5]>    → 0.9
    <lora:pose:[1.0:0.4:0.2]>      → 0.4
    <lora:style:[0.4:0.6:0.4]>     → 0.6
    總和: 2.5 ✅
  
超過 4.0:
  • 可能過度引導
  • 失去自然感
  • 圖像僵硬
```

---

## 總結: LoRA 使用決策樹

```
開始生成
    ↓
需要特定角色? → YES → Base: 角色 LoRA [1.0:0.6:0.3]
    │                   Face: 角色 LoRA 0.6
    ↓
需要特定風格? → YES → Base: 風格 LoRA [0.4:0.6:0.4]
    │
    ↓
需要特定服裝? → YES → Base: 服裝 LoRA [0.7:0.9:0.5]
    │
    ↓
需要特定姿勢? → YES → Base: 姿勢 LoRA [1.0:0.4:0.2]
    │
    ↓
需要特定場景? → YES → Base: 場景 LoRA [0.3:0.6:0.6]
    │
    ↓
Base 生成完成
    ↓
五官需要修復? → YES → FaceDetailer
    │                   • 五官 LoRA: 0.7
    │                   • 角色 LoRA: 0.6 (如果 Base 有用)
    ↓
手部需要修復? → YES → HandDetailer
    │                   • 手部 LoRA: 0.8
    │                   • 姿勢 LoRA: 0.7 (如果需要)
    ↓
完成!
```

---

**最重要的原則**: 
- Base 階段用結構性 LoRA 確立構圖
- FaceDetailer 用細節性 LoRA 精修五官
- HandDetailer 用修復性 LoRA 矯正手部
- 權重隨階段遞減,避免僵硬
- 測試找到最適合你的配置!