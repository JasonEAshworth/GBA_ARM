.text
.align 2
.global main
.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004
.set BLUE, 0x7C00
.set GREEN, 0x03E0
.set RED, 0x001F



@.set REG_KEYINPUT, 0x04000130
@.set BTN_A, 1
.set VRAM, 0x06000000
@last address = 0x06013FFF

main:
	ldr R0, =REG_DISPCNT
	ldr R1, =0x403
	strh R1, [R0]
	ldr R12, =VRAM
	
	main_loop:
		@ldr r3, =REG_KEYINPUT
		@ldrh r1, [r3]
		@mvn r0, #0
		@ands r2, r1, #BTN_A
		@bleq set_upper_left
		
		@Pixel One!		
		@x position of pixel
		MOV R7, #123		
		@y position of pixel
		MOV R8, #63	
		@RGB of pixel
		LDR R9, =RED		
		bl draw_pixel		
		
		@Pixel Two!
		@x position of pixel
		MOV R7, #10		
		@y position of pixel
		MOV R8, #10	
		@RGB of pixel
		LDR R9, =BLUE		
		bl draw_pixel
		
		@Pixel Three!
		@x position of pixel
		MOV R7, #280		
		@y position of pixel
		MOV R8, #130	
		@RGB of pixel
		LDR R9, =GREEN		
		bl draw_pixel		
		 
		bl fill_screen
		
		
		@load shit for draw line
		@X position into R7
		MOV R7, #50
		@Y position into R8
		MOV R8, #50
		@Color into R9
		LDR R9, =RED
		@Length into R10
		MOV R10, #25
		@draw the fucking line.
		bl draw_line
		
		@shit for square
		@X position into R7
		MOV R7, #150
		@Y position into R8
		MOV R8, #80
		@Color into R9
		LDR R9, =GREEN
		@Width into R10
		MOV R10, #25
		@Height into R11
		MOV R11, #15		
		bl fill_rectum
	
	
	waste_loop:
		b waste_loop
		
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
	
	LDR R9, =BLUE
	
	fill_screen_loop:
		strh R9, [R1]
		ADD R1, #2
		CMP R1, R7
		BLT fill_screen_loop	
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14	
	
draw_line:

	STMFD r13!, {r1-R11, r14}

	@LDR R1, =VRAM
	MOV R2, #1
	line_loop:		
		bl draw_pixel	
		ADD R2, #1
		ADD R7, #1
		CMP R2, R10
		BLT line_loop
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14
	
	
fill_rectum:
	STMFD r13!, {r1-R11, r14}
	
	MOV R2, #0
	
	@R9 is Color	
	@R7 is X position	
	@R8 is Y position	
	@R10 is Width	
	@R11 is Height
	
	make_square:
		bl draw_line
		ADD R2, #1
		ADD R8, #1		
		CMP R2, R11		
		BNE make_square
		
	
	LDMFD r13!, {r1-R11, r14}
	mov r15, r14
.end



