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

In this assignment, you have to build a μGO compiler.

assignment and the descriptions for the execution steps are as follows.

* Build your μGO compiler by injecting the Java assembly code into your flex/bison code developed in the previous assignments.
* Run the compiler with the given μGO program (e.g., test.go file) to generate the corresponding Java assembly code (e.g., test.j file).
* Run the Java assembler, Jasmin, to convert the Java assembly code into the Java bytecode (e.g., test.class file).
* Run the generated Java bytecode (e.g., test.class file) with JVM and display the results.

### 2 Workflow Of The Complier

You are required to build a μGO compiler based on the previous two assignments. The execution

steps are described as follows.

* Build your compiler by make command and you will get an executable named mycompiler.
* Run your compiler using the command $ ./mycompiler < input.go, which is built by lex and yacc, with the given μGO code (.go file) to generate the corresponding Java assembly code (.j file).
* The Java assembly code can be converted into the Java Bytecode (.class file) through the Java assembler, Jasmin, i.e., use $ java -jar jasmin.jar hw3.j to generate Main.class.
* Run the Java program (.class file) with Java Virtual Machine (JVM); the program should generate the execution results required by this assignment, i.e., use $ java Main.class to run the executable.

## 3. What Should Your Compiler Do?

In Assignment 3, the flex/bison file only need to print out the error messages, we score your

assignment depending on the JVM execution result, i.e., the output of the command: $ java

Main.class.

When ERROR occurs during the parsing phase, we expect your compiler to print out ALL error

messages, as Assignment 2 did, and DO NOT generate the Java assembly code (.j file).

### Each test case is 10pt and the total score is 130pt

There 13 test cases which are all included in the Compiler hw3 file.


## 4. References

* Jasmin instructions: http://jasmin.sourceforge.net/instructions.html
* Java bytecode instruction listings: https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings
* Java Language and Virtual Machine Specifications: https://docs.oracle.com/javase/specs/
* The Go Playground: https://play.golang.org/
