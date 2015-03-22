.text
.align 2
.global _start

.set REG_DISPCNT, 0x04000000
.set REG_DISPSTAT, 0x04000004
.set SCREEN0, 0x06000000
.set SCREEN1, 0x0600A000
.set MODE_3, 0x3
.set MODE_5, 0x5
.set BG2, 0x400
.set REG_DMA3SAD, 0x040000D4
.set REG_DMA3DAD, 0x040000D8
.set REG_DMA3CNT, 0x040000DC
.set REG_KEYINPUT, 0x04000130

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

_start:
	bl init_video
	bl init_timers
	
	@ setup startTime and stopTime variables
	sub r13, r13, #8
	
	bl tick
	str r0, [r13, #4]
	
	b main
	
main:
	bl tick
	
	@ set startTime
	str r0, [r13, #4]
	
	bl imsomeroutine	
		
	bl tick
	ldr r1, [r13, #4]
	sub r0, r0, r1
	
				@ set stopTime
				@str r0, [r13, #8]
				
				@ get startTime
				@ldr r3, [r13, #4]
				
				@ldr r1, =1000
				@sub r3, r0, r3
				@cmp r1, r3
				
				@strle r0, [r13, #4]
				@blle stop
	
	b main
	
imsomeroutine:
	stmfd r13!, {r0, r14}
	
	ldr r0, =1000000
	
	imsomeroutine_loop:
		subs r0, r0, #1
		bne imsomeroutine_loop
	
	ldmfd r13!, {r0, r14}
	mov r15, r14

init_video:
	stmfd r13!, {r0-r1, r14}
	
	ldr r0, =REG_DISPCNT
	ldr r1, =MODE_3 | BG2
	strh r1, [r0]
	
	ldmfd r13!, {r0-r1, r14}
	mov r15, r14

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

tick:
	@ parameters: none
	@ returns: r0 - the elapsed time (in milliseconds)
	@ description: reads the GBA's timer data registers and returns value in r0
	
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
	
.end
