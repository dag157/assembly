.text
	lui 	$s0, 0xffff		#load upper part
	ori 	$s0, $s0, 0x8000	#load lower part
	addi 	$s1, $zero, 9		#add counter
	add 	$s2, $zero, $zero	#set to 0
	add 	$s3, $zero, $zero	#set to 0
	
outerLoop:

	beq 	$s2, $s1, outerDone	#when whole map is printed we're done
	add 	$s3, $zero, $zero	#s3 is now 0
	
innerLoop:

	beq 	$s3, $s1, innerDone	#when 1st row is done we move on
	lb 	$a0, 0($s0)		#loads value into a0
	addi 	$v0, $zero, 1		#prints int
	syscall				#prints int
	addi 	$s3, $s3, 1		#add 1 to counter
	addi 	$s0, $s0, 1		#adds 1 to sudoku patttern
	j innerLoop			#iterate
	
innerDone:

	addi 	$a0, $zero, 10		#print \n
	addi 	$v0, $zero, 11		#\n
	syscall				#next line
	addi 	$s2, $s2, 1		#add 1 to counter
	j outerLoop			#jumps to next row to print
	
outerDone:

    	add 	$a0, $zero, $zero       # start the first call at 0, remember 81 spaces 0 -80
    	jal    	_solveSodoku            # begin solving
    	
finish:

    	li	    $v0, 10		# end program
   	syscall
    
_solveSodoku:
    					# The main stack
  	addi    $sp, $sp, -20          	# Add some stack space
    	sw      $ra, 16($sp)         	# return address
   	sw      $s3, 12($sp)        	# $s3 register saved
   	sw      $s2, 8($sp)         	# $s2 register saved
  	sw      $s1, 4($sp)         	# $s1 register saved
  	sw      $s0, 0($sp)         	# $s0 register saved

    	add     $s0, $zero, $a0       	# save starting position in s0
    	beq     $s0, 81, solvedSodoku 	# check if we examined enough spaces

    					# Obtain the space's row and column
    	addi    $s3, $zero, 9           # s3 is the size of the row, and the column
    	div     $s0, $s3              	# divide the cell by 9 
    	mflo    $s1                   	# s1 is the space's row 
   	mfhi    $s2                   	# s2 is the space's column

    					# Check if the space is a 0 or has a value 1-9
    	lb      $t0, 0xffff8000($s0)   	# $t0 is the value of the space
    	beqz    $t0, inputValue       	# is does not contsain value, start solving
    	addi    $a0, $s0, 1           	# if it does, we move on
    	jal     _solveSodoku            # recursive call
    	j       endSodokuSolver         # finish this call

inputValue:
    					# Check if the value in $s3 is a legal candidate for this cell
    	add 	$a0, $zero, $s3		# a0 = s3 is 9
    	add 	$a1, $zero, $s1		# a1 = s1 = space row number
    	add 	$a2, $zero, $s2		# a2 = s2 = space column number
    	jal     check                 	# check function
    	bnez    $v0, numberFailed 	# result, if v0 = 1 then it failed
    	sb      $s3, 0xffff8000($s0)	# else store the number into s3
   					# Next space
    	addi    $a0, $s0, 1           	# Increase a0
    	jal     _solveSodoku            # recursive call
    	beqz    $v0, endSodokuSolver    # If the final call worked, then we endit

numberFailed:

    	sub     $s3, $s3, 1             # Decrease number to check it
    	bnez    $s3, inputValue       	# make sure it isnt 0
    	sb      $zero, 0xffff8000($s0) 	# if number didnt work put 0 in the space
    	addi 	$v0, $zero, 1
   	j       endSodokuSolver         # Jump to return instructions

solvedSodoku:
    	add    $v0, $zero, $zero        # Return code is 0 (success)

endSodokuSolver:
   					# Take out the stack
    	lw      $s0, 0($sp)           	# Restore s0
    	lw      $s1, 4($sp)          	# Restore s1
    	lw      $s2, 8($sp)         	# Restore s2
    	lw      $s3, 12($sp)        	# Restore s3
    	lw      $ra, 16($sp)        	# Restore ra
    	addi    $sp, $sp, 20        	# add space back to stack
    	jr      $ra                 	# finish and return
    
check:
    					# Row check
    	addi	$t0, $zero, 9
    	add	$t4, $zero, 1
    	mul     $t1, $a1, $t0         	# grab the beginning spac ein the row
    	
_checkRow:

    	lb      $t2, 0xffff8000($t1)   	# Value of space
   	beq     $a0, $t2, numAlreadyPresent  # check if the number already exists
    	addi    $t1, $t1, 1           	# next cell
    	addi	$t4, $t4, 1
    	bne	$t4, 10, _checkRow
    					# Column check
    	add	$t1, $zero, $a2		#grab first space in the column
    	add	$t4, $zero, 1		# add one to iterate
    	
_checkColumn:

    	lb      $t2, 0xffff8000($t1)   	# Value of space
    	beq     $a0, $t2, numAlreadyPresent  # check if the number already exists
    	addi	$t4, $t4, 1
    	addi    $t1, $t1, 9           	# next cell
    	bne	$t4, 10, _checkColumn
					# set up subgrid check
    	div     $t0, $a1, 3           	# $t0 = row / 3
   	mul     $t0, $t0, 27          	# finds which row to start at
    	div     $t1, $a2, 3           	# $t1 = column / 3
    	mul     $t1, $t1, 3           	# colmun offset
    	add     $t1, $t0, $t1         	# first cell in the subgrud
	addi	$t3, $zero, 3		# count column
	addi	$t0, $zero, 3		# count row
    	
_checkSubgrid:

    	lb      $t2, 0xffff8000($t1)   	# Value of the current cell
    	beq     $a0, $t2, numAlreadyPresent  # Number already present in column
    	sub     $t3, $t3, 1           	# Decrement the column counter
    	beq   	$t3, 0, nextSubRow      # Check if end of current box row is reached
    	addi    $t1, $t1, 1           	# Increment the pointer to the current cell
    	j       _checkSubgrid           # Check the next cell in the row
    	
nextSubRow:

    	addi    $t1, $t1, 7           	# next cell after a row is done
    	addi    $t3, $zero, 3           # reset counter
    	sub     $t0, $t0, 1           	# decrease to iterate
    	bnez    $t0, _checkSubgrid      # if we finished the last box, check
    	add 	$v0, $zero, $zero	# of so we good success
    	jr      $ra                   	# Return 0

numAlreadyPresent:

    	addi 	$v0, $zero, 1           # failed
    	jr      $ra                   	# Return 1
