# 8B模型格式化實戰案例集

## 使用說明

這個文檔包含30個實戰案例,從簡單到複雜,用於訓練和測試8B格式化模型。

每個案例包含:
1. **場景描述** - 主LLM的粗糙輸出
2. **決策分析** - 格式化判斷過程
3. **期望輸出** - 正確的Prompt Control格式

---

## 第一組: 基礎單人場景 (1-10)

### 案例1: 簡單單人肖像
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long red hair, green eyes,
white dress, standing, smiling,
in garden

【決策分析】
- 人數: 1 → 無AREA
- 顏色: 紅髮+綠眼,不重疊 → 無CUT  
- LoRA: 需要眼睛細節 → 0.7開始
- 權重: 髮色1.2,眼睛1.1,服裝1.1

【期望輸出】
<lora:illustrious:0.85> 1girl, 
(long red hair:1.2), (green eyes:1.1), 
(white dress:1.1), standing, smiling 
BREAK 
in garden, (flowers:0.9) 
[::<lora:eye_detail:0.8>:0.7]
```

### 案例2: 動態單人 - 跳舞
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, flowing pink hair, purple eyes,
dancing, dynamic pose, dress flowing,
on stage, spotlight

【決策分析】
- 人數: 1 → 無AREA
- 動態姿勢 → 需要動態pose LoRA (0.0-0.5)
- 動作強調 → 權重1.2
- 光影 → spotlight LoRA (0.3開始)

【期望輸出】
<lora:illustrious:0.85> [<lora:dynamic_pose:0.9>::0.5]
1girl, (flowing pink hair:1.2), (purple eyes:1.1),
(dancing:1.2), (dynamic pose:1.2), 
(dress flowing with motion:1.1)
BREAK
on stage, (spotlight:1.1::0.3,0.9), 
(dramatic lighting:1.0::0.3)
[::<lora:eye_detail:0.8>:0.7]
```

### 案例3: 躺臥姿勢 - 橫版
```
【主LLM輸出】
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
1girl, long black hair, blue eyes,
lying on bed, relaxed, wearing pajamas,
in bedroom, soft morning light

【決策分析】
- 躺臥 → 橫版正確 4:3
- 無AREA需求
- 柔和光線 → 0.3-0.9
- 強調放鬆姿態

【期望輸出】
<lora:illustrious:0.85> 1girl,
(long black hair:1.2), (blue eyes:1.1),
(lying on bed:1.2), (relaxed pose:1.1),
wearing pajamas
BREAK
in bedroom, (soft morning light:1.1::0.3,0.9),
(peaceful atmosphere:0.9)
[::<lora:eye_detail:0.8>:0.7]
```

### 案例4: 特寫肖像
```
【主LLM輸出】
[ASPECT_RATIO] 2:3 [/ASPECT_RATIO]
1girl, short blonde hair, amber eyes,
close-up portrait, looking at viewer,
neutral expression, simple background

【決策分析】
- 特寫 → 極豎版 2:3
- 構圖: close-up → 0.0-0.5有效
- 眼睛是重點 → 強調+detail LoRA
- 簡單背景 → 低權重

【期望輸出】
<lora:illustrious:0.85> 1girl,
(short blonde hair:1.2), (amber eyes:1.3),
[close-up portrait::0.5], (looking at viewer:1.2),
neutral expression
BREAK
(simple background:0.7)
[::<lora:eye_detail:0.9>:0.7],
(detailed face:1.1)
```

### 案例5: 全身動作 - 跑步
```
【主LLM輸出】
[ASPECT_RATIO] 9:16 [/ASPECT_RATIO]
1girl, twin tails red hair, green eyes,
running, school uniform, energetic,
in school courtyard, motion blur on background

【決策分析】
- 極豎版 9:16 適合全身奔跑
- 動態 → 需要動態LoRA
- 運動模糊背景 → 0.4後生效
- 活力感 → 適當權重

【期望輸出】
<lora:illustrious:0.85> [<lora:dynamic_pose:0.9>::0.5]
1girl, (twin tails:1.2), (red hair:1.2), (green eyes:1.1),
(running:1.3), (school uniform:1.1), 
(energetic expression:1.1)
BREAK
in school courtyard,
[:motion blur on background:0.4],
(speed lines:0.8::0.4)
```

### 案例6: 多配件單人
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long silver hair, red eyes,
gothic lolita dress, black and white,
hat, gloves, holding umbrella,
standing, elegant pose

【決策分析】
- 多配件但屬於整體風格 → 無CUT
- 黑白配色 → 對比但不混淆
- 優雅姿態 → 適當權重
- 配件細節 → 0.6後加入

【期望輸出】
<lora:illustrious:0.85> 1girl,
(long silver hair:1.2), (red eyes:1.2),
(gothic lolita dress:1.2), (black and white:1.1),
standing, (elegant pose:1.1)
BREAK
[:hat, gloves:0.6], (holding umbrella:1.1),
[:ornate accessories:0.7]
[::<lora:fabric_detail:0.7>:0.7]
```

### 案例7: 幻想生物特徵
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long white hair, golden eyes,
elf ears, angel wings, white dress,
floating, glowing, magical atmosphere

【決策分析】
- 幻想元素 → 需要fantasy LoRA
- 發光效果 → 0.5後強化
- 飄浮姿態 → 早期建立
- 魔法氛圍 → 持續到最後

【期望輸出】
<lora:illustrious:0.85> <lora:fantasy:0.7::0.0,0.8>
1girl, (long white hair:1.2), (golden eyes:1.2),
(elf ears:1.2), (angel wings:1.3),
(white dress:1.1),
(floating:1.2), [floating pose::0.5]
BREAK
(glowing:0.7:1.2:0.5,1.0), (magical aura:1.1::0.5),
(ethereal atmosphere:1.0)
[::<lora:eye_detail:0.8>:0.7]
```

### 案例8: 職業裝扮 - 護士
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, short brown hair, brown eyes,
nurse uniform, white and pink,
standing, professional pose, holding clipboard,
in hospital, clean bright environment

【決策分析】
- 職業角色 → 制服強調
- 道具 → 手部細節重要
- 明亮環境 → 光照設置
- 專業感 → 姿態權重

【期望輸出】
<lora:illustrious:0.85> 1girl,
(short brown hair:1.1), (brown eyes:1.1),
(nurse uniform:1.2), (white and pink:1.1),
standing, (professional pose:1.1),
(holding clipboard:1.1)
BREAK
in hospital, (clean environment:1.0),
(bright lighting:1.1::0.3)
[::<lora:hand_fix:0.9>:0.6],
[::<lora:eye_detail:0.8>:0.7]
```

### 案例9: 情緒表現 - 悲傷
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, long dark blue hair, gray eyes,
sitting alone, sad expression, tears,
in rain, wet clothes, dim lighting

【決策分析】
- 情緒重點 → 表情和眼淚強調
- 雨天 → 特效0.4後
- 昏暗光線 → 全程
- 濕衣服質感 → 0.7後

【期望輸出】
<lora:illustrious:0.85> 1girl,
(long dark blue hair:1.2), (gray eyes:1.2),
sitting alone, (sad expression:1.3),
(tears:1.2), (crying:1.1)
BREAK
in rain, [:rain effects:0.4],
(wet clothes:1.1), [:fabric wet texture:0.7],
(dim lighting:1.1::0.0,1.0), (moody atmosphere:1.1)
[::<lora:eye_detail:0.9>:0.7]
```

### 案例10: 背景強調場景
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
1girl, red hair, white dress,
standing in vast flower field,
wide shot, panoramic view,
sunset, golden hour

【決策分析】
- 橫版寬幅 → 環境重要
- 廣角 → 早期構圖
- 人物相對小 → 權重平衡
- 日落 → 光影LoRA

【期望輸出】
<lora:illustrious:0.85> 1girl,
(red hair:1.1), (white dress:1.1),
standing, [wide shot::0.5],
[panoramic view::0.4]
BREAK
(in vast flower field:1.3), (endless flowers:1.2),
(sunset:1.2), (golden hour:1.3::0.3,0.9),
(dramatic sky:1.1), (warm colors:1.1::0.3)
```

---

## 第二組: 雙人場景 (11-20)

### 案例11: 雙人並排 - 需要AREA
```
【主LLM輸出】
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
2girls, side by side,
left girl: long blonde hair, blue eyes, pink dress
right girl: short black hair, red eyes, blue dress
standing, smiling, in park

【決策分析】
- 雙人並排 → 需要AREA左右分割
- 顏色: 金髮粉裙 vs 黑髮藍裙 → 已AREA隔離,無需CUT
- 對稱構圖 → 權重相同

【期望輸出】
<lora:illustrious:0.85> 2girls, side by side
BREAK
AREA(0,0,0.5,1) 1girl, (long blonde hair:1.2),
(blue eyes:1.1), (pink dress:1.2), smiling AND
AREA(0.5,0,0.5,1) 1girl, (short black hair:1.2),
(red eyes:1.1), (blue dress:1.2), smiling
BREAK
standing, in park, (trees in background:0.8)
```

### 案例12: 雙人擁抱 - 不用AREA
```
【主LLM輸出】
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
2girls, hugging each other,
first girl: red hair, green eyes
second girl: blue hair, yellow eyes
close together, happy, tears of joy

【決策分析】
- 擁抱 → 空間重疊,不用AREA
- 顏色交叉(紅vs藍,綠vs黃) → 需要CUT!
- 方形構圖 → 親密互動
- 情緒表達 → 眼淚細節

【期望輸出】
<lora:illustrious:0.85> 2girls,
[CUT:red-haired girl, green eyes:red green_eyes] AND
[CUT:blue-haired girl, yellow eyes:blue yellow_eyes]
BREAK
(hugging each other:1.3), (close together:1.2),
(happy expression:1.2), (tears of joy:1.1)
[::<lora:eye_detail:0.9>:0.7]
```

### 案例13: 雙人對峙 - 戰鬥
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
1girl 1boy, facing each other in combat stance,
girl: red hair, wielding sword, warrior armor
boy: black hair, wielding spear, dark armor
in arena, dramatic lighting, tension

【決策分析】
- 對峙 → AREA左右分割
- 戰鬥場景 → 動態LoRA 0.0-0.5
- 武器 → 手部細節重要
- 戲劇性 → 光影強化

【期望輸出】
<lora:illustrious:0.85> [<lora:dynamic_pose:0.9>::0.5]
1girl, 1boy, (combat stance:1.2)
BREAK
AREA(0,0,0.5,1) 1girl, (red hair:1.2),
(warrior armor:1.2), (wielding sword:1.2) AND
AREA(0.5,0,0.5,1) 1boy, (black hair:1.1),
(dark armor:1.2), (wielding spear:1.2)
BREAK
facing each other, in arena,
(dramatic lighting:1.2::0.3), (tension:1.1)
[::<lora:hand_fix:0.9>:0.6]
```

### 案例14: 雙人互動 - 教學
```
【主LLM輸出】
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
1girl 1woman, teacher and student,
teacher: adult, brown hair, glasses, professional attire
student: young girl, blonde hair, school uniform
sitting at desk, teacher explaining, student taking notes

【決策分析】
- 互動但有主從 → 可不用AREA
- 年齡/身份差異 → 權重區分
- 桌面道具 → 手部細節
- 學習場景 → 明亮光線

【期望輸出】
<lora:illustrious:0.85> 1girl, 1woman,
(teacher and student:1.2)
BREAK
(adult woman:1.1), (brown hair:1.1), glasses,
(professional attire:1.1), (teaching:1.2) AND
(young girl:1.1), (blonde hair:1.1),
(school uniform:1.1), (taking notes:1.1)
BREAK
sitting at desk, (books and papers:1.0),
(bright indoor lighting:1.0::0.3)
[::<lora:hand_fix:0.9>:0.6]
```

### 案例15: 雙人前後景深
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
2girls, one in foreground one in background,
foreground: red hair, close-up, looking at viewer
background: blonde hair, blurred, waving

【決策分析】
- 前後關係 → 不用AREA,用權重
- 前景清晰 → 高權重+細節
- 背景模糊 → 低權重
- 景深效果 → 全程

【期望輸出】
<lora:illustrious:0.85> 2girls,
(foreground girl:1.3), (red hair:1.2),
(close-up:1.2), (looking at viewer:1.2),
(detailed face:1.2)
AND
(background girl:0.7), (blonde hair:0.8),
(blurred:1.1), waving
BREAK
(depth of field:1.3), (bokeh:1.1)
[::<lora:eye_detail:0.9>:0.7]
```

### 案例16: 雙人牽手 - 親密
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl 1boy, holding hands, walking together,
girl: long pink hair, sundress
boy: brown hair, casual shirt
in sunset, romantic atmosphere

【決策分析】
- 牽手 → 手部細節重要!
- 並行走動 → 方向一致
- 浪漫 → 日落光影
- 不用AREA (一起行動)

【期望輸出】
<lora:illustrious:0.85> 1girl, 1boy,
(holding hands:1.3), (walking together:1.2)
BREAK
1girl, (long pink hair:1.2), (sundress:1.1) AND
1boy, (brown hair:1.1), (casual shirt:1.0)
BREAK
(sunset:1.2), (romantic atmosphere:1.2::0.3,0.9),
(warm glow:1.1::0.3), (golden hour:1.1::0.3)
[::<lora:hand_fix:1.0>:0.6]
```

### 案例17: 雙人高度差
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl 1boy, significant height difference,
tall boy patting short girl's head,
boy: tall, dark hair, smiling down
girl: short, pink hair, looking up, blushing

【決策分析】
- 高度差 → 縱向構圖,豎版正確
- 頭部互動 → 手部細節
- 視線對視 → 強調
- 無需AREA

【期望輸出】
<lora:illustrious:0.85> 1girl, 1boy,
(height difference:1.3)
BREAK
(tall boy:1.2), (dark hair:1.1),
(patting head:1.2), (smiling down:1.1) AND
(short girl:1.2), (pink hair:1.2),
(looking up:1.2), (blushing:1.2)
BREAK
(eye contact:1.1)
[::<lora:hand_fix:0.9>:0.6],
[::<lora:eye_detail:0.8>:0.7]
```

### 案例18: 雙人舞蹈
```
【主LLM輸出】
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
1girl 1boy, ballroom dancing,
formal attire, elegant poses,
in ballroom, chandelier lighting

【決策分析】
- 舞蹈 → 動態LoRA 0.0-0.5
- 優雅姿態 → 姿勢強調
- 華麗光線 → 吊燈效果
- 方形構圖平衡

【期望輸出】
<lora:illustrious:0.85> [<lora:dynamic_pose:0.9>::0.5]
1girl, 1boy, (ballroom dancing:1.3),
(formal attire:1.2), (elegant poses:1.2)
BREAK
1girl, (ball gown:1.2) AND
1boy, (suit and tie:1.1)
BREAK
in ballroom, (chandelier lighting:1.2::0.3),
(elegant atmosphere:1.1), (sparkles:0.8::0.5)
```

### 案例19: 雙人多色衝突
```
【主LLM輸出】
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
2girls, close together, best friends,
first: golden hair, blue eyes, white dress
second: blue hair, golden eyes, white dress

【決策分析】
- 顏色交叉!! (金髮藍眼 vs 藍髮金眼)
- 無AREA分割
- 必須使用CUT防汙染
- 白裙相同 → 不需要CUT白裙

【期望輸出】
<lora:illustrious:0.85> 2girls, best friends,
(close together:1.2)
BREAK
[CUT:golden-haired girl, blue eyes:golden blue_eyes] AND
[CUT:blue-haired girl, golden eyes:blue golden_eyes]
BREAK
both wearing (white dress:1.1)
[::<lora:eye_detail:0.9>:0.7]
```

### 案例20: 雙人情境複雜
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
1girl 1boy, sitting on bench,
girl reading book, boy sleeping on her shoulder,
peaceful park scene, afternoon sun

【決策分析】
- 不對稱互動 → 不用AREA
- 各有動作 → 分別描述
- 手部(拿書) → 細節
- 溫馨氛圍 → 柔和光線

【期望輸出】
<lora:illustrious:0.85> 1girl, 1boy,
sitting on bench
BREAK
1girl, (reading book:1.2), (holding book:1.1),
(calm expression:1.1) AND
1boy, (sleeping:1.2), (head on shoulder:1.2),
(peaceful:1.1)
BREAK
in park, (afternoon sun:1.1::0.3,0.9),
(dappled sunlight:1.0), (peaceful atmosphere:1.1)
[::<lora:hand_fix:0.9>:0.6]
```

---

## 第三組: 多人場景 (21-25)

### 案例21: 三人並排
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
3girls, standing in a row, idol group,
left: blonde, pink outfit
center: red hair, white outfit, leader
right: black hair, blue outfit
on stage, colorful lights

【決策分析】
- 三人並排 → AREA三等分
- 中間是焦點 → 略高權重
- 舞台燈光 → 多彩效果
- Idol主題 → 可能需要風格LoRA

【期望輸出】
<lora:illustrious:0.85> <lora:idol_style:0.7::0.0,0.8>
3girls, (idol group:1.2), standing in row
BREAK
AREA(0,0,0.33,1) 1girl, (blonde:1.2),
(pink outfit:1.2) AND
AREA(0.33,0,0.34,1) 1girl, (red hair:1.3),
(white outfit:1.2), (leader:1.2), (center focus:1.2) AND
AREA(0.67,0,0.33,1) 1girl, (black hair:1.2),
(blue outfit:1.2)
BREAK
on stage, (colorful stage lights:1.2::0.3),
(spotlight:1.1::0.3)
```

### 案例22: 四人圍坐 - 不用AREA
```
【主LLM輸出】
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
4girls, sitting around table,
having tea party, chatting, laughing,
varied hair colors and outfits,
in garden, flowers

【決策分析】
- 四人圍坐 → 不用AREA (圓形佈局)
- 方形構圖適合
- 群體互動 → 整體描述
- 多色但空間分散 → 可能不需CUT

【期望輸出】
<lora:illustrious:0.85> 4girls,
(sitting around table:1.2), (tea party:1.2),
(chatting:1.1), (laughing:1.1),
(varied hair colors:1.1), (different outfits:1.0)
BREAK
in garden, (flowers:1.0), (teacups and plates:1.0),
(cheerful atmosphere:1.1), (bright daylight:1.0::0.3)
```

### 案例23: 五人群像
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
5girls, group photo, school uniforms,
various poses, smiling, waving,
in front of school building

【決策分析】
- 5人 → 避免AREA
- 群體照 → 整體構圖描述
- 學生群體 → 統一制服
- 橫版寬幅適合

【期望輸出】
<lora:illustrious:0.85> 5girls,
(group photo:1.3), (school uniforms:1.2),
(various poses:1.1), smiling, waving,
(group shot:1.2)
BREAK
in front of school building,
(school campus:1.0), (bright sunlight:1.0::0.3),
(cheerful atmosphere:1.1)
```

### 案例24: 三人前中後
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
3girls, layered composition,
foreground: red hair, detailed, looking back
midground: blonde, walking forward
background: black hair, distant, blurred

【決策分析】
- 前中後 → 用權重不用AREA
- 景深強烈 → 重點在前景
- 細節遞減 → 權重梯度
- 豎版適合縱深

【期望輸出】
<lora:illustrious:0.85> 3girls,
(layered composition:1.2)
BREAK
(foreground:1.4), (red hair:1.3),
(detailed:1.3), (looking back:1.2)
AND
(midground:1.1), (blonde:1.1),
walking forward
AND
(background:0.7), (black hair:0.8),
(distant:0.7), (blurred:1.1)
BREAK
(strong depth of field:1.3), (bokeh:1.2)
[::<lora:eye_detail:0.9>:0.7]
```

### 案例25: 雙人+寵物
```
【主LLM輸出】
[ASPECT_RATIO] 4:3 [/ASPECT_RATIO]
2girls 1cat, in living room,
first girl: playing with cat, brown hair
second girl: watching and smiling, black hair
white cat, fluffy, playful

【決策分析】
- 人+動物 → 整體場景
- 白貓 → 可能需要CUT (如果女孩穿白衣)
- 互動場景 → 動作細節
- 室內溫馨 → 柔和光線

【期望輸出】
<lora:illustrious:0.85> 2girls, 1cat
BREAK
1girl, (brown hair:1.2), (playing with cat:1.2) AND
1girl, (black hair:1.1), watching, smiling
BREAK
[CUT:white cat, fluffy:white fluffy],
playful cat
BREAK
in living room, (cozy atmosphere:1.1),
(warm indoor lighting:1.0::0.3)
```

---

## 第四組: 特殊場景 (26-30)

### 案例26: 天氣漸變
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, standing, holding umbrella,
weather changes from sunny to rainy,
starting happy, ending melancholic

【決策分析】
- 天氣轉換 → 時間調度
- 表情變化 → 時間調度
- 雨傘出現時機 → 定時
- 光線變化 → 動態權重

【期望輸出】
<lora:illustrious:0.85> 1girl, standing,
[happy:melancholic:0.6]
BREAK
[sunny day:rainy:0.5],
[:holding umbrella:0.5],
[:rain effects:0.5],
(weather transition:1.1)
BREAK
(lighting:1.2:0.6:0.0,0.5),
(dim lighting:0.6:1.2:0.5,1.0)
```

### 案例27: 時間推移場景
```
【主LLM輸出】
[ASPECT_RATIO] 16:9 [/ASPECT_RATIO]
1girl, in same location throughout day,
morning: energetic, having breakfast
afternoon: working at desk
evening: relaxed, watching sunset

【決策分析】
- 時間序列 → SEQ或多段調度
- 動作變化 → 三階段
- 光線變化 → 全程動態
- 複雜調度案例

【期望輸出】
<lora:illustrious:0.85> 1girl
BREAK
[energetic:working:relaxed:0.3,0.6],
[having breakfast:at desk:watching sunset:0.3,0.6]
BREAK
same location,
(morning light:1.2::0.0,0.3),
(afternoon light:1.1::0.3,0.6),
(evening light:1.3::0.6,1.0),
(sunset colors:0.0:1.3:0.6,1.0)
```

### 案例28: 風格切換
```
【主LLM輸出】
[ASPECT_RATIO] 1:1 [/ASPECT_RATIO]
1girl, red hair, blue eyes,
starts realistic, transitions to anime style,
same character throughout

【決策分析】
- 風格轉換 → LoRA調度
- 早期寫實 → realistic LoRA
- 後期動漫 → anime LoRA
- 角色一致性

【期望輸出】
<lora:realistic:0.9::0.0,0.4>
[<lora:anime_style:0.5>::0.4,0.7]
[<lora:anime_style:1.0>::0.7]
BREAK
1girl, (red hair:1.2), (blue eyes:1.1),
(consistent character:1.2)
BREAK
(style transition:1.1),
[::<lora:eye_detail:0.8>:0.7]
```

### 案例29: 多LoRA複雜組合
```
【主LLM輸出】
[ASPECT_RATIO] 3:4 [/ASPECT_RATIO]
1girl, dynamic dancing pose,
detailed eyes, perfect hands,
flowing dress with detailed fabric,
dramatic lighting, anime style

【決策分析】
- 風格: anime → 全程
- 動態: dynamic_pose → 0.0-0.5
- 眼睛細節: eye_detail → 0.7-1.0
- 手部: hand_fix → 0.6-1.0
- 布料: fabric_detail → 0.7-1.0
- 光影: dramatic_light → 0.3-0.9
- 多LoRA不衝突

【期望輸出】
<lora:anime_style:0.85>
[<lora:dynamic_pose:0.9>::0.5]
(dramatic lighting:1.2::0.3,0.9)
BREAK
1girl, (dancing:1.2), (dynamic pose:1.2),
(flowing dress:1.2)
BREAK
[::<lora:eye_detail:0.8>:0.7],
[::<lora:hand_fix:0.9>:0.6],
[::<lora:fabric_detail:0.7>:0.7],
(detailed eyes:1.2), (perfect hands:1.1),
(fabric texture:1.1)
```

### 案例30: 極端複雜場景
```
【主LLM輸出】
[ASPECT_RATIO] 21:9 [/ASPECT_RATIO]
Epic battle scene, 3girls vs enemies,
left: red-haired warrior, sword, aggressive
center: blonde mage, casting spell, focused
right: black-haired archer, bow, aiming
dynamic poses, magic effects, dramatic lighting,
in ruins, fire and smoke, cinematic

【決策分析】
- 超寬幅電影感
- 三人戰鬥 → AREA分割
- 各有武器 → 手部細節
- 多種效果 → 分階段加入
- 動態+魔法+光影 → 多LoRA
- 史詩級複雜度

【期望輸出】
<lora:illustrious:0.85>
[<lora:dynamic_pose:1.0>::0.5]
[<lora:battle_scene:0.8>::0.0,0.7]
(dramatic lighting:1.3::0.3,0.9)
BREAK
3girls, (epic battle:1.3), (cinematic:1.2)
BREAK
AREA(0,0,0.33,1) 1girl, (red hair:1.2),
(warrior:1.2), (wielding sword:1.3),
(aggressive stance:1.2) AND
AREA(0.33,0,0.34,1) 1girl, (blonde:1.2),
(mage:1.2), (casting spell:1.3),
(focused expression:1.2) AND
AREA(0.67,0,0.33,1) 1girl, (black hair:1.2),
(archer:1.2), (holding bow:1.3),
(aiming:1.2)
BREAK
in ruins, (fire:0.6:1.2:0.4,1.0),
(smoke:0.6:1.1:0.4,1.0),
[:magic effects:0.5], (sparks:0.7::0.5),
(debris:1.0)
BREAK
[::<lora:hand_fix:1.0>:0.6],
[::<lora:eye_detail:0.8>:0.7],
[::<lora:magic_fx:0.7>:0.5]
```

---

## 訓練建議

### 階段1: 基礎訓練 (案例1-10)
- 掌握基本權重設置
- 理解AREA基礎概念
- 學會LoRA時間判斷

### 階段2: 進階訓練 (案例11-20)
- 掌握雙人AREA判斷
- 學會CUT使用時機
- 理解互動場景處理

### 階段3: 複雜訓練 (案例21-30)
- 多人場景決策
- 時間調度運用
- 多LoRA組合策略

### 評估標準
每個案例檢查:
- [ ] 語法正確無誤
- [ ] AREA使用恰當
- [ ] CUT判斷正確
- [ ] LoRA時間合理
- [ ] 權重設置適當
- [ ] 可直接在ComfyUI運行

建議: 
1. 先熟讀決策分析
2. 自己嘗試格式化
3. 對比期望輸出
4. 理解差異原因
5. 重複練習直到熟練

當你的8B模型能夠正確處理這30個案例時,
它就具備了實戰級別的格式化能力!
