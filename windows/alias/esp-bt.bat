@echo off

set "B=C:\Users\dimitri\.platformio\packages\toolchain-xtensa-esp-elf\bin"
set "E=C:\Users\dimitri\Desktop\projects\dunamis\GEN_2\gen2_esp\.pio\"
set "E=%E%build\dual80\firmware.elf"

"%B%\xtensa-esp32s3-elf-addr2line.exe" -aspCfire "%E%" %*