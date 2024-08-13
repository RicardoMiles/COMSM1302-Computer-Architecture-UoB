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
@LCL
M = D

@call$main.test
0;JMP 
(returnaddress)
