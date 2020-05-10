// Submitted by Jeremy Stuart (UCID 00311644) for CPSC 355 Fall 2019, assignment 5 part b

define(argc_r, w19)
define(argv_r, x20)
define(month_r, w21)
define(day_r, w22)
define(year_r, x23)

	.text
fmt:	.string	"%s %d%s, %d\n"
err1:	.string "usage: a5b mm dd yyyy\ntoo few arguments, make sure input is mm dd yyyy\n"
err2:	.string "usage: a5b mm dd yyyy\ntoo many arguments, make sure input is mm dd yyyy\n"
err3:	.string "usage: a5b mm dd yyyy\nInput error.  Make sure month is between 1 and 12.\n"
err4:	.string	"usage: a5b mm dd yyyy\nInput error.  Make sure day is between 1 and 31.\n"
err5:	.string "usage: a5b mm dd yyyy\nInput error.  Make sure year is greater than 0.\n"	

	// Months from C declaration
	jan_m:	.string	"January"
	feb_m:	.string	"February"
	mar_m:	.string	"March"
	apr_m:	.string	"April"
	may_m:	.string	"May"
	jun_m:	.string	"June"
	jul_m:	.string "July"
	aug_m:	.string "August"
	sep_m:	.string "September"
	oct_m:	.string	"October"
	nov_m:	.string "November"
	dec_m:	.string	"December"

	// Suffixes for days
	st_m:	.string "st"
	dn_m:	.string "nd"
	rd_m:	.string "rd"
	th_m:	.string "th"
	.balign 4
	
	.data
	
	// array of months
month_m:.dword 	jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
	
	// array of ordinal suffixs
suffix_m:.dword	st_m, dn_m, rd_m, th_m
	.balign 8	

	.text
	.balign 4
	.global main

main:	stp	x29, x30, [sp, -16]!		// allocate 16 bytes
	mov	x29, sp				// move stack pointer to frame pointer

	mov	argc_r, w0			// move w0 (number of arguments) into w19
	mov	argv_r, x1			// move x1 (address of array) into x20

	// range checks for inputs
	// check for number of arguments
range:	cmp	argc_r, 4			// compare number of arguments with 4
	b.lt	lt				// if args < 4 goto lt
	cmp	argc_r, 4			// compare number of arguments with 4
	b.gt	gt				// if args > 4 goto gt
	b	argmov				// goto argmov to move arguments into registers

lt:	adrp	x0, err1			// load err1 message into x1
	add	x0, x0, :lo12:err1		// load the lower 12 bits into x1
	b	print_error			// goto print error

gt:	adrp	x0, err2			// load err2 into x1
	add	x0, x0, :lo12:err2		// load the lower 12 bits into x1
	b	print_error			// goto print error


	// put arguments into registers and convert to ints
argmov:	mov	w28, 1				// load 1 as first argument
	ldr	x0, [argv_r, w28, SXTW 3]	// load the first argument into the month register
	bl	atoi				// convert from ascii to int
	mov	month_r, w0			// move the new int into month register

	mov	w28, 2				// load 2 as second argument
	ldr	x0, [argv_r, w28, SXTW 3]	// load the second argument in the month register
	bl 	atoi				// convert from ascii to int
	mov	day_r, w0			// move the new int into day register
	
	mov	w28, 3				// load 3 a third argument
	ldr	x0, [argv_r, w28, SXTW 3]	// load the third argument into the year register
	bl	atoi				// convert from ascii to int
	sxtw	x0, w0				// sign extend year in case of negative
	mov	year_r, x0			// move the new int int year register (x23)

	// range check for month
mcheck:	cmp	month_r, 1			// compare month to 1
	b.lt	merror				// goto print_error if less than
	cmp	month_r, 12			// compare month to 12
	b.gt	merror				// goto print_error if greater than
	b	dcheck				// if month in range, check day

merror:	adrp	x0, err3			// move err3 string into x1
	add	x0, x0, :lo12:err3		// load the lower 12 bits of err3
	b	print_error			// goto print error

	//range check for day
dcheck:	cmp	day_r, 1			// compare day to 1
	b.lt	derror				// goto print_error if less than
	cmp	day_r, 31			// compare day to 31
	b.gt	derror				// goto print_error if greater than
	b	ycheck				// if day in range, goto ycheck

derror:	adrp	x0, err4			// move err4 string into x1
	add	x0, x0, :lo12:err4		// load lower 12 bits of err4 string
	b	print_error			// goto print error

	//range check for year
ycheck:	cmp	year_r, 1			// compare year to 1
	b.lt	yerror				// goto print_error if less than
	b	ordchk				// if year in range, goto ordinal check

yerror:	adrp	x0, err5			// move err5 into x1
	add	x0, x0, :lo12:err5		// move lower 12 bits into x1
	b	print_error

	// ordinal suffix check
	// day modulo 10
ordchk:	mov	w24, 10				// mov 10 into x24
	sdiv	w25, day_r, w24			// divide the day by 10, put in x25
	mul	w26, w25, w24			// multiply the quotient and divisor
	sub	w27, day_r, w26			// remainder stored in w27

	// check conditions for suffix
	// if (w27 == 1 && day_r != 11) return "st"
	cmp	w27, 1				// compare remainder and 1
	b.ne	jump1				// if not equal goto check next suffix
	cmp	day_r, 11			// compare day to 11
	b.eq	suf_th				// if day is 11, suf_th	
	adrp	x28, suffix_m			// calculate base address for suffix
	add	x28, x28, :lo12:suffix_m	// load the lower 12 bits of x28
	mov	w27, 0				// mov 0 to w27 to load next step
	ldr	x3, [x28, w27, SXTW 3]		// load the first variable in suffix array (st)
	b	print				// jump to print
	
	// if (w27 == 2 && day_r != 12) return "nd"
jump1:	cmp	w27, 2				// compare remainder and 2
	b.ne	jump2				// if not equal goto next suffix
	cmp	day_r, 12			// compare day to 12
	b.eq	suf_th				// if day is 12, goto suf_th
	adrp	x28, suffix_m			// calculate base address for suffix
	add	x28, x28, :lo12:suffix_m	// load the lower 12 bits of x28
	mov	w27, 1				// load 1 into w27 to load next step
	ldr	x3, [x28, w27, SXTW 3]		// load the second variable in suffix array (nd)
	b	print				// jump to print

	// if (w27 == 3 && day_r != 13) return "rd"
jump2:	cmp	w27, 3				// compare remainder and 3
	b.ne	suf_th				// if not equal goto suf_th
	cmp	day_r, 13			// compare day to 13
	b.eq	suf_th				// if day is 11, goto suf_th	
	adrp	x28, suffix_m			// calculate base address for suffix
	add	x28, x28, :lo12:suffix_m	// load the lower 12 bits of x28
	mov	w27, 2				// load 2 into w27 for the next step
	ldr	x3, [x28, w27, SXTW 3]		// load the third variable in suffix array (rd)
	b	print				// jump to print

	// else return "th"
suf_th:	adrp	x28, suffix_m			// calculate base address for suffix
	add	x28, x28, :lo12:suffix_m	// load the lower 12 bits of x28
	mov	w27, 3				// load 3 into w27 for the next step
	ldr	x3, [x28, w27, SXTW 3]		// load the fourth variable in suffix array (th)
	
	// print result if all checks passed
print:	sub 	month_r, month_r, 1		// subtract 1 from the month to load from array
	adrp	x28, month_m			// load base address for month_m
	add	x28, x28, :lo12:month_m		// load the lower 12 bits from x28
	ldr	x1, [x28, month_r, SXTW 3]	// load the proper month from month array

	mov	w2, day_r			// load the day into w2 for printing
	mov	x4, year_r			// load the year into x4 for printing

	adrp	x0, fmt				// load the print string for the date
	add	x0, x0, :lo12:fmt		// load the lower 12 bits of x0
	bl	printf

end:	mov	w0, 0				// return 0
	ldp	x29, x30, [sp], 16		// deallocate 16 bytes
	ret					// return




	// PRINT ERROR FUNCTION
print_error:	
	bl	printf				// print the string
	b	end				// jump to end of the program
