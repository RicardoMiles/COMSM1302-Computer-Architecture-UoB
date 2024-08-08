# Software Part
## Hack CPU detail 
* Hack CPU is 16-bit word size, one instruction have 16 bits
* Manipulate Program counter to achieve loop
* A register is the unique register could load value directly
* Program counter hold the number of ROM address of next instruction would be executed by CPU
* Variable - store RAM address - mapping A register
* Lable - ROM address
* Execute instruction first, then PC changed. E.g. When the CPU is executing the second instruction, the PC currently is 1, after executing, it +1
* R0 - R15  are called virtual registers
* @var is sensible about Capitalized variable identifier
* Only the instruction without @ be followed by semiclone and jump instruction
* If [result of instruction] satisfies [condition], goto the ROM address currently contained in A register right now.
* change A's value and jump instruction could not appear in same line(same clock circle); every time you change A, Program Counter changes
* The jump instruction condition judges&cares the right side of assignment.
* 512*256 resolutiion screen of Hack, every word between 0x4000 - 0x5FFF controlled a set of 16 pixel on screen, the sequence is mirroring by the binary expression of memory.
    * e.g. RAM[0x4020] stores 0b 0000 0000 0000 0001, screen will show the most left pixel of this set as black
    * each word in 0x4000–0x5FFF controls not one pixel, but 16!
*  The @ command only works on values of up to 15 bits!

## Hack Assembly Syntax
* Binary Operation
    * Operands have to be 2 register
    * One of them have to be D register 
    * Assigning operation is not counted 
    * You can do multiple assignment, But A/M/D should be in the fixed sequence.
* @num  - load number to A register , at most 15 bit in Binary
* `A = -D` is also Unary Operation, because right side there is only one register
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

### Calculate the pixel memory position by its number
Row `r` from the top displayed on screen

Column `c` from left displayed on screen


Both counting from 0

The pixel at Row `r` Column `c` is controlled by the `(c%16)`th bit from the right at address `0x4000 + 32r + (c/16)`

## 






## Examinablity for Test 2
### week 5：
视频3中的图灵机定义不考察。

幻灯片中的其他内容（Church-Turing论文、图灵完备性和停机问题）考察，但仅限于幻灯片的内容深度。
### week 7：
视频3-4中提到的特定CPU的具体细节（如每条指令所需的周期数或从内存中检索数据所需的纳秒时间）不考察。但你需要记住所有CPU共有的关键定性细节（如L3缓存访问比L1缓存访问慢）。
### week 8：
Hack汇编语法考察，但不需要背诵定义——如果有相关问题，会提供EBNF的相关摘录。

视频2最后一张幻灯片（关于使用多个符号表处理高级语言中的作用域）仅在与week 11内容重叠时考察。
### week 9：
Hack VM语法考察，但不需要背诵定义——如果有相关问题，会提供EBNF的相关摘录。
### week 11：
不需要知道如何用Jack编程，不会问Jack语言的细节，也不会要求阅读、编写或调试Jack代码。但你需要理解将高级语言编译成Hack VM的基本原理，具体到Jack中探讨的程度。例如，你需要知道什么是方法，可能会被问到将方法编译成Hack VM的过程，但不会要求阅读、编写或调试Jack中的方法声明。

同样，Jack语法考察，但不需要背诵定义——如果有相关问题，会提供EBNF的相关摘录。

除了Memory.alloc、Memory.deAlloc和Sys.init（你需要知道）之外，任何需要的Hack“操作系统”细节（如Nisan和Schocken附录6中涵盖的）都会提供给你。