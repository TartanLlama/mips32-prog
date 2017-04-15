	.data
freespace: 	.word 	0	#next available space
counter:	.word	0
	.text
make_tree:
	lw 	$t0, counter		#load counter into t0
	bne 	$t0, $zero, isspace	#if there is space, branch
	move 	$t1, $a0		#save a0
	li 	$v0, 9		#sbrk
	li 	$a0, 1200		#enough space for 100
	syscall	  		#carry out sbrk
	move 	$a0, $t1		#reload a0
	sw 	$v0, freespace	#store new space
	li 	$t0, 100		#put new counter data in t0
	sw 	$t0, counter		#store new counter
isspace:lw 	$v0, freespace	#load next free space into v0
	addi 	$t0, $t0, -1	#decrement counter
	sw 	$t0, counter		#store counter
	sw 	$a0, 8($v0)		#store node data
	sw 	$a2, 4($v0)		#store right child
	sw	$a1, 0($v0)		#store left child
	addi 	$t0, $v0, 12	#get next free location
	sw 	$t0, freespace	#store next free location
	jr 	$ra
	
contents:
	lw 	$v0, 8($a0)
	jr 	$ra
	
left_child:
	lw 	$v0, 0($a0)
	jr 	$ra
	
right_child:
	lw 	$v0, 4($a0)
	jr 	$ra
	
size:	addiu	$sp, $sp, -32	#make stack frame
	sw	$fp, 28($sp)	#save frame pointer
	sw	$ra, 24($sp)	#save return address
	addiu	$fp, $sp, 32	#new frame pointer
	bnez 	$a0, recurse	#if the tree is not null, recurse
	li 	$v0, 0		#return 0 if the tree is null
	b	restore		#restore and return
recurse:jal	left_child	#get the left tree
	sw	$a0, 20($sp)	#store root node for later use
	move	$a0, $v0	#move the left tree to arguments
	jal	size		#get the size of left tree
	lw	$a0, 20($sp)	#load root node
	sw	$v0, 20($sp)	#store the size of the left tree
	jal	right_child	#get the right subtree
	move	$a0, $v0	#move right subtree to arguments
	jal	size		#get the size of right tree
	lw	$t0, 20($sp)	#load size of left tree
	add	$v0, $v0, $t0	#add sizes together into return register
	addi	$v0, $v0, 1	#add this tree to the overall size
restore:lw	$ra, 24($sp)	#restore return address
	lw	$fp, 28($sp)	#restore frame pointer
	addiu	$sp, $sp, 32	#restore stack pointer
	jr 	$ra

fulltree:
	addiu 	$sp, $sp, -32
        sw      $fp, 28($sp)    # Save frame pointer
	sw	$ra, 24($sp)	# Save $ra
	sw	$s0, 20($sp)	
	addiu   $fp,$sp,32      # New frame pointer	
	bne	$a0, $zero, notleaf
	li	$v0,0
	move	$v1, $a1
	b 	ret_fulltree

notleaf:
	addiu	$a0, $a0, -1  # recursive calls will construct trees 1 shallower
	move	$s0, $a0	# save for second recursive call
	jal	fulltree      # make first subtree
	move	$a1, $v1      # recover node count
	move	$a0, $s0      #  restore depth parameter
	move	$s0, $v0      # save first subtree
	jal	fulltree      # make second subtree
	addiu	$a0, $v1, 1	# count this node
	move	$a1, $s0	# parameters for making node
	move	$a2, $v0
	move	$s0, $a0	# save count
	jal	make_tree
	move	$v1, $s0	# return
	
ret_fulltree:
	lw	$s0, 20($sp)
	lw	$ra,  24($sp)
	lw      $fp, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	
	
	
	
main:	addiu 	$sp, $sp, -32
        sw      $fp, 28($sp)    # Save frame pointer
	sw	$ra, 24($sp)	# Save $ra
	addiu   $fp,$sp,32      # New frame pointer
	
	
testmake:
	li 	$a0, 10	# get the length
	li	$a1, 0
	jal	fulltree
	move	$s0, $v0	#store the root node into s0 for safekeeping
	move	$a0, $s0	#put in root node as argument

testsize:
	jal	size		#get size from root node
	move	$a0, $v0	#move size to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print size
	
testcontents:
	move	$a0, $s0	#move root node back to argument
	jal	contents	#get the contents of the root node
	move	$a0, $v0	#move contents to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print contents
	
testleft:
	move	$a0, $s0	#move root node back to arguments
	jal	left_child	#get left child
	move	$s1, $v0	#store child in s1 for safekeeping
	move	$a0, $v0	#move child to argument
	jal	size		#get left tree size
	move	$a0, $v0	#move size to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print size
	
	move	$a0, $s1	#move left subtree to argument
	jal	contents	#get contents of left subtree
	move	$a0, $v0	#move contents to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print contents
	
testright:
	move	$a0, $s0	#move root node back to arguments
	jal	right_child	#get right child
	beqz	$v0, finish
	move	$s0, $v0	#store child in s0 for safekeeping
	move	$a0, $v0	#move child to argument
	jal	size		#get right tree size
	move	$a0, $v0	#move size to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print size
	
	move	$a0, $s0	#move right subtree to argument
	jal	contents	#get contents of right subtree
	move	$a0, $v0	#move contents to be printed
	li	$v0, 1		#print int syscall value
	syscall			#print contents
	b	testright
	
	
	
finish:	lw      $fp, 28($sp)    # restore fp
	lw	$ra, 24($sp)	# restore ra
        addiu   $sp,$sp,32      # restore sp
        jr      $ra             # return
