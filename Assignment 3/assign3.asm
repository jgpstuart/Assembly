//CPSC355 Assignment 3, written by Jeremy Stuart (00311644)

define(i_reg, w19)
define(j_reg, w20)
define(min_reg, w21)
define(temp_reg, w22)
define(array_reg, x23)

fmt1:	.string "v[%d]: %d\n"			// print string 1
fmt2:	.string "\nSorted array:\n"		// print string 2
	.balign 4				// align statement for printing

array_count = 50				// number of elements in array

// set sizes for program variables
i_size = 4					// size of i is 4 bytes (int)
j_size = 4					// size of j is 4 bytes (int)
min_size = 4					// size of min is 4 bytes (int)
temp_size = 4					// size of temp is 4 bytes (int)
array_size = array_count * 4

// offsets, base is the Frame Pointers (16 bytes)
i_s = 16					// 16 since FP is 16 bytes
j_s = i_s + i_size				// last offset plus that variable's size
min_s = j_s + j_size				// last offset plus that variable's size
temp_s = min_s + min_size			// last offset plus that variable's size
array_s = temp_s + temp_size			// last offset plus that variable's size


variable_sizes = i_size + j_size + min_size + temp_size + array_size	// size of all variables added together
alloc = -(16 + variable_sizes)& -16		// allocation variable for setting up stack
dealloc = -alloc				// reverse of allocation variable for ending program

fp	.req x29				// register equate Frame Pointer to "fp"
lr	.req x30				// register equate Link Register to "lr"

.global main

	// allocate the initialized variables and frame record
main:	stp	fp, lr, [sp, alloc]!
	mov	fp, sp
	
	// initialize the loop variables
	mov	i_reg, 0			// move 0 to w19
	str	i_reg, [fp, i_s]		// store x19 in the stack over i
	b	test_1				// run test for loop1

	// the body of loop 1
loop1:	bl	rand				// random number stored in w0
	and	temp_reg, w0, 0xFF		// bitwise and digit with 256 to get the modulus
	ldr	i_reg, [fp, i_s]		// load i into w19
	add	array_reg, fp, array_s		// calculate array base address
	str	temp_reg, [array_reg, i_reg, SXTW 2]	// store the random number into stack:
						// address: array base address + i * 4
	
	// Loop 1 print statement
print1:	adrp	x0, fmt1			// load fmt1 into x0
	ldr	i_reg, [fp, i_s]		// load i into w19
	mov	w1, i_reg			// mov i into w1
	add	x0, x0, :lo12:fmt1		// lower 12 bits of the string
	mov	w2, temp_reg			// mov the random number into w2
	bl	printf				// call printf

	add	i_reg, i_reg, 1			// increment i
	str	i_reg, [fp, i_s]		// update i in the stack

	// loop test for the first loop (i<50)
test_1:	cmp	i_reg, array_count		// compare i and array_count (50)
	b.lt	loop1				// go back to loop1 if i is less than 50

	// setup loop 2
	mov	i_reg, 0			// reset i to 0
	str	i_reg, [fp, i_s]		// store i in the stack
	mov	w28, array_count		// load 50 into 28
	sub	w28, w28, 1			// store the upper loop limit in x28
	b	test_2				// run test for loop2

	// start loop 2
loop2:	ldr	i_reg, [fp, i_s]		// load i into w19
	str	i_reg, [fp, min_s]		// store i in minimum

	// setup loop 3
	ldr	i_reg, [fp, i_s]		// load i into w19
	add	i_reg, i_reg, 1			// increment, i+1
	str	i_reg, [fp, j_s]		// store i+1 into j
	b	test3				// run the test for the internal loop
	
	// start of loop 3
loop3:	ldr	j_reg, [fp, j_s]		// load j into x20
	ldr	min_reg, [fp, min_s]		// load min into x21
	add	array_reg, fp, array_s		// array base address
	ldr	w24, [array_reg, j_reg, SXTW 2]	// load array at v[j] to w24
	ldr	w25, [array_reg, min_reg, SXTW 2]	// load array at v[min] to w25

	// compare elements
if:	cmp	w24, w25			// if v[j] < v[min]
	b.gt	incj				// skip next line if v[j] > v[min]
	str	j_reg, [fp, min_s]		// store j in min
	
	// increment j
incj:	ldr	j_reg, [fp, j_s]		// load j
	add	j_reg, j_reg, 1			// increment j
	str	j_reg, [fp, j_s]		// store j in memory

	// loop test for loop 3
test3:	ldr	j_reg, [fp, j_s]		// load j
	cmp	j_reg, array_count		// compare j and the array size
	b.lt	loop3

	// swap elements in the array
swap:	ldr	i_reg, [fp, i_s]		// load i into w19
	ldr	min_reg, [fp, min_s]		// load min into w21
	add	array_reg, fp, array_s		// array base address
	ldr	w24, [array_reg, i_reg, SXTW 2]	// load array at v[i] to w24
	ldr	w25, [array_reg, min_reg, SXTW 2]// load array at v[min] to w25
	
	mov	temp_reg, w25			// mov v[min] to w22 which will be temp
	ldr	w25, [array_reg, i_reg, SXTW 2]	// load v[i]
	str	w25, [array_reg, min_reg, SXTW 2]// store v[i] over v[min]
	str	temp_reg, [array_reg, i_reg, SXTW 2]// store temp over v[i]  
	
	// increment i post swap
	ldr 	i_reg, [fp, i_s]		// load i from stack
	add	i_reg, i_reg, 1			// increment i by 1
	str	i_reg, [fp, i_s]		// store i

	// loop test for loop 2
test_2:	ldr	i_reg, [fp, i_s]		// load i
	cmp	i_reg, w28			// compare i and the upper loop limit
	b.lt	loop2				// branch to loop2 if i<(upper loop limit)

	// print the "Sorted array:" string
print2:	adrp	x0, fmt2			// load fmt2 into x0
	add	x0, x0, :lo12:fmt2		// load lower 12 bits
	bl	printf				// call printf 
	
	// setup final print loop
	mov	i_reg, 0			// load 0 to w19 to reset i to 0
	str	i_reg, [fp, i_s]		// store i to stack
	
	// print statement
print3:	add	array_reg, fp, array_s		// calculate array base address
	ldr	w26, [array_reg, i_reg, SXTW 2]	// get v[i]

	adrp	x0, fmt1			// load fmt1 into x0
	mov	w1, i_reg			// load w19 (i) into w1
	add	x0, x0, :lo12:fmt1		// load lower 12 bits
	mov	w2, w26				// load x26 (v[i]) into w2
	bl	printf				// call printf

	add	i_reg, i_reg, 1			// increment i	

	// print loop test
	cmp	i_reg, array_count		// compare i and 50
	b.lt	print3				// if i is less than 50, go back to print3

end:	mov	w0, 0				// reset w0 to 0
	mov	w1, 0				// reset w0 to 0
	mov	w2, 0				// reset w2 to 0
	ldp	fp, lr, [sp], dealloc		// deallocate all program variables from the stack			
	ret					// return control to the OS
