summon minecraft:area_effect_cloud ~ ~ ~ {CustomName:'{"text":"0","font":"font_animation:raid/2"}',CustomNameVisible:1,Duration:22,Tags:['{"text":"","font":"font_animation:raid/2"}', '{"text":"","font":"font_animation:raid/1"}', '{"text":"","font":"font_animation:raid/0"}', 'new_font_anim']}
scoreboard players set @e[type=area_effect_cloud,tag=new_font_anim,limit=1] font_animation 21
tag @e[type=area_effect_cloud,tag=new_font_anim,limit=1] remove new_font_anim
