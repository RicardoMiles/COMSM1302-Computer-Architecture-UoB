// Call
@auto$func.vm$0 // Push call frame to stack
D=A
@SP
A=M
M=D
@LCL
D=M
@SP
A=M+1
M=D
@ARG
D=M
@SP
A=M+1
A=A+1
M=D
@THIS
D=M
@SP
A=M+1
A=A+1
A=A+1
M=D
@THAT
D=M
@SP
A=M+1
A=A+1
A=A+1
A=A+1
M=D 
D=A+1 // Update LCL
@LCL
M=D
@SP // Update ARG
D=M
@3
D=D-A
@ARG
M=D
@call$exam.test // Jump to function
0;JMP
(auto$func.vm$0) // Return label
// Function
(call$exam.test) // Function label
@R13 // Initialise local segment via loop
M=0  // (NB this is horribly slow, especially for small local segments!)
(auto$func.vm$1) // Here R13 stores the i for which we're initialising local i
@R13
D=M
@6
D=D-A
@auto$func.vm$2
D;JEQ
@R13
D=M
M=M+1
@LCL
A=M+D
M=0
@auto$func.vm$1
0;JMP
(auto$func.vm$2)
@6 // Set SP
D=A
@LCL
D=M+D
@SP
M=D
// Label
(manual$func.vm$LOOPSTART)
//push
@3
D=A
@SP
M=M+1
A=M-1
M=D
//pop
@2
D=A
@LCL
A=M+D
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
//push
@3080
D=A
@SP
M=M+1
A=M-1
M=D
//pop
@THIS
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
@3
D=A
@THIS
A=M+D
D=M
@SP
M=M+1
A=M-1
M=D
@5
D=A
@ARG
A=M+D
D=M
@SP
M=M+1
A=M-1
M=D
//pop
@func.vm.0
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// lt
@SP
M=M-1
A=M
D=M
@SP
A=M-1
D=D-M
@auto$func.vm$3
D;JGT
@SP
A=M-1
M=0
@auto$func.vm$4
0;JMP
(auto$func.vm$3)
@SP
A=M-1
M=-1
(auto$func.vm$4)
// If-goto
@SP
M=M-1
A=M
D=M
@manual$func.vm$LOOPSTART
D;JNE
@3
D=A
@LCL
A=M+D
D=M
@SP
M=M+1
A=M-1
M=D
// sub
@SP
M=M-1
A=M
D=M
@SP
A=M-1
M=M-D
// Return
@5 // Store return address in R13
D=A
@LCL 
A=M-D
D=M
@R13
M=D
@SP // Copy return value to argument 0, NB this may overwrite
A=M-1 // return address if argument has length 0
D=M
@ARG
A=M
M=D
D=A+1 // Update SP
@SP
M=D
@LCL // Restore THAT
A=M-1
D=M
@THAT
M=D
@LCL // Restore THIS
A=M-1
A=A-1
D=M
@THIS
M=D
@3 // Restore ARG
D=A
@LCL
A=M-D
D=M
@ARG
M=D
@4 // Restore LCL
D=A
@LCL
A=M-D
D=M
@LCL
M=D
@R13 // Jump to return address
A=M
0;JMP
(HaltInfiniteLoop)
@HaltInfiniteLoop
0;JMP