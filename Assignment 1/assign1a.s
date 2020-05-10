//Assignment 1, part a. CPSC 355. Jeremy Stuart (00311644).

fmt:	.string "Current X value = %d\nCurrent Y value = %d\nMaxiumum Value = %d\n\n"
	.balign 4

.global main

main:	stp	x29, x30, [sp, -16]!	// because we were told to do this, and that we'd learn why later
	mov	x29, sp			// ditto!
	
	mov	x19, 4			// set 4 as the end point of the loop
	mov 	x20, -10		// x, used to calculate the function
	mov	x21, -20000		// STORE MAXIMUM VALUE HERE

test:	cmp	x19, x20		// compare two registers to see if looping stops
	b.lt	finish			// if x == 4, end the loop and finish the program

	// calculate -2 * x^3 and store in x22
top: 	mul	x22, x20, x20		// x * x
	mul	x22, x22, x20		// x * (x * x)
	mov	x28, -2 		// store -2 in x28 to multiply in next step
	mul 	x22, x22, x28		// -2 * (x * x * x)
	
	// calculate -22*x^2 and store in x23
	mul	x23, x20, x20		// x * x
	mov	x28, -22		// store -22 in x28 to multiple in next step
	mul	x23, x23, x28		// -22 * (x * x)
	
	// calculate 11*x and store in x24
	mov	x28, 11			// store 11 in x28 for next step
	mul	x24, x20, x28		// x * 11

	// add the results of the previous three calculations and finish the function
	add	x25, x22, x23		// (-2*x^3) + (-22*x^2)
	add	x25, x25, x24		// result of last line + 11x
	add	x25, x25, 57		// last result +  57, function answer stored in X25

	cmp	x21, x25		// compare the current maximum value with the function output in this loop
	b.gt	print			// if the max value is greater than the function output, jump to print
	mov	x21, x25		//replace the current max with the function result

	// print the results of this iteration
print:	adrp 	x0, fmt			// prep printing
	add	x0, x0, :lo12:fmt	// something about the lower 12 bits of the string that we'll learn about later
	mov	x1, x20			// the value of x to be printed
	mov	x2, x25			// the value of y to be printed
	mov	x3, x21			// the current maximum value of the function to be printed
	bl	printf			// call printf

	//  increment x and start the loop again
	add 	x20, x20, 1		// increment the value of x
	b	 test 			// run the loop test

	// end the program
finish: mov	x0, 0			// reset x0 register
	mov	x1, 0			// reset x1 register
	mov	x2, 0			// reset x2 register
	mov	x3, 0			// reset x3 register
	ldp	x29, x30, [sp], 16	// because we were told to end the program this way and we'd learn why later
	ret				// ditto!

