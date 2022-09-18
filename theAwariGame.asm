################################################################################################################################################# 
# Program: Project: Awari Game  Programmer: Andrew Kim
# Due Date: Dec 2, 2021    Course: CS2640
#################################################################################################################################################
# Overall Program Functional Description:
# This program is to play The Awari Game. You will select from a series of pits(0-5).
# Starting with 3 beans and zero for your home pit the goal is to gather as many beans as possible.
# The game is over only if either your pits or the cpu's pit are empty.
# You can also capture if the last bean goes into an empty pit and the opposite
# side of the board has beans in them. All the beans including the last one and opposite side goes to home pit.
# Only one addition turn is rewarded if the last bean is placed in home pit per turn.
################################################################################################################################################
# Pseudocode Description: 
# 1. First I will ask the user to input a seed number and if the user inputs a zero, I will use a default number.
# 2. Then, I prepare and set up the board filling everything except the player home pit(array number 24) and the cpu home pit(array number 52) 
# 3. Once that is set up I ask the user to input a number 0-5. If the user input an invalid number, ask the user to try again.
# 4. I will also have to check if that array element "pit" has beans in them. If it is empty, make user pick another pit.
# 5. An extra turn will be rewarded if the last bean was placed on the player home pit.
# 6. Beans will also be captured if the last bean placed was an empty pit and if the pit opposite to it has bean(s) in them.
# 7. For the cpu side, it is basically the same thing but we utilize the rand function to produce "random" numbers for the cpu to pick.
# 8. The cpu will pick again if the pit selected was empty. The cpu will also get and extra turn and capture beans if the conditions are met.
# 9. End the program.
# I will give a brief description of what these functions do, I go more indepth in the acutual function.

# prepareboard 
# This function will simply fill in the board with thress and leave the player's and cpu's home pits empty.

# printValues:
# I first start by printing the cpu's side of the board. Then on the next line I print out the home pits. Finally, I then print out player's side of the board.

# playerMove:
# asks for user input and checks if it is valid.

# capturedPlayer:
# I first check if player landed in an empty pit. Then check if we landed on either home pits. If we did we do not want to capture anything.
# Afterward I find out which pit it landed on. Then check if the corresponding opposite side has any values. If it does, take those beans and the one we just
# placed, into the home pit.

# gameOver:
# gameOver will add all the elements from 0-5. If the sum turns out to be zero, then we know we had completely emptied out player's side.

# cpuMoves
# Using the rand function from Chuck a Luck, we will get random numbers. With that the same logic will be applied as the player's move for cpu's turn.

# capturedCPU
# The same logic as capturedPlayer will be used. However, this time we will save to 54($t0), which is the home pit for cpu.

# gameOver2
# the same logic is applied here, but this time we are adding from pits 7-12.
###############################################################################################################################################
.data
	array: .space 56 #making space for 14 digits.
	message: .asciiz "\nNow playing Awari!\n\n"
	
	win: .asciiz "Congratulations. You win!\n\n"
	lose: .asciiz "Computer wins. You lose.\n\n"
	tie: .asciiz "You tied.\n\n"
	endMesssage: .asciiz "Thanks for playing."
	
	newLine: .asciiz "\n"
	space: .asciiz " "
	threeSpace: .asciiz "   "
	bigSpace: .asciiz "               "
	
	playerInput: .asciiz "Select a pit number(0-5): "
	errorInput: .asciiz "Invalid input. You must pick from your pit (0-5).\n"
	nobeans: .asciiz "That is an empty bit, try again.\n"
	cpuInput: .asciiz "The computer picked from pit: "
	
	secondTurn: .asciiz "Landed in home pit. Second Turn Granted!\n"
	
	playerCapturedBeans: .asciiz "You have captured beans!\n"
	CPUCapturedBeans: .asciiz "Computer has captured beans!\n"
	
	playersPitEmpty: .asciiz "Player pits are now empty, Game has ended. \n"
	cpusPitEmpty: .asciiz "CPU pits are now empty, Game has ended. \n"
	
	rng: .asciiz "Enter a seed number: "
	playerAmount:.asciiz" You had: "
	cpuAmount: .asciiz" Cpu had: "
.align 2

		
seed: .word 31415
.globl main
.text
main:
	# initializing the array and t1 as zero and t2 as 3.
	la $t0, array #initializing the array
	li $t1, 0 #here t1 will be used as a counter
	li $t2, 3 #starting game number.
	
    	li $v0, 4
    	la $a0, rng
    	syscall  #Asks the user to input a value for random number generator.
    	
    	li $v0, 5
    	syscall #Gets the user input for random number generator.
    	beqz $v0, seedError #this subroutine will trigger if the user inputted zero for their seed value. The preset value of 31415 will be used instead.

seedReturn: #This is used to comeback if user input was 0 for seed.
    	move $a0, $v0 # now saving the seed value into a0 to be used in the rand function.
    	jal seedrand #Storing the seed to be used in the rand function.    
    			
	li $v0, 4
    	la $a0, newLine
    	syscall
    	
	li $v0, 4
    	la $a0, message
    	syscall
    	
	jal prepareboard
	jal printValues

loop:
	jal playerMove
	addi $s6, $t0, -4#Once we come back from player move, the pointer goes one additional space when it comes back.
			  #here we iterate back and save into s6.
	jal printValues
	jal capturedPlayer
	jal gameOver
	
	la $t2, array #here I am repurposing t2 to initalized an array
	addi $t2, $t2, 24 #here we are now pointing to 6th array space.
	beq $s6, $t2, extraPlayerTurn# if last bean was not in player home pit, go to cpuTurn
	j cpuTurn
extraPlayerTurn:
	li $v0, 4
    	la $a0, secondTurn
    	syscall 
    	
	jal playerMove
	addi $s6, $t0, -4#Once we come back from player move, the pointer goes one additional space when it comes back.
			  #here we iterate back and save into s6.
	jal printValues
	jal capturedPlayer
	jal gameOver

cpuTurn:
	jal cpuMoves
	addi $s6, $t0, -4 #this is the same process as the player array space.
	jal printValues
	jal capturedCPU
	jal gameOver2
	
	la $t2, array #here I am repurposing t2 to initalized an array
	addi $t2, $t2, 52 #here we are now pointing to 6th array space.
	beq $s6, $t2, extraCPUTurn#checks if cpu landed on cpu's home pit.
	j loop
extraCPUTurn:
	li $v0, 4
    	la $a0, secondTurn
    	syscall 
    	
	jal cpuMoves
	addi $s6, $t0, -4 #this is the same process as the player array space.
	
	jal printValues
	jal capturedCPU
	jal gameOver2	

	j loop

prepareboard:
	beq $t1, 6, prepareboardskip #this is to leave our home pit array #6 empty
	beq $t1, 13, prepareboardEnd # 13 because this will leave cpu pit #14 empty
	sw $t2, 0($t0)
prepareboardskip:	
	addi $t0, $t0, 4 #points to the next array
	addi $t1, $t1, 1 #t1 is being used as a counter to know when to break out of the loop
	j prepareboard
	
prepareboardEnd:
	jr $ra
	
printValues:
	li $t1, 0 #resetting the counter
	la $t0, array#making the array point back the the very start
	li $v0, 4
    	la $a0, threeSpace
    	syscall
loopCPU:#printing the cpu's side of the board
	beq $t1, 6, outofCPU
    	lw $t2, 48($t0)
    	
    	li $v0, 1 #prints stuff from the array
	move $a0, $t2
	syscall
    	
    	li $v0, 4
    	la $a0, space
    	syscall
    	
    	add $t1, $t1, 1 #adding 1 so we know when to exit the loop
    	addi $t0, $t0, -4 #here we are iterating down the array
    	j loopCPU
outofCPU:   	
	li $v0, 4
    	la $a0, newLine
    	syscall	
	
homePit:#printing the home pits for player and cpu
	la $t0, array #making the array point back the the very start
    	lw $t2, 52($t0)	
    	li $v0, 1 #prints CPU home pit.
	move $a0, $t2
	syscall

	li $v0, 4
    	la $a0, bigSpace
    	syscall
    	
	lw $t2, 24($t0) 				
	li $v0, 1 #prints Player home pit.
	move $a0, $t2
	syscall

	li $v0, 4
    	la $a0, newLine
    	syscall	
	
printPlayer:#printing player's side of the board
	la $t0, array
	li $t1, 0 #resetting the counter

	li $v0, 4
    	la $a0, threeSpace
    	syscall	
loopPlayer:
	beq $t1, 6, outofPlayer#makes sure we are only in 0-5 array elements.
    	lw $t2, ($t0)
    	
    	li $v0, 1 #prints stuff from the array
	move $a0, $t2
	syscall
	
    	li $v0, 4
    	la $a0, space
    	syscall
    	
    	add $t1, $t1, 1 #adding 1 so we know when to exit the loop
    	addi $t0, $t0, 4 #pointing to the next array space
	j loopPlayer
outofPlayer:
	li $v0, 4
    	la $a0, newLine
    	syscall
    	li $v0, 4
    	la $a0, newLine
    	syscall
    	
	jr $ra	
	
playerMove:
	li $t2, 4 #changing t2 to equal to 4 so we can multiply 4 with user input to find the correct array space
	li $v0, 4
    	la $a0, playerInput
    	syscall
    	
	li $v0, 5
    	syscall
    	
    	move $t3, $v0 # using t3 for a different purpose here, saving user input
    	blt $t3, $zero, inputError #checking if user input was valid
	bgt $t3, 5, inputError
	
	la $t0, array  
	mul $t3, $t3, $t2#since numbers are spaced out by 4 in the array, we want to multiply by 4 to get to the correct array space
	
	add $t0, $t0, $t3#moves the pointer to where t3 is pointing to
	lw $t4, ($t0)#taking all the beans and placing it into t4
	beqz $t4, emptyPit #this checks if player is picking from an empty pit
	sw $zero, ($t0)#pit is now empty

addingPlayerBeans:
    	addi $t0, $t0, 4#pointing to next pit
    	beqz $t4, outofPlayerBeans# this will count how many times we have to go around the pit.
	lw $t5, ($t0) #t5 will be used to add one to the pit.
    	add $t5, $t5, 1 #adding one bean to the current array space
    	sw $t5, ($t0)
    	sub $t4, $t4, 1# here we are keeping track how many beans we have left
    	j addingPlayerBeans
outofPlayerBeans:
	jr $ra
	
inputError:
	li $v0, 4
    	la $a0, errorInput
    	syscall
	j playerMove
	
emptyPit:
	li $v0, 4
    	la $a0, nobeans
    	syscall
	j playerMove
	
cpuMoves:
	li $v0, 4
    	la $a0, cpuInput
    	syscall
	
	li $s2, 4 #using s2 to save the value 4 so we can multiply and divide later.
	move $s3, $ra #saving the ra to s3
again:
	jal rand
	move $t6, $v0 	#Getting the a number and storing it to t6.

	la $t0, array #making the pointer point to the start of the array
	mul $a0, $t6, $s2#multiplying to we point to the correct array space
	addu $t0, $t0, $a0 #points to that array space.
	
	lw $t4, ($t0)#loading in the value and placing it into t4
	beqz $t4, again #this checks if cpu is picking from an empty pit
	
	li $v0, 1
    	move $a0, $t6
    	syscall
    	
    	li $v0, 4
    	la $a0, newLine
    	syscall
    	
	sw $zero, ($t0)#pit is now empty
	la $t2, array #using t2 here to initalize an array to check if we are out of bounds.
	addi $t2, $t2, 56#check if it is in the last element
addingCPUBeans:
    	addi $t0, $t0, 4#pointing to next pit
    	beqz $t4, outofCPUBeans# this will count how many times we have to go around the pit.
    	beq $t0, $t2, loopback
    	
	lw $t7, ($t0) #$t7 will be used to add one to the pit on the CPU side.
    	add $t7, $t7, 1 #adding one bean to array space
    	sw $t7, ($t0)
    	sub $t4, $t4, 1#keeping track how many beans we have left
    	j addingCPUBeans
    	
loopback:
	la $t0, array #pointing to the start of the array
startingAgain:
    	beqz $t4, outofCPUBeans
	lw $t7, ($t0) #$t7 will be used to add one to the pit on the CPU side.
    	add $t7, $t7, 1
    	sw $t7, ($t0)
    	sub $t4, $t4, 1# same process as the top
    	addi $t0, $t0, 4   	
    	j startingAgain
    	
outofCPUBeans:
	move $ra, $s3
	jr $ra



capturedPlayer:
	li $t2, 1
	li $s0, 4 # saving s0 as 4 so we can divide and multiply later
	lw $s5 ($s6) #using s6 when we saved it earlier from main
	bne $t2, $s5, capturedPlayerEnd#checks if the last pit is not equal to one bean.
	la $t0, array
	addi $t0, $t0, 24# pointing to player home pit
	beq $t0, $s6, capturedPlayerEnd# checks if this is in the home pit for player, we will just skip it.

	addi $t0, $t0, 28 #now we are pointing to cpu home pit
	beq $t0, $s6, capturedPlayerEnd# checks if this is in the home pit in the cpu side, if we are we will just skip it.
	la $t0, array
	sub $s4, $s6, $t0 #subtracting with current array element with base array so we can calculate the actual pit number when we divide by 4
	div $s4, $s0
	mflo $s4#saving divided number to s4
	
	# here we will be testing which pit we landed in, and branch to the corresponding opposite pit.
	beqz $s4,capturePlayer0	
	beq $s4,$t2,capturePlayer1
	
	li $t2, 2
	beq $s4,$t2,capturePlayer2
	
	li $t2, 3
	beq $s4,$t2,capturePlayer3
	
	li $t2, 4
	beq $s4,$t2,capturePlayer4
	
	li $t2, 5
	beq $s4,$t2,capturePlayer5
	
	li $t2, 7
	beq $s4,$t2,capturePlayer7
	
	li $t2, 8
	beq $s4,$t2,capturePlayer8
	
	li $t2, 9
	beq $s4,$t2,capturePlayer9
	
	li $t2, 10
	beq $s4,$t2,capturePlayer10
	
	li $t2, 11
	beq $s4,$t2,capturePlayer11
	
	li $t2, 12
	beq $s4,$t2,capturePlayer12
	
	j capturedPlayerEnd
	
capturePlayer0:# the same logic will be applied throughout capture function
	lw $s0, 48($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1 #adding one from the last bean placement to empty pit.
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit.
	
	sw $t2, 24($t0)
	
	sw $zero, 48($t0)
	sw $zero, ($t0)
	
	j capturePlayerPrint

capturePlayer1:
	lw $s0, 44($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1 #adding one from the last bean placement to empty pit.
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit
	
	sw $t2, 24($t0)
	
	sw $zero, 44($t0)
	sw $zero, 4($t0)
	
	j capturePlayerPrint  	

capturePlayer2:
	lw $s0, 40($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1#adding one from the last bean placement to empty pit.
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit
	
	sw $t2, 24($t0)
	
	sw $zero, 40($t0)
	sw $zero, 8($t0)
	
	j capturePlayerPrint
    	
capturePlayer3:#looking at pit 3 and the pit 9
	lw $s0, 36($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1#adding one from the last bean placement to empty pit
	add $t2, $t2, $s0#getting the opposite board beans and adding it to player home pit
	
	sw $t2, 24($t0)
	
	sw $zero, 36($t0)
	sw $zero, 12($t0)
	
	j capturePlayerPrint
    	
capturePlayer4:#looking at pit 4 and the pit 8
	lw $s0, 32($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1#adding one from the last bean placement to empty pit
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit
	
	sw $t2, 24($t0)
	
	sw $zero, 32($t0)
	sw $zero, 16($t0)
	
	j capturePlayerPrint
    	
capturePlayer5:#looking at pit 5 and the pit 7
	lw $s0, 28($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1# and so on
	add $t2, $t2, $s0# this will continue until the 12th pit.
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 28($t0)
	sw $zero, 20($t0)
	
	j capturePlayerPrint  

capturePlayer7:#looking at pit 7 and the pit 5
	lw $s0, 20($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 28($t0)
	sw $zero, 20($t0)
	
	j capturePlayerPrint   	   	
 
capturePlayer8:#looking at pit 8 and the pit 4
	lw $s0, 16($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 32($t0)
	sw $zero, 16($t0)
	
	j capturePlayerPrint
    	    	   	    	   	
capturePlayer9:#looking at pit 9 and the pit 3
	lw $s0, 12($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 36($t0)
	sw $zero, 12($t0)
	
	j capturePlayerPrint
	    	
capturePlayer10:#looking at pit 10 and the pit 2
	lw $s0, 8($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 40($t0)
	sw $zero, 8($t0)
	
	j capturePlayerPrint
    	
capturePlayer11:#looking at pit 11 and the pit 1
	lw $s0, 4($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 44($t0)
	sw $zero, 4($t0)
    	j capturePlayerPrint 

   	    	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	
capturePlayer12:#looking at pit 12 and the pit 0
	lw $s0, ($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 24($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 24($t0)#home pit
	
	sw $zero, 48($t0)
	sw $zero, ($t0)
	
capturePlayerPrint:
	li $v0, 4
    	la $a0, playerCapturedBeans
    	syscall
    	
    	move $s3, $ra #saving the ra to s3
    	jal printValues
    	move $ra, $s3 #saving the ra to s3  	 	    	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	   	    	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	   	    	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	
capturedPlayerEnd:
	jr $ra	
	
	
	
capturedCPU:
	li $t2, 1
	li $s0, 4
	lw $s5 ($s6)
	bne $t2, $s5, capturedPlayerEnd#checks if the last pit is not equal to one bean.
	la $t0, array
	addi $t0, $t0, 24
	beq $t0, $s6, capturedPlayerEnd# checks if this is in the home pit for player, we will just skip it.

	addi $t0, $t0, 28
	beq $t0, $s6, capturedPlayerEnd# checks if this is in the home pit in the cpu side, if we are we will just skip it.
	la $t0, array
	sub $s4, $s6, $t0 #subtracting the current address to the base address so we can get the acutal pit number when we divide by 4
	div $s4, $s0 # dividing by 4 to get the acutual pit number.
	mflo $s4 #saving the pit number to s4
	
	# here we will be testing which pit we landed in, and branch to the corresponding opposite pit
	beqz $s4,capturecpu0	
	beq $s4,$t2,capturecpu1
	
	li $t2, 2
	beq $s4,$t2,capturecpu2
	
	li $t2, 3
	beq $s4,$t2,capturecpu3
	
	li $t2, 4
	beq $s4,$t2,capturecpu4
	
	li $t2, 5
	beq $s4,$t2,capturecpu5
	
	li $t2, 7
	beq $s4,$t2,capturecpu7
	
	li $t2, 8
	beq $s4,$t2,capturecpu8
	
	li $t2, 9
	beq $s4,$t2,capturecpu9
	
	li $t2, 10
	beq $s4,$t2,capturecpu10
	
	li $t2, 11
	beq $s4,$t2,capturecpu11
	
	li $t2, 12
	beq $s4,$t2,capturecpu12
	
	j capturedCPUEnd
	
capturecpu0:
	lw $s0, 48($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)# cpu home pit
	addi $t2, $t2, 1 #adding one from the last bean placement to empty pit
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit
	
	sw $t2, 52($t0)
	
	sw $zero, 48($t0)
	sw $zero, ($t0)
	
	j captureCPUPrint

capturecpu1:
	lw $s0, 44($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)# cpu home pit
	addi $t2, $t2, 1#adding one from the last bean placement to empty pit
	add $t2, $t2, $s0 #getting the opposite board beans and adding it to player home pit
	
	sw $t2, 52($t0)
	
	sw $zero, 44($t0)
	sw $zero, 4($t0)
	
	j captureCPUPrint  	

capturecpu2:
	lw $s0, 40($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)
	addi $t2, $t2, 1 # adding one from the last bean placement to empty pit
	add $t2, $t2, $s0#getting the opposite board beans and adding it to player home pit
	
	sw $t2, 52($t0)
	
	sw $zero, 40($t0)
	sw $zero, 8($t0)
	
	j captureCPUPrint
    	
capturecpu3:#looking at pit 3 and the pit 9
	lw $s0, 36($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)
	addi $t2, $t2, 1 # the process will continue on to the 0th pit
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)
	
	sw $zero, 36($t0)
	sw $zero, 12($t0)
	
	j captureCPUPrint
    	
capturecpu4:#looking at pit 4 and the pit 8
	lw $s0, 32($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)
	
	sw $zero, 32($t0)
	sw $zero, 16($t0)
	
	j captureCPUPrint
    	
capturecpu5:#looking at pit 5 and the pit 7
	lw $s0, 28($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit
	
	sw $zero, 28($t0)
	sw $zero, 20($t0)
	
	j captureCPUPrint  

capturecpu7:#looking at pit 7 and the pit 5
	lw $s0, 20($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit
	
	sw $zero, 28($t0)
	sw $zero, 20($t0)
	
	j captureCPUPrint   	   	
 
capturecpu8:#looking at pit 8 and the pit 4
	lw $s0, 16($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit
	
	sw $zero, 32($t0)
	sw $zero, 16($t0)
	
	j captureCPUPrint
    	
    	    	   	    	   	
capturecpu9:#looking at pit 9 and the pit 3
	lw $s0, 12($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit
	
	sw $zero, 36($t0)
	sw $zero, 12($t0)
	
	j captureCPUPrint
	    	
capturecpu10:#looking at pit 10 and the pit 2
	lw $s0, 8($t0) 
	beqz $s0, capturedPlayerEnd#checking if there are beans in pit 2
	lw $t2, 52($t0)#home pit
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit
	
	sw $zero, 40($t0)
	sw $zero, 8($t0)
	
	j captureCPUPrint
    	
capturecpu11:#looking at pit 11 and the pit 1
	lw $s0, 4($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)#home pit for cpu
	addi $t2, $t2, 1
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#home pit saving new value into the home pit
	
	sw $zero, 44($t0)
	sw $zero, 4($t0)
    	j captureCPUPrint 

   	    	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	    	    	    	   	    	   	    	   	    	   	    	    	   	    	   	    	   	    	   	
capturecpu12:#looking at pit 12 and the pit 0
	lw $s0, ($t0)
	beqz $s0, capturedPlayerEnd
	lw $t2, 52($t0)#home pit
	addi $t2, $t2, 1 #adding one because we are taking the one bean that landed on an empty pit.
	add $t2, $t2, $s0
	
	sw $t2, 52($t0)#saving new value to cpu home pit
	
	sw $zero, 48($t0)
	sw $zero, ($t0)
	
    	
captureCPUPrint:
	li $v0, 4
    	la $a0, CPUCapturedBeans
    	syscall
    	
    	move $s3, $ra #saving the ra to s3 before going to jal printValues
    	jal printValues
    	move $ra, $s3 #saving the ra to s3  
    	
    	
capturedCPUEnd:
	jr $ra


gameOver:
	la $t0, array#resetting the array pointer
	li $t1, 0 #resetting the counter
	li $t9, 0 #t9 will be used to hold the sum of all players beans.
playerZero:
	beq $t1, 6, outPlayerZero
	lw $t8, ($t0) #t8 will be used to determine if all the player pits are empty
	
	add $t9, $t8, $t9 #adding each pit from player side
	addi $t0, $t0, 4 #pointing to the next element
	addi $t1, $t1, 1#adding by two because we are iterating by two array numbers 
	
	j playerZero
outPlayerZero:
	beqz $t9, endPlayer# t9 holds the sum of all the player pits, if zero, show end prompt
	jr $ra
	
	
gameOver2:
	la $t0, array#resetting the array pointer 
	li $t1, 0 #resetting the counter
	li $t9, 0 #will hold the sum of all the numbers of cpu pit. We are also resetting the value.
	addi $t0, $t0, 28 # this will point to pit number 7
cpuZero:
	beq $t1, 6, outCPUZero
	lw $t8, ($t0) #t8 will be used again to determine if all the player pits are empty
	
	add $t9, $t8, $t9 #using t9 this time to sum up cpu beans in each pit
	addi $t0, $t0, 4 #pointing to the next element
	addi $t1, $t1, 1#adding by two because we are iterating by two array numbers 
	
	j cpuZero
outCPUZero:
	beqz $t9, endCPU #if all the pits add up to zero, that means all the pits are empty, so we exit out.
	jr $ra


rand: #using the same function as the Chuck a Luck to get the random numbers.
	lw $v0, seed #use the seed number either from user or the preset.
	sll $t2, $v0, 13
	xor $v0, $v0, $t2
	srl $t2, $v0, 17# Compute $v0 ^= $v0 >> 17
	xor $v0, $v0, $t2
	sll $t2, $v0, 5# Compute $v0 ^= $v0 << 5
	xor $v0, $v0, $t2 
	sw $v0, seed# Save result as next seed
	
	andi $v0, $v0, 0xFFFF
	li $t2, 6
	div $v0, $t2
	mfhi $v0 #take the remainder, then increment
	addi $v0, $v0, 7#Adding 7 will make the results between 7-12. Previously it was 0-5.
	jr $ra
seedrand: 
	sw $a0, seed #saving the seed number into a0
	jr $ra
seedError:
	lw $v0, seed #preset value is now being used as the seed.
	j seedReturn
	
endPlayer:
	li $v0, 4
    	la $a0, playersPitEmpty
    	syscall
	j done
endCPU:
	li $v0, 4
    	la $a0, cpusPitEmpty
    	syscall 
	
done:
	la $t0, array
	addi $t0, $t0, 24
	lw $s0, ($t0) #here we will now begin comparing the amount of player's home pit beans by storing it to s0 and...
	
	addi $t0, $t0, 28 # here we will point to the cpu home pit
	lw $s1, ($t0)#...then we will use s1 to hold total amount in cpu home pit
	
	beq $s0, $s1, tied
	blt $s0, $s1, cpuWin
	bgt $s0, $s1, playerWin
tied:
	li $v0, 4
    	la $a0, tie
    	syscall
    	j end
cpuWin:
	li $v0, 4
    	la $a0, lose
    	syscall
    	j end
playerWin:
	li $v0, 4
    	la $a0, win
    	syscall
end:
	li $v0, 4 #Prints "You Had:"
    	la $a0, playerAmount
    	syscall 
    	
    	li $v0, 1 
	move $a0, $s0 #using s0 from ealier to print the amount
	syscall
    	
    	li $v0, 4
    	la $a0, newLine
    	syscall 
    	
    	li $v0, 4#Prints "CPU Had:"
    	la $a0, cpuAmount
    	syscall 
	
	li $v0, 1 
	move $a0, $s1 #using s1 from ealier to print the amount
	syscall
	
	li $v0, 4
    	la $a0, newLine
    	syscall 
    	
	li $v0, 4
    	la $a0, endMesssage
    	syscall 
	
	li $v0, 10
	syscall	
