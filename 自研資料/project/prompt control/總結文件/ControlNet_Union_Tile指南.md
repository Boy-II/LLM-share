# ControlNet Union SDXL Tile 使用指南

> 針對 xinsir/controlnet-union-sdxl-1.0 的 Tile 功能深度解析
> 
> 作者: Boy | 更新日期: 2025-11-11

---

## ControlNet Union SDXL 簡介

### 什麼是 ControlNet Union?

這是一個**統一的 All-in-One ControlNet**,單一模型支援 12+ 種控制類型!

```
傳統 ControlNet:
  • control_sd15_tile.pth (專門處理 Tile)
  • control_sd15_canny.pth (專門處理 Canny)
  • control_sd15_depth.pth (專門處理 Depth)
  → 需要多個模型檔案,佔用大量空間

ControlNet Union SDXL:
  • controlnet-union-sdxl-1.0.safetensors (統一模型)
  → 一個檔案支援所有控制類型!
  → 包含 Tile 功能 ✅
```

### Union 的 Tile 功能

ControlNet Union **內建 3 種 Tile 模式**:

| 模式 | 功能 | 適用場景 |
|------|------|----------|
| **Tile Deblur** | 去模糊 | 修復模糊圖像 |
| **Tile Variation** | 變化生成 | 保持構圖但改變細節 |
| **Tile Super Resolution** | 超解析度 | 1M→9M 極限放大 |

---

## 在 ComfyUI 中使用

### 基礎節點設定

#### 方法 1: 使用 ControlNet Union 節點

```
[Load Image] 原圖
    ↓
[ControlNet Union Type Selector]
  control_type: "tile"
    ↓
[Apply ControlNet]
  strength: 0.5
  start_percent: 0.0
  end_percent: 1.0
  control_net: controlnet-union-sdxl-1.0
    ↓
[KSampler]
  denoise: 0.5
  steps: 25
    ↓
[VAE Decode]
```

#### 方法 2: 使用 ComfyUI 內建節點

```
[Load Image] 原圖
    ↓
[ControlNetApplyAdvanced]
  control_net: controlnet-union-sdxl-1.0
  image: 原圖
  strength: 0.5
  control_mode: "tile"  ← 關鍵參數
    ↓
[KSampler Img2Img]
  denoise: 0.5
```

### 完整工作流程範例

#### 場景 1: Tile Super Resolution (推薦)

```
目標: 1248x1824 → 2496x3648 極致細節

[Load Image] 1248x1824
    ↓
[Upscale Image] 2x → 2496x3648
  upscale_method: lanczos
    ↓
[ControlNet Union Type Selector]
  control_type: "tile"
    ↓
[Load Checkpoint] illustrious-v1.0
    ↓
[PCLazyLoraLoader]
  <lora:character:0.6>
  <lora:quality:0.5>
    ↓
[Apply ControlNet]
  strength: 0.5-0.6
  control_net: controlnet-union-sdxl-1.0
    ↓
[CLIP Text Encode] Positive:
  masterpiece, best quality, highly detailed,
  sharp focus, crisp, clear, detailed face,
  detailed hands, detailed clothing textures
    ↓
[CLIP Text Encode] Negative:
  lowres, blurry, soft, out of focus,
  low quality, worst quality, artifacts
    ↓
[KSampler]
  denoise: 0.5-0.6
  steps: 25-30
  cfg: 7-8
  sampler: euler_a 或 dpmpp_2m
    ↓
[VAE Decode]
    ↓
[FaceDetailer]
  guide_size: 512
  denoise: 0.35
  <lora:face_detail:0.7>
    ↓
[Save Image]

時間成本: ~90秒
VRAM 需求: ~11-12GB
品質: 9.5/10
```

#### 場景 2: Tile Deblur (去模糊)

```
適用: 原圖模糊,需要修復

[Load Image] 模糊圖像
    ↓
[ControlNet Union Type Selector]
  control_type: "tile_deblur"  ← 去模糊模式
    ↓
[Apply ControlNet]
  strength: 0.6-0.7  ← 較高 strength
    ↓
[KSampler]
  denoise: 0.6-0.7  ← 較高 denoise
  steps: 30
  cfg: 8
    ↓
結果: 清晰圖像

注意: 
  • 去模糊需要較高參數
  • 但不要過度 (strength > 0.8 可能改變構圖)
```

#### 場景 3: Tile Variation (變化生成)

```
適用: 保持構圖但想要不同細節

[Load Image] 原圖
    ↓
[ControlNet Union Type Selector]
  control_type: "tile_variation"  ← 變化模式
    ↓
[Apply ControlNet]
  strength: 0.4-0.5  ← 中等 strength
    ↓
[KSampler]
  denoise: 0.5-0.6
  steps: 25
  seed: [隨機]  ← 不同 seed 產生不同變化
    ↓
結果: 構圖相同,細節不同

用途:
  • 生成多個版本供選擇
  • 微調細節但保持整體
  • 創意探索
```

---

## 參數調整指南

### ControlNet Union Tile 參數表

| 用途 | Strength | Denoise | Steps | CFG | 效果 |
|------|----------|---------|-------|-----|------|
| **標準細節增強** | 0.5 | 0.5 | 25 | 7 | 平衡,推薦 |
| **保守增強** | 0.4 | 0.45 | 20 | 7 | 構圖超穩定 |
| **激進增強** | 0.6 | 0.6 | 30 | 8 | 細節豐富 |
| **去模糊** | 0.7 | 0.65 | 30 | 8 | 修復模糊 |
| **變化生成** | 0.4 | 0.55 | 25 | 7 | 多樣性 |

### Union 特殊優勢

#### 1. 更好的高解析度支援

```
Union 使用 Bucket Training:
  • 支援任意長寬比
  • 1:1, 3:4, 9:16 等都能完美處理
  • 不會有變形或品質下降

Illustrious + Union:
  832x1216 → 2496x3648
  1024x1024 → 3072x3072
  1216x832 → 3648x2496 (橫向)
  
  全部都能完美處理!
```

#### 2. 更好的細節保留

```
Union 使用 10M+ 高品質訓練數據:
  • 細節更豐富
  • 質感更真實
  • 邊緣更清晰
  
對比測試 (1248x1824 → 2496x3648):
  SD1.5 Tile:    細節 8/10
  Union Tile:    細節 9.5/10
```

#### 3. 更好的提示詞跟隨

```
Union 使用 DALL-E 3 式 Re-captioning:
  • 提示詞理解更準確
  • 細節描述更到位
  • 複雜提示詞處理更好
  
實例:
  Prompt: "highly detailed Victorian dress 
           with intricate lace patterns"
  
  SD1.5 Tile: 只增強整體細節
  Union Tile: 真的生成細緻的蕾絲紋理
```

---

## 與 Illustrious 完美配合

### 為什麼 Union + Illustrious 是絕配?

```
Illustrious 特點:
  • Danbooru 訓練,二次元風格強
  • 多角色控制好
  • 提示詞理解精準
  
Union 特點:
  • SDXL 架構,與 Illustrious 同根
  • 高解析度優化
  • 細節增強頂級
  
結合效果:
  ✅ 構圖準確 (Illustrious)
  ✅ 細節豐富 (Union Tile)
  ✅ 風格統一
  ✅ 性能最優
```

### 完整工作流程 (Illustrious + Union)

```
階段 1: Base 生成
  [Empty Latent] 832x1216
      ↓
  [Latent Upscale] 1.5x → 1248x1824
      ↓
  [PCLazyLoraLoader]
    <lora:character:[1.0:0.6:0.3]>
    <lora:outfit:[0.7:0.9:0.5]>
    <lora:pose:[1.0:0.4:0.2]>
      ↓
  [KSampler] denoise: 0.6, 28 steps
      ↓
  [VAE Decode] → Base 圖 (1248x1824)
  
階段 2: Union Tile 細節增強
  [Upscale Image] 2x → 2496x3648
      ↓
  [ControlNet Union] type: "tile"
    strength: 0.5
      ↓
  [KSampler] denoise: 0.5, 25 steps
      ↓
  Tile 增強圖 (2496x3648)
  
階段 3: FaceDetailer 精修
  [FaceDetailer]
    guide_size: 512
    denoise: 0.35
    <lora:character:0.6>
    <lora:face_detail:0.7>
      ↓
  最終圖像

總時間: ~100秒
總 VRAM: ~12GB
品質: 極致 9.5/10
```

---

## ProMax 版本高級功能

### ProMax 的三大超級功能

Union 的 ProMax 版本新增:

#### 1. Tile Super Resolution (極限放大)

```
能力: 1M → 9M 解析度!

實例:
  1024x1024 (1M) → 3072x3072 (9M)
  
使用:
  [ControlNet Union ProMax]
    control_type: "tile_super"
    strength: 0.6
  [KSampler]
    denoise: 0.5
    steps: 30
    
  可以分多階段:
    1024 → 2048 (denoise 0.5)
    → 3072 (denoise 0.4)
    
  避免一次放太大導致失真
```

#### 2. Image Inpainting (局部重繪)

```
功能: Union 內建 Inpainting

使用:
  [Draw Mask] 標記要重繪的區域
      ↓
  [ControlNet Union ProMax]
    control_type: "inpainting"
    strength: 0.7
      ↓
  [KSampler]
    denoise: 0.8  ← Inpainting 用高 denoise
    
  只重繪選中區域,其他完美保留
```

#### 3. Image Outpainting (擴展畫面)

```
功能: 擴展圖像邊界

使用:
  [Extend Canvas] 擴展畫布
      ↓
  [ControlNet Union ProMax]
    control_type: "outpainting"
    strength: 0.6
      ↓
  [KSampler]
    denoise: 0.7
    
  Prompt: 描述要補充的內容
  
  實例: 1024x1024 → 1024x1536 (延伸下半部)
```

---

## 多控制組合 (高級技巧)

### Union 支援多控制疊加

#### 範例 1: Tile + Openpose

```
用途: 放大的同時調整姿勢

[Load Image] 原圖
    ↓
[Upscale] 2x
    ↓
[OpenPose Preprocessor]
    ↓
[ControlNet Union Multi]
  control_1: "tile" (strength 0.5)
  control_2: "openpose" (strength 0.7)
    ↓
[KSampler] denoise: 0.6
    ↓
結果: 
  • 細節增強 (Tile)
  • 姿勢微調 (Openpose)
```

#### 範例 2: Tile + Depth

```
用途: 細節增強 + 深度控制

[Load Image] 原圖
    ↓
[Upscale] 2x
    ↓
[Depth Preprocessor]
    ↓
[ControlNet Union Multi]
  control_1: "tile" (strength 0.5)
  control_2: "depth" (strength 0.4)
    ↓
[KSampler] denoise: 0.5
    ↓
結果:
  • 細節增強
  • 深度層次更好
  • 立體感提升
```

---

## 實戰案例

### 案例 1: 全身照極致放大

```
目標: 832x1216 → 2496x3648

Base (Illustrious):
  832x1216 → Latent 1.5x → 1248x1824
  denoise: 0.6, 28 steps
  ↓
Union Tile 放大:
  Upscale 2x → 2496x3648
  ControlNet Union Tile (strength 0.5)
  denoise: 0.5, 25 steps
  ↓
FaceDetailer:
  guide_size: 512
  denoise: 0.35, 20 steps
  
結果:
  • 構圖完美保持
  • 服裝細節豐富 (紋理、褶皺)
  • 五官極致清晰
  • 背景細節提升

時間: ~100秒
品質: 9.5/10
```

### 案例 2: 雙人場景處理

```
目標: 1248x1824 雙人圖 → 2496x3648

Base (Illustrious):
  使用 Regional Prompts 控制兩個角色
  ↓
Union Tile:
  strength: 0.45  ← 多人用略低參數
  denoise: 0.48
  
  Prompt: 
    2girls, highly detailed faces, 
    detailed clothing textures,
    clear sharp focus
  ↓
FaceDetailer × 2:
  自動偵測兩張臉
  denoise: 0.38  ← 略高,小臉需要更多重繪
  
結果:
  • 兩個角色都清晰
  • 五官都精緻
  • 服裝細節到位
  • 無混淆或干擾

時間: ~130秒
```

### 案例 3: 去模糊修復

```
情境: 拿到一張模糊的生成圖,想修復

[Load Image] 模糊圖 (1248x1824)
    ↓
[ControlNet Union]
  control_type: "tile_deblur"  ← 專用去模糊
  strength: 0.7
    ↓
[KSampler]
  denoise: 0.65
  steps: 30
  cfg: 8
  
  Prompt:
    sharp, clear, crisp, highly detailed,
    perfect focus, high quality
  
  Negative:
    blurry, soft, out of focus, hazy,
    motion blur, unfocused
    ↓
[Save Image]

結果:
  • 模糊大幅改善
  • 細節恢復
  • 但不改變構圖
  
注意: 
  • 只能改善輕中度模糊
  • 極度模糊的圖無法完全修復
  • 原圖構圖要好
```

---

## 常見問題 (Union 專屬)

### Q1: Union 和傳統 SD1.5 Tile 有什麼區別?

```
A: Union 是 SDXL 架構,全面優於 SD1.5

對比:
                SD1.5 Tile        Union SDXL Tile
解析度上限      2048x2048         4096x4096+
細節品質        8/10              9.5/10
提示詞理解      7/10              9/10
多長寬比        ❌ 容易變形        ✅ 完美支援
訓練數據        較少              10M+ 高品質
參數量          相近              相近 (無明顯增加)

結論: Union 全面碾壓 SD1.5 版本
```

### Q2: Union 可以和其他 SDXL 模型搭配嗎?

```
A: 可以!Union 官方確認相容性

已測試相容:
  ✅ Illustrious (完美)
  ✅ Pony Diffusion XL (完美)
  ✅ Blue Pencil XL (良好)
  ✅ Counterfeit XL (良好)
  ✅ 其他 SDXL 微調模型 (基本相容)

不相容:
  ❌ SD1.5 模型
  ❌ SDXL Lightning (速度模型可能有問題)
  ❌ SDXL Turbo (同上)
```

### Q3: ProMax 版本值得用嗎?

```
A: 如果需要極限放大或高級功能,非常值得

ProMax 額外功能:
  • Tile Super Resolution (1M→9M)
  • Inpainting (局部重繪)
  • Outpainting (擴展畫布)
  
什麼時候用 ProMax:
  ✅ 需要 3x 以上放大
  ✅ 需要局部修改
  ✅ 需要擴展畫面
  
什麼時候用標準版:
  ✅ 日常 1.5-2x 放大
  ✅ 追求速度
  ✅ VRAM 有限

標準版時間: ~90秒
ProMax 時間: ~120秒 (+30秒)
```

### Q4: Union 的 Tile 和 Ultimate SD Upscale 哪個好?

```
A: 各有優勢,可以結合使用

Union Tile:
  ✅ 品質最高 (SDXL 架構)
  ✅ 提示詞理解好
  ✅ 與 Illustrious 配合完美
  ❌ 需要足夠 VRAM (~12GB)
  ❌ 不能超過 2-3x 放大
  
Ultimate SD Upscale:
  ✅ VRAM 友善 (Tiled Diffusion)
  ✅ 支援超大倍數放大 (4x+)
  ✅ 無縫接縫處理
  ❌ 基於 SD1.5 (品質略低)
  ❌ 提示詞理解一般
  
推薦方案:
  日常 2x 放大:  Union Tile ⭐
  超大放大 3x+:  Ultimate SD Upscale
  極致品質:      Union Tile + 手動分階段
```

### Q5: 多人場景用 Union Tile 要注意什麼?

```
A: 降低參數,避免過度重繪

單人場景:
  strength: 0.5
  denoise: 0.5
  
雙人場景:
  strength: 0.45  ← 降低 0.05
  denoise: 0.48   ← 降低 0.02
  
三人+ 場景:
  strength: 0.4   ← 再降
  denoise: 0.45   ← 再降
  
原因:
  • 多人場景構圖複雜
  • 高參數容易改變位置關係
  • 細節優先在 FaceDetailer 補足
  
技巧:
  • 提示詞明確說明人數: "2girls"
  • 使用 Regional Prompts 分別控制
  • FaceDetailer 處理各個臉部
```

---

## 總結

### Union Tile 的核心優勢

```
✅ All-in-One 設計
  • 單一模型,12+ 控制類型
  • 不需多個 ControlNet 檔案
  • 節省空間,管理方便
  
✅ SDXL 架構加持
  • 品質頂級
  • 高解析度原生支援
  • 任意長寬比完美處理
  
✅ 訓練數據優質
  • 10M+ 高品質圖像
  • DALL-E 3 式 Re-captioning
  • 細節理解到位
  
✅ 與 Illustrious 完美配合
  • 同為 SDXL 架構
  • 風格統一
  • 性能最優
```

### 推薦工作流程

```
標準流程 (日常使用):
  Base (Illustrious) 
    → Union Tile 2x 
    → FaceDetailer
  時間: ~100秒
  品質: 9.5/10
  
極致流程 (精品圖):
  Base (Illustrious, 高解析度)
    → Union Tile 1.5x
    → FaceDetailer
    → Union Tile 1.5x (二次)
  時間: ~3分鐘
  品質: 10/10
  
多人流程:
  Base (Regional Prompts)
    → Union Tile (低參數)
    → FaceDetailer × N
  時間: 視人數
  品質: 9/10
```

### 關鍵參數速查

| 場景 | Strength | Denoise | Steps | 說明 |
|------|----------|---------|-------|------|
| **標準放大** | 0.5 | 0.5 | 25 | 平衡最佳 |
| **保守增強** | 0.4 | 0.45 | 20 | 構圖優先 |
| **激進細節** | 0.6 | 0.6 | 30 | 細節優先 |
| **去模糊** | 0.7 | 0.65 | 30 | 修復模糊 |
| **多人場景** | 0.45 | 0.48 | 25 | 避免過度 |

---

**記住**: ControlNet Union SDXL 是目前最強的 Tile 解決方案,搭配 Illustrious 效果極致!你已經在用最好的工具了! 🎉