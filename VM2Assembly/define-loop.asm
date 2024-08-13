(call$exam.test)
@R13
M = 0

(assignZero)
@R13
D = M
@6
D = D - A
@finishAssign
D;JEQ

@SP
A = M
M = 0
@SP
M = M + 1

@R13
M = M + 1

@assignZero
0;JMP
(finishAssign)
