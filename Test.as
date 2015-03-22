.text
.align 2
.gloval main

.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004
.set VRAM, 0x06000000

main:
	LDR R0, =REG_DISPCNT
	LDR R1, =0x403	
	//putting the number in R1 into the adress held by R0
	STRH R1, [R0]

	@LDR R0, =VRAM
	@loop:
	@	LDR R1, =0xFFFF03E0	
	@	STR R1, [R0]
	@	ADD R0, #4
	LDR R0, =0x1f
	BL set_upper_left
	
loop:
	b loop
	
set_upper_left:

	@R0 - the pixel value
	@storing the link address
	@only store the ones that we are going to modify	
	STMFD R13!, {R1, R14}
	
	LDR R1, =VRAM
	STRH R0, [R1]	
	
	@loading the link address so we can return.
	LDMFD R13!, {R1, R14}	
	MOV R15, R14

.end

