from os import listdir, system
import json

# animated java 輸出資料包後手動增加 tag @s add effect
model_list = [
	r"C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack\data\miko\functions\summon\zzz\execute"
]

for path in model_list:
	function_list = listdir(path)
	for file in function_list:
		if int(file[:file.find('.')]) % 3 == 1:
			with open(path + '\\' + file, "a") as f:
				f.write("\ntag @s add effect")
	
# 補被蓋掉的 minecraft tick tag
with open(r"C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack\data\minecraft\tags\functions\tick.json", "r") as f:
	tick = json.loads(f.read())
	tick["values"].append("main:main")
with open(r"C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack\data\minecraft\tags\functions\tick.json", "w") as f:
	f.write(json.dumps(tick))

system("pause")