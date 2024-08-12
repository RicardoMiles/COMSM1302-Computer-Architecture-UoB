@auto$52 // Push return address
D=A
@SP
A=M
M=D 
@LCL // Push old LCL
D=M
@SP
A=M+1
M=D
@ARG // Push old ARG
D=M
@SP
A=M+1
A=A+1
M=D
@THIS // Push old THIS
D=M
@SP
A=M+1
A=A+1
A=A+1
M=D
@THAT // Push old THAT
D=M
@SP
A=M+1
A=A+1
A=A+1
A=A+1
M=D
@SP // Set new ARG = old SP - 7
D=M
@7
D=D-A
@ARG
M=D
@SP // Set new LCL = old SP + 5
D=M
@5
D=D+A
@LCL
M=D
@call$Main.exam // Jump to function code
0;JMP
(auto$52) // Return label from function code
