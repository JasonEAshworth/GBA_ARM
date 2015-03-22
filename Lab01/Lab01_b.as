.text
.align 2

.global main

main:
	@p1
	mov R0, #7
	mov R1, #0x45
	
	@p2
	mov R4, R0
	mov R6, #2
	mul  R4, R6
	add R4, R4, #100
	
	@p3	
	mov R5, #0
	b count
	
count:
	add R5, R5, #1
	cmp R5, #10
	bllt count
	
.end




