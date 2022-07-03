summon minecraft:area_effect_cloud ~ ~ ~ {CustomName:'{"text":"0","font":"font_animation:beam_prepare/1"}',CustomNameVisible:1,Duration:11,Tags:['{"text":"","font":"font_animation:beam_prepare/1"}', '{"text":"","font":"font_animation:beam_prepare/0"}', 'new_font_anim']}
scoreboard players set @e[type=area_effect_cloud,tag=new_font_anim,limit=1] font_animation 10
tag @e[type=area_effect_cloud,tag=new_font_anim,limit=1] remove new_font_anim
