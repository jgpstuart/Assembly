//Submitted by: Jeremy Stuart (UCID 00311644) for CPSC 355 Fall 2019, assigment 5 part a

define(MAXVAL, 100)
define(BUFSIZE, 100)
define(c_r, w26)
define(s_r, x28)
define(lim_r, w27)

	.bss				// .bss section of memory
val_m:	.skip	MAXVAL * 4		// zero the val array, size 100 * 4 (int)
buf_m:	.skip	BUFSIZE * 1		// zero the buf array, size 100 * 1 (char)
sp_m:	.skip	4			// set sp = 0, 4 bytes for int
bufp_m:	.skip	4			// set bufp = 0, 4 bytes for int

	.text				// text section of memory
perr:	.string "error: stack full\n"
eerr:	.string "error: stack empty\n"
berr:	.string "ungetch: too many characters\n"
	.balign 4

	// PUSH FUNCTION
	.global push

push:	stp	x29, x30, [sp, -16]!	// allocate 16 bytes for push
	mov	x29, sp			// move the stack pointer to x29

	// store x0 (input "f") into a register)
	mov	w15, w0			// move "f" into x15	

	// load sp
	adrp	x9, sp_m		// load address for sp_m
	add	x9, x9, :lo12:sp_m	// load the lower 12 bits of sp_m
	ldr	w10, [x9]		// w10 = sp

	// if statement
if:	cmp	w10, MAXVAL		// compare w10 (sp variable) with MAXVAL
	b.ge	else1			// goto "else" if sp  > MAXVAL
	adrp	x9, val_m		// load the base address of val_m
	add	x9, x9, :lo12: val_m	// load base address for array, store in x9
	str	w15, [x9, w10, SXTW 2]	// load "f" into the val array at [sp]
	
	// increment sp (sp++)
	add	w10, w10, 1		// add 1 to current value of sp_m and store in w10
	adrp	x9, sp_m		// load address for sp_m
	add	x9, x9, :lo12:sp_m	// load lower 12 into x9
	str	w10, [x9]		// store w10 into x9
	mov	w0, w15			// store w15 in w0 to move out of function
	b	end1			// jump over "else" statement and end push

	// else statement
else1:	adrp	x0, perr		// load the push error string
	add	x0, x0, :lo12:perr	// load the lower 12 bits
	bl	printf			// print the string
	bl	clear			// execute the clear function
	
end1:	ldp	x29, x30, [sp], 16	// deallocate memory
	ret				// return
	

	// POP FUNCTION
	.global pop

pop:	stp	x29, x30, [sp, -16]!	// allocate 16 bytes for pop
	mov	x29, sp			// move the stack pointer to x29

loop2:	mov	w10, 0			// move 0 to w10
	adrp	x9, sp_m		// load address for sp_m
	add	x9, x9, :lo12:sp_m	// load the lower 12 bits of sp_m
	ldr	w11, [x9]		// w10 = sp

	cmp	w11, w10		// if (sp > 0)
	b.le	else2			// branch to else2 if less or equal
	
if2:	sub	w11, w11, 1		// --sp (decrement sp by 1)
	adrp	x9, sp_m		// load address for sp_m
	add	x9, x9, :lo12:sp_m	// load the lower 12 bits of x9
	str	w11, [x9]		// store --sp
	
	adrp	x9, val_m		// load base address of val_m
	add	x9, x9, :lo12:val_m	// load the lower 12 bits of val_m
	ldr	w0, [x9, w11, SXTW 2]	// load val[--sp]
	b	end2			// jump to end

else2:	adrp	x0, eerr		// load the push error string
	add	x0, x0, :lo12:eerr	// load the lower 12 bits
	bl	printf			// print the string
	bl	clear			// execute the clear function
	mov	w0, 0			// return 0
	
end2:	ldp	x29, x30, [sp], 16	// deallocate memory
	ret				// return



	// CLEAR FUNCTION
	.global clear

clear:	stp	x29, x30, [sp, -16]!	// allocate 16 bytes for the frame record
	mov	x29, sp			// move the stack pointer the frame record

	mov	w9, 0			// move 0 into x9
	adrp	x10, sp_m		// load the address of sp_m
	add	x10, x10, :lo12:sp_m	// load the lower 12 bits of sp_m
	str	w9, [x10]		// store 0 in sp_m

	ldp	x29, x30, [sp], 16	// deallocate memory
	ret				// return


	
	// GETCH FUNCTION
	.global getch

getch:	stp	x29, x30, [sp, -16]!	// allocate 16 bytes for the frame record
	mov	x29, sp			// move the stack pointer to the frame record

	mov	w9, 0			// move 0 into x9
	adrp	x12, bufp_m		// load address for bufp_m
	add	x12, x12, :lo12:bufp_m	// load the lower 12 bits of bufp_m
	ldr	w10, [x12]		// w10 = bufp
	
	cmp	w10, w9			// compare bufp and 0
	b.le	else3			// jump to else3 if less than or equal to
	
	sub	w10, w10, 1		// subtract 1 from bufp
	str	w10, [x12]		// store --bufp using x12
	adrp	x9, buf_m		// load the base address of buf_m
	add	x9, x9, :lo12:buf_m	// load base address for array, store in x9
	ldr	w0, [x9, w10, SXTW 2]	// load buf at --bufp into w0 to return
	b	end3

else3:	bl	getchar			// run getchar, result in w0

end3:	ldp	x29, x30, [sp], 16
	ret

	// UNGETCH FUNCTION
	.global ungetch

ungetch:stp	x29, x30, [sp, -16]!	// allocate 16 bytes for the frame record
	mov	x29, sp			// move the stack pointer to the frame record

	mov	w19, w0			// move the contents of x0 into w19 (int c)

	adrp	x12, bufp_m		// load address for bufp into x12
	add	x12, x12, :lo12:bufp_m	// load the lower 12 bits of bufp_m
	ldr	w10, [x12]		// w10 = bufp

	cmp	w10, BUFSIZE		// compare, bufp > BUFSIZE
	b.le	else4			// goto else4 if less or equal to
	
	adrp	x0, berr		// load the berr string into x0
	add	x0, x0, :lo12:berr	// load the lower 12 bits of x0
	bl	printf			// call printf
	b	end4			// branch to end4
	
else4:	adrp	x11, buf_m		// load the base address of the array
	add	x11, x11, :lo12:buf_m	// load base for array, store in x11
	str	w19, [x11, w10, SXTW 2]	// load "c" into buf array at [bufp]

	add	w10, w10, 1		// increment bufp
	adrp	x9, bufp_m		// load base address for bufp_m
	add	x9, x9, :lo12:bufp_m	// load the lower 12 bits
	str	w10, [x9]		// store w10 into x9 (bufp++)

end4:	ldp	x29, x30, [sp], 16	// deallocate the 16 bytes
	ret				// return

i_size = 4				// size of i = 4 (int)
c_size = 4				// size of c = 4 (int)

i_s = 16				// offset for i from frame record
c_s = i_s + i_size			// offset for c is i size + i_s

alloc = -(16 + i_size + c_size) & -16	// memory allocation for getop
dealloc = -alloc			// deallocation for getop


	// GETOP FUNCTION
	.global getop

getop:	stp	x29, x30, [sp, alloc]!	// allocate memory for getop
	mov	x29, sp			// move stack pointer to frame pointer

	mov	s_r, x0			// move *s argument into s_r
	mov	lim_r, w1		// mov lim argument into lim_r

	// setup for while loop
	bl	getch			// get character
	mov	c_r, w0			// move character into c_r
	b	whitst			// branch to while test

	// while statement setup
while:	bl	getch			// get character
	mov	c_r, w0			// move character into w9
	
	add	x10, x29, c_s		// put base address of c into x9
	str	c_r, [x10]		// store the character into c
	
	// while ((c = getch()) == ' ' || c == '\t' || c == '\n')
whitst:	cmp 	c_r, 32			// compare char with decimal 32 (space in ASCII)
	b.eq	while			// if equal restart the loop
	cmp	c_r, 9			// compare char with decimal 9 (tab in ASCII)
	b.eq	while			// if equal restart the loop
	cmp	c_r, 10			// compare char with decimal 10 (newline in ASCII)
	b.eq	while			// if equal restart the loop
	
	// if (c < '0' || c > '9')
jump5:	cmp	c_r, 48			// compare char with decimal 48 (0 in ASCII)
	b.lt	returnc			// if c < 0 goto returnc
	cmp	c_r, 57			// compare char with decimal 57 (9 in ASCII)
	b.gt	returnc			// if c > 9 goto returnc
	b	jump6			// if 0 <= c <= 9 goto jump 6

	// return c;
returnc:mov 	w0, c_r			// move c into w0 to return
	b	endgetop		// got the end of getop to return c

	// s[0] = c;
jump6:	mov 	w9, 0			// move 0 into x9
	strb	c_r, [s_r]		// store c in s[0]

	//for (i = 1; (c = getchar()) >= '0' && c <= '9'; i++)
	//setup
	mov	w12, 1			// move 1 into x12 as i
	add	x10, x29, i_s		// load base address of i to store new value
	str	w12, [x10]		// store i at x10
	b	fortest			// branch to fortest

	// loop body
forloop:bl	getchar			// getchar to reassign c
	mov	c_r, w0			// move new char into w26
	add	x10, x29, c_s		// load base address of c
	str	c_r, [x10]		// store c in stack memory
	
	add	x10, x29, i_s		// load base address of i
	ldr	w12, [x10]		// load i into x12
	cmp	w12, lim_r		// compare i and lim
	b.lt	jump7			// if i < lim goto jump7
	b	loopend			// if greater than, goto loopend

jump7:	add	x10, x29, i_s		// load base address of i to load value
	ldr	w12, [x10]		// load i in to w12

	strb	c_r, [s_r, w12, sxtw]	// store c into s[i]

loopend:add	w12, w12, 1		// increment i by 1
	str	w12, [x10]		// store i in stack memory

fortest:cmp	c_r, 48			// compare char with decimal 48 (0 in ASCII)
	b.lt	jump8			// logical compliment, jump8 out of for loop if c<0
	cmp	c_r, 57			// compare char with decimal 57 (9 in ASCII)
	b.gt	jump8			// logical compliment, jump8 out of for loop if c>9
	b	forloop			// restart the loop

	// if (i < lim) 
jump8:	add	x10, x29, i_s		// load base address of i
	ldr	w12, [x10]		// load i into w12
	cmp	w12, lim_r		// compare i and lim
	b.ge	else5			// if i >= lim goto else5
	
	// ungetch(c)
	add	x10, x29, c_s		// load base address of c_s into x10
	ldr	c_r, [x10]		// load c into w23
	mov	w0, c_r			// load w23 (c) into w0 for ungetch
	bl	ungetch			// run ungetch with argument c (in w0)
	
	// s[i] = '\0';
	add	x11, x29, i_s		// load base address of i into x11
	ldr	w12, [x11]		// load i into w12
	mov	w9, 0			// move 0 into w9 (0 is null in ASCII)
	strb	w9, [s_r, w12, SXTW]	// store 0 (ASCII null) into s[i]
	
	// return NUMBER;		// NUMBER = '0'
	mov	w0, 48			// move decimal 48 (ASCII for 0) into w0,
	b	endgetop		// goto endgettop to end the function

	// while (c != '\n' && c != EOF)
else5:	add	x10, x29, c_s		// load the base address of c
	ldr	c_r, [x10]		// load c into w9
	cmp	c_r, 10			// compare c and decimal 10 (newline in ASCII)
	b.eq	jump9			// if c == '\n' goto jump9
	cmp	c_r, 0			// if c < 0 (equivilent of any EOF)
	b.lt	jump9			// if c < 0 (negative) goto jump9

	// c = getchar();
	bl	getchar			// run getchar
	add	x9, x29, c_s		// load the base address for c
	str	w0, [x9]		// store c
	b	else5			// restart while loop
	
	// s[lim-1] = '\0';
jump9:	sub	w9, lim_r, 1		// lim - 1 store in w9
	mov	w10, 0			// mov 0 into w10 (0 is null in ASCII)
	strb	w10, [s_r, w9, SXTW]	// store '\0' into s[lim-1]

	// return TOOBIG;		// TOOBIG = '9'
	mov	w0, 57			// move 57 into w0 (ASCII for '9')
	b	endgetop		// go to end of get top

endgetop:				// burn this mother down
	ldp	x29, x30, [sp], dealloc	// deallocate memory for getop
	ret				// return
