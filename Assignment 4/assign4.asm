// Assignment 4, CPSC355		Authored by: Jeremy Stuart (00311644)
// University of Calgary

define(c_base_r, x9)
define(cuboid_base_r, x19)
define(FALSE, 0)
define(TRUE, 1)

// print strings
prt0:	.string "Initial Cuboid Values:\n" 
prt1:	.string "Cuboid %s origin = (%d, %d)\n"
prt2:	.string "\tBase width = %d Base length = %d\n"
prt3:	.string "\tHeight = %d\n"
prt4:	.string "\tVolume = %d\n\n"
prt5:	.string "\nCuboid changed values:\n"
prt1st:	.string "first"
prt2nd:	.string "second"
	.balign 4

// sizes for point
x_size = 4								// size of x (int) = 4
y_size = 4								// size of y (int) = 4
point_size = x_size + y_size						// size of point is x + y (8)

// sizes for dimension
width_size = 4								// size of width (int) = 4
length_size = 4								// size of length (int) = 4
dimension_size = width_size + length_size				// size of dimension is width + length = 8

//sizes for cuboid
height_size = 4								// size of height (int) = 4
volume_size = 4								// size of volume (int) = 4
cuboid_size = point_size + dimension_size + height_size + volume_size	// size of the cuboid = point + dimension + height + volume (24)

// sizes for first and second
first_size = cuboid_size						// size of the first cuboid is the size of a cuboid
second_size = cuboid_size						// size of the second cuboid is the size of a cuboid

// point offsets
x_s = 0									// offset for x is 0 from the top of point
y_s = x_s + x_size							// offset for y is under x

// dimension offsets
width_s = 0								// offset for width is 0 from the top of dimenion
length_s = width_s + width_size						// offset for length is under width

// cuboid offsets
point_s = 0								// offset of point in cuboid is 0
dimension_s = point_s + point_size					// offset of dimension is under point
height_s = dimension_s + dimension_size					// offset of height is under dimension
volume_s = height_s + height_size					// offset of volume is under height

// offsets for first and second
first_s = 16								// first cuboid is located under the frame record
second_s = first_s + first_size						// second cuboid is located under first cuboid

alloc = -(16 + first_size + second_size) & -16				// allocation for main
dealloc = -alloc							// deallocation for main


.global main

main:		stp		x29, x30, [sp, alloc]!			// allocate memory for main
		mov		x29, sp					// move the frame pointer to the stack pointer
		
		add		x8, x29, first_s			// base address of allocated spcae for "first" in main to pass to newCuboid
		bl		newCuboid				// call newCuboid
		add		x8, x29, second_s			// base address of allocated space for "second" in main to pass to newCuboid
		bl		newCuboid				// call newCuboid
		
		adrp		x0, prt0				// move the prt0 string into x0 to pass it
		add		x0, x0, :lo12:prt0			// allocate the string to the lower 12 bits
		bl		printf					// call printf
		
		// initial printCuboid for first
		adrp		x0, prt1st				// move the prt1st string into x0 to pass it
		add		x0, x0, :lo12:prt1st			// allocate the string to the lower 12 bits
		add		x1, x29, first_s			// store address for first_cuboid into x1
		bl		printCuboid				// run printCuboid
		
		// initial printCuboid for second
		adrp		x0, prt2nd				// load the prt2nd string into x0
		add		x0, x0, :lo12:prt2nd			// allocate the string to the lower 12 bits
		add		x1, x29, second_s			// send address for second_cuboid
		bl		printCuboid				// run printCuboid
		
		// prepare if statement
		add		x0, x29, first_s			// store base address for first_cuboid in x0 to pass it
		add		x1, x29, second_s			// store base address for second_cuboid in x1 to pass it
		bl 		equalSize				// branch to  equalSize
		cmp		w0, TRUE				// compare the returned value of equalSize and TRUE (1)
		b.ne		jump					// if the value is not equal (logical compliment) branch to jump
		
		// prepare arguments for move
		add		x0, x29, first_s			// store address for first cuboid in x0 to pass it
		mov		w1, 3					// move second argument = 3 into w1 to pass it
		mov		w2, -6					// move third argument = -6 into w2 to pass it
		bl		move					// run move

		// prepare arguments for scale
		add		x0, x29, second_s			// send address for second cuboid
		mov		w1, 4					// move fourth argument = 4 into w1 to pass it
		bl		scale					// run scale
		
		// heading for the second print statement
jump:		adrp		x0, prt5				// load prt5 string into x0
		add		x0, x0, :lo12:prt5			// allocate the string to the lower 12 bits
		bl		printf					// call printf
		
		// second printCuboid for first
		adrp		x0, prt1st				// load prt1st string into x0
		add		x0, x0, :lo12:prt1st			// allocate the string to the lower 12 bits
		add		x1, x29, first_s			// send address for first_cuboid
		bl		printCuboid				// run printCuboid
		
		// second printCuboid for second
		adrp		x0, prt2nd				// load the string into x0
		add		x0, x0, :lo12:prt2nd			// allocate the string to the lower 12 bits 
		add		x1, x29, second_s			// send address for second_cuboid
		bl		printCuboid				// run printCuboid
				
end:		ldp		x29, x30, [sp], dealloc			// deallocate memory from main
		ret							// return


		// NEWCUBOID SUBROUTINE
c_size = cuboid_size							// the size of c is the size of newCuboid
alloc = -(16 + c_size) & -16						// allocation of space for newCuboid
dealloc = -alloc							// deallocation of space for newCuboid
c_s = 16								// offset for c, under the frame record

newCuboid:
		stp		x29, x30, [sp, alloc]!			// allocate frame record and space on the stack
		mov		x29, sp					// move the frame record to the stack pointer
		
		// create c struct base address
		add		c_base_r, x29, c_s 			// store base address for new cuboid in x9
		
		// initialize all values in c struct
		mov		w10, 0					// move c.origin.x intial value (0) to w9
		str		w10, [c_base_r, point_s + x_s] 		// store c.origin.x 
		mov		w10, 0					// move c.origin.y inital value (0) to w9
		str 	w10, [c_base_r, point_s + y_s]			// store c.origin.y
		mov		w10, 2					// move c.base.width inital value (2) to w9
		str		w10, [c_base_r, dimension_s + width_s]	// store c.base.width
		mov		w10, 2					// move c.base.length initial value (2) to w9
		str		w10, [c_base_r, dimension_s + length_s]	// store c.base.length
		mov		w10, 3					// move c.height initial value (3) to w9
		str		w10, [c_base_r, height_s]		// store c.height
		mov		w10, 12					// move c.volume inital value (2*2*3) to w9
		str		w10, [c_base_r, volume_s]		// store c.volume
		
		// return c
		ldr		w10, [c_base_r, point_s + x_s]		// load c.origin.x to w10
		str		w10, [x8, point_s + x_s]		// store c.origin.x in the main function cuboid memory using x8
		ldr		w10, [c_base_r, point_s + y_s]		// load c.origin.y to w10
		str		w10, [x8, point_s + y_s]		// store c.origin.y in the main function cuboid memory using x8
		ldr		w10, [c_base_r, dimension_s + width_s]	// load c.base.width to w10
		str		w10, [x8, dimension_s + width_s]	// store c.base.width in the main function cuboid memory using x8
		ldr		w10, [c_base_r, dimension_s + length_s]	// load c.base.length to w10
		str		w10, [x8, dimension_s + length_s]	// store c.base.length in the main function cuboid memory using x8
		ldr		w10, [c_base_r, height_s]		// load c.height to w10
		str		w10, [x8, height_s]			// store c.height in the main function cuboid memory using x8
		ldr		w10, [c_base_r, volume_s]		// load c.volume to w10
		str		w10, [x8, volume_s]			// store c.volume in the main function cuboid memory using x8
		
		mov		w0, 0					// reset x0 to 0
		
		ldp		x29, x30, [sp], dealloc			// deallocate memory for newCuboid
		ret							// return
		

		// EQUAL SIZE SUBROUTINE
result_size = 4								// result in an int, size is 4
alloc = -(16 + result_size) & -16					// allocate size for equalSize
dealloc = -alloc							// deallocate size
result_s = 16								// offset of result from the frame register for equalSize

equalSize:	stp		x29, x30, [sp, alloc]!			// allocate frame record for equalSize and store x29 and x30
		mov		x29, sp					// set stack pointer to the location of the current frame record
		
		// set result to false
		mov		w9, FALSE				// set w19 to false
		str		w9, [x29, result_s]			// store FALSE in result space in the stack
		
		// start of if statements, load widths of first and second
		ldr		w10, [x0, dimension_s + width_s]	// load first.dimension.width into w10
		ldr		w11, [x1, dimension_s +width_s]		// load second.dimension.width into w11
		cmp		w10, w11				// compare the result of first.dimension.width and second.dimension.width
		b.ne	endEqual					// jump to endEqual if the result is not equal (logical compliment for if)

		// load lengths of first and second for second if statment
		ldr		w12, [x0, dimension_s + length_s]	// load first.dimension.length into w22
		ldr		w13, [x1, dimension_s + length_s]	// load second.dimension.length into w23
		cmp		w12, w13				// compare first.dimension.length and second.dimension.length
		b.ne	endEqual					// jump to endEqual if the result is not equal (logical compliment for if)

		// load heights of first and second for third if statement
		ldr		w14, [x0, dimension_s + height_s]	// load first.dimension.height into w24
		ldr		w15, [x1, dimension_s + height_s]	// load second.dimension.height into w25
		cmp		w14, w15				// compare first.dimension.height and second.dimension.height
		b.ne	endEqual					// jumpt to endEqual if the result is not equal (logical compliment for if)
		mov		w9, TRUE				// set x19 to TRUE
		str		w9, [x29, result_s]			// store TRUE in result space in the stack

endEqual:	ldr		w0, [x29, result_s]			// move result into x0 to pass back to main
		
		mov		w1, 0					// reset x0 to 0
		
		ldp		x29, x30, [sp], dealloc			// deallocate the memory for equalSize
		ret							// return


		// MOVE SUBROUTINE
move:		stp		x29, x30, [sp, -16]!			// allocate 16 bytes in the stack for the routine
		mov		x29, sp					// move the frame pointer to the stack pointer
		
		// add 3 to origin.x
		ldr		w9, [x0, point_s + x_s]			// load origin.x from stack into w9
		add		w9, w9, w1				// add origin.x with second argument (3)
		str		w9, [x0, point_s + x_s]			// store origin.x back into stack
		
		// add -6 to origin.y
		ldr		w10, [x0, point_s + y_s]		// load origin.y from stack into w10
		add		w10, w10, w2				// add origin.y with third argument (-6)
		str		w10, [x0, point_s + y_s]		// store origin.y back into stack
		
		mov		w0, 0					// reset w0 to 0
		
		ldp		x29, x30, [sp], 16			// deallocate 16 bytes from the stack
		ret							// return
		
		
		// SCALE SUBROUTINE
scale:		stp		x29, x30, [sp, -16]!			// allocate 16 bytes in the stack for the routine
		mov		x29, sp					// move the frame pointer to the stack pointer
		
		ldr		w9, [x0, dimension_s + width_s]		// load origin.width
		mul		w9, w9, w1				// multiply origin.width * 4
		str		w9, [x0, dimension_s + width_s]		// store origin.width
		
		ldr		w10, [x0, dimension_s + length_s]	// load origin.length
		mul		w10, w10, w1				// multiply origin.length * 4
		str		w10, [x0, dimension_s + length_s]	// store origin.length
		
		ldr		w11, [x0, height_s]			// load height
		mul		w11, w11, w1				// multiply height * 4
		str		w11, [x0, height_s]			// store height
		
		mul		w12, w9, w10				// multiply width * length and store in x12
		mul		w12, w12, w11				// multiply (width * length) * height
		str		w12, [x0, volume_s]			// store volume to origin.volume
		
		mov		w0, 0					// reset w0 to 0
		
		ldp		x29, x30, [sp], 16			// deallocate the memory for scale
		ret							// return
		
		
		// PRINT CUBOID
printCuboid:	stp		x29, x30, [sp, -16]!			// allocate 16 bytes for printCuboid
		mov		x29, sp					// set the frame pointer to the stack pointer
		
		// relocate x0, and x1 to prepare priting
		mov		cuboid_base_r, x1			// move the cubiod address to x19
		mov		x1, x0					// move the label pointed to x1 to prep printing
		
		// first print statement
		adrp		x0, prt1				// move prt1 string to x0
		add		x0, x0, :lo12:prt1			// allocate the lower 12 to x0
		ldr		w2, [cuboid_base_r, point_s + x_s] 	// load the value of point.x into w2
		ldr		w3, [cuboid_base_r, point_s + y_s]	// load the value of point.y into w3
		bl		printf
		
		// second print statement
		adrp		x0, prt2				// move prt2 string to x0
		add		x0, x0, :lo12:prt2			// allocate the lower 12 to x0
		ldr		w1, [cuboid_base_r, dimension_s + width_s]	// load dimension.width into w1
		ldr		w2, [cuboid_base_r, dimension_s + length_s]	// load dimension.length into w2
		bl		printf					// call printf
		
		// third print statement
		adrp		x0, prt3				// move prt3 string to x0
		add		x0, x0, :lo12:prt3			// allocate the lower 12 to x0
		ldr		w1, [cuboid_base_r, height_s]		// load height into w1
		bl 		printf					// call printf
		
		// fourth print statement
		adrp		x0, prt4				// move prt4 string to x0
		add		x0, x0, :lo12:prt4			// allocate the lower 12 to x0
		ldr		w1, [cuboid_base_r, volume_s]		// load base into w1
		bl		printf					// call printf
		
		mov		x0, 0					// reset x0 to 0
		
		ldp		x29, x30, [sp], 16			// deallocate 16 bytes from printCuboid
		ret							// return
		
		








