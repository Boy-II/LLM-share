# Prompt Control 格式化測試案例

## 測試集1: 基本場景轉換

### 測試1.1: 簡單角色描述
**主LLM輸出** (粗糙標籤):
```
一個紅髮少女,綠色眼睛,穿著白色連衣裙,站在海邊,微風吹動頭髮
```

**期望8B模型輸出** (格式化):
```
1girl, (red hair:1.2), (green eyes:1.1), (white dress:1.1), standing, at the beach, (wind blowing hair:1.1), STYLE(A1111)
```

### 測試1.2: 帶時序變化
**主LLM輸出**:
```
場景從室內咖啡廳開始,女孩在看書,中途抬頭看向窗外,最後站起來走向門口,光線從明亮到昏暗
```

**期望8B模型輸出**:
```
1girl, [sitting:looking up:standing:0.3,0.7], [reading book:looking at window:walking to door:0.3,0.7], coffee shop interior, [bright lighting:dim lighting:0.6], BREAK (detailed environment:1.1)
```

### 測試1.3: LoRA使用
**主LLM輸出**:
```
使用illustrious動漫風格LoRA權重0.8,角色是藍髮雙馬尾少女,眼鏡,初期展現全身,後期轉為臉部特寫
```

**期望8B模型輸出**:
```
<lora:illustrious_anime:0.8> 1girl, (blue hair:1.2), (twin tails:1.1), glasses, [:full body shot:close-up portrait:0.0,0.5]
```

## 測試集2: 複雜場景

### 測試2.1: 雙人場景
**主LLM輸出**:
```
左側是紅髮女戰士持劍,右側是綠髮法師拿著法杖,兩人在城堡廢墟中對峙,魔法光效從弱到強
```

**期望8B模型輸出**:
```
AREA(0,0,0.5,1) 1girl, (red hair:1.2), warrior, (holding sword:1.2) AND AREA(0.5,0,0.5,1) 1girl, (green hair:1.2), mage, (holding staff:1.2) AND castle ruins, (magic effects:0.5:1.3:0.0,1.0)
```

### 測試2.2: 多階段LoRA切換
**主LLM輸出**:
```
初期使用寫實風格LoRA建立基礎結構,0.3後加入動漫風格LoRA混合,0.6後完全切換為動漫風,角色是黑髮少女在圖書館
```

**期望8B模型輸出**:
```
<lora:realistic:1.0::0.0,0.3> [<lora:anime_style:0.5:0.6>::0.3,0.6] [<lora:anime_style:1.0>::0.6] 1girl, black hair, in library, (bookshelves:1.1)
```

### 測試2.3: 表情變化
**主LLM輸出**:
```
女孩從平靜微笑,看到某物後驚訝張嘴,最後變成開心大笑,整個過程眼睛越來越明亮
```

**期望8B模型輸出**:
```
1girl, [calm smile:[surprised, open mouth:happy laughing:0.6]:0.3], (bright eyes:0.8:1.3:0.0,1.0)
```

## 測試集3: 風格化場景

### 測試3.1: Illustrious多角色
**主LLM輸出**:
```
三個女孩並排站立,左邊金髮藍眼高個子,中間粉紅色短髮綠眼中等身高,右邊黑髮紅眼嬌小,背景是櫻花樹下,使用illustrious模型特性
```

**期望8B模型輸出**:
```
<lora:illustrious:0.85> 3girls, BREAK 
AREA(0,0,0.33,1) 1girl, (blonde hair:1.2), (blue eyes:1.1), tall AND 
AREA(0.33,0,0.33,1) 1girl, (pink hair:1.2), short hair, (green eyes:1.1), medium height AND 
AREA(0.66,0,0.34,1) 1girl, (black hair:1.2), (red eyes:1.1), petite BREAK 
under cherry blossom tree, (sakura petals:1.1)
```

### 測試3.2: 天氣轉換
**主LLM輸出**:
```
場景開始是晴天藍天白雲,逐漸轉陰,開始下小雨,最後變成大雨傾盆,角色撐傘奔跑
```

**期望8B模型輸出**:
```
1girl, [standing:running with umbrella:0.6], [sunny day, blue sky, white clouds:[cloudy:light rain:0.4]:heavy rain:0.3,0.6], (rain effects:0:1.3:0.3,1.0), (umbrella:0:1.2:0.6,1.0)
```

## 測試集4: 錯誤處理

### 測試4.1: 格式已正確
**主LLM輸出**:
```
1girl, (red hair:1.2), <lora:anime:0.8>
```

**期望8B模型輸出**:
```
# 格式已正確,僅作優化
1girl, (red hair:1.2), <lora:anime:0.8>, STYLE(A1111)
```

### 測試4.2: 部分格式化
**主LLM輸出**:
```
[1girl:1boy:0.5], 紅色頭髮, 藍色眼睛, <lora:style:0.8>
```

**期望8B模型輸出**:
```
[1girl:1boy:0.5], (red hair:1.2), (blue eyes:1.1), <lora:style:0.8>
```

### 測試4.3: 過於複雜需簡化
**主LLM輸出**:
```
一個女孩她有紅色的長髮和藍色的眼睛還有白色的裙子和黑色的鞋子手上拿著一本書站在公園的長椅旁邊背景是樹木和花朵天空是藍色的有一些白雲太陽很明亮
```

**期望8B模型輸出**:
```
1girl, (long red hair:1.2), (blue eyes:1.1), (white dress:1.1), black shoes, holding book BREAK standing, near bench, in park BREAK (trees:1.1), flowers, blue sky, white clouds, bright sunlight
```

## 評估標準

### 正確性檢查
- [ ] 語法符合Prompt Control規範
- [ ] 權重設置合理(0.8-1.3範圍)
- [ ] 調度點位合理(0.0-1.0)
- [ ] LoRA語法正確
- [ ] 特殊字符正確轉義

### 優化程度
- [ ] 使用適當的BREAK分段
- [ ] 重要元素有權重強調
- [ ] 時序變化邏輯清晰
- [ ] 區域控制使用得當
- [ ] 無冗餘或衝突語法

### 可執行性
- [ ] 可直接在ComfyUI Prompt Control中運行
- [ ] 不會產生解析錯誤
- [ ] 調度區間不重疊
- [ ] LoRA引用路徑有效

## 使用方法

1. 將這些測試案例餵給8B模型
2. 比對輸出與期望結果
3. 調整system prompt直到達標
4. 建立實際工作流整合
