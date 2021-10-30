mcdp make ../immortal soul datapack
rd /S /Q "C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack"
xcopy "C:\Users\MaugouMio\Desktop\immortal soul datapack\build\immortal soul datapack" "C:\Users\MaugouMio\AppData\Roaming\.minecraft\saves\Immortal Soul test1\datapacks\immortal soul datapack" /E /Y /I /Q
rd /S /Q "C:\Users\MaugouMio\Desktop\immortal soul datapack\build\immortal soul datapack"
pause