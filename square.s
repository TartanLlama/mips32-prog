		.data
new_line:	.asciiz		"\n"

		.text

		.globl	main
main:	addiu	$sp,$sp,-32		# Make stack frame
	sw	$ra, 28($sp)		# Save frame pointer
	sw	$ra, 24($sp)		# Save return address
	addiu	$fp,$sp,32   		# New frame pointer
	li	$s0, 1			# Initialise loop
	li	$s1, 10			# Store loop end
loop:	bge	$s0, $s1, finish	# Check for loop end
	mult	$s0, $s0  		# Square the loop counter
	mflo	$a0  			# Move lo to argument register for printing
	li	$v0, 1		       	# Syscall print_int
	syscall		     		# Print int
	la	$a0, new_line		# Store new_line in argument register
	li	$v0, 4			# Syscall print_string
	syscall	     			# Print string
	addiu	$s0, 1			# Increment counter
	b	loop			# Go to start of loop
finish:	lw	$fp, 28($sp)		# Restore fp
	lw 	$ra, 24($sp)		# Restore ra
	addiu	$sp,$sp,32		# Restore sp
	jr	$ra			# Return

