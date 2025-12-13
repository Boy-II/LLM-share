# Chat Log - LoRA Image Tagging Prompt Project

**Date:** 2025-12-06
**Current Goal:** Create a structured prompt for LLM to analyze images and generate tags/descriptions for LoRA training.

## Progress
- Initialized project files.
- Created `chat_log.md`.
- **Update:** Rewrote `prompt.md` in Chinese.
- **Update:** Configured `prompt.md` to output both Natural Language (Short Sentences) and Tag-based formats.
- **Update:** Focused on comprehensive description for manual tuning.
- **Update:** Split `prompt.md` into `prompt_NL.md` (Natural Language) and `prompt_tag.md` (Tags).
- **Update:** Added **Global Features** section (skin, body type, race) to both prompts.
- **Update:** Removed subjective **Quality Tags** (masterpiece, best quality, etc.) to focus on content description.
- **Update:** Refined **Head, Body, Hips** sections to explicitly distinguish between **Front** and **Back** views.
- **Update:** Simplified Back view description (removed scapula/spine) to focus on exclusion of front features.
- **Update:** Added conditional visibility check for **Feet**.
- **Update:** Implemented **Layered Clothing Logic**: Body > Underwear > Clothing > Outerwear.
- **Update:** Added **Physics & Action Engine** to handle visibility exceptions.
- **Update:** Defined **Clothing Structure Rules**:
    - **Separates:** Must split into Top and Bottom.
    - **Attributes:** Added mandatory description fields for all clothing.
- **Update:** Added dedicated **Accessories** checks for each body part.
- **Update:** Added **Underwear Specs**: Explicit requirement to detail Style, Material, Color, and Details.
- **Update:** Refined **Handwear**: Classified Gloves and Detached Sleeves as items requiring mandatory Material, Color, and Style attributes.
- **Update:** Removed **Art Style & Medium** sections entirely.
- **Update:** Modified **Hands**: Removed **Fingernails**, Added **Tattoos** (tattoo) to accessories.
- **Update:** Refined **NSFW Judgment** to strict **Binary Classification** (SFW vs NSFW).
- **Update:** Finalized Output Formats:
    - **Natural Language:** Appended standalone SFW/NSFW tag at the end.
    - **Tags:** Appended 'sfw' to the example output.
- **Update:** **Optimization:** Extracted **Universal Clothing & Physics Standards** into a dedicated section.
- **Update:** **Major Reordering:** Updated analysis logic to the following order: 1.NSFW > 2.Count > 3.Char > 4.Action > 5.Char2 > 6.Env > 7.Light > 8.Cam.
- **Update:** Created **Text-to-Image Conversion Prompts**:
    - `t2i_prompt_NL.md`: For converting raw text to structured Natural Language prompts.
    - `t2i_prompt_tag.md`: For converting raw text to structured Tag prompts.
- **Update:** **Fix for Object Loss:** Added **Reinforcement Rule** to `t2i` prompts.
- **Update:** **Consistency Analysis (CoT):** Added a **Phase 1** to T2I prompts.
- **Update:** **POV Preference:** Updated T2I prompts to prioritize **Male POV** (`male pov`, `looking at viewer`) in 1girl+1boy interaction scenes.
- **Update:** **Expression Constraint:** Updated T2I prompts to **avoid 'ahegao'/'rolling eyes'**.
- **Update:** **Perspective Logic Check:** Added a validation step to T2I Phase 1.
- **Update:** **Strict Skin Tone Rule:** Explicitly instructed to OMIT skin tags by default.
- **Update:** **Core Task & Output Format (NL & Tag):**
    - **Input Source:** Extract from `<content>...</content>` tags.
    - **Selection:** Generate exactly **3 Highlight Scenes**.
    - **Wrapper:** Encapsulate each prompt in `image###...###`.
- **Update:** **Variable System (Consistency):**
    - Added mandatory `<update>` block before prompts.
    - **Keys:** `Role.{Name}.Static`, `Role.{Name}.Hair`, `Role.{Name}.Outfit`, `Action.Pose`, `Scene.Env`.
- **Update:** **Output Wrapper (Final):**
    - Entire block (Prompt + Update) MUST be wrapped in `<image>...</image>`.
    - Prompt string MUST be wrapped in `image###...###`.
- **Update:** **Status Snapshot:** Added `<status_current_variables>` block.
- **Update:** **T2I Tag Prompt Finalization:**
    - **Removed:** Variable tracking (`<update>`, `<status>`).
    - **New Core Task:** Embed prompts directly into the text flow (`<content>` wrapper).
    - **Optimized:** Translated instructions to concise English to save tokens.
- **Update:** **Sync:** Updated `t2i_prompt_NL.md` to match the optimized structure.
- **Update:** **Language:** Changed `t2i_prompt_NL.md` output language to **English** Short Sentences.

## Todo
- [x] Create comprehensive structured prompt template (Complete).
- [x] Test prompt with actual images (Complete).
