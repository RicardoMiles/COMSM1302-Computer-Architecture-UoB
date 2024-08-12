// if O is pressed wait for M
    //if M is pressed goto drawBlack
    // Otherwise goto 3
// Otherwise wait for O
(waitO)
@KBD
D = M
@79
D= D - A
@waitO
D;JNE

(waitM)
@KBD
D = M // no key pressed
@waitM
D;JEQ

@79
D = D - A
@waitM
D;JEQ

// could not directly compare with @77
@2
D = D + A
@waitO
D;JNE

//OM has been entered, fill the screen black forever
@SCREEN
D = A
@i
M = D

(drawBlack)
@i
D = M
@KBD
D = D - A
@enddraw
D;JGE

// draw black
D = 0 
D = !D
@i
A = M
M = D
@i
M = M +1
@drawBlack
0;JMP
(enddraw)
@enddraw
0;JMP
