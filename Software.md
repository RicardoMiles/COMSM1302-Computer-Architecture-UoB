# Software Part
## Hack Assembly Syntax
* 
## Hack Assembly Trick
### Write 0xFFFF
Since it is not allowed to write 16-bit into register in Hack Assembly.(Insrtuction could at most assign 15 bits). So the best way to do it is

```
@0
D = !A
```

### Loop the whole screen
Loop each pixel on screen is executable given that Hack CPU is memory mapped. The address from 0x4000 to 0x5FFF is screen. The Hack CPU manipulate the input and output directly by manipulate the memory.

```
// Pseudocode:
// While True:
//     For every i between 0x4000 and 0x5FFF
//         if RAM[KBD] !=0:
//             Write 0x0000 to RAM[i]
//         Otherwise:
//             Write 0xFFFF to RAM[i]
//
// Infinite loop
```

Then put it into Assembly code

```
(bigloop)
// For all i between
    @SCREEN
    D = A
    @i
    M = D
    (smallloop)
        // If i = 0x6000;Jump to bigloop
        // A.K.A if the i reach the KBD, it is equivalent to loop over the last pixel of SCRREN
        // If 0x6000 - i == 0;Jump to bigloop 
        @i
        D = M
        @KBD
        D = D - A
        @bigloop
        D;JEQ

        // If RAM[KBD] != 0,jump to (writezero)
        @KBD
        D = M
        @writezeroes
        D;JNE

        // Otherwise, write 0XFFFF to RAM[i]
        D = 0 
        D = !D
        @i
        A = M 
        M = D
        @i
        M = M + 1
        @smallloop
        0;JMP

        //Write 0x0000 to RAM[i]
        (writezeroes)
        D = 0
        @i
        A = M
        M = D
        @i
        M = M +1
        @smallloop
        0;JMP

//Loop infinitely
@bigloop
0;JMP
```

### Practice of sum 
Goal: Sum all the integers from 0 to RAM[0] and put the result in RAM[1].

So, if RAM[0] == 3; then RAM[1] should be 0+1+2+3 = 6.

```
// let a variable to hold the current number
@currentNum
M = 0
// Set RAM[1] = 0, initialize the procedure
@R1
M = 0

// While currentNum <= RAM[0]
//      add currentNum to RAM[1]
//      increase the value of currentNum by 1
(loopstart)
    @currentNum
    D = M
    @R-1
    D = D - M
    @loopend
    D;JGT
    @currenNum
    M = M + 1
    @loopstart
    0;JMP
(loopend)
@loopend
0;JMP
```
