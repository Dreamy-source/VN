cd VN
clear

python3 Utils/asm.py \
    Source/Firmwares/vnfirmwaremgr.asm \
    -o Build/Firmwares/vnfirmwaremgr.frm \
    --provide-syntax=nasm-vn

iverilog -g2012 -o Build/Final/vn \
    -I Source/Core \
    -I Source/Components/Memory \
    Source/Core/top.sv

clear
vvp Build/Final/vn