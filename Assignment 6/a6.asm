// Assignment 6, CPSC355   Submitted by: Jeremy Stuart (00311644)

define(x_reg, d16)
define(y_reg, d17)
define(ln_reg, d18)
define(fd, w19)
define(temp_r1, d20)
define(temp_r2, d21)
define(temp_r3, d22)

buff_size = 8					// size of the buffer
alloc = -(16 + buff_size) & -16			// memory allocation
dealloc = -alloc				// memory deallocation
buff_s = 16					// buffer offset

	.data
limit_m:.double	0r1.0e-13			// the limit for expansions for the taylor series
zero_m:	.double	0r0.0				// the number 0 to reset some of the temp variables

	.text
header:	.string	"\tx value:\t ln(x):\n"
prt:	.string "%13.10f \t\t %13.10f\n"
error:	.string "Error opening file, aborting...\n"
noinpt:	.string "Please specify a file name\n"
errcls:	.string "Error, file could not be closed properly.\n"
	.balign 4


	.global main

main:	stp	x29, x30, [sp, alloc]!		// allocate memory for main
	mov	x29, sp				// move stack pointer to frame pointer

	// check to make sure file name given
	cmp	w0, 1				// compare number of arguments to 1
	b.gt	open				// jump to open if true
	
	adrp	x0, noinpt			// no "no input" string into x0
	add	x0, x0, :lo12:noinpt		// load lower 12 bits into x0
	bl	printf				// call printf
	b	end				// jump to end of program

	// open the file using user input
open:	mov	w0, -100			// 1 argument to open file (current working directory)
	ldr	x1, [x1, 8]			// load the address of the file name input into x20
	mov	w2, 0				// 3rd argument, read only = 0
	mov	w3, 0				// 4th argument, not used
	mov	x8, 56				// service request, 56 = openat
	svc	0				// call system function
	mov	fd, w0				// move file descriptor into fd register (w19)
	cmp	w0, 0				// error checking
	b.ge	setup				// error handling check, go to setup if file opened
	
	// run the error string and go close file
errp:	adrp	x0, error			// load the error code string
	add	x0, x0, :lo12:error		// load the lower 12 bits of error string
	bl	printf				// run printf
	b	close				// jump to the end of the code

	// print the header for the columns
setup:	adrp	x0, header			// load the header into x0
	add	x0, x0, :lo12:header		// load the lower 12 bits into x0
	bl	printf				// print the header

	// setup calculation
loop:	fmov	y_reg, 1.0			// move 1 into y reg
	adrp	x26, zero_m			// load zero inot d26
	add	x26, x26, :lo12:zero_m		// load the lower 12 bits of zero_m into d26
	fmov	ln_reg, x26			// reset ln_reg to 0

	// read the next variable from the file
	mov	w0, fd				// move the file descriptor into w0
	add	x1, x29, buff_s			// put address for buffer into x1
	mov	x2, buff_size			// read argument, taking in 8 btyes (buff_size)
	mov	x8, 63				// service request, 63 = read
	svc	0				// call system function

	//error check
	cmp	w0, buff_size			// cmp for error check, returned bytes vs buff_size
	b.lt	close				// if less than 8 bytes, end the program

	// move loaded variable into x_reg
	ldr	x_reg, [x29, buff_s]		// store the variable into the x register	

	// (1/y)((x-1)/x)^y = Taylor Expansion
	// temp1 = (1/y)
tyexp:	fmov	d25, 1.0			// move 1.0 into d25 for calculation
	fdiv	temp_r1, d25, y_reg		// d23 (1) / y

	//temp2 = (x-1)/x
	fsub	temp_r2, x_reg, d25		// (x - 1.0) stored in temp_r2
	fdiv	temp_r2, temp_r2, x_reg		// (x-1) / x = temp2
	
	//temp3 = temp2 ^ y
	fmov	d24, 1.0			// make d24 the exponent multiply counter
	fmov	temp_r3, temp_r2		// make temp_r3 = temp_r2 for first exponentiation step
	b	exptest				// goto the exponent loop test		

	// exponent multiplication
expnt:	fmul	temp_r3, temp_r3, temp_r2	// temp_r3 * temp_r2 (note: temp_r3 = temp_r2 on first step)
	fmov	d26, 1.0			// mov 1.0 to d26 to increment counter
	fadd	d24, d24, d26			// increment counter

	// how many multiplications of the exponent done
exptest:fcmp	d24, y_reg			// check if counter vs y to see if y multiplications done
	b.lt	expnt				// if counter > y, run another loop of exponent

	//temp3 = temp1 * temp3
endcalc:fmul	temp_r3, temp_r1, temp_r3	// multiply (1/y) * ((x-1)/x)^y (temp1 * temp3), store in temp 3
	fadd	ln_reg, ln_reg, temp_r3		// add result to value of ln(x)
	
	// test if temp3 > abs(1e-13)
	fabs	temp_r3, temp_r3		// abs(temp_r3)
	adrp	x25, limit_m			// load limit_m (1.0e-13) into d25
	add	x25, x25, :lo12:limit_m		// load the lower 12 bits of d25
	ldr	d27, [x25]			// load the value in limit_m into d26
	fcmp	temp_r3, d27			// check if temp_r3 < 1.0e-13 (in d26)
	b.lt	prtlnx				// if temp_r3 < 1.0e-13, print ln(x)
	
	// setup for next expansion calculation	
	fmov	temp_r3, temp_r2		// reset temp3 to temp2
	fmov	d26, 1.0			// move 1.0 into d26
	fadd	y_reg, y_reg, d26		// add 1 to the value of y
	b	tyexp				// if temp_r3 => 1.0e-13, cacluclate next taylor expansion

	// print x and ln(x)
prtlnx:	adrp	x0, prt				// load prt string to print outcome
	add	x0, x0, :lo12:prt		// load the lower 12 bits of th prt
	fmov	d0, x_reg			// load x as first argument
	fmov	d1, ln_reg			// load ln(x) into second argument
	bl	printf				// call printf
	b	loop				// go read next value to run loop again

	// close the file
close:	mov	w0, fd				// 1st arguement, file descriptor
	mov	x8, 57				// service request, 57 = close file
	svc	0				// system call

	// error check for closing
	cmp	w0, 0				// compare return value from closing to 0
	b.ge	end				// if greater or equal, end the program
	
	// print close error message
	adrp	x0, errcls			// load error close string to x0
	add	x0, x0, :lo12:errcls		// load lower 12 bits into x0
	bl	printf				// call printf	

	// end program
end:	mov	w0, 0				// load 0 into w0
	ldp	x29, x30, [sp], dealloc		// deallocate memory
	ret					// return control to OS
