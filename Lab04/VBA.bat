@echo off
set /p fname="Enter file name: "  %=%
arm-elf-as -mcpu=arm7tdmi -o %fname%.elf %fname%.as 
arm-elf-objcopy -O binary %fname%.elf %fname%.bin
..\VBA\VisualBoyAdvance-SDL  %fname%.bin