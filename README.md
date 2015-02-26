# Arithmetic-Analyzer-in-Scheme

Description: 
A simple Arithmetic Analyzer machine in Scheme which displays data +, -, *, / operations on numerical values. 
As well as catching syntax errors when invalid string is entered.

How to run the program:
You will need a Scheme compiler to run this program, suggested compiler is DrRacket.
When click on Run, DrRacket will open a console prompting  user input:

  > (compile)

An input field will appear in console, user can input string such as:
  ( + -.123123123 (- (*  3 5) (/ 123. 4234.2) ))
Press Enter.

The compiled operations will be:

  move 3 register-1
  move 5 register-2
  times register-1 register-2
  move 123. register-3
  move 4234.2 register-4
  divide register-3 register-4
  subtract register-1 register-3
  move -.123123123 register-5
  add register-5 register-1
  
  SUCCESSFULLY COMPILED!!!

It is assumed that the number of registers are unlimited (which is not the case in real life), reusing registers would be more realistic.

Errors Catching:
The program will catch simple syntax error such as missing "(", "+", "-", "*", "/", "/".
Invalid characters that are not "(", "+", "-", "*", "/", "/", digits, ".", space

The expression valid syntax are: 
  <arithmetic-expression> → (<op> <arithmetic-expression> <arithmetic-expression>)
                          | <constant>
  <op> → + | - | * | /

The validation of arithmetic expression are done at runtime, it will parse from the first valid Expression. Until the program hits an invalid expression
that is not "register-x" or a number in <constant> case.

Improvements:
The error catching can be improved to show the location of the error in original input string.
The program can be modified to implement stacks to parse expression and catch errors earlier during execution instead of runtime. This will improve performance greately when a big arithmetic opertaion is used.
