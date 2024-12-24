#Taleed Hamadneh 1220006
#Qasim Batrawi 1220204
#section 1
####### Data Segment ########
.data
#C:/Users/ASUS/Desktop/Computer Engineering/Architecture/Project 1/input.txt
#C:/Users/ASUS/Desktop/Computer Engineering/Architecture/Project 1/output.txt
#D:/uni/y3 s1/Architecture ENCS4370/Projects/Equations.txt
#D:/uni/y3 s1/Architecture ENCS4370/Projects/output.txt
filepath: .space 100
enterfilename: .asciiz "Please enter the file path :)\n"
erroropenfile: .asciiz "Error: Can't open the file"
filedata: .space 1024
equation: .space 15 #to store the eq
newline: .asciiz "\n"
welcome: .asciiz "Welcome to our system...\n"
calculate: .asciiz "\nNew System :))) \n Calculating is in progress...\n"
options: .asciiz "Please Choose one option: \n"
Savetofile: .asciiz "Choose f or F to save the result to the output file\n"
screen: .asciiz "Choose s or S to print the result on the screen\n"
errormessage: .asciiz "\nInvalid input...try again\n"
exitsystem: .asciiz "Choose e or E to exit\n"
bye: .asciiz "\nBye Bye"
outputfilename: .asciiz "C:/Users/ASUS/Desktop/Computer Engineering/Architecture/Project 1/output.txt"
resultfile: .asciiz "The result has been saved to the File successfully.\n"
exitmenu: .asciiz "Exited from menu\n"
space: .asciiz " "
nosolution: .asciiz "Can't solve !!.. No solution\n"
equal: .asciiz " = "
buffer: .space 100
firstVar: .space 1
secondVar: .space 1
thirdVar: .space 1
FLOAT: .float 100.0
Point: .asciiz "."
zero: .float 0.0       # Define a floating-point constant in memory
one: .float 1.0       # Define a floating-point constant in memory
negative: .asciiz "-"
negOne: .float -1.0

matrix: .word 0 , 0 , 0 , 0 
	.word 0 , 0 , 0 , 0
	.word 0 , 0 , 0 , 0
	
#used to print string
 .macro printstring (%str)
      li $v0, 4 
      la $a0, %str
      syscall  
 .end_macro 
 	
###### Text segment #######
.text
.globl main
main: 
	printstring(welcome)
	printstring(enterfilename)
	printstring(newline)
        #opeeen fileeeeee
        la $a0, filepath
	li $a1, 100 #length of file path
	li $v0, 8
	syscall 
	la   $t0, filepath    # load address of filepath

	replace_newline: #when the user enter the path, it has \n so replace it with \0
 	 lb   $t1, 0($t0)   #loop to find \n
  	 beq  $t1, 0x0A, replace  #if \n => replace it with \0
   	 addi $t0, $t0, 1      #index++
  	  j    replace_newline  

	replace:
   	 sb   $zero, 0($t0) #Store null terminator '\0' at current position (index)
     	 #prepare for reding
     	 li $a1 ,0 #flag (0 for read)
    	 li $a2 ,0 #mode is ignored in reading
     	 li $v0 ,13 #open file syscall
   	 syscall
	 bltz $v0 ,erroropen
     	 move $s0, $v0 #store the file descriptor
     	 j readFile

erroropen: 
	printstring(newline)
	printstring(erroropenfile)
	printstring(newline) 
        j endprogram #end program
        
readFile:
    #read from file
    move $a0, $s0 #load the file descriptor
    la $a1, filedata #the buffer to store the file data
    la $a2, 1024 #buffer length
    li $v0, 14 #read syscall
    syscall
    # now filedata buffer has the file data
    beq $v0,$zero, endprogram #EOF
    move $s7 , $a1
start:  
    li $s1 , 0  #  *** reinitialize the register that will store the first variable
    li $s2 , 0  #  *** reinitialize the register that will store the second variable
    li $s3 , 0  # *** reinitialize the register that will store the third variable
    li $t1 , 0 # this register will tell me either if there is a number beside the variable or not
    li $t6 , 0 # this will tell my the current row i am at
    li $t7 , 0 # the number to store in matrix
    la $t8 , matrix # address of first element in the matrix
    li $t9 , 0 # sign register
    li $k1 , 0 #  number of variables in the system, so if the number of variables > number of rows, then jump to noSolutuon
    li $k0 , 0 #  this will tell me if noSolution or not, if its 1 then noSolution
    li $t2 , 0
    li $t3 , 0
    li $t4 , 0
    li $t5 , 0
    			
charbychar:
    # s7 now has the file pointer
    
    lb $t0 , 0($s7) # read char from the file, we increment s7 
    
    beqz $t0, endprogram # EOF
    
    beq $t0 , 43 , posSign # char is +
    
    beq $t0 , 45 , negSign # char is -
    
    beq $t0 , 10 , storeInMatrix # char is \n 
    
    beq $t0, 42 , star # if * 
    
    #if its not alpha or star or num => continue reading from the file 
    #else => store in the matrix
    blt $t0 , 48 , incrementPointer # char is not alpha and not number and not star
    bgt $t0 , 123 , incrementPointer # char is not alpha and not number and not star
    #// 48->0 123->z
    ble $t0 , 57 , charIsNumber # char is number // 48 57
    #// 58 123
    blt $t0 , 65 , incrementPointer # char is not alpha and not number and not star // 58 64
    #// 65->A 123->z
    blt $t0 , 91 , storeInMatrix # char is alpha // 65 91 Capital
    #// 92 123    4x+5y+3Z = 12
    bgt $t0 , 96 , storeInMatrix # char is alpha  // 96 123 small
    ble $t0 , 96 , incrementPointer # char is not alpha and not number // 92 95
    
    charIsNumber:
        addi $t0, $t0, -48 # change from char to number
        mul $t7 , $t7 , 10
        add $t7 , $t7 , $t0
        li $t1 , 1 # this register will tell me there is a number beside the variable
    
    incrementPointer:    #continue reading
        addi $s7 , $s7 , 1
        j charbychar
    
posSign: 
    xor $t9 , $t9 , 0 # if $t9 is 0, then the next number is positive
    j incrementPointer

negSign: 
    xor $t9 , $t9 , 1 # if $t9 is 1, then the next number is negative
    j incrementPointer

star: 
    printstring(calculate)
    
    la $t0, buffer        # Load the address of the buffer into $t0
    li $t1, 100           # Set the size of the buffer (100 bytes)

   clear_buffer: #clear the buffer between the system and the other
   	sb $zero, 0($t0)      # Store 0x00 (null) in the current byte
   	addi $t0, $t0, 1      # Move to the next byte
   	subi $t1, $t1, 1      # Decrement the counter
   	bgtz $t1, clear_buffer # Repeat until all 100 bytes are cleared
    	
    j menu
   	        
storeInMatrix: #when alpha or number
    j checkVariable
    returnToStore2:
        beq $t1 , 0 , setToOne # the variable has no number beside it, so we will set $t7=1
    returnToStore1:
        beq $t9 , 1 , changeToNeg #if there is a negative sign
    returnToStore:    
        sw $t7 , 0($t8) #store in the matrix
        li $t7 , 0 # reset the number
        li $t9 , 0 # reset the sign
        li $t1 , 0 # reset
        j incrementPointer
        
checkVariable: #to know where to store in the matrix
    beq $t0 , 10 , pointerToLastColumn # char is \n
    beq $t0 , $s1 , pointerToFirstColumn #x was found before
    beq $t0 , $s2 , pointerToSecondColumn #y was found before
    beq $t0 , $s3 , pointerToThirdColumn #z was found before
    beq $s1 , 0 , firstVariableFound # s1 = x #first time of x
    beq $s2 , 0 , secondVariableFound # s2 = y #first time of y
    beq $s3 , 0 , thirdVariableFound  # s3 = z #first time of z
    returnToCheckVariable:
        beq $t0 , $s1 , pointerToFirstColumn
        beq $t0 , $s2 , pointerToSecondColumn
        beq $t0 , $s3 , pointerToThirdColumn
        addi $k1 , $k1 , 1
        
pointerToFirstColumn:
    move $t5 , $t6 # $t6 is the row number, $t5 = $t6
    # $t8 = $t5 * 16 => equation to store in the first column (x)
    
    mul $t5 , $t5 , 16
    la $t3 , matrix
    add $t8 , $t5 , $t3
    
    j returnToStore2
    
pointerToSecondColumn:
    move $t5 , $t6 # $t6 is the row number, $t5 = $t6
    # $t8 = $t5 * 16 + 8 => equation to store in the second column (y)
    
    mul $t5 , $t5 , 16
    addi $t5 , $t5 , 4
    la $t3 , matrix
    add $t8 , $t5 , $t3
    
    j returnToStore2
    
pointerToThirdColumn:
    move $t5 , $t6 # $t6 is the row number, $t5 = $t6
    # $t8 = $t5 * 16 + 8  => equation to store in the third column (z)
    
    mul $t5 , $t5 , 16
    addi $t5 , $t5 , 8
    la $t3 , matrix
    add $t8 , $t5 , $t3
    
    j returnToStore2
    
pointerToLastColumn:

    move $t5 , $t6 # $t6 is the row number, $t5 = $t6
    # $t8 = $t5 * 16 + 12
    # t5 = t6 row number
    # t8 = 16 * t5 + 12
    
    mul $t5 , $t5 , 16
    addi $t5 , $t5 , 12
    la $t3 , matrix
    add $t8 , $t5 , $t3
    
    addi $t6 , $t6 , 1 # we have read '\n', so we have finished the current line
    #t6 stores num of lines (rows)
    j returnToStore2
                
firstVariableFound:
    move $s1 , $t0
    addi $k1 , $k1 , 1  # *** we have found new variable, so increment the register
    #k1 has the num of variables (to handle if #eq is less than #vars) 
    j returnToCheckVariable
    
secondVariableFound:
    move $s2 , $t0
    addi $k1 , $k1 , 1  # *** we have found new variable, so increment the register
    j returnToCheckVariable
    
thirdVariableFound:
    move $s3 , $t0
    addi $k1 , $k1 , 1  # *** we have found new variable, so increment the register
    j returnToCheckVariable    
	
setToOne: #if there is no num beside the var
    li $t7 , 1
    j returnToStore1
    
changeToNeg: #if there is negative
    mul $t7 , $t7 , -1
    j returnToStore
       
menu:
     bgt $k1 , $t6 , noSolution #  if the number of variables greater than number of lines, the jump to no solution 
    #it sets k0 = 1
     backmenu:
        printstring(newline)
        printstring(options)
     	printstring(screen)
     	printstring(Savetofile)
     	printstring(exitsystem)
 	 
 	li $t1,83 #S
 	li $t2,115 #s
 	li $t3,70 #F 
 	li $t4,102 #f
 	li $t5,101 #e
 	li $t7,69 #E 
 	   
 	printstring(newline)
 	 
 	li $v0, 12 #read char
 	syscall
 	 
 	move $t0, $v0 #save the char
 	
 	lwc1 $f30, one          # Directly load 1.0 into $f30
 	lwc1 $f28, zero          # Directly load 0.0 into $f28
 	#to know if the buffer will be printed on the screen or on the file
 	#if f30 = f28 => screen
 	#f30!=f28 =>file
 	 
 	printstring(newline)
 	 
 	beq $t0, $t1 printonscreen
 	beq $t0, $t2 printonscreen
 	beq $t0, $t3 savetofile
 	beq $t0, $t4 savetofile
 	beq $t0, $t5 exitfrommenu
 	beq $t0, $t7 exitfrommenu
	 
	j invalidinput #any other char

savetofile:
      
      printstring(newline)
      printstring(resultfile)
      printstring(newline)	
      
      beq $k0,1,nosol_file #if there is no solution (divide by zero, or vars > eq
      
      beq $t6 , 3 , CRAMER_BEGIN_3x3 #3 rows => 3x3
      beq $t6 , 2 , CRAMER_BEGIN_2x2 #2 rows => 2x2
      
   printtofile:	 
      # open the file
      la $a0 ,outputfilename #defined above
      li $a1 ,1 #flag (1 for write)
      li $a2 ,0 #mode is ignored in reading
      li $v0 ,13 #open file syscall
      syscall
      
      # write on file
      move $s0, $v0
      li $v0, 15    
      move $a0, $s0    #file descriptor
      la $a1, buffer #result
      li $a2, 100 #result length         
      syscall
      #close the file
      move $a0, $s0
      li $v0, 16
      syscall
       
      j menu
      
nosol_file:
      # open the file
      la $a0 ,outputfilename #defined above
      li $a1 ,1 #flag (1 for write)
      li $a2 ,0 #mode is ignored in reading
      li $v0 ,13 #open file syscall
      syscall 
	
       #write on the file	
       move $s0, $v0
       li $v0, 15    
       move $a0, $s0    #file descriptor
       la $a1, nosolution #result
       li $a2, 31 #result length         
       syscall
       
       #close the file
       move $a0, $s0
       li $v0, 16
       syscall
       j menu
		
printonscreen:
 	 lwc1 $f30, zero          # Directly load 0.0 into $f30
 	 #now $f28 = $f30 => print on screen
         printstring(newline)
	 beq $k0,1,nosol_screen
	 beq $t6 , 3 , CRAMER_BEGIN_3x3 #3 rows => 3x3
	 beq $t6 , 2 , CRAMER_BEGIN_2x2 #2 rows => 2x2
	 PRINT:
	 	printstring(buffer) #on screen
	 	j backmenu
	
nosol_screen:
	printstring(nosolution)
	j menu	
	
exitfrommenu:
        printstring(newline)
        printstring(exitmenu) 
        addi $s7 , $s7 , 1 
        la $t0, matrix
        li $t1, 0 #index
        li $t2,12 #no of elements
        loop:
        beq $t2,0,start #empty the matrixxxx between systems
        sw $t1, 0($t0)
        addi $t0,$t0,4
        addi $t2,$t2,-1
        j loop
       
CRAMER_BEGIN_3x3:

	# we have the following equations:
	#	a1X + b1Y + c1Z = d1
	#	a2X + b2Y + c2Z = d2
	#	a3X + b3Y + c3Z = d3
	
	la $t0 , matrix  # load the address of the 1st element in the matrix
	
	lw $t1 , 0($t0)  # a1
	lw $t2 , 4($t0)  # b1
	lw $t3 , 8($t0)  # c1
	lw $t4 , 12($t0) # d1
	lw $t5 , 16($t0) # a2
	lw $s6 , 20($t0) # b2
	lw $t7 , 24($t0) # c2          
	lw $t8 , 28($t0) # d2
	lw $t9 , 32($t0) # a3
	lw $gp , 36($t0) # b3
	lw $sp , 40($t0) # c3
	lw $fp , 44($t0) # d3
	
	# now we will calculate the determinante of the matrix det(A)    
	
	mul $s4 , $s6 , $sp # $s4 = b2 * c3
	mul $s5 , $t7 , $gp # $s5 = c2 * b3
	sub $ra , $s4 , $s5 # $ra = (b2 * c3)-(c2 * b3)
	mul $ra , $t1 , $ra # $s1 = a1*((b2 * c3)-(c2 * b3))
	
	mul $s4 , $t5 , $sp # $s4 = a2 * c3
	mul $s5 , $t7 , $t9 # $s5 = c2 * a3                              #	a1 b1 c1    #
	sub $a2 , $s4 , $s5 # $a2 = (a2 * c3)-(c2 * a3)			 #	a2 b2 c2    #
	mul $a2 , $t2 , $a2 # $a2 = b1*((a2 * c3)-(c2 * a3))  		 #	a3 b3 c3    #
	
	mul $s4 , $t5 , $gp # $s4 = a2 * b3
	mul $s5 , $s6 , $t9 # $s5 = b2 * a3
	sub $a3 , $s4 , $s5 # $a3 = (b2 * c3)-(c2 * b3)
	mul $a3 , $t3 , $a3 # $a3 = c1*((b2 * c3)-(c2 * b3))
	
	sub $v0 , $ra , $a2  
	add $v0 , $v0 , $a3 # $v0 = det(A)
	
	 beq $v0 , $zero , nosolution  # check if det(A) is zero
	
	# now we will calculate det(Ax)
	
	mul $s4 , $s6 , $sp # $s4 = b2 * c3
	mul $s5 , $t7 , $gp # $s5 = c2 * b3
	sub $ra , $s4 , $s5 # $ra = (b2 * c3)-(c2 * b3)
	mul $ra , $t4 , $ra #  $ra = d1*((b2 * c3)-(c2 * b3))	           #	d1 b1 c1   #
									   #	d2 b2 c2   #
	mul $s4 , $t8 , $sp # $s4 = d2 * c3				   # 	d3 b3 c3   #
	mul $s5 , $t7 , $fp # $s5 = c2 * d3
	sub $a2 , $s4 , $s5 # $a2 = (d2 * c3)-(c2 * d3)
	mul $a2 , $t2 , $a2 # $a2 = b1*((d2 * c3)-(c2 * d3))
	
	mul $s4 , $t8 , $gp # $s4 = d2 * b3
	mul $s5 , $s6 , $fp # $s4 = b2 * d3
	sub $a3 , $s4 , $s5 # $a3 = (d2 * b3)-(b2 * d3)
	mul $a3 , $t3 , $a3 # $a3 = c1*((d2 * b3)-(b2 * d3))
	
	sub $v1 , $ra , $a2  
	add $v1 , $v1 , $a3 # $v1 = det(Ax)
	
	# now we will calculate det(Ay)
	
	mul $s4 , $t8 , $sp # $s4 = d2 * c3
	mul $s5 , $t7 , $fp # $s5 = c2 * d3
	sub $ra , $s4 , $s5 # $ra = (d2 * c3)-(c2 * d3)
	mul $ra , $t1 , $ra # $ra = a1*((d2 * c3)-(c2 * d3))	           #	a1 d1 c1   #
									   #	a2 d2 c2   #
	mul $s4 , $t5 , $sp # $s4 = a2 * c3				   # 	a3 d3 c3   #
	mul $s5 , $t7 , $t9 # $s5 = c2 * a3
	sub $a2 , $s4 , $s5 # $a2 = (a2 * c3)-(c2 * a3)
	mul $a2 , $t4 , $a2 # $a2 = d1*((a2 * c3)-(c2 * a3))
	
	mul $s4 , $t5 , $fp # $s4 = a2 * d3
	mul $s5 , $t8 , $t9 # $s4 = d2 * a3
	sub $a3 , $s4 , $s5 # $a3 = (a2 * d3)-(d2 * a3)
	mul $a3 , $t3 , $a3 # $a3 = c1*((a2 * d3)-(d2 * a3))
	
	sub $t0 , $ra , $a2  
	add $t0 , $t0 , $a3 # $t0 = det(Ay)
	
	# now we will calculate det(Az)
	
	mul $s4 , $s6 , $fp # $s4 = b2 * d3
	mul $s5 , $t8 , $gp # $s5 = d2 * b3
	sub $ra , $s4 , $s5 # $ra = (b2 * d3)-(d2 * b3)
	mul $ra , $t1 , $ra # $ra = a1*((b2 * d3)-(d2 * b3))	           #	a1 b1 d1   #
									   #	a2 b2 d2   #
	mul $s4 , $t5 , $fp # $s4 = a2 * d3				   # 	a3 b3 d3   #
	mul $s5 , $t8 , $t9 # $s5 = d2 * a3
	sub $a2 , $s4 , $s5 # $a2 = (a2 * d3)-(d2 * a3)
	mul $a2 , $t2 , $a2 # $a2 = b1*((a2 * d3)-(d2 * a3))
	
	mul $s4 , $t5 , $gp # $s4 = a2 * b3
	mul $s5 , $s6 , $t9 # $s4 = b2 * a3
	sub $a3 , $s4 , $s5 # $a3 = (a2 * b3)-(b2 * a3)
	mul $a3 , $t4 , $a3 # $a3 = d1*((a2 * b3)-(b2 * a3))
	
	sub $k1 , $ra , $a2  
	add $k1 , $k1 , $a3 # $k1 = det(Az)
	
	# now we will calculate X Y Z
	
	# first, we will move the values from v0,v1,t0,k1 to a floating point registers
	mtc1 $v0 , $f0 # $f0 = det(A)
	mtc1 $v1 , $f2 # $f1 = det(Ax)
	mtc1 $t0 , $f4 # $f2 = det(Ay)
	mtc1 $k1 , $f6 # $f3 = det(Az)
	
	cvt.s.w $f0 , $f0 # $f0 = det(A)
	cvt.s.w $f2 , $f2 # $f1 = det(Ax)
	cvt.s.w $f4 , $f4 # $f2 = det(Ay)
	cvt.s.w $f6 , $f6 # $f3 = det(Az)
	
	div.s $f8 , $f2 , $f0 # $f4 = det(Ax)/det(A) = X
	div.s $f10 , $f4 , $f0 # $f5 = det(Ay)/det(A) = Y
	div.s $f14 , $f6 , $f0 # $f6 = det(Az)/det(A) = Z 
	
	j storeInBuffer3x3 #store the result
	 	 	 
# CRAMER_3x3 END

CRAMER_BEGIN_2x2:

	# we have the following equations:
	#	a1X + b1Y + c1Z = d1
	#	a2X + b2Y + c2Z = d2
	#	a3X + b3Y + c3Z = d3
	
	la $t0 , matrix  # load the address of the 1st element in the matrix
	
	lw $t1 , 0($t0)  # a1
	lw $t2 , 4($t0)  # b1
	lw $t4 , 12($t0) # d1
	lw $t5 , 16($t0) # a2
	lw $t3 , 20($t0) # b2          
	lw $t8 , 28($t0) # d2
	lw $t9 , 32($t0) # a3
	lw $gp , 36($t0) # b3
	lw $fp , 44($t0) # d3
	
	# now we will calculate the determinante of the matrix det(A)    
	
	mul $s4 , $t1 , $t3 # $s4 = a1 * b2
	mul $s5 , $t2 , $t5 # $s5 = b1 * a2                               #    a1 b1    #
	sub $v0 , $s4 , $s5 # $ra = (a1 * b2)-(b1 * a2)= det(A)           #    d2 b2    # 
	
	beq $v0 , $zero , nosolution  # check if det(A) is zero
	
	# now we will calculate det(Ax)
	
	mul $s4 , $t4 , $t3 # $s4 = d1 * b2
	mul $s5 , $t2 , $t8 # $s5 = b1 * d2                                #	d1 b1    #
	sub $v1 , $s4 , $s5 # $ra = (d1 * b2)-(b1 * d2) = det(Ax)          #    d2 b2    #

	# now we will calculate det(Ay)
	
	mul $s4 , $t1 , $t8 # $s4 = a1 * d2
	mul $s5 , $t4 , $t5 # $s5 = d1 * a2                                #	a1 d1    #
	sub $t0 , $s4 , $s5 # $ra = (a1 * d2)-(d1 * a2) = det(Ay)          #    d2 b2    #
	
	# now we will calculate X Y Z
	
	# first, we will move the values from v0,v1,t0 to a floating point registers
	mtc1 $v0 , $f0 # $f0 = det(A)
	mtc1 $v1 , $f2 # $f1 = det(Ax)
	mtc1 $t0 , $f4 # $f2 = det(Ay)

	cvt.s.w $f0 , $f0 # $f0 = det(A)
	cvt.s.w $f2 , $f2 # $f1 = det(Ax)
	cvt.s.w $f4 , $f4 # $f2 = det(Ay)
	
	div.s $f8 , $f2 , $f0 # $f4 = det(Ax)/det(A) = X
	div.s $f10 , $f4 , $f0 # $f5 = det(Ay)/det(A) = Y
	
	j storeInBuffer2x2 #store the result
	 	 	 
# CRAMER_2x2 END

storeInBuffer3x3:

	la $t9 , buffer #load the address of the buffer
	sb $s1 , 0($t9) #store the variable char (x) in the buffer
	addi $t9 , $t9 , 1
	#store "=" to in buffer
	la $t1, equal #"="
    	jal stringCopy #stores the equal to the buffer
    	# *********************** MOVE floating register to the buffer
    	mov.s $f20 , $f8 #move x result to f20
    	jal FloatToString #convert the floating result to string to store it in the buffer
    	#store new line in the buffer
    	la $t1, newline
    	jal stringCopy
    	
    	#Same as above but for Y and Z
    	
    	sb $s2 , 0($t9) 
	addi $t9 , $t9 , 1
	la $t1, equal
    	jal stringCopy
    	# *********************** MOVE floating register to the buffer
    	mov.s $f20 , $f10 #y result
    	jal FloatToString
    	la $t1, newline
    	jal stringCopy
    	
    	sb $s3 , 0($t9)
	addi $t9 , $t9 , 1
	la $t1, equal
    	jal stringCopy
    	# *********************** MOVE floating register to the buffer
    	mov.s $f20 , $f14 #z result
    	jal FloatToString
    	la $t1, newline
    	jal stringCopy
	
	c.eq.s $f30, $f28      # Compare $f0 and $f1 for equality
        bc1t PRINT             # Branch to 'label' if the condition is true (equal) if equal => print on screen
	
	j printtofile
	
storeInBuffer2x2:
	#same as 3x3 but for x and y only
	la $t9 , buffer
	sb $s1 , 0($t9)
	addi $t9 , $t9 , 1
	la $t1, equal
    	jal stringCopy
    	# *********************** MOVE floating register to the buffer
    	mov.s $f20 , $f8
    	jal FloatToString
    	la $t1, newline
    	jal stringCopy
    	
    	sb $s2 , 0($t9)
	addi $t9 , $t9 , 1
	la $t1, equal
    	jal stringCopy
    	# *********************** MOVE floating register to the buffer
    	mov.s $f20 , $f10
    	jal FloatToString
    	la $t1, newline
    	jal stringCopy
    	
    	c.eq.s $f30, $f28      # Compare $f0 and $f1 for equality
        bc1t PRINT             # Branch to 'label' if the condition is true (equal)
	
	j printtofile

# dont use a1 , k1 , t6 , f8 , f10 , f14
FloatToString:
    #Handle the negative numbers
    lwc1 $f0 , zero #f0 =0.0
    c.lt.s $f20 , $f0      # Compare if $f0 < $f1 (i.e., $f0 < 0)
    bc1t lessthanzero  # Branch to 'less_than_zero' if the condition is true
    j skip #if positive num => continue
    
    lessthanzero:
    	    la $t1, negative # t1 = "-"
            lb $t2 , 0($t1)                
            sb $t2 , 0($t9) #store the - to the buffer
            addi $t9 , $t9 , 1
            l.s $f0, negOne            # Load -1.0 into $f0
            mul.s $f20, $f20, $f0       # Multiply $f20 by $f0 (-1.0)
            
    skip:
    
    cvt.w.s $f0, $f20   	# Convert float in $f12 to integer in $f0 # f20 = 12.35, $f0 = 12
    cvt.s.w $f2, $f0 # f2 = 12.0
    sub.s $f1,$f20 ,$f2  # $f1 = 0.35
    lwc1 $f2, FLOAT # $f2 = 100.0
    mul.s $f1, $f2, $f1 # f1 = 35.0  	# Subtract the truncated float from the original float to get the fraction part
    mfc1 $t0, $f0  # t0 = 12     	# Move the integer to $t0

    li $t2, 10          # Prepare divisor
    li $t8 , 0
    
    # t0 = 12, we want to reverse to 21 as integer in t8
    ReverseInt:
    #reverse the integer before converting it to string because the converting to string reverse it
    	div $t0, $t2
    	mflo $t0 #ans
    	mfhi $t1 # Remainder (digit)
    	mul $t8 , $t8 , 10
    	add $t8 , $t8 , $t1
    	bnez $t0, ReverseInt
    	# t8 = 21 (int) reversing done
    	
    	#converting the int part to string
    loopToConvertIntToString:
    	div $t8, $t2
    	mflo $t8 #ans
    	mfhi $t1  # Remainder (digit)
    	addiu $t1, $t1, '0'  # Convert to ASCII   
    	sb $t1, 0($t9) #store to the buffer  
    	addiu $t9, $t9, 1
    	bnez $t8, loopToConvertIntToString
    	# t3 = 12(string) reversing done
    	
    	#store the point to the buffer after the x = 12
    la $t1, Point
    lb $t2 , 0($t1)                
    sb $t2 , 0($t9)
    addi $t9 , $t9 , 1
   
   #f1 = 35
    cvt.w.s $f1, $f1      # Convert float in $f1 to integer
    mfc1 $t5, $f1 #t5 = 35
    li $t2, 10          # Prepare divisor
    li $t8 , 0
    
    # t5 = 35, we want to reverse to 53 as integer in t8
    ReverseInt2:
    	div $t5, $t2
    	mflo $t5 #ans
    	mfhi $t1   # Remainder (digit)
    	mul $t8 , $t8 , 10
    	add $t8 , $t8 , $t1
    	bnez $t5, ReverseInt2
    	# t8 = 53 (int) reversing floating part done
    	
    	#converting the floating part to string
    loopToConvertIntToString2:
    	div $t8, $t2
    	mflo $t8 #ans
    	mfhi $t1   # Remainder (digit)
    	addiu $t1, $t1, '0' 	# Convert to ASCII
    	sb $t1, 0($t9)
    	addiu $t9, $t9, 1
    	bnez $t8, loopToConvertIntToString2
    	# t3 = 35(string) reversing done
     
    jr $ra # back to 604
						
stringCopy: #this store chars into the buffer (address in t9)
    lb $t2 , 0($t1)                
    sb $t2 , 0($t9)                
    beq $t2 , $zero, stringCopyEnd #if finished => back to jal 
    addi $t1 , $t1 , 1               
    addi $t9 , $t9 , 1               
    j stringCopy                     
    
stringCopyEnd: #after finishing storing, go back to jal
    jr $ra                       
                              
invalidinput:
	printstring(errormessage)
	j menu
	
noSolution:
	li $k0 , 1 #no solution
        j backmenu
        
endprogram:
	    #close file
	    move $a0, $s0
            li $v0, 16
            syscall
	    printstring(bye)
	    printstring(newline)
	    li $v0,10 #end the program
            syscall