cd VN
clear

python3 Source/Utils/asm.py \
    Source/Misc/Firmwares/Source/vnfirmwaremgr.asm \
    -o Source/Misc/Firmwares/Build/vnfirmwaremgr.frm \
    --provide-syntax=nasm-vn

iverilog -g2012 -o Build/Final/vn \
    -I Source/Core \
    -I Source/Memory \
    Source/Core/top.sv

clear
vvp Build/Final/vn