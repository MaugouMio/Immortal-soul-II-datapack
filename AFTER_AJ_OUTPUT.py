from os import listdir, system, path
import json

DP_DIR = r"C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack\data"

# animated java 輸出資料包後手動增加 tag @s add effect
model_list = [
	path.join(DP_DIR, r"miko\functions\summon\zzz\execute"),
	path.join(DP_DIR, r"abyss\functions\summon\zzz\execute")
	path.join(DP_DIR, r"abyss_head\functions\summon\zzz\execute")
]

for p in model_list:
	function_list = listdir(p)
	for file in function_list:
		if int(file[:file.find('.')]) % 3 == 1:
			with open(p + '\\' + file, "a") as f:
				f.write("\ntag @s add effect")
				
# 召喚巫女分身會是 invisible 的 variant，這個不要加 UUID 指定
with open(path.join(DP_DIR, r"miko\functions\summon\invisible.mcfunction"), "r") as f:
	new_summon_func = f.read().replace(",UUID:[I;1,1,1,1]", "")
with open(path.join(DP_DIR, r"miko\functions\summon\invisible.mcfunction"), "w") as f:
	f.write(new_summon_func)
	
# 補被蓋掉的 minecraft tick tag
with open(path.join(DP_DIR, r"minecraft\tags\functions\tick.json"), "r") as f:
	tick = json.loads(f.read())
	tick["values"].append("main:main")
with open(path.join(DP_DIR, r"minecraft\tags\functions\tick.json"), "w") as f:
	f.write(json.dumps(tick))

system("pause")