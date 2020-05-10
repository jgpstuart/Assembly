//Assignment 1, part b. CPSC 355. Jeremy Stuart (00311644).

//print strings
fmt:	.string "Current X value = %d\nCurrent Y value = %d\nMaxiumum Value = %d\n\n"
final:	.string "Maximum value: %d\n"
	.balign 4

define(top, x19)
define(x_r, x20)
define(max, x21)
define(y_r, x25)

.global main

main:	stp	x29, x30, [sp, -16]!	// do this because it's needed, we'll be taught why later
	mov	x29, sp			// another required line that we'll be taught about later
	
	mov	top, 4			// set 4 as the end point of the loop
	mov 	x_r, -10		// x, used to calculate the function
	mov	max, -20000		// STORE MAXIMUM VALUE HERE

	// run the loop test
	b 	test			// jump to the loop test

	// calculate -2 * x^3 and store in x22
top: 	mul	x22, x_r, x_r		// x * x
	mul	x22, x22, x_r		// x * (x * x)
	mov	x28, -2 		// store -2 in x28 to multiply in next step
	mul 	x22, x22, x28		// -2 * (x * x * x)
	
	// calculate -22*x^2 and store in x23
	mul	x23, x_r, x_r		// x * x
	mov	x28, -22		// store -22 in x28 to multiple in next step
	mul	x23, x23, x28		// -22 * (x * x)
	
	// calculate (11*x) + 57 using multiply add  and store in x24
	mov	x28, 11			// store 11 in x28 for this calculation
	mov	x27, 57			// store 57 in x27 for the next step
	madd	x24, x_r, x28, x27	//57 + (x * 11)

	// add the results of the previous three calculations and finish the function
	add	y_r, x22, x23		// (-2*x^3) + (-22*x^2) + (11x)
	add	y_r, y_r, x24		// add (11x  + 57) to the last operation to get the final value of y

	cmp	max, y_r		// compare the current maximum value with the function output in this loop
	b.gt	print			// if the max value is greater than the function output, jump to print
	mov	max, y_r		//replace the current max with the function result

	// print the results of this iteration
print:	adrp 	x0, fmt			// load the print string into x0
	add	x0, x0, :lo12:fmt	// something about the lower 12 bits, not 100% sure what it does though
	mov	x1, x_r			// the value of x to be printed
	mov	x2, y_r			// the value of y to be printed
	mov	x3, max			// the current maximum value of the function to be printed
	bl	printf			// call printf

	//  increment x and start the loop again
	add 	x_r, x_r, 1		// increment the value of x
	
	// the loop test
test:	cmp	top, x_r		// compare two registers to see if looping stops
	b.ge	top			// if x == 4, end the loop and finish the program


	// end the program
finish: adrp	x0, final		// load the print string into x0
	add	x0, x0, :lo12:final	// something about th elower 12 bits, not 100% sure what it does though
	mov	x1, max			// load the max value into x1 for printing in the string
	bl	printf			// call printf
	mov	x0, 0			// reset value of x0 to 0
	mov	x1, 0			// reset value of x1 to 0
	mov	x2, 0			// reset value of x2 to 0
	mov	x3, 0			// reset value of x3 to 0
	ldp	x29, x30, [sp], 16	// line required to end the program
	ret				// line required to end the program

