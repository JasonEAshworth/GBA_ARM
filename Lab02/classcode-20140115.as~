.text
.align 2
.global main

.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004

.set REG_KEYINPUT, 0x04000130
.set BTN_A, 1

.set VRAM, 0x06000000

main:
	LDR R0, =REG_DISPCNT
	LDR R1, =0x403
	STRH R1, [R0]
	
	
loop:
	LDR R0, =REG_KEYINPUT
	LDRH R1, [R0]
	
	MVN R0, #0
	ANDS R2, R1, #BTN_A
	BL set_upper_left
	
	b loop
	
set_upper_left:
	@ R0 - the pixel value
	
	STMFD R13!, {R1, R14}
	
	ADRL R0, ship
	ADD R0, R0, #2
	MOV R1, #32
	MOV R1, R1, LSL #5
	
	MOV R2, #0
	MOV R5, #0
	MOV R6, #0
	LDR R7, =0x7C1F
	LDR R3, =VRAM
	image_loop: 
		LDRH R4, [R0]
		CMP R4, R7
		STRNEH R4, [R3, R5]
		
		ADD R0, R0, #2
		ADD R5, R5, #2
		CMP R5, #64
		MOVEQ R5, #0
		ADDEQ R3, R3, #480
		ADDEQ R6, R6, #1
		
		CMP R6, #32
		bne image_loop
	
	LDMFD R13!, {R1, R14}
	MOV R15, R14
	
.end

