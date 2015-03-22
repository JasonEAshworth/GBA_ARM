.text
.align 2
.global main
@Display stuff
.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004
.set BLUE, 0x7C00
.set GREEN, 0x03E0
.set RED, 0x001F
.set BLACK, 0x0000


@Button Stuff!
.set REG_KEYINPUT, 0x04000130
.set BTN_A, 0x01
.set BTN_B, 0x02
.set BTN_UP, 0x40
.set BTN_DWN, 0x80
.set BTN_LFT, 0x20
.set BTN_RGT, 0x10

.set VRAM, 0x06000000
@last address = 0x06013FFF

@timer set up
.set T0, 0x4000100
.set T0D, 0x4000102
.set T1, 0x4000104
.set T1D, 0x4000106
.set T2, 0x4000108
.set T2D, 0x400010A
.set T3D, 0x400010E
.set T3, 0x400010C

.set TICKS, 256
.set MIN_CNT, 65476
.set SEC_CNT, 65280


main:
	ldr R0, =REG_DISPCNT
	ldr R1, =0x403
	strh R1, [R0]
	ldr R12, =VRAM
	bl fill_screen	
	
	LDR R2, =T3
	LDR R3, =MIN_CNT
	strh R3, [R2]
	
	LDR R2, =T3D
	LDR R3, =0x84
	strh R3, [R2]
	
	LDR R2, =T2
	LDR R3, =MIN_CNT
	strh R3, [R2]
	
	LDR R2, =T2D
	LDR R3, =0x84
	strh R3, [R2]
	
	LDR R2, =T1
	LDR R3, =SEC_CNT
	strh R3, [R2]
	
	LDR R3, =T1D
	LDR R2, =0x84
	strh R2, [R3]
	
	ldr R2, =T0D
	ldr R3, =0x80
	strh r3, [r2]	
	
	main_loop:
		ldr r0, =REG_KEYINPUT
		ldrh r1, [r0]
		
		mvn r0, #0
		
		@ bl fill_screen	
		
		ands r2, r1, #BTN_A
		
		@Pixel One!		
		@x position of pixel
		MOV R7, #115		
		@y position of pixel
		MOV R8, #79	
		@RGB of pixel
		LDReq R9, =RED
		ldrne R9, =BLACK		
		bl draw_pixel
		
			
		
		ands r2, r1, #BTN_B
		@Pixel One!		
		@x position of pixel
		MOV R7, #124		
		@y position of pixel
		MOV R8, #79	
		@RGB of pixel
		LDReq R9, =BLUE
		ldrne R9, =BLACK		
		bl draw_pixel
		
		
		ands r2, r1, #BTN_UP
		@Pixel One!		
		@x position of pixel
		MOV R7, #119		
		@y position of pixel
		MOV R8, #70	
		@RGB of pixel
		LDReq R9, =RED
		ldrne R9, =BLACK		
		bl draw_pixel
		
		
		ands r2, r1, #BTN_DWN
		@Pixel One!		
		@x position of pixel
		MOV R7, #119		
		@y position of pixel
		MOV R8, #88	
		@RGB of pixel
		LDReq R9, =RED
		ldrne R9, =BLACK		
		bl draw_pixel
		
		
		ands r2, r1, #BTN_RGT
		@Pixel One!		
		@x position of pixel
		MOV R7, #128		
		@y position of pixel
		MOV R8, #79	
		@RGB of pixel
		LDReq R9, =RED
		ldrne R9, =BLACK		
		bl draw_pixel
		
		
		ands r2, r1, #BTN_LFT
		@Pixel One!		
		@x position of pixel
		MOV R7, #110		
		@y position of pixel
		MOV R8, #79	
		@RGB of pixel
		LDReq R9, =RED
		ldrne R9, =BLACK		
		bl draw_pixel		
	
		
		@This is where I do my counting!
		
		@ADRL R0, minutes
		@ADRL R1, hours
		
		
		bl draw_seconds
		bl draw_minutes		
		
		b main_loop
		
draw_pixel:

	@ R0 - pixel value
	STMFD r13!, {r1-R11, r14}	
	
	@load the y value
	@ldr r4, r8
	
	@width
	MOV R10, #240
	@will use later...
	MOV R11, #2
	
	@multiply the Y position by the width and store it in R2
	MUL r2, r8, R10
	
	@Adding the x value to it.
	add r2, r2, R7
	
	@multiplying by 2 (store in R11)
	MUL r3, r2, R11
	
	@putting the color into the VRAM plus the offset for the pixel position
	strh r9, [r12, r3]
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14	
	
fill_screen:

	STMFD r13!, {r1-R11, r14}
	
	@R12 is VRAM
	LDR R7, =0x06013FFF
	LDR R1, =VRAM
	
	LDR R9, =BLACK
	
	fill_screen_loop:
		strh R9, [R1]
		ADD R1, #2
		CMP R1, R7
		BLT fill_screen_loop	
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14	
	

draw_seconds:
	

	STMFD r13!, {r1-R11, r14}
	@bl fill_screen
	ADRL R0, seconds
	
	ldr R1, =T2
	LDRH r2, [r1]
	ldr R3, =MIN_CNT
	
	SUB R4, R2, R3
	
	CMP R4, #59
	
	BLGE fill_screen
	ADDGE R4, #2
	@ADDEQ R4, #1
	
	@CMP R4, #0	
	mov r4, r4, lsl #1
	draw_sec:
		
		@mov r4, r4, lsl #1
		ldrh R5, [R0, R4]
		@and R5 with #0xFF00 to get X value
		@Right shift by 8
		@And with #0xFF00 to get Y value
		AND R7, R5, #0xFF
		MOV R5, R5, LSR #8
		AND R8, R5, #0xFF
		
		LDR R9, =RED
		bl draw_pixel		
		
		SUB R4, #16
		@SUB R6, #1
		cmp R4, #0
		BLGT draw_sec		
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14	
	
draw_minutes:
	
	STMFD r13!, {r1-R11, r14}
	ADRL R0, minutes
	
	ldr R1, =T3
	LDRH r2, [r1]
	ldr R3, =MIN_CNT
	
	SUB R4, R2, R3
	
	CMP R4, #59
	BLGE fill_screen
	
	MOV R11, R4
	
	
	@MOV R6, R4	
	mov r4, r4, lsl #1
	draw_min:
		
		@mov r4, r4, lsl #1
		ldrh R5, [R0, R4]
		@and R5 with #0xFF00 to get X value
		@Right shift by 8
		@And with #0xFF00 to get Y value
		AND R7, R5, #0xFF
		MOV R5, R5, LSR #8
		AND R8, R5, #0xFF
		LDR R9, =GREEN
		bl draw_pixel
		SUB R4, #16
		
		cmp R4, #0
		BLGT draw_min	
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14
	
.end



