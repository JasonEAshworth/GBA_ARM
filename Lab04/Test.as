.text
.align 2
.global main

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


main:
 mov r1, #20
 mov r2, #30
 sub r13, r13, #8
 str r1, [r13,#4]
 str r2, [r13,#8]

 ldr r0, =REG_DISPCNT
 ldr r1, =0x403
 strh r1, [r0]
 ldr r12, =VRAM
  
 loop:
 	ldr r7, [r13, #4]
 	ldr r8, [r13, #8]
 	ldr r9, =WHITE
 	bl draw_pixel
 	 

 	bad:
 	 b bad

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
