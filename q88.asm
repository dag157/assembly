.text
loop: 	beq $t9, $zero, loop

	add $s0, $zero, $a0
	add $s1, $zero, $a1
	#addition
	add $s2, $s0, $s1
	#subtraction
	sub $s3, $s0, $s1
	#prepare results in $v0 A + B | A-B
	add $v0, $zero, $s3
	sll $v0, $v0, 16
	andi $s2, $s2, 0xffff
	or $v0, $v0, $s2
	#multiplication
	add $s0, $zero, $zero		#clear all registers
	add $s1, $zero, $a0
	add $s2, $zero, $a1
	add $s3, $zero, $zero
	add $t3, $zero, $zero
	add $t7, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	add $s4, $zero, $zero
	
	
	bltz $s1, fixneg		#checks is input a is negative
	bltz $s2, fixeNegTwo		#checks if input b is negative
	
	fixneg:
		sub $s1, $zero, $s1	#makes a positive
		addi $t8, $zero, 1 	#adds to negative counter
		bltz $s2, fixeNegTwo	#if input b is negative we got that too
		bge $s2, 0, multiplye	#if not just multiply
		
	fixeNegTwo:
		sub $s2, $zero, $s2	#make input b positive
		addi $t8, $t8, 1	#add to negative counter
	
	multiplye:				#s3 is gonna be the total $t3 is the count
		beq $t3, 16, FinalStep		#when the iteration is done to print
		
		addi $s0, $zero, 1		#mask
		srlv $t7, $s2, $t3		#shift second number to the right
		and $t5, $s0, $t7		#make sure t4 is equal to something
		beq $t5, $zero, zeroAdd		#branch
		sllv $t6, $s1, $t3		#t6 is the value of the shifted but
		add $s4, $s4, $t6		#s4 is the mutlipled value
		addi $t3, $t3, 1		#add 1 to t3 for while loop
		j multiplye			# loop multiply until t3 equals 4
		
		
	zeroAdd:
		
		add $s4, $s4, $zero		#if zero add nothing essentially
		addi $t3, $t3, 1		#add 1 to the counter
		j multiplye			#loop back to multiplye
	#division
	
	FinalStep:
		beq $t8, 0, division		#if two positives do nothing
		beq $t8, 1, changeValueM	#if a negative and psoitve send to make it negative
		beq $t8, 2, division		#if two negatives do nothing

		changeValueM:			#makes value negative
		sub $s4, $zero, $s4
		
		
	
	division:
	add $s0, $zero, $zero		#clear all registers not in use just in case
	add $s1, $zero, $a0
	add $s2, $zero, $a1
	add $s3, $zero, $zero
	add $t3, $zero, $zero
	add $t7, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	add $t8, $zero, $zero
	add $s3, $s2, $s2
	
	bltz $s1, switch 		#if input a is negative go to switch 1
	bltz $s2, switch2		#if input 2 is negative go to switch 2
	bge $s1, $zero, divisionM	#else start dividing
	
	switch:
		sub $s1, $zero, $s1	#make s1 positive in this case
		addi $t6, $t6, 1 	#add 1 to t6
		bltz $s2, switch2	#if s2 is neg go to switch 2
		bgez $s2, divisionM	#if not doesnt matter than
	switch2:
		sub $s2, $zero, $s2	#make s2 postibe
		addi $t6, $t6, 1	#add to $t6
	
	divisionM:				#s3 is gonna be the total $t3 is the count
		
		blt $s1, $s2, zeroAddDiv	#if s1 is less than s2 go to zeroAddDiv
		
		sub $s1, $s1, $s2		#else keep subtracting
		addi $t4, $t4, 1		#then add to t4 aka the count/denominator
		j divisionM
	
	zeroAddDiv:
		
		sll $s1, $s1, 8			#s1 if the remainder now
		#srl $s2, $s2, 8
		beqz $s1, dividevalue		#if s1 is equal to 0 wont matter
		j dividetwo			#if not jump to divide two
	
	dividetwo:
		blt $s1, $s2, dividevalue	#if s1 less than s2 then go to divide value
		beqz $s1, dividevalue		#if $s1 is equal to zero do the same
		sub $s1, $s1, $s2		#subtarct s2 from s1
		addi $t5, $t5, 1		#add to $t5 the decimal place
		j dividetwo
		
		
	dividevalue:
		
		sll $t4, $t4, 8			#move t4 is the elft 8 spaces
		#andi $t4, $t4, 0xffff
		add $t4, $t4, $t5		#add t5 there too
		
		beq $t6, 0, skipChange		#if t6 is equal to 0 skip changes aka no ned
		beq $t6, 2, skipChange		#double negative means cancels out

		changeValue:
		sub $t4, $zero, $t4		#if not subtract to get real negative number
		
		skipChange:
		
	MultDivEntry:
	sra $s4, $s4, 8	#changed a to l
	add $v1, $zero, $t4
	sll $v1, $v1, 16
	#andi $s4, $s4, 0xffff
	or $v1, $v1, $s4
	add $v1, $zero, $zero
	add $v1, $zero, $t4
	sll $v1, $v1, 16
	#andi $s4, $s4, 0xffff
	add $v1, $v1, $s4
	
	add $s0, $zero, $zero			#clear all the registers for good practice
	add $s1, $zero, $zero
	add $s2, $zero, $zero
	add $s3, $zero, $zero
	add $s4, $zero, $zero
	add $s5, $zero, $zero
	add $s6, $zero, $zero
	add $s7, $zero, $zero
	add $t0, $zero, $zero
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	add $t3, $zero, $zero
	add $t7, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	
	
	#square root
	add $s0, $zero, $a0		
	
	
	bgtz $s0, skipNeg	#check if the value in A is negative or posititve
	sub $s0, $zero, $s0  	#if negative make it positive
	
	skipNeg:
	
	isqrt:

 	 	sll   $s0, $s0, 8	  	#move our number to the elft by 8 bits for precision
  		move  $t1, $s0         		#store a0 to t1
 	 	move  $t5, $zero		#store 0 into t5
	
 	 	addi  $t0, $zero, 1		#our divisor
 	 	sll   $t0, $t0, 30      	#shift to second-to-top bit

	sqrtbit:
 		slt   $t2, $t1, $t0    		#num < bit
 		beq   $t2, $zero, sqrtloop	#jump to the sqrt loop if false

  		srl   $t0, $t0, 2       	#shift bit to the right until A is less than the bit
  		j     sqrtbit			#return until true

	sqrtloop:
 		beq   $t0, $zero, sqrtreturnVal

 		add   $t3, $t5, $t0     	#t3 = return value + original bit
 		slt   $t2, $t1, $t3		#if num < this value, loops again
 		beq   $t2, $zero, sqrtelse	#then we would jump to add more decimal places

 		srl   $t5, $t5, 1       	#shift return value to the right 1
 		j     sqrtloopEnd

	sqrtelse:
		sub   $t1, $t1, $t3     	#subtract dividend by total of the return value and the current bit value
 		srl   $t5, $t5, 1       	#shift return value to the right
 		add   $t5, $t5, $t0     	#add the return value to the current bit answer
	
	sqrtloopEnd:
		srl   $t0, $t0, 2       	#sift our bit divisor to the right by 2 
		j     sqrtloop			#loop until precision is complete

	sqrtreturnVal:
  
	add $a2, $zero, $t5			#add the value into a2 reigster to be displayed
	
	add $s0, $zero, $zero			#clear all registers so they dont itnerfer with next iteration
	add $s1, $zero, $zero
	add $s2, $zero, $zero
	add $s3, $zero, $zero
	add $s4, $zero, $zero
	add $s5, $zero, $zero
	add $s6, $zero, $zero
	add $s7, $zero, $zero
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	add $t3, $zero, $zero
	add $t7, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	
	add $t9, $zero, $zero			#allow looping
	j loop
