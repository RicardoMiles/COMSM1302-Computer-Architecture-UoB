// return
// Store return address in R13 - LCL minus 5
@5
D = A
@LCL
D = M - D
A = D
D = M
@R13
M = D

// Copy return value to argument 0
// retrieve the value from top of stack
@SP
A = M - 1
D = M
// store into argument 0
// store into return address if argument has length 0
@ARG
A = M
M = D

// update SP
@ARG
D = A
D = D + 1
@SP
M = D

// RESTORE THAT
@LCL
D = M
D = D - 1
A = D
D = M
@THAT
M = D

// RESTORE THIS
@LCL
D = M
@2
D = D - A
A = D
D = M
@THIS
M = D

// RESTORE ARG
@LCL
D = M
@3
D = D - A
A = D
D = M
@ARG
M = D

// RESTORE LCL
@LCL
D = M
@4
D = D - A
A = D
D = M
@LCL
M = D

// JUMP TO RETURN ADDRESS
@R13
A = M
0;JMP

(HALT)
@HALT
0;JMP












