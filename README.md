# Micro-go-compiler
# μGo: A Simple Go Programming

# Language

**Compiler 2020 Programming Assignment III**

**μGO Compiler for Java Assembly Code Generation**

**Due Date: June 11, 2020 at 23:**

**Demonstration: June 12, 2020 from 10:00 to 17:**

This assignment is to generate Java assembly code (for Java Virtual Machines) of the given μGO

program. The generated code will then be translated to the Java bytecode by the Java assembler,

Jasmin. The generated Java bytecode should be run by the Java Virtual Machine (JVM)

successfully.

```
Environmental Setup
```
```
Recommended OS: Ubuntu 18.
Install dependencies: $ sudo apt install flex bison
Java Virtual Machine (JVM): $ sudo apt install default-jre
Java Assembler (Jasmin) is included in the Compiler hw3 file.
```
## 1. Java Assembly Code Generation

In this assignment, you have to build a μGO compiler. Figure 1 shows the big picture of this

assignment and the descriptions for the execution steps are as follows.

```
Build your μGO compiler by injecting the Java assembly code into your flex/bison code
developed in the previous assignments.
Run the compiler with the given μGO program (e.g., test.go file) to generate the
corresponding Java assembly code (e.g., test.j file).
Run the Java assembler, Jasmin, to convert the Java assembly code into the Java bytecode
(e.g., test.class file).
Run the generated Java bytecode (e.g., test.class file) with JVM and display the results.
```

```
Constant in μGO Jasmin Instruction
```
```
94 ldc 94
```
```
8.7 ldc 8.
```
```
"Hello world" ldc "Hello world"
```
```
true / false iconst_1 / iconst_0 (idc 1 / ldc 0)
```
```
μGO Operator Jasmin Instruction (int32) Jasmin Instruction (float32)
```
```
+ - (ignore or a blank) - (ignore or a blank)
```
- ineg fneg

```
μGO Operator Jasmin Instruction (int32) Jasmin Instruction (float32)
```
```
+ iadd fadd
```
- isub fsub

```
* imul fmul
```
```
/ idiv fdiv
```
```
% irem -
```
## 2. Java Assembly Language (Jasmin Instructions)

In this section, we list the Jasmin instructions that you may use in developing your compiler.

### 2.1 Literals (Constants)

The table below lists the constants defined in μGO language. Also, the Jasmin instructions that we

use to load the constants into the Java stack are given. More about the load instructions could be

found in the course slides, Intermediate Representation.

### 2.2 Operations

The tables below lists the μGO operators and the corresponding assembly code defined in Jasmin

(i.e., Jasmin Instruction).

#### 2.2.1 Unary Operators

#### 2.2.2 Binary Operators

The following example shows the standard unary and binary arithmetic operations in μGO and

the corresponding Jasmin instructions.


```
μGO Operator Jasmin Instruction
```
```
&& iand
```
```
|| ior
```
```
! ixor (true xor b equals to not b)
```
```
μGO Code:
```
```
Jasmin Code (for reference only):
```
#### 2.2.3 Boolean Operators

```
μGO Code:
```
```
Jasmin Code (for reference only):
```
#### 2.2.4 Comparison operators

You need to use subtraction and jump instruction to complete comparison operations. For int32,

you can use isub. For float32, there is an instruction fcmpl is used to compare two floating-

point numbers. Note that the result should be bool type, i.e., 0 or 1. Jump instruction will be

mentioned at section 2.6.

```
μGO Code:
```
##### - 5 + 3 * 2

```
ldc 5
ineg
ldc 3
ldc 2
imul
iadd
```
```
// Precedence:! > && > ||
true || false && !false
```
```
iconst_1 ; true (1)
iconst_0 ; false (2)
iconst_1 ; load true for "not" operator
iconst_0 ; false (3)
ixor ; get "not" result (4) from (3)
iand ; get "and" result (5) from (2),(4)
ior ; get "or" result from (1),(5)
```
##### 1 > 2

##### 2.0 < 3.


```
Jasmin Code (for reference only):
```
### 2.3 Store/Load Variables

Relative operators: =, +=, -=, *=, /=, %=, ++, --.

#### 2.3.1 Primitive Type

The following example shows how to load the constant at the top of the stack and store the value

to the local variable (x = 9). In addition, it then loads a constant to the Java stack, loads the

content of the local variable, and adds the two values before the results are stored to the local

variable (y = 4 + x). Furthermore, the example code exhibits how to store a string to the local

variable (z = "Hello"). The contents of local variables after the execution of the Jasmin code are

shown as below.

```
μGO Code:
```
```
Jasmin Code (for reference only):
```
```
ldc 1
ldc 2
isub
ifgt L_cmp_
iconst_
goto L_cmp_
L_cmp_0:
iconst_
L_cmp_1:
```
```
ldc 2.
ldc 3.
fcmpl
iflt L_cmp_
iconst_
goto L_cmp_
L_cmp_2:
iconst_
L_cmp_3:
```
```
x = 9
y = 4 + x
z = "Hello"
```
```
ldc 9
istore 0 ; store 9 to x
```
```
ldc 4
iload 0 ; load x
iadd ; add 4 and x
istore 1 ; store the result to y
```
```
ldc "Hello"
astore 2 ; store a string to z
```

```
Index Name Type Address Lineno Element type
```
```
0 x array 0 1 int
```
```
1 y int32 1 2 -
```
#### 2.3.2 Array Type

The following example shows how to create an variable with array type and store/load the array

element. For int32 array, you need to use newarray int to get the reference of an integer array,

and newarray float for float32 array. In this assignment, an array can store only integer or

floating-point values.

**Hint:** You may need swap instruction to implement array load and store.

```
μGO Code:
```
```
Jasmin Code (for reference only):
```
```
Symbol table in this case:
```
```
var x [ 3 ]int
var y int
x[ 0 ] = 999
y = x[ 0 ] + 4
```
```
ldc 3 ; array length
newarray int ; create an array (int32: int, float32: float)
astore 0 ; stroe array variable to local variable 0
```
```
ldc 0
istore 1 ; initialize y with 0
```
```
aload 0 ; load array
ldc 0 ; index of element
ldc 999 ; value to store to the element
iastore ; store 999 to the element (x[0])
```
```
aload 0 ; load array
ldc 0 ; index of element
iaload ; load the element (x[0]) to stack
ldc 4
iadd
istore 1 ; store the result to y
```

### 2.4 Print

The following example shows how to print out the constants with the Jasmin code. Note that

there is a little bit different for the actual parameters of the println functions invoked by the

```
invokevirtual instructions, i.e., int32 (I), float32 (F), and string (Ljava/lang/String;). Note
```
also that you need to treat bool type as string when encountering print statement, and the

corresponding code segments are shown as below.

```
μGO Code:
```
```
Jasmin Code (for reference only):
```
### 2.5 Type Conversions (Type Casting)

The following example shows the usage of the casting instructions, i2f and f2i, where x is

int32 local variable 0, y is float32 local variable 1.

```
μGO Code:
```
```
Jasmin Code (for reference only):
```
```
println( 30 )
print("Hello")
print(true)
```
```
ldc 30 ; integer
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
```
```
ldc "Hello" ; string
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
```
```
iconst_1 ; true
ifne L_cmp_
ldc "false" ; we should load "false" and "true" as string literal for
printing
goto L_cmp_
L_cmp_0:
ldc "true"
L_cmp_1:
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
```
```
x = x + int32(y)
```
```
iload 0 ; x
fload 1 ; y
f2i ; convert y to int
iadd ; add them
istore 0 ; store to x
```

```
Jasmin Instruction Description
```
```
goto <label> direct jump
```
```
ifeq <label> jump if zero
```
```
ifne <label> jump if nonzero
```
```
iflt <label> jump if less than zero
```
```
ifle <label> jump if less than or equal to zero
```
```
ifgt <label> jump if greater than zero
```
```
ifge <label> jump if greater than or equal to zero
```
### 2.6 Jump Instruction

The following example shows how to use jump instructions (both conditional and non-conditional

branches). Jump instruction is used in if statement and for statement.

```
μGO Code (if statement, x is an int32 variable):
```
```
Jasmin Code (for reference only):
```
```
if x == 10 {
/* do something */
} else {
/* do the other thing */
}
```
```
iload 0 ; load x
ldc 10 ; load integer 10
isub
ifeq L_cmp_0 ; jump to L_cmp_0 if x == 0; if not, execute next line
iconst_0 ; false (if x != 0)
goto L_cmp_1 ; skip loading true to the stack by jumping to L_cmp_
L_cmp_0: ; if x == 0 jump to here
iconst_1 ; true
L_cmp_1:
ifeq L_if_false
; do something
goto L_if_exit
L_if_false:
; do the other thing
L_if_exit:
```

```
μGO Code (for statement, x is an int32 variable):
```
```
Jasmin Code (for reference only):
```
### 2.7 Setup Code

A valid Jasmin program should include the code segments for the execution environment setup.

Your compiler should be able to generate the setup code, together with the translated Jasmin

instructions (as shown in the previous paragraphs). The example code is listed as below.

```
Filename: hw3.j (generated by your compiler)
```
```
for x > 0 {
x--
}
```
```
L_for_begin :
iload 0 ; x
ldc 0
isub
ifgt L_cmp_
iconst_
goto L_cmp_
L_cmp_0 :
iconst_
L_cmp_1 :
ifeq L_for_exit ; exit when the condition is false
iload 0 ;---+
ldc 1 ; +--- (x--)
isub ; |
istore 0 ;---+
goto L_for_begin ; goto loop begin
L_for_exit :
```
```
.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100 ; Define your storage size.
.limit locals 100 ; Define your local space number.
```
```
; ... Your generated Jasmin code for the input μGO program ...
```
```
return
.end method
```

### 2.8 Workflow Of The Complier

You are required to build a μGO compiler based on the previous two assignments. The execution

steps are described as follows.

```
Build your compiler by make command and you will get an executable named mycompiler.
Run your compiler using the command $ ./mycompiler < input.go, which is built by lex
and yacc, with the given μGO code (.go file) to generate the corresponding Java assembly
code (.j file).
The Java assembly code can be converted into the Java Bytecode (.class file) through the
Java assembler, Jasmin, i.e., use $ java -jar jasmin.jar hw3.j to generate Main.class.
Run the Java program (.class file) with Java Virtual Machine (JVM); the program should
generate the execution results required by this assignment, i.e., use $ java Main.class to
run the executable.
```
## 3. What Should Your Compiler Do?

In Assignment 3, the flex/bison file only need to print out the error messages, we score your

assignment depending on the JVM execution result, i.e., the output of the command: $ java

Main.class.

When ERROR occurs during the parsing phase, we expect your compiler to print out ALL error

messages, as Assignment 2 did, and DO NOT generate the Java assembly code (.j file).

### Each test case is 10pt and the total score is 130pt

There 13 test cases which are all included in the Compiler hw3 file.


## 5. References

```
Jasmin instructions: http://jasmin.sourceforge.net/instructions.html
Java bytecode instruction listings: https://en.wikipedia.org/wiki/Java_bytecode_instruction_lis
tings
Java Language and Virtual Machine Specifications: https://docs.oracle.com/javase/specs/
The Go Playground: https://play.golang.org/
```
