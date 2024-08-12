// Push return address
// Push old LCL
// Push old ARG
// Push old THIS
// Push old THAT
// Set new ARG = old SP - (num followed by call)
// Set new LCL = old SP + 5
// Jump to function code
// Return label from function code


@auto$func.vm$0 //Push return address 
D = A
@SP
A = M
M = D
// Push old LCL
@LCL
D = M
@SP
A = M+1
M = D

// Push old ARG
@ARG
D = M
@SP
A = M + 1
A = A + 1
M = D
@THIS
A = M + 1
A = A + 1
A = A + 1
M = D
@THAT
A = M + 1
A = A + 1
A = A + 1
A = A + 1
M = D
// Set new ARG to old SP - 3 since call exam.test 3
@SP
D = M
@3
D = D - A
@ARG
M = D
//Set new LCL = old SP + 5 , return address, lcl,arg,this,that
@SP
D = M
@5
D = D + A
@LCL
M = D 
@call$exam.test //Jump to function
0;JMP
(auto$52) 

//function exam.text 6
(call$exam.test)
@LCL // Initialize lcoal segment via loop
A = M
M = 0
@i
M = 0
(loopstart)
@i
D = M
@5
D = D - A
@loopend
D;JGT
@LCL
A = M
A = A + D
M = 0
@i
M = M + 1
@loopstart
0;JMP
(loopend)
//Set SP
@6
D = A
@LCL
D = D + M
@SP
M = D

// label
(manual$func.vm$LOOPSTART)

// push constant 3
@3
D = A
@SP
A = M
M = D
@SP
M = M + 1

// pop local 2
@LCL
D = M
@2
D = D + A
@R13
M = D
@SP
M = M - 1
A = M
D = M
@R13
A = M
M = D

//pop pointer 0


// Return
// Store return address in R13
@5
D = A
@LCL
D = M - D
A = D
D = M
@R13
M = D
// Copy the return value to argument 0
@SP 
A = M - 1
D = M
@ARG
A = M
M = D
// Update SP
D = A + 1
@SP
M = D

// Recover THIS
// retrieve th this value under lcl
@LCL
A = M -1
A = A -1
D = M
@THIS
M = D

//Recover That
@LCL
A = M -1
D = M
@THIS
M = D

//Restore ARG
@3
D = A
@LCL
A = M-D
D = M
@ARG
M = D

@4 // Restore LCL
D = A
@LCL
A = M - D
D = M
@LCL
M = D
@R13
A = M
0;JMP
(HaltInfiniteloop)
@HaltInfiniteloop
0;JMP