// Goal: Write the intermediate digit sums of the binary digital root of RAM[0] into RAM[1], RAM[2], ...
@R0 // x <- RAM[0], pos <- 1.
D=M
@x
M=D
@pos
M=1
(start_digit_sum)
@x // If x = 1, jump to end_digit_sum.
D=M-1
@end_digit_sum
D;JEQ
@total  // total <- 0, mask <- 1
M=0
@mask
M=1
(start_digit_count)
@x // If x & mask != 0, total++.
D=M
@mask
D=D&M
@no_increment
D;JEQ
@total
M=M+1
(no_increment)
// If mask = 0x8000, end the loop. 
@mask
D=M
@end_digit_count
D;JLT
// Otherwise, mask += mask and go back to start_digit_count.
@mask
D=M
M=D+M
@start_digit_count
0;JMP
(end_digit_count)
@total // x, RAM[pos] <- total, pos++
D=M
@pos
A=M
M=D
@x
M=D
@pos
M=M+1 
@start_digit_sum // Loop
0;JMP
(end_digit_sum) // Halt.
@end_digit_sum
0;JMP
