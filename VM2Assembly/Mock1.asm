//Read from RAM0 and RAM1
//add them up store them in RAM2
@R0
D = M
@R1
D = D + M
@R2
M = D;

@multiply
D;JGT
(normalflow)
@R1
D = M
@R2
M = D|M
(halt)
@halt
0;JMP

(multiply)
D = -D
@R2
M = D
@normalflow
0;JMP
