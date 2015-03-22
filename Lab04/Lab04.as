.text
.align 2
.global _start

@general

.set EWRAM, 0x02000000
.set IWRAM, 0x03000000

.set REG_DMA3SAD, 0x040000D4
.set REG_DMA3DAD, 0x040000D8
.set REG_DMA3CNT_L, 0x040000DC
.set REG_DMA3CNT_H, 0x040000DE
.set DST_INC, 0x00 << 5
.set DST_DEC, 0x01 << 5
.set DST_FIX, 0x10 << 5
.set SRC_INC, 0x00 << 7
.set SRC_DEC, 0x01 << 7
.set SRC_FIX, 0x10 << 7
.set DMA_16, 0x0 << 10
.set DMA_32, 0x1 << 10
.set DMA_START_NOW, 0x00 << 12
.set DMA_ENABLE, 0x1 << 15

@ timer registers
.set REG_TM0D, 0x04000100
.set REG_TM1D, 0x04000104
.set REG_TM2D, 0x04000108
.set REG_TM3D, 0x0400010C

.set REG_TM0CNT, 0x04000102
.set REG_TM1CNT, 0x04000106
.set REG_TM2CNT, 0x0400010A
.set REG_TM3CNT, 0x0400010E

.set DIV_1, 0x0
.set DIV_64, 0x1
.set DIV_256, 0x2
.set DIV_1024, 0x3
.set CASCADE, 0x4
.set ENABLE, 0x80

@display
.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004
.set REG_KEYINPUT, 0x04000130
.set VRAM, 0x06000000

@colors
.set BLACK, 0x0000
.set BLUE, 0x7C00
.set GREEN, 0x03E0
.set RED, 0x001F
.set WHITE, 0xFFFF

@buttons
.set BTN_A, 0x01
.set BTN_B, 0x02
.set BTN_RT, 0x10
.set BTN_LT, 0x20
.set BTN_UP, 0x40
.set BTN_DN, 0x80

@ball position
.set B_X, 2
.set B_Y, 50

.set XOFF, 4 
.set YOFF, 8

.set code_length, end - main
_start:
	bl init_video
	bl init_timers

	sub r13, r13, #8
	@b main
	bl to_iwram
	ldr r15, =EWRAM

to_iwram:
	stmfd r13!, {r0, r14}

	ldr r0, =REG_DMA3DAD
	ldr r1, =EWRAM
	str r1, [r0]
	
	ldr r0, =REG_DMA3SAD
	adr r1, main
	str r1, [r0]
	
	ldr r0, =REG_DMA3CNT_L
	ldr r1, =code_length
	strh r1, [r0]
	
	ldr r0, =REG_DMA3CNT_H
	ldr r1, =DST_INC | SRC_INC | DMA_32 | DMA_START_NOW | DMA_ENABLE
	strh r1, [r0]
	
	ldmfd r13!, {r0, r14}
	mov r15, r14

main:
	ldr r12, =VRAM


	bl someroutine

	@ set stopTime
	@str r0, [r13, #8]
	
	@ get startTime
	@ldr r3, [r13, #4]
	
	@ldr r1, =1000
	@sub r3, r0, r3
	@cmp r1, r3
	
	@strle r0, [r13, #4]
	@blle stop

	@load data for draw line
	@X position into r7
	mov r7, #90
	@Y position into r8
	mov r8, #140
	@Color into r9
	ldr r9, =WHITE
	@Length into r10
	mov r10, #25
	mov r5, #1 @ballx dir
	mov r6, #1 @bally dir
	mov r3, #B_X
	mov r4, #B_Y
	main_loop:

		bl tick
		@set startTime
		str r0, [r13,#4]
	
		ldr r0, =REG_KEYINPUT
		ldrh r1, [r0]
		
		@PADDLE RIGHT BOUND
		ands r2, r1, #BTN_RT
		addeq r7,r7, #1
		cmp r7, #215
		movgt r7 , #215

		@PADDLE LEFT BOUND
		ands r2, r1, #BTN_LT
		subeq r7, r7, #1
		cmp r7, #0
		movlt r7, #0 

		@bounds checkign on ball
		mov r2, r7
		add r2, r10

		cmp r3, #239
		mvngt r5, r5
		addgt r5, #1
		cmp r4, #139		
		blgt bounce

		cmp r4, #159
		bgt game_over
		
		cmp r3, #1
		mvnlt R5, r5
		addlt r5, #1
		cmp r4, #1
		mvnlt r6, r6
		addlt r6, #1

		bl anim
		bl unball
		bl draw_line
		bl undraw

		bl someroutine
		bl tick
		ldr r1, [r13, #4]
	
		sub r0, r0, r1

		b main_loop



draw_pixel:

	@ r0 - pixel value
	stmfd r13!, {r1-r11, r14}
	
	
	@load the y value
	@ldr r4, r8
	
	@width
	mov r10, #240
	@will use later...
	mov r11, #2
	
	@multiply the Y position by the width and store it in r2
	mul r2, r8, r10
	
	@Adding the x value to it.
	add r2, r2, r7
	
	@multiplying by 2 (store in r11)
	mul r3, r2, r11
	
	@putting the color into the VRAM plus the offset for the pixel position
	strh r9, [r12, r3]
	
	ldmfd r13!, {r1-r11, r14}
	mov r15, r14	

draw_line:

	stmfd r13!, {r1-r11, r14}
	mov r2, #1
	line_loop:		
		bl draw_pixel	
		add r2, #1
		add r7, #1
		cmp r2, r10

		bllt line_loop

	ldmfd r13!, {r1-r11, r14}
	mov r15, r14

bounce:@ checks left side of paddle for ball
	stmfd r13!, {r1, r14}
	cmp r3, r7
	blgt dink
	ldmfd r13!, {r1, r14}
	mov r15, r14

dink: @ checks right side of paddle for ball
	stmfd r13!, {r1, r14}
	cmp r3, r2
	bllt doink
	ldmfd r13!, {r1, r14}
	mov r15, r14		

doink: @ bounces the ball
	stmfd r13!, {r1, r14}
	mvn r6, r6
	add r6, #1
	ldmfd r13!, {r1, r14}
	mov r15, r14

undraw:
	stmfd r13!, {r1-r11, r14}
	ldr r9, =BLACK
	mov r2, #0
	mov r3, r7
	add r3, r10
	sub r7 , #1
	mov r4, #100
	
	ll1:
		
		bl draw_pixel
		add r2, #1
		cmp r2, r7
		
		blt ll1
	ll2:
		
		bl draw_pixel
		mov r7 , r3 
		add r3,#1
		cmp r3,#240
		blt ll2 

	ldmfd r13!, {r1-r11, r14}
	mov r15, r14

draw_ball:
	stmfd r13!, {r1-r11, r14}
	ldr r9, =GREEN
	
	mov r7,r3
	mov r8,r4

	bl draw_pixel

	
	ldmfd r13!, {r1-r11, r14}
	mov r15, r14

unball:
	stmfd r13!, {r1,r2, r7-r11, r14}
	ldr r9, =BLACK
	mov r7,r3
	mov r8,r4

	mvn r1, r5
	add r1, #1
	mvn r2, r6
	add r2, #1
	add r7, r1
	add r8, r2

	bl draw_pixel
	ldmfd r13!, {r1,r2, r7-r11,r14}
	mov r15, r14

anim:

	@animate ball
	@ if ball.y is 141 or greater game ends
	@ if ball y is greater than 0 and 
	stmfd r13!, {r1,r2,r7-r11, r14}

	add r3, r5
	add r4, r6

	bl draw_ball

	bl unball

	
	ldmfd r13!, {r1,r2,r7-r11, r14}
	mov r15, r14

game_over:
	b game_over

tick:
	@ parameters: none
	@ returns: r0 - the elapsed time (in milliseconds)
	@ description: reads the GBAs timer data registers 
	@and returns value in r0
	
	stmfd r13!, {r1-r2, r14}
	
	ldr r1, =REG_TM1D
	ldrh r0, [r1]
	
	ldr r1, =REG_TM2D
	ldrh r2, [r1]
	
	mov r1, #1000
	mul r2, r1, r2
	
	add r0, r2, lsl #6
	
	ldmfd r13!, {r1-r2, r14}
	mov r15, r14

someroutine:
	stmfd r13!, {r11, r14}
	ldr r11, =20000
	
	imsomeroutine_loop:
		subs r11, r11, #1
		bne imsomeroutine_loop
	ldmfd r13!, {r11,r14}
	mov r15, r14
	
end:

mov r0, r0

init_timers:
	@ parameters: none
	@ returns: nothing
	
	
	stmfd r13!, {r0-r1, r14}
	
	@ load zero into timer 2's data registers
	eor r0, r0
	ldr r1, =REG_TM2D
	strh r0, [r1]
	
	@ load timer 1's data register to overflow into timer 2 after 64 seconds
	@ timer 0 will overflow every 1ms, 65536 - 64000 = 1536, 64000 * 0.001 = 64
	ldr r0, =1536
	ldr r1, =REG_TM1D
	strh r0, [r1]
	
	@ load timer 0's data register to overflow into timer 1's data register
	@ after 16780 ticks (65536 - 16780 = 48756, overflows every 1 millisecond)
	ldr r0, =48756
	ldr r1, =REG_TM0D
	strh r0, [r1]
	
	@ set timers 1 and 2 to cascade mode
	ldr r0, =ENABLE | CASCADE
	ldr r1, =REG_TM2CNT
	strh r0, [r1]
	ldr r1, =REG_TM1CNT
	strh r0, [r1]
	
	@ set timer 0 to count with a divider of 1
	ldr r0, =ENABLE | DIV_1
	ldr r1, =REG_TM0CNT
	strh r0, [r1]
	
	ldmfd r13!, {r0-r1, r14}
	mov r15, r14

init_video:
	stmfd r13!, {r0-r2,r12}
	
	ldr r0, =REG_DISPCNT
	ldr r1, =0x403
	strh r1, [r0]


	ldmfd r13!, {r0-r2,r12}
	mov r15, r14
.end
