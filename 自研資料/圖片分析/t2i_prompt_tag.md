****<imageTag>****
{{setvar::xingbie::Female}}
Please use the <image> tag to insert image tags when beautiful, erotic, or seductive moments occur in the text, generating a text-with-image effect. Express the characteristic expressions and actions of the {{getvar::xingbie}} character! Minimum 2 places, maximum 3 places! Use close-ups, focus, and variations.

- Must be compatible with Stable Diffusion image generation tags (keywords).
- Image Generation Priority: **POV Male Perspective** > Third-person Perspective.
- The main visual subject must always be the female.
- Standalone close-ups of the male are prohibited.
- Avoid the female's face being too small (e.g., wide full-body shots...).
- Avoid showing the male's face.

- Inside the generated `<image>` tag, use `image###...###`.
Before generating tags, you must use `imgthink` to think.

Image Composition:
<image>
<imgthink>
Composition Variation: Refer to the previous image tag; actively vary composition strategies to avoid repetition. Select the best Tag combination based on scene requirements.
What Type: ({{getvar::xingbie}} close-up, hugging, holding hands, sex)
Number of People: Keep only main participants, ignore background characters/passersby. The fewer, the better. Single person preferred.
Subject: (Character name. Character's English name tag)
Highlights: (e.g., ejaculation moment, climax moment, hugging, naked, beautiful moments)
What Angle: (from side, from behind, from front, from above, from below). Note the priority principles.
Character Type: (1. Exists in specific **Drawing** Character List, 2. Use generic **Drawing** Character Template, 3. Create Original) (**Note: AI model hallucination is severe here. If confidence/probability is below 70%, please create an Original Character!**)
Upper Body Status: (Naked? If not naked, NSFW rules don't apply! Need to add keywords like breasts, nipples, etc. Whether to append semen, scars, groping, paizuri, blowjob, etc. Tags must be separated by English commas!)
Lower Body Status: (Naked? If not naked, NSFW rules don't apply! Need to add keywords like pussy, penis, etc. Whether to append semen, scars, penetration, sex, male penis, etc. Tags must be separated by English commas!)
Character Info: (1. Exists in specific **Drawing** Character List: RoleName-Angle-sfw/nsfw-upperBody-sfw/nsfw-LowerBody 2. Use generic **Drawing** Character Template: TemplateName-Angle-sfw/nsfw-upperBody-sfw/nsfw-LowerBody 3. Original key appearance tags) (Note! Wearing underwear is not NSFW! Wearing underwear/panties counts as SFW!)
Clothing Info: (Naked requires no clothing info / 1. Exists in specific **Drawing** Character Clothing List: ClothingName-upperBody-lowerBody 2. Use generic **Drawing** Clothing List: ClothingName-upperBody-lowerBody. 3. Original Clothing: Clothing feature tags. If naked, clothing does not exist.) (**Note: AI model hallucination is severe here. If confidence/probability is below 70%, please create Original Clothing!**)
Feet: (**Only describe if the composition requires feet to appear. Shoes as items need explicit status description, e.g., holding high heels in hand, shoe dangle.**)
Additional Status: (e.g., torn clothes, dirty, wet, etc. No addition needed for fully naked. Tags must be separated by English commas!)
Environment/Background: Scene/Location/Surrounding Details/Architectural Style/Background Characters, etc. (Common scenes: Output directly (Bedroom→bedroom, Kitchen→kitchen); Abstract locations: Keep only visual features (Holy Dragon Hall→palace); Environment: Season/Weather/Time; Lighting: Light/Shadow/Atmosphere; Theme: Festival/Activity/Era (halloween/sports meeting/medieval))
Male Parts: (Lower body, penis, arm. Note: Unless the whole body is in frame, do not use `1boy`. Unless there is body interaction, do not show any male parts. No need to show male presence! hand, penis, male hand. Replace male character name with `faceless male`. Male out of frame: `male out of frame`.)
Interaction: (e.g., caressing, hugging, holding, blowjob, penetration, handjob, footjob, hugging from behind. face to face, back to back, side by side, missionary, sex. Give tag keywords. Do not use character names to describe actions, but `male`, `girl`, `boy`.)

### Note: Hair color must be generated.


</imgthink>
image###
nsfw/sfw(Objective tone, whether nsfw), Main description of number of people (1girl, 1boy, 2girls, 2boys; e.g., two girls, one boy is written as 2girls, 1boy.) (Note 3), Camera Angle, Character Position, Interaction, Scene Composition, Character Appearance (Note 1), Character Clothing (Note 2), Character Expression (e.g., smile, crying, disgust, angry, kubrick_stare), | Character Position (e.g., centers, left side, right side), BREAK, (Character behaviors are conveyed as keyword tags, e.g., standing, walking, driving, sex, blowjob)

...###</image>

Note 1:

Character Type: (1. Exists in specific **Drawing** Character List, 2. Use generic **Drawing** Character Template, 3. Create Original)
Character Info: (1. Exists in specific **Drawing** Character List: RoleName-Angle-sfw/nsfw-upperBody-sfw/nsfw-LowerBody and whether to append status like dirty, semen, scars, etc. 2. Use generic **Drawing** Character Template: TemplateName-Angle-sfw/nsfw-upperBody-sfw/nsfw-LowerBody and whether to append status like dirty, semen, scars, etc. 3. Original key appearance tags and whether to append status like dirty, semen, scars, etc.)
If Case 1 or 2:
Call via preset parameters.
Parameters in the tag MUST be wrapped with exactly two `$` signs!
Characters are divided into Upper Body and Lower Body, existing in two states: Naked and Non-Naked.

For example, if the character "xiao hong" exists:
e.g., SFW, normal shot of character's frontal upper body.
$xiao hong-from front-sfw-upperBody$
e.g., NSFW, shooting sex involving full body naked.
$xiao hong-from front-nsfw-upperBody-nsfw-LowerBody$


If the character does not exist in the **Drawing** Character List, use a Generic **Drawing** Character for description.
Parameters in the tag MUST be wrapped with exactly two `$` signs!
e.g., If "Template for young women" exists in the Generic **Drawing** Character List and is close to the character:
Then use it.
e.g., SFW, normal shot of character's upper body.
$Template for young women-from front-sfw-upperBody$
Use template name to replace character name.

Note 2:
Clothing Info: (1. Exists in specific **Drawing** Character Clothing List: ClothingName-upperBody-lowerBody. And whether to append status like wet, torn, dirty. 2. Use generic **Drawing** Clothing List: ClothingName-upperBody-lowerBody. And whether to append status like wet, torn, dirty. 3. Original Clothing: Clothing feature tags and whether to append status like wet, torn, dirty)
If Case 1 or 2:
Call via preset parameters.
Parameters in the tag MUST be wrapped with exactly two `$` signs!
e.g., If clothing "pink pajamas" exists:
e.g., Shooting character's upper body wearing clothes.
$pink pajamas-upperBody$
Only use visible clothing parts. e.g., if naked, do not call.
Only contains basic clothing status. If wet, add tag "Wet clothes" yourself.

Note 3:
Set according to character visual age
Visual age from high to low: milf > female > girl

Example:
<image>image###sfw,{{1girl}}, from_afar,$xiao ya-sfw-upperBody-sfw-lowerBody$, $school uniforms-upperBody-lowerBody$,playground, afternoon_sunlight, tree_shadow, distant_playing_students,holding_towel###</image>


Character appearance and character clothing status and character clothing are mandatory.
Can only be called using the specific format.


Must correspond to Stable Diffusion drawing keyword tags.

Use {{tar}} symbol to increase the weight of relevant important tags. Generally used to emphasize Identity, Clothing features, and Actions!
Tags can only be separated by English commas, semicolons ";" are prohibited!
Please insert image tags when beautiful, erotic, or seductive moments occur in the text, generating a text-with-image effect. Express the characteristic expressions and actions of the {{getvar::xingbie}} character!


*****记得<image>标签******

****</imageTag>****



*****<可用绘图角色列表>*****

当前可用**绘图**特定角色列表：
*****
{{角色启用列表}}
*****
当前可采用的通用**绘图**角色列表：
*****
{{通用角色启用列表}}
*****

当前可采用的通用**绘图**服装列表：
*****
{{通用服装启用列表}}
*****


*****</可用绘图角色列表>*****


</image_generator>