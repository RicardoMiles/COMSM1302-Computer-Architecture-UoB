# Valuable info from Q&A channel

## Jack - object and its fields storage

* Object is a pointer stored on the stack
* Object fields are stored on the heap aka allocated on the heap



## Hack CPU -pipeline

* each clock cycle (after the pipeline has been filled) the CPU will finish one instruction (unless there is a stall) -- hence the average of one instruction per cycle.  每个周期不止执行一条，但是执行完的只有一条
* It is limited to one instruction per clock cycle (e.g., cannot be two instructions per clock cycle) because the final unit in the pipeline can handle only a single instruction at a time, and so is limited to finishing a **maximum of one instruction per clock cycle.**



## Hack Assembly - A register could not be manipulated at a jump instruction

* A=D;JEQ   **invalid**
* **A value could not change if there is a jump condition**
* One instruction per cycle, if manipulate A at the same time, there is two instruction
  * Update the value of A and set it into D
  * set the PC to the value of D



## Handy Trick for VM 2 Assembly

* Store the return address in R13, and jump back to it

  ```assembly
  @R13
  A = M
  0;JMP
  ```





## Lexing v.s. Parsing

*  During Lexing are the labels dealt with a symbol table and then in Parsing variables are dealt with
* parsing doesn’t deal with symbol tables
* variable tables are being done while parsing is happening



# General Assembly Feature

* assembly language should map 1 to 1 with the machine code





## Memory Allocation Attemp 3

* Last address - First address + 1 - 3
* final segment - first segment +1 -3



## Hack Assembly - Strict ordering when multiple assignment

* When there is multiple assignment, the register to be set should in the order AMD
*  if you are assigning M to both A and D, then AD=M is valid, but DA=M is not.  



# Hack VM - bitwise NOT should make the number 16 bits then flips all the bits

* E.g. 157  ->0b 1001 1101, it should be 0b 0000 0000 1001 1101, then do the flips   -> 0b 1111 1111 0110 0010



# Mapping RAM address in VM to Assembly

* Argument = RAM[ARG] = RAM[RAM[2]]
* Local = RAM[LCL] = RAM[RAM[1]]
* This = RAM[pointer 0] = RAM[THIS] = RAM[RAM[3]]
* That = RAM[pointer 1] = RAM[THAT] = RAM[RAM[4]]



## Hack VM - stack calculation

![image](https://github.com/user-attachments/assets/1451c925-2121-404a-9b29-7b45266f2092)

* SP 指向stack上的第一个未占用地址。 因此，SP 指向的条目不会被占用，并且在**计算堆栈中的条目数时不应包括在内。**
* 堆栈的基数为 256 ，计算堆栈内条目因该是 SP - 256



## Handy Trick to consider the instruction in RISC v.s. CISC

* A good rule of thumb is to ask if the instruction could be broken down into two or more different instructions.  If so, it’s likely to be a CISC instruction only.



## RAM size in Hack ISA v.s. Hack microarchitecture

* ISA size : 32 KB
* Micro-architecture: 64 KB



## Deep comprehension about Hack VM object

* Because objects in Hack VM are just arrays, we access them using the array pointer 'this'.  The values of this are determined by the value of 'pointer 0' (see attached slide from 9th week -- lecture 3).  





