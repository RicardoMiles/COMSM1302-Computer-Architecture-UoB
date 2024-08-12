(no_O) // If O not pressed, jump back to no_O.
@KBD
D=M
@79
D=D-A
@no_O
D;JNE
(no_M) // If no key is pressed, jump back to no_M.
@KBD
D=M
@no_M
D;JEQ
@79   // If O is pressed, jump back to no_M.
D=D-A
@no_M
D;JEQ
@2    // If any other key than M is pressed, jump back to no_O.
D=D+A
@no_O
D;JNE
// OM has been entered, fill the screen black forever.
@SCREEN       // Initialise i to 0x4000.
D=A
@i
M=D
(fill_loop)   
@i            // Set RAM[i] to -1 (colouring 16 pixels black)
A=M
M=-1
@i            // i++
M=M+1
D=M           // If i < KBD, jump back to fill_screen and keep going.
@KBD
D=D-A
@fill_loop
D;JNE
(halt)
@halt
0;JMP
