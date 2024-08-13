//push constant 6
@6
D = A
@SP
A = M
M = D
@SP
M = M + 1

//push constant 3
@3
D = A
@SP
A = M
M = D
@SP
M = M + 1

//sub
@SP
AM = M - 1
D = M
A = A - 1
M = M - D
