@R0 // Add RAM[0] to RAM[1], then store the result in RAM[2].
D=M
@R1
D=M+D
@R2
M=D
@endif // If RAM[2] is positive, then multiply RAM[2] by $-1$.
D;JLE
@R2
M=-M
D=M
(endif)
@R1 // Take a bitwise OR of RAM[2] with RAM[1] and store the result in RAM[2].
D=M|D
@R2
M=D
(halt)
@halt
0;JMP
