# Software Part

## Hack CPU detail

* Hack CPU is 16-bit word size, one instruction have 16 bits
* Manipulate Program counter to achieve loop
* A register is the unique register could load value directly
* Program counter hold the number of ROM address of next instruction would be executed by CPU
* Variable - store RAM address - mapping A register
* label - ROM address
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
* The @ command only works on values of up to 15 bits!

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

### Hack ISA

* Instruction length is always multiple word size
* Havard -> 2 separate memory bank, separate data and instruction
* Von ->  data and instructions stores at same memory
* Modern computer use Von ISA more
* PC A M -> special purpose registers
* D -> general purpose register

### Addressing Mode

* Immediate Addressing: Interpret oprand as data
* Direct Addressing: Interpret operand as the position of data
* Indirect Addressing : Interpret operand as the position of the pointer which points to the data
* E.g. @num -> immediate addressing
* E.g. @label ->direct addressing
* E.g.   Firstly, @5; then,M = 1;
* It depends give what to A register, @num give number to A, @label parse the address of label and give address to A, @num then manipulate M, give A the address of pointer, A is the pointer of M

### Pipeline and stall

Stall aka bubble, three harzard leads to stall

* Data hazard
* Conditional hazard
* Structural hazard

All the rest of pipline will stall until the conflict instruction executed.

Pipeline of Hack C-instructions fetch-exectute 

* 4 stages of  it: Fetch; Decode; Execute; Writeback
* we can set the clock speed to the propagation delay of the slowest stage, rather than of the entire fetch-execute cycle!

### Compiler - Lexing

* Use an assembler to turn assembly into machine code.
* Lexing converts source code text into a list of tokens
* Parsing analyze the structure of tokens, also known as analyze syntax
* IR - Intermediate representation
* Hack assembler has only two step: parsing and lexing
* On lexing stage, labels are recorded in symbol table; but, label itself will not be converted to token
* Your lexer will also handle labels, which would normally be part of semantic analysis
* 对于每一行： 
  * 移除所有注释和空白。
  * 如果该行为空，则跳过。
  * 如果该行是一个标签，将其添加到符号表中，并记录当前行对应的 ROM 地址。
  * 否则，将该行分解为标记并输出到一个临时文件中。

### Assember - demand

Assembler todo list: 

* 为每一个变量分配一个对应的RAM地址，从16开始。
* 用RAM地址替换变量
* 为每个标签分配一个ROM中的地址，这个ROM地址和标签出现的机器代码行相对应
* 用ROM地址替换标签
* 完成上述步骤，才将@语句替换成A指令
* 由Symbol Table 来完成上述操作，在汇编过程中，跟踪程序使用的所有标签和便来年个的地址
* Filling the symbol table 和 lexing 以及parsing同步进行

![image](https://github.com/user-attachments/assets/3c2c9f47-e8ae-4c58-836e-b065e62d779f)

### Identifier and symbol tables

* In Hack, identifiers are labels and and variables.
* Symbol table is a data structure mapping the names of identifiers to their meaning
* In Hack, we will have one symbol table for labels (mapping each label name to its ROM address) and one for variables (mapping each variable name to its RAM address).
* Both the label and variable tables start empty.

### Working mechanism of symbol table

In parsing, for each identifier we find, we check the symbol tables:

* If it’s in the label table, hooray — substitute in the ROM address.
* If it’s in the variable table, hooray — substitute in the RAM address.
* If it’s in neither table, it must be the first occurrence of some variable. So we add it to the variables table with the first unassigned RAM address.

### Compiler - Parsing

* The goal of parsing is to convert a list of tokens into a parse tree or concrete syntax tree (CST) which gives its BNF structure.

![image](https://github.com/user-attachments/assets/d80f873f-ef02-4048-adb5-ce878736a66c)

## LL parsing

* go through tokens from left to right
* build CST from the top down 
* Process
  * 如果⟨指令⟩以 '@' 标记开头：
    * 如果使用了一个新变量，分配 RAM 并将其添加到符号表中。
    * 如果使用了一个现有变量或标签，从符号表中检索相应的 RAM/ROM 地址。
    * 生成并输出相应的 A-指令。
  * 否则：
    * 将其分解为一个赋值、一个计算和一个条件。
    * 将这些分配到适当的 dest、comp 和 jump 值。
    * 生成并输出相应的 C-指令。

### BNF

* Programmers express grammars in Backus-Naur Form (BNF), and usually just understanding BNF is enough.
* A context-free grammar (or just grammar) is a way of quickly and rigorously specifying which strings in a language have valid syntax.
* 上下文无关文法：这是一种用于定义编程语言或自然语言语法的数学系统。与上下文相关的文法不同，上下文无关文法的规则不依赖于字符周围的上下文。
* Anything we define as part of the grammar must be enclosed in ⟨⟩s. We call these **non-terminal symbols**. Anything else (e.g. ‘lecturer’) is a **terminal symbol** or **token**.

![image](https://github.com/user-attachments/assets/a5fe5a92-37a9-4d67-af6d-f75aec592590)

* BNF allows recursion.
* The goal of parsing is to convert a list of tokens into a parse tree or concrete syntax tree (CST) which gives its BNF structure.

### EBNF for Hack assembly

![image](https://github.com/user-attachments/assets/b10968ad-02d3-4507-9325-8ab0e65f2887)

### Track scope

作用域 - 是一张又一张独立的symbol table

### VM syntax detail

* **Compilers for many languages can and do use the same IR.**

* Goals of VM
  
  * Implement function calls! (Next week...)
  * Proper compile-time memory allocation! (Next week...)
  * Multi-file compilation support for libraries. (Next week...)

* The Hack VM is an example of a stack machine
  
  * create
  
  * push
  
  * pop
    
    * Stacks are **LIFO**: “Last In, First Out”.
    * Hack **Assembly** use **physical memory** — every memory address is the exact logical signal sent to a physical latch on a physical chip, either ROM or RAM.
    * Hack **VM(IR)** use **virtual memory.**
    * push with the command **push [memory] [address].**
    * The **Hack VM has 8(!) separate virtual memory banks**, which our VM translator will map to different segments (continuous blocks) of the underlying RAM.
  
  * **local** is general-purpose storage for local variables. 
  
  * **constant** holds the constant i at each 15-bit address i. This “memory” is read-only and doesn’t correspond to any physical ROM or RAM.
    
    * The Hack VM represents a result of true by 0xFFFF, and false as 0x0000\
    * For operations that pop two values, **y is the first value popped and x is the second value.** E.g. push constant 3, push constant 1, sub will end with 2 on top of the stack rather than −2

### VM branching

* Syntax for goto:
  
  * **label LABEL NAME** declares a label at that point of the code. 
  * **goto LABEL NAME** jumps to that label from anywhere in the code.
  * **if-goto LABEL NAME** pops the stack and executes goto LABEL NAME if the result is non-zero (i.e. if it is not false).

* **if-goto** in the same way that we would use **D;JNE** in assembly. 
  
  The differences are: 
  
  * The value we compare to zero is the top of the stack instead of D. 
  * We have proper logical operators gt, eq, lt, and, or and not built into the language to replace the various jump conditions.

* ***this*** segment can only be used to access RAM[0x0800–0x3FFF]； For anything outside that, we must instead use the **that** memory segment.

* ***that*** maps range  0 to RAM[pointer 1]

* 在函数调用开始时，***local***段是空的，其内容将在函数返回时被丢弃。

* 在函数调用开始时，***argument***段将保存该调用的参数。此段不能被写入。

* ***static***段的内容在函数调用之间保持不变（它将用于稍后在高级语言中处理静态和全局变量）。

* ***temp*** 的行为与***local***相同，但被映射到更小的内存区域。它被设计为“工作空间”，供编译器在从高级语言编译单个指令时使用，而不需要干扰local的内容。

### Hack VM Tokens

![image](https://github.com/user-attachments/assets/fa42eecb-8618-4ef4-b1f3-5da32adaea20)

### Memory and the Stack

* base addrss和offset这组概念非常重要，local后的数字就是偏移量offset，没有一个local地址都是mapped to基地址加上offset

* Hack 虚拟机的每个八个虚拟内存段都连接有 64KB 的内存（以 32,768 个 16 位字组成）。另外，它还有一个可以无限增长的堆栈。Hack CPU 总共支持 64KB 的内存。因此，某些东西必须有所取舍。

* HACK assembly key word
  
  * 局部变量段（local）的基地址存储在 `RAM[1]` 中，即 `LCL`。
  
  * 参数段（argument）的基地址存储在 `RAM[2]` 中，即 `ARG`。
  
  * 指针段（pointer）被分配了长度为 2 的固定段，基地址为 3。所以：
  - `this` 的基地址（即 `pointer 0`）存储在 `RAM[3]` 中，即 `THIS`。
  
  - `that` 的基地址（即 `pointer 1`）存储在 `RAM[4]` 中，即 `THAT`。
  * 临时段（temp）被分配了长度为 8 的固定段，基地址为 5。
  
  * 静态段（static）被分配了长度为 240 的固定段，基地址为 16。
  - 如果编译文件 `Foo.vm`，则地址 `static 5` 应该映射到 Hack 汇编变量 `Foo.5`。（解释将在下周进行！）
  * 常量段（constant）不会出现在物理内存中。

* 堆栈顶部一个字（word）之后的地址存储在 `RAM[0]` 中，即 `SP`（SP 代表堆栈指针）。
  
  当我们将一个新值 `x` 压入堆栈时，我们将 `x` 写入 `RAM[SP]`，然后递增 `SP`。
  
  当我们将一个值从堆栈弹出并存入 `RAM[i]` 时，我们先递减 `SP`，然后将 `RAM[SP]` 的值复制到 `RAM[i]`。

* **堆栈指针（SP）**：堆栈顶部一个字之后的地址存储在 `RAM[0]` 中，这个位置称为堆栈指针（SP）。它指向堆栈的下一个空闲位置，表示下一个值应该放置在哪里。

### Extending VM by Function Call - Flow Control

* On function return: Program flow returns to the line after the original function call. The local variables x and y return to their old values. The argument variable n returns to its old values. The static variables times called and layers deep are unchanged

* Function call goal
  
  * 目标 1：程序流程。在函数调用时，我们应该跳转到函数的开始。在函数返回时，我们应该跳回到调用的地方。
  
  * 目标 2：内存分配。在函数调用时，我们应该为新的局部变量和参数变量分配内存。在函数返回时，我们应该释放这些内存。
  
  * 目标 3：程序状态。在函数调用时，我们应该保存所有现有的局部变量、参数变量和大多数寄存器值，并用新的值替换它们。在函数返回时，我们应该恢复它们，使其保持不变。
  
  * 目标 4：静态变量不应受到函数调用和返回的影响。

* 因为Hack VM层面才有stack，hack assembly层面没有stack，但还是用栈思想来设计functioncall的流程控制

* Function call时 store the address to stack, push the address to stack, then jump;On return, pop the return address from the stack, then jump to it

### Memory Allocation

* 编译器需要： 每次调用函数时，为已知数量的已知大小的局部/参数变量找到空间。

* 假设每个变量占用一个字的存储空间，我们将参数存储在底部，然后是局部变量，然后是程序状态。（具体顺序其实并不重要。） 对第 i 个参数变量的引用变为对 `RAM[OSP + i]` 的引用。 对第 i 个局部变量的引用变为对 `RAM[OSP + 7 + i]` 的引用。

* 我们将需要压入栈中的程序状态部分（例如返回地址、旧的 OSP 值、旧的寄存器值）称为调用函数的调用帧（call frame），或简称为帧（frame）。在上一张幻灯片中，我们称其为“旧状态”。
  
  程序仍然可以使用栈的顶部部分作为在函数内部进行算术操作的工作存储空间。我们将这个子栈称为工作栈（working stack），并将整个栈（包括所有过去的调用帧）称为全局栈（global stack）

* 所有的算数都使用二进制补码 2‘s complement

* frame 帧

* call frame 调用帧

* push到stack上的旧的Program State被称为call frame

* global stack全局栈

* 函数内部仍可用的stack顶部的sub stack叫做working stack

* 调用子函数时当前的working stack 回合其余旧的state一起保存

* 不同阶段的SP - 假设function f 会用10 word的局部变量， 7 word参数变量和 5 word 当前程序状态
  
  * Call function
    
    将当前的SP存在一个register中，作为Old Stack Pointer - OSP；
    
    将SP value +=10，因为架设了call 一次用10个word局部变量
    
    再将SP value +=12（5 word program state 7word argument），依次将Program State 和arguments塞进stack
    
    然后跳转到function label
  
  * Function execute
    
    将  arguments,  local,  program state 自下而上存储
    
    对第 i 个参数变量的引用变为对 `RAM[OSP + i]` 的引用。
    
    对第 i 个局部变量的引用变为对 `RAM[OSP + 7 + i]` 的引用。（因为7个argument是预设的）
  
  * Function return 
    
    存储返回值 optional
    
    将SP重新设为OSP
    
    将之前的Program State复制到寄存器
    
    跳转到返回地址（从Stack里取出的）
    
    Optional对返回值进行操作

### Hack VM function call syntax

* The syntax to return from a function is `return`, which returns the top value of the stack.
* The syntax to call a function is `call name x`, where `name` is the function’s name and `x` is the number of arguments to use. This pops the top x values of the stack
* The syntax to define a function is `function name x`, where `name` is the function’s name and `x` is the size of the function’s local segment

### Function Declaration in VM to Assembly

假设我们的虚拟机翻译器遇到了代码行 `function myFunc 3`。在右侧，我们继续上张幻灯片的例子。我们生成的汇编代码必须：

1. **生成标签：**
   
   * 每当虚拟机翻译器遇到一个函数声明时，首先要生成一个标签（label），该标签用于标识函数的入口点。在汇编代码中，这个标签将是函数开始执行的位置。
   
   * 这个标签通常可以直接从函数名推导出来，这样就不需要额外的符号表来管理标签和函数名之间的映射

2. **设置栈指针（SP）：**
   
   * 函数执行时需要为局部变量分配内存空间。这里的指令将栈指针（SP）设置为局部变量段（LCL）加上局部变量的数量（3）。这一步为函数的局部变量分配了必要的栈空间。

3. **初始化局部变量：**
   
   * 在栈中为局部变量分配空间后，需要将这些变量初始化为零。这里具体提到初始化 `local 0`、`local 1` 和 `local 2`，因为函数声明中指定了 3 个局部变量。

4. **进入函数的实际代码：**
   
   * 完成标签生成、栈指针设置和局部变量初始化后，程序就可以进入实际的函数代码进行执行了。这个步骤相当于函数的主要功能部分开始运行。

### Function Return in VM to Assembly

**存储返回地址：**

- 在函数返回之前，程序需要知道要跳转到哪里，这就是返回地址。通常，返回地址会保存在调用函数时的栈中。为了便于后续操作，返回地址会暂时存储在一个寄存器中，例如 R13。

**复制返回值：**

- 函数的返回值通常存储在栈顶。当函数即将返回时，程序会将这个返回值复制到新的工作栈的位置，即当前 `ARG` 的位置。这是因为 `ARG` 是调用函数时的参数存储位置，当函数返回时，返回值将覆盖最初的参数位置。

**调整栈指针（SP）：**

- 接下来，将栈指针 `SP` 设置为新工作栈的顶部，即 `ARG + 1`。这意味着栈顶现在指向了返回值的上方，准备在返回后进行新的操作。

**恢复旧状态：**

- 在调用函数之前，程序会保存一些关键的状态信息（如 `THAT`、`THIS`、`ARG` 和 `LCL`）在栈中。在函数返回时，这些状态需要恢复，以确保返回后程序能继续正常运行。恢复的过程是从当前 `LCL` 值开始，向下遍历栈，依次恢复这些寄存器的值。

**跳转到返回地址：**

- 最后，程序跳转到返回地址，完成函数的返回操作。这一步同时丢弃了 `SP` 以上的所有栈内容，因为这些内容在函数返回后已经不再需要。

### First Attempt Note Miscs

* **函数调用**: 在汇编语言中，你需要手动处理函数调用。通常，这包括将返回地址（通常是下一条指令的地址）放入 A 寄存器，然后使用 **D=A; @SP; A=M; M=D; @SP; M=M+1** 将其推入栈中，然后使用 **@****函数名** 和 **0;JMP** 来跳转到函数的开始位置。

* **函数返回**: 在函数的末尾，你需要从栈中弹出返回地址并跳转回去。这通常是通过 **@SP; M=M-1; A=M; 0;JMP** 来完成的。

* 在函数调用时，`**LCL**`会被设置为当前的`**SP**`值，因为新的局部变量将从当前栈顶开始被分配。
  
  - **SP**是栈指针，它指向栈顶的下一个位置，即下一个将要被推入的值的位置。
  
  - 在函数调用时，**SP**会递增，因为我们要将返回地址（标签）、**LCL**、**ARG**、**THIS**和**THAT**推入栈中。
  
  - 在函数返回时，SP会被重置回ARG + n的位置，其中n是函数返回值的数量（通常是1）

* 在函数调用时，`**ARG**`会被设置为`**SP - n - 5**`的位置，其中`**n**`是传递给函数的参数数量。”-5”是因为在推入参数之前，栈中已经包含了保存的`**LCL**`、`**ARG**`、`**THIS**`和`**THAT**`，以及返回地址。

* 当我们将一个新值x推入栈时，我们将x写入RAM[SP]，然后增加SP。

* 当我们从栈中弹出一个值到RAM[i]时，我们减少SP，然后复制RAM[SP]到RAM[i]

* 在写VM代码时function名必须包含文件名，比如文件叫Sum.vm 则 function Sum.sum 1

### Function Call 在VM栈以及Assembly层面的同步解读

* 开始call的时候Assembly要以一个label结束，一遍后续return的时候可以回到这个ROM地址
* 在VM层面塞这个label（return address在Nand2课程的slides里）进入栈顶
* 再将Assembly里面 LCL ARG THIS THAT的value依次塞进栈顶；其实也就是将四个段的基地址指针存入Stack
  * LCL RAM[1]  local segment的基地址&起始地址
  * ARG RAM[2]  argument segment 的基地址&起始地址
  * RAM[Pointer 0] - RAM[RAM[3]] this segment 的基地址&起始地址
  * RAM[Pointer 1] - RAM[RAM[4]]  that segment 的基地址&起始地址
* 结合例子来看 call function 2 会将此刻stack 顶上两个弹出并发送给function
  * step 1 建call frame 调用帧 - 搞个label回头可以return跳回来 - 把标签名push进stack
  * step 2 保存当前program state - push LCL ARG THIS THAT 进stack ； Assembly层面需要复制这些值进stack内存（RAM[256]开始的栈内存）到这为止， SP仍然指向标签的地址，两个实参地址肯定就在SP当前的地址（label）下面的两个，然后我们通过操作SP值来得到实参地址来访问实参，在Assembly层面把访问得到的地址值设为new ARG  
  * step3 因为已知call frame从local variable开始，所以讲SP+5（四个旧状态，sp定义为栈顶+1）
  * step4 现在的SP就是New LCL
  * 最后jump到函数定义时的标签，以function Myfunc 3（3代表local variable数量，也就是local段长度）为例，这时将等值的SP和LCL同时+3留下重组空间，并且把三个local variable初始化为0
* Return时
  * return value存在top of stack （VM视角）； 在Assembly层面暂时将它存到一处（比如R13， R13-R15是VM暂存段的范围）
  * 在Vm层面上，下一步是将这个return value复制到 old stack上，到caller stack上，来替代<u>最底层</u>的argument（函数调用时push进栈以供利用的那个，对这个被调用的子函数来说，是bottommost的），也就是当前ARG指向的
  * 如果函数设计上没有argument，那么这个return value有覆写return label return address的可能性。
  * 老的ARG也好OSP也好，其地址都是从现LCL往回计算得到的（砍回其下的Old THAT THIS ARG LCL）
  * 销毁掉局部段，SP变为OSP，set it into ARG+1

```assembly

```

### Hack Jack Memory

* `Memory.alloc`

* `Memory.deAlloc`

* `Sys.init`

* From inside a method definition, the fields of the class variable act as local variables. (This replaces C-style myFoo.x syntax.) The class variable itself can also be accessed via the this keyword, and `methodCall()` is interpreted as `this.methodCall()`.

* both constructors and functions must start with the name of the class. So e.g. let `myFoo = Foo.makeFoo();` is valid Jack code, but let `myFoo = makeFoo(); `is not.

* 在Jack中，通常会为类定义一个名为 `dispose` 的方法，用于在完成对象的其他清理操作后，调用 `Memory.deAlloc(this)` 以释放该对象所占用的内存。

* In Jack, all class-type variables are stored on the heap — only ints, chars and booleans are stored on the stack.  all of these variables are stored as pointers

* The expression `my object[i]` means: go to `the address of my object`, add `i` to it, and return the result.

* **A backdoor into memory**:  For example, the code 
  
  ```
  var int x; 
  let x = 16384; 
  let x[0] = 0
  ```
  
  will set RAM[0x4000] to zero.

* 在Jack语言中，每个文件只包含一个类的声明。

* 文件名为 `Foo.jack` 的文件应包含名为 `Foo` 的类，以及该类的所有字段、方法等内容。

* 在C语言中那些不与结构体关联的部分（例如全局变量和函数）在Jack中应该放在 `Main` 类中。

* 每个Jack程序都会从调用 `Main.main()` 函数开始运行， `Main.main()` 就像C语言中 `main` 函数的对应部分。

* 每个Jack文件都会被单独编译为Hack VM的代码。

* 之后，这些生成的 `.vm` 文件可以通过VM翻译器合并成一个Hack汇编文件，再由汇编器编译成Hack机器码。

* Jack文件可以使用在其他Jack文件中定义的类。

* 编译器会假设这些类可用，并且假设所使用的方法也会存在。

* newlines are <u>***not***</u> tokens in Jack! Like in C, they’re just whitespace.

* all variables must be declared at the start of a class

* Jack is an LL(2) language

* 在解析我们的 token 列表时，我们将维护两个 token 指针：`current` 和 `lookahead`。始终 `current` 是我们尚未解析的第一个 token，`lookahead` 是第二个 token。

* Hack Jack 在VM层面的处理
  
  * **Local Segment (`local`)**:
    
    - 变量通过 `var` 声明后，会存储在 `local` 段中。具体来说，这些变量通常是在子程序体（`subroutineBody`）的开始部分声明的，属于局部变量。
  
  * **Argument Segment (`argument`)**:
    
    - 函数参数会存储在 `argument` 段中。这些参数通常在子程序声明（`subroutineDec`）中的参数列表（`parameterList`）部分被声明。
  
  * **Static Segment (`static`)**:
    
    - 使用 `static` 声明的变量会存储在 `static` 段中。这些变量是静态变量，通常在类的开始部分（`classVarDec`）声明，属于类级别的变量。
  
  * **This Segment (`this`)**:
    
    - 使用 `field` 声明的变量会存储在 `this` 段中。`field` 声明的变量属于实例变量，即属于对象本身。它们通常在类的开始部分（`classVarDec`）声明。
  
  * **That Segment (`that`)**:
    
    - `that` 段通常用于编译涉及数组或字段变量的表达式时。它和 `this` 段一起使用，`this` 用于字段变量，`that` 用于处理数组索引的情况。
  
  * **Temp Segment (`temp`)**:
    
    - `temp` 段用于临时存储数据，特别是在编译单个语句时，需要临时保存中间结果。
  
  * **Pointer and Constant Segments**:
    
    - `pointer` 和 `constant` 段的用途已经很明确：`pointer` 用于处理内存指针，`constant` 用于处理常量值。
  
  * 在 Hack VM 中，控制流是通过 goto 和 label 实现的。因此，当你开始编译一个 while 语句时，你首先需要生成两个唯一的标签，以标记循环的开始和结束位置。例如，while_start_4 可以表示循环的起点，while_end_4 可以表示循环的终点。
  
  * 在 Hack VM 中，控制流是通过 goto 和 label 实现的。因此，当你开始编译一个 while 语句时，你首先需要生成两个唯一的标签，以标记循环的开始和结束位置。例如，while_start_4 可以表示循环的起点，while_end_4 可以表示循环的终点。
  
  * 使用 advance_tag 来移动到 ⟨expression⟩，并调用 compile_expression 函数，将条件表达式编译成 VM 代码。这个表达式的结果会被推入栈中。
  
  * 输出 not 指令（用于取反表达式的结果），然后输出 if-goto while_end_4。这意味着如果条件表达式为假（即结果为 0），则跳转到 while_end_4 标签处，结束循环。
  
  * 使用 advance_tag 移动到循环体的 ⟨statements⟩，并调用 compile_statements 来编译循环体中的所有语句。
  
  * 输出 goto while_start_4，这会使程序跳转回循环的起点，再次检查条件。然后输出 label while_end_4，标记循环的结束位置。
  
  * 最后，使用 advance_tag 跳过 ‘}’ 和 </whileStatement> 标签，并从 compile_while 函数返回。此时，整个 while 语句的 VM 代码已经生成完毕。

![image](https://github.com/user-attachments/assets/3baa404c-5978-4bb8-b17f-740fa1c7451b)

![image](https://github.com/user-attachments/assets/4179e9e2-5707-4f4e-99f2-0197fdf26d8b)

* 当编译器遇到子程序调用时，它需要将传递给子程序的所有参数（表达式）压入栈中。接着，生成一个 `call` 指令，调用对应的子程序（例如 `myClass.mySub`）。这样，程序在运行时会正确地跳转到子程序并使用提供的参数。

* 当编译器处理子程序的参数列表和局部变量声明时，它会建立一个符号表来跟踪这些变量。在实际生成代码时，符号表会帮助编译器将这些变量替换为具体的本地变量和参数，并确保它们在子程序体中被正确引用

* 当子程序需要返回时，编译器需要将返回值（如果有的话）压入栈中。如果没有返回值，则压入一个虚拟值以占位。然后，编译器生成一个 return 指令，使程序能够正确返回到调用子程序的地方。

* `doStatement` 通常用来调用子程序，但由于它不关心返回值，因此在调用之后，返回值仍然留在栈上。如果不处理，这会导致栈上的“内存泄漏”（即不必要的数据残留在栈中）。因此，编译器需要插入一个指令（例如 `pop temp 0`）来清除栈顶数据。

![image](https://github.com/user-attachments/assets/23c2db8c-9e6d-4790-8df8-683b950c9d97)

### Symbol table generating in Jack to VM

* 符号表的创建：
  
  * 在编译一个类时，当编译器遇到类的开头标签（即 ⟨class⟩）时，会为该类创建一个新的符号表。这个符号表用于跟踪类中的所有字段和静态变量。

* 字段和静态变量的条目：
  
  * 每个 classVarDec（类变量声明）中声明的变量都会在符号表中添加一个条目。field 变量和 static 变量分别分配不同的偏移量，以确保它们在内存中的位置是唯一的和有序的。这些偏移量将用于生成代码时访问这些变量。

* 使用符号表生成代码：
  
  * 在处理类中的子程序声明（⟨subroutineDec⟩）时，编译器会使用之前创建的类符号表来正确生成访问类变量的代码。这确保了子程序中对类字段和静态变量的访问是正确的。

* 符号表的释放：
  
  * 当编译器遇到类的结束标签（⟨class⟩）时，类的符号表就不再需要了，因此会被释放。这是一种资源管理的做法，确保符号表只在需要的时候存在。

### Jack details 2

* In Jack, every object is a pointer-based array. 
* Example code for comprehensino

```
var Foo myFoo;
//Code to initialise myFoo
Output.PrintInt(myFoo);
```

it will print the RAM address at which myFoo is stored

* If Class Foo has fields x,y and z, defined in that order, then the object myFoo will be like:
  
  * myFoo.x is stored at RAM[myFoo];
  * myFoo.y is stored at RAM[myFoo+1],and
  * myFoo.z is stored at RAM[myFoo+2]

* myFoo[i] == RAM[myFoo + i]

* in the example above, myFoo[2] will evaluate to myFoo.z

* All object fields in Jack are allocated on the heap, but the pointer Foo is stored on the stack like any other var

* 为简单起见，Jack 中的所有对象字段都在堆上分配。指针 `Foo` 像其他变量一样存储在栈上。

* 我们将确保 `this 0` 始终存储在当前对象所指向的地址。如果我们能做到这一点，那么 Jack 中的 `this[i]` 将始终映射到 Hack VM 中的 `this i`。

* 在编译 ⟨subroutineCall⟩ 时，我们必须：
  
  * 仅对于方法：将当前对象压入栈中（并将其添加到符号表中）作为新的第一个参数，然后再编译 ⟨expressionList⟩ 的其他参数。相应地调整生成的 VM call 命令。
  * 编译器需要能够区分方法调用和普通的子程序调用。这可以通过检查是否有 `.` 来实现，`.` 左边的标识符通常是对象实例而不是类名。

* Compile declaration for subFunction
  
  * For method , set point 0 to the base addresss of current object, aka argument 0
  * For constructor, call `Memory.alloc` to allocate segment for object, use Symbol table to confirm the size it should be allocated. Set point 0 to the base address of new allocated object

* 无论是方法还是构造函数，都应避免在子程序体内更改 `pointer 0` 的值。`pointer 0` 应始终指向当前对象的基地址，以确保方法和字段访问的正确性。

* ![image](https://github.com/user-attachments/assets/70719e03-d747-4291-89bf-c70164d161da)

* constructor should always return this

* Method 可以通过对象实例来调用（例如 `myVar.mySub(a,b)`），也可以在<i><u>**当前对象**</u></i>上下文中直接调用（例如 `mySub(a,b)`）。

* On call layer, function and constructor do no extra deal. But methods will take the current object `myVar` as the first argument - `argument 0` and pass to method. Because method need to know it is called on which object

* On start, Functions do no special deal. Constrcutors will set `this` pointer(the base address of this segment) to the new established object's base address. Methods will set this pointer set to current object `myVar` 

* In the body, functions is boring. In constructors and methods , the segment of class `myClassVar` will be interpreted `this.myClassVar`, `myMethod(a)` will be interpreted into `this.myMethod(a)`.

* In return, functions and methods is boring, return as expected. But, constructors will always return `this`, which is the reference of new established obejct.

### Jack2VM - compiling <term>

* When it is a simple constant or expression, push and generating related code in VM

* When it is identifier or string literal -> search symbol table to make sure what kind of identifier it is (argument, local variable, static variables or a field with offset i)
  
  * 如果它是带有偏移量 i 的参数，生成 push argument i。
  * 如果它是带有偏移量 i 的变量，生成 push local i。
  * 如果它是带有偏移量 i 的静态变量，生成 push static i。静态变量在类的所有对象中共享，因此即使在函数中也是有效的。
  * 如果它是带有偏移量 i 的字段，那么要使它在 Jack 代码中有效，我们必须在方法或构造函数中。此时，它属于当前对象，该对象始终存储在 pointer 0。请记住，对象在 RAM 中存储为数组，第 i 个字段在位置 i 上——所以 push this i 就能完成这个工作。

* <u>**如果它同时出现在类和子程序符号表中，则优先考虑子程序符号表。**</u>

### Jack2VM - compiling <term> string literal

如果 ⟨term⟩ 是一个字符串字面量，官方的 nand2tetris 编译方法是：

* 使用 String.new 创建一个具有合适最大长度的新字符串。
* 使用调用 String.appendChar 初始化字符串以匹配字面量。
  * 将 C 字符转换为 Hack VM 整数以传递给 String.appendChar 很容易，因为 Hack 字符集与 ASCII 对齐（参见 Nisan 和 Schocken 的附录 5）——所以你只需将其强制转换为整数即可。
* 将新字符串的地址压入栈中。

非官方的解决方案: 修改 Jack 语法

```
⟨term⟩ ::= integer literal | string literal | 'true' | 'false' | 'null' | 'this' | identifier, '[' ⟨expression⟩ ']' | '(' ⟨expression⟩ ')' | (('-' | '~') ⟨term⟩) | ⟨subroutineCall⟩;
```

```
⟨letStatement⟩ ::= 'let', identifier, '[', ⟨expression⟩ ']', '=', ⟨expression⟩, ';' | string literal;
```

```
⟨expressionList⟩ ::= [(⟨expression⟩) | string literal], {',' (⟨expression⟩ | string literal)}];
```

修改 Jack 语法：

* 幻灯片建议对 Jack 语法进行修改，以更明确地包含字符串字面量的处理。通过在 ⟨letStatement⟩ 和 ⟨expressionList⟩ 中明确表示字符串字面量，编译器可以更好地控制这些字符串的管理和释放。
  
  * 让 compile_expression_list 将字符串字面量参数列表传递回 compile_subroutine_call。
  * 如果第一个参数是字符串字面量，将其再次压入栈中作为另一个参数，并适当增加调用命令的参数计数。
  * 在生成 VM 调用命令后，函数参数仍将保留在栈上（在当前栈指针之上）。
  * 检索所有字符串字面量并对它们调用 String.dispose。如果第一个参数是字符串字面量，则改为对最后一个参数调用 String.dispose。

* 处理 ⟨letStatement⟩：
  
  * 在编译 let 语句时，继续使用官方方法。这意味着如果用户显式地创建了一个指向字符串字面量的指针，那么用户有责任在合适的时机调用 String.dispose 来释放该字符串的内存。

* 处理 ⟨expressionList⟩ 中的字符串字面量：
  
  * 对于 ⟨subroutineCall⟩ 中的 ⟨expressionList⟩，幻灯片建议自动管理字符串字面量的释放。
    编译器应通过 compile_expression_list 将字符串字面量的列表传递给 compile_subroutine_call，然后在生成 VM 调用命令后对这些字符串字面量调用 String.dispose 来释放它们的内存。
    如果第一个参数是字符串字面量，编译器应该将其再次压入栈中作为另一个参数，并相应地增加调用命令的参数数量。

* 潜在问题：
  
  * 一个潜在问题是，第一个函数参数可能会在函数调用结束时被返回值覆盖。因此，建议在处理字符串字面量释放时，如果第一个参数是字符串字面量，则改为对最后一个参数调用 String.dispose，以避免覆盖问题。

### Binary Multiply Assembly

## From Nand 2 Tetris OG

### Stack

![image-20240810001621526 - 副本](https://github.com/user-attachments/assets/b61a6af4-e05e-4d76-87ed-1648713625c1)

### Function Call

![image](https://github.com/user-attachments/assets/7f3c4340-9b3a-4644-ba68-b09999226a86)

![image-20240810131433769](https://github.com/user-attachments/assets/121219c8-7702-4785-aa9d-189c19d260f4)

![image](https://github.com/user-attachments/assets/c277f286-9559-4883-9c80-ae3569de05d3)

* 注意看这个具体实现，包括了call 和 return
* Saved frame是一系列指针
* 执行完毕， the top of callee stack 也就是return value 会覆盖到 argument 0的位置，sp重置为 argument 0那个位置 +1，然后，属于callee function的东西全部就销毁了， LCL ARGS THIS THAT这些指针全部恢复原来值，那个saved frame被读档了

![image](https://github.com/user-attachments/assets/8ea80e1c-3bc9-4b3b-8187-d217616be39f)

![image](https://github.com/user-attachments/assets/96649795-ec13-40d2-a4ee-e624d3b8a042)

![image](https://github.com/user-attachments/assets/319304a6-9cf2-47ed-8042-2c8f0d9d268f)

![image](https://github.com/user-attachments/assets/6d727480-d31f-4060-b63f-cbf379db702e)

## Quiz Error Book

### Quiz 5

![image](https://github.com/user-attachments/assets/827b266c-6462-49c5-aacb-37379a6515c6)

![image](https://github.com/user-attachments/assets/7bb012ee-7b8f-427a-9dec-701d2969686f)

* Binary Operation must have two registers , so A could not add itself
* C-instruction could also do assignment, but only 0, 1, -1
* option F is definitely invalid because binary operation's operands should including D register

![image](https://github.com/user-attachments/assets/4140f26f-2f97-4a2a-b20f-754b1ff014fa)

```
@list_start
D = M
@49
D = D + A
A = D
```

### Quiz 6

![image](https://github.com/user-attachments/assets/7a4cb3f7-cf7a-4f8e-aa55-aabd34e5aa79)

![image](https://github.com/user-attachments/assets/aa38f61f-9032-4534-9a1e-9e51008a803f)

* 微架构是计算机硬件的物理设计——电路图和 PCB 布局。
* 指令集架构 (ISA) 是计算机响应机器代码指令的方式。
* 因此，字长、内存地址空间和支持的寻址模式都是 ISA 的属性。时钟速度、使用的晶体管数量和能效都是微架构的属性。
* C 指令有 3 个操作数：comp、jump 和 dest。
* In absence of stalls, a pipelined CPU average one clock cycle per instruction executed. 时钟周期是最快指令执行的市场，也许同步干别的但真正干完且能干完的只有且仅有一条最短的 instruction

### Quiz 7

* printf in C is a identifier just because it is defined by lib stdio.h
* A parse tree is the same thing as a CST, but not an AST.
* CST 拆解语法树的时候，没有括号不要多心去考虑结合变号问题，都会在BNF定义好的，唯一参考是BNF，照着BNF去拆

### Quiz 8

![image](https://github.com/user-attachments/assets/2944a6ae-777d-44ec-841c-e324f29bb81b)

![image](https://github.com/user-attachments/assets/b95fa631-4b03-4e86-b3df-524d949db5e5)

![image-20240811000511707](C:\Users\Ricardo\AppData\Roaming\Typora\typora-user-images\image-20240811000511707.png)

* 都是同一类型的VM 层面的stack计算问题
* sub操作是先push的减去后push的

![image-20240811000817827](C:\Users\Ricardo\AppData\Roaming\Typora\typora-user-images\image-20240811000817827.png)

* 一方面需要死记硬背
* 一方面需要理清重要的概念：This段是RAM[pointer 0]；that 段是 RAM[pointer 1]
* temp segment max size 8
* 大写的LCL ARG THIS THAT 本质都是一个地址一个指针，我们从里面得到的是地址，所以要把这些东西塞进RAM[ ? ] 去找内存段真正的值
* R5- R12 用来存temp值只能死记硬背

![image](https://github.com/user-attachments/assets/59eba210-64ca-480b-a286-ae6b331dc0c2)

* The global stack now spans RAM[256] - RAM[308], so 53 values.王牌做题技巧，就是直接从RAM[256]这个stack段的基地址开始摁数

* Solution Diagram shows below
  
  ![76C79A66-C574-475F-896B-453D8A182134](https://github.com/user-attachments/assets/07768c95-5b5b-4b32-add3-d62953452411)

![image](https://github.com/user-attachments/assets/90ab8c25-2834-42ec-b710-adffa48036b7)

* Hack VM 程序的栈有一个固定的大小，每次递归调用都会消耗栈上的一部分空间。每个函数调用至少需要 5 个字的栈空间，而栈从地址 256 开始。经过 360 次递归调用后，栈指针的位置将达到 256 + 360*5 = 2056，这超出了栈的限制，导致栈溢出，进入了从地址 2048 开始的堆空间。
* 在将 VM 代码翻译成汇编代码时，VM 翻译器只是将标签转换为汇编标签，并不管理汇编代码中的 ROM 地址。地址管理工作由Assembler完成，而不是 VM 翻译器。
* 不同的编程语言可以使用相同的中间表示（IR）
* 在 Hack VM 中，函数的命名遵循文件名的基础名称（不包括 ".vm" 扩展名），后面跟一个点和一个描述性的函数名称。例如，如果文件名是 `Example.vm`，那么函数名可能是 `Example.functionName`

![image](https://github.com/user-attachments/assets/0722952f-3208-4233-bb66-62fa0bd3409a)

* **堆内存管理**:
  
  - **手动释放**: 堆上分配的内存不会自动释放，必须由程序员使用 `free()` 函数来手动释放。
  
  - **运行时分配**: 如果你在程序运行过程中才知道变量的大小，就需要在堆上分配内存（例如，通过 `malloc()`）。
  
  - **长度未知的字符串**: 在 C 语言中，如果你处理的字符串长度在编译时不知道（例如，通过用户输入获取的字符串），它们会在堆上分配内存。

* **栈内存管理**:
  
  - **函数返回时释放**: 栈上分配的内存是局部的，只有在函数调用结束后，这些内存才会被自动释放。
  
  - **编译时分配**: 如果变量的大小在编译时已经知道，就可以在栈上分配这些变量（例如，局部变量）。
    Translate it into Chinese and explain it more vividly and simple in Chinese. 
  
  - **指针的栈分配**: 在 C 语言中，局部变量包括指针通常是在栈上分配的。虽然指针的值（即内存地址）存储在栈上，但它们指向的内存（如果通过 `malloc()` 等方式分配）则可能在堆上。

![image](https://github.com/user-attachments/assets/7acb42b9-9d0b-49ee-94aa-509edea2ea01)
![image](https://github.com/user-attachments/assets/5f9c401a-67fe-4c3b-add2-2eddf51cde46)

* local变量一有子函数调用它就清零了，所以从头至尾只有静态段的static 0一直在*2，在调用了三次的子函数中每次翻倍后都是和被进入子函数调用而归零的local 0相加，也就是翻了八倍。

### Quiz 9

<img width="817" alt="image" src="https://github.com/user-attachments/assets/11d4a110-f318-45fe-934b-021d5e9e48f2">

<img width="563" alt="image" src="https://github.com/user-attachments/assets/a5edf90c-a023-427d-aaad-86baef10eedb">
*

* 从反馈信息中可以看出，栈用于所有以下用途：
  
  - **存储局部变量**：在函数调用期间，栈会用来存储函数的局部变量。
  - **存储调用帧**：栈用于存储每个函数调用的信息（即调用帧），包括返回地址、参数和局部变量。
  - **计算复杂的算术表达式**：栈常常用于保存和计算复杂的算术表达式的中间结果。
  - **计算复杂的逻辑表达式**：同样，栈也用于计算逻辑表达式。

### Mock Theory

![image](https://github.com/user-attachments/assets/8dbc8fb2-2106-48b4-8a70-d84f03cf090b)
![image](https://github.com/user-attachments/assets/bbe76c4d-9ca8-4897-9b80-68e6374e7add)

* Assembly do the label , VM just turn VM label into assembly label
* malloc and free themselves can't defragment memory

![image](https://github.com/user-attachments/assets/d4ac3564-3e16-4d1e-84bb-d5025c40dfdc)

* Remember, an object in Jack is just a pointer, and is stored on the stack like any other variable. The memory it points to contains the object's fields and lives on the heap.

![image](https://github.com/user-attachments/assets/0f91b6a5-ee63-4e9a-a2f4-6672f847df8f)
![image](https://github.com/user-attachments/assets/9ad2795f-fdf1-499f-882b-04181bfa5db1)
![image](https://github.com/user-attachments/assets/e56b3b83-9fd1-4cd5-911a-0df0e6f67367)

* **The first address in segment**
  
  * 用来表示段中可以使用的空间有多大。
  * 假设一个段从地址 0x1106 到 0x759，计算可用空间后，得出总共是 0x9AE 个地址，<u>**但要减去 3 个用来存储段信息的地址**</u>，所以实际可用空间是 0x9AB。

* **The second address in segment**
  
  * 如果存的是 0x0000，表示这个段已经被使用；
  * 如果是 0xFFFF，表示这个段是空闲的。

* **The third and fourth address**
  
  * If and only if this segment is free
  * The third one is used for connecting previoud free segment
  * The fourth one is used for connecting the afterward free segment

* Calculate the size
  
  * Last address - First address +1 - 3 = size

* Revised Answer:
  
  * a)0x9AB
  * b)Impossible to tell
  * c)Impossible to tell
  * d)0xDF
  * e)0x75B
  * f)Impossible to tell
  * g)Impossible to tell
  * h)Correct answer not listed - 0x2FE

![image](https://github.com/user-attachments/assets/228a1e9b-1958-4307-9954-00699df8493d)

* Explanation from Blackboard:
  
  * a) In order for lines 3 and 4 to be doing anything meaningful with "this", line 2 had better be setting it. With pop pointer 0, we set this 0 to the string's current length, this 1 to the string's maximum length, and this 2 to the base address of the string's array.
  
  * b) We want to avoid crashing if the current length is less than the maximum length, i.e. if this 0 < this 1. The top of the stack will be "true" if and only if this 0 < this 1, and the function call to Sys.error is right between this and the nocrash label, so we should write "if-goto nocrash".
  
  * c) We want to call Sys.error while passing only one value as an argument - namely the top value of the stack (52) - so we need to "call Sys.error 1".
  
  * d) Remember that this 2 stores the base address of the string's array, and this 1 is the string's current length, i.e. the number of characters it contains. So the current string is stored in RAM[this 2], RAM[1 + this 2], ..., RAM[this 0 + this 2 - 1], and the new last character should be stored at address this 0 + this 2. That's at the top of the stack right now, so we should "push local 0" to store it where the comment tells us to.
  
  * e) We've just transferred the address the new character should be stored at into pointer 1, which holds the base address of "that". So we can store the new character (which is argument 1) at this address with "pop that 0".
  
  * f) We always have to return at the end of every function in Hack VM.

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