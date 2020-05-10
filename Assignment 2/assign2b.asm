// assign2b, Assignment 2, CPSC 355 submitted by Jeremy Stuart (00311644)

print1:	.string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"

print2: .string "product = 0x%08x multiplier = 0x%08x \n\n"

print3: .string "64-bit result = 0x%016lx (%ld)\n"
	.balign 4


define(FALSE, 0)
define(TRUE, 1)
define(multiplier, w19)
define(multiplicand, w20)
define(product, w21)
define(i, w22)
define(negative, w23)
define(result, x24)
define(temp1, x25)
define(temp2, x26)

.global main

main:		stp	x29, x30, [sp, -16]!		// save the start states of the machine
		mov	x29, sp				// save the state states of the machine

		// Print out initial values of variables
start:		mov	multiplicand, 522133279		// set multiplicand
		mov	multiplier, 200			// set multiplier
		mov	product, 0			// preset product

		// Print out initial values of variables
		adrp	x0, print1			// prep for printing
		add	x0, x0, :lo12:print1		// prep print 1
		mov	w1, multiplier			// load multiplier into w1
		mov	w2, multiplier			// load multiplier into w2
		mov	w3, multiplicand		// load multiplicand into w3
		mov	w4, multiplicand		// load multiplicand into w4
		bl	printf				// print line print1

		// Determine if multiplier is negative
		cmp	multiplier, 0			// compare multiplier and 0 for turnary if
		mov	negative, TRUE			// set negative to TRUE
		b.lt	loopSetup			// if cmp is neg then jump to the loop, otherwise fall through
		mov	negative, FALSE			// set negative to FALSE

		// Setup the loop and goto the loop test
loopSetup:	mov	i, 0				// set i to 0
		b	loopTest			// jump to the loop test

		// The primary loop of the algorithm
topLoop:	tst	multiplier, 0x1			// test the first bit of the multiplier to see if it's 1
		b.eq	jump1				// go to jump1 if first bit isn't 1
		add	product, product, multiplicand	// add muptiplicand and product

		// Arithmetic shift right the combined product and multiplier		
jump1:		lsr	multiplier, multiplier, 1	// logical shift left the multiplier
		tst	product, 0x1			// check if product first bit is 1
		b.ne 	bitIsOne			// if it's 1, go to the orr operation
		and	multiplier, multiplier, 0x7FFFFFFF // the else part of the statement
		b	endloop				// go to the end of the loop
bitIsOne:	orr	multiplier, multiplier, 0x80000000 // execute the orr opearation if the tst was true
endloop:	asr	product, product, 1		// Arithmetic shift right for the product to presever sign bit
		add	i, i, 1				// End of the loop, add 1 to i		

		// Loop test
loopTest:	cmp	i, 32				// is i less than 32
		b.lt	topLoop				// restart loop if i less than 32


		// Adjust product register if multiplier is negative
postLoop:	tst	negative, 0x1			// test to see if negative is set to TRUE
		b.eq	jump2				// if negative is set to 0 then go to jump 2
		sub	product, product, multiplicand	// subtract multiplicand from product as per the algorithm

		// Print out product and multiplier
jump2:		adrp	x0, print2			// prep print statement 2
		add	x0, x0, :lo12:print2		// load print2 into x0
		mov	w1, product			// load product into w1 for printing
		mov	w2, multiplier			// load multiplier into w2 for printing
		bl	printf				// call printf
					
		// Combine product and multplier together
lastStep:	sxtw	temp1, product			// sign extend the product  to prep for a 32 bit shift left, load it in temp1
		and	temp1, temp1, 0xFFFFFFFF	// and the temp1 value with a large number (4294967295)
		lsl	temp1, temp1, 32		// shift value left 32 bits
		sxtw	temp2, multiplier		// textend multiplier into temp2
		and	temp2, temp2, 0xFFFFFFFF	// and the temp2 with a large number (4294967295)
		add	result, temp1, temp2		// add temp1 and temp2 and store them in result

		// Print out the 64-bit result
finalPrint:	adrp	x0, print3			// prep print statement 3
		add	x0, x0, :lo12:print3		// load print3 into x0
		mov	x1, result			// load result into x1
		mov	x2, result			// load result into x2
		bl	printf				// call printf
	
		mov	x0, 0				// reset x0/w0
		mov	x1, 0				// reset x1/w1
		mov	x2, 0				// reset x2/w2
		mov	x3, 0				// reset x3/w3
		mov	x4, 0				// reset x4/w4


		ldp	x29, x30, [sp], 16		// reload the starting state
		ret					// exit the program
