        .data
freenode:  .word   0               ## A global variable
freenodect:  .word   0
        .text
prepend: lw $t0,freenodect
	 move $t1,$a0
	 bne $t0, $zero, gotroom
	 li $v0, 9
	 li $a0, 800
	 syscall
	 sw $v0, freenode
	 li $t0, 100
	 sw $t0, freenodect
gotroom: lw $v0, freenode
	 addi $t0, $t0, -1
	 sw $t0 freenodect
	 addi $t0,  $v0, 8
	 sw $t0, freenode
	 sw $t1, 4($v0)
	 sw $a1, 0($v0)
	 jr $ra


contents: lw $v0, 4($a0)
	  jr $ra

next_node: lw $v0, 0($a0)
	   jr $ra

length_r: addiu $sp, $sp, -32
        sw      $fp, 28($sp)    # Save frame pointer
	sw	$ra, 24($sp)	# Save $ra
	addiu   $fp,$sp,32      # New frame pointer
	bne	$a0, $zero, notend
	li	$v0, 0
	b	ret
notend:	jal	next_node
	move	$a0, $v0
	jal	length_r
	addi	$v0,1
ret:	lw      $fp, 28($sp)    # restore fp
	lw	$ra, 24($sp)	# restore ra
        addiu   $sp,$sp,32      # restore sp
        jr      $ra             # return
	
length_i: 
	move	$t0, $a0
	li	$t1, 0
loop:	beq	$t0, $zero, atend
	addiu	$t1,1
	lw 	$t0, 0($t0)
	b	loop
atend:	move	$v0, $t1
        jr      $ra             # return
	
main:	 addiu $sp, $sp, -32
        sw      $fp, 28($sp)    # Save frame pointer
	sw	$ra, 24($sp)	# Save $ra
	addiu   $fp,$sp,32      # New frame pointer
	li	$a1, 0		# empty list
	li	$s0, 1000	# loop counter
loop2:	beq	$s0, $zero, endloop  # loop check
	addiu	$s0,-1		# decrement counter
	move	$a0, $s0	# counter is contents
	jal	prepend		# make a node
	move	$a1, $v0	# new list becomes argument to next call
	b 	loop2
endloop:move	$s0, $v0	# get the list
	move	$a0, $s0	# pass to length_r
	jal 	length_r
	move 	$a0, $v0	# get length
	li	$v0,1		#print
	syscall
	li 	$a0, 0x20	# print space
	li	$v0,11
	syscall
	move	$a0, $s0	# pass to length_i
	jal	length_i
	move 	$a0, $v0	# get the length
	li	$v0, 1
	syscall
	
	lw      $fp, 28($sp)    # restore fp
	lw	$ra, 24($sp)	# restore ra
        addiu   $sp,$sp,32      # restore sp
        jr      $ra             # return