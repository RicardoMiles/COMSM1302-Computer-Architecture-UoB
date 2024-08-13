// call final.test 3
@returnaddress
D = A
@SP
A = M
M = D

@LCL
D = M
@SP
A = M + 1
M = D

@ARG
D = M
@SP
A = M + 1
A = A + 1
M = D

@THIS
D = M
@SP
A = M + 1
A = A + 1
A = A + 1
M = D

@THAT
D = M
@SP
A = M + 1
A = A + 1
A = A + 1
A = A + 1
M = D

@SP
D = M
@3
D = D - A
@ARG
M = D

@SP
D = M
@5
D = D + A
@ARG
M = D

@call$final.test
0;JMP

(returnaddress)


// function final.test 6
(call$final.test)
@R13
M = 0

(assignloop)
@R13
D = M
@6
D = D - A
@endassign
D;JEQ

@R13
D = M
@LCL
A = A + D
M = 0

@SP
M = M + 1
@R13
M = M + 1

@assignloop
0;JMP
(endassign)

// return
@returnaddress
A = D
@R13
M = D

@SP
D = M
A = D - 1
D = M

@ARG
A = M
M = D

D = A
D = D + 1
@SP
M = D

@LCL
// D = A
D = M
@1
A = D - A
D = M
@THAT
M = D 

@LCL
//D = A
D = M
@2
A = D - A
D = M
@THIS
M = D 

@LCL
//D = A
D = M
@3
A = D - A
D = M
@ARG
M = D 

@LCL
//D = A
D = M
@4
A = D - A
D = M
@LCL
M = D 

@R13
A = M
0;JMP

(HALT)
@HALT
0;JMP
