# Arithmetic-Analyzer-in-Scheme

## Description: 
A simple Arithmetic Analyzer machine in Scheme which displays data +, -, *, / operations on numerical values. 
As well as catching syntax errors when invalid string is entered.

How to run the program:
You will need a Scheme compiler to run this program, suggested compiler is DrRacket.
When click on Run, DrRacket will open a console prompting  user input:

```
  (compile)
```  

An input field will appear in console, user can input string such as:
```
 ( + -.123123123 (- (*  3 5) (/ 123. 4234.2) ))
``` 
  
Press Enter.

The compiled operations will be:

* move 3 register-1
* move 5 register-2
* times register-1 register-2
* move 123. register-3
* move 4234.2 register-4
* divide register-3 register-4
* subtract register-1 register-3
* move -.123123123 register-5
* add register-5 register-1
  
* SUCCESSFULLY COMPILED!!!

It is assumed that the number of registers are unlimited (which is not the case in real life), reusing registers would be more realistic.

## Implementations:
The program currently parse real number using regular expression:
`(define number "[-+]?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)")`
This expression will be valid for: `-.1231`, `-1231.`, `+1231.2312`, but not `-.`
You can modify this to only parse simple integer instead of real number using
`(define number "[-]?([0-9]+)")`

The compilation process is done within `extractConstant` and `extractString`.
When the input string is parsed as stand alone constant: `3`, `   3    `, ` (3)`, extractConstant will be called, otherwise it will be compiled by extractString.

```
(define (extractConstant input registerCount)
  (let*
      ([numberExpression (pregexp number)]
       [extractedNumber (first (regexp-match numberExpression input))]
       [inputValueCount (length (regexp-match* numberExpression input))])
    (when (> inputValueCount 1)
      ;If the input string has more than 2 number, returns a syntax error message
      (error "Syntax Error: There are more than 1 constants in the input string"))
    (moveValue extractedNumber registerCount) ;Display the move call to store value into register
    (display result) 
    (newline) 
    (display "SUCCESSFULLY COMPILED!!!")))
```

extractString is a recursive function which parse and compile any valid arithmetic expression (check Errors Catching for expression grammar.

The error checking process and checking if the string is successfully compiled is as followed.
```
(define (extractString input registerCount)
    ...
    ; Escape program when syntax error occurs or all of the expressions are evaluated
    ; In this part, the expression (<op> <exp> <exp>) doesn't exist
    ; The program will parse the current input string to find out what is missing and return error message properly
    (when (equal? validExpression #f)
      (when (list? (regexp-match phrase input))
        (display result) 
        (newline) 
        (display "SUCCESSFULLY COMPILED!!!"))
      (when (equal? (regexp-match phrase input) #f)
        (cond
          [(equal? (regexp-match (pregexp openBracket) input) #f) (error (string-append "Syntax Error: Missing '('\nStack Trace: " input))]
          [(equal? (regexp-match (pregexp (string-append openBracket optionalSpace operator)) input) #f) (error (string-append "Syntax Error: Missing OPERATOR '+-*/'\nStack Trace: " input))]
          [(equal? (regexp-match (pregexp (string-append optionalSpace operator requiredSpace numericExp)) input) #f) (error (string-append "Syntax Error: First Expression is MISSING or NOT CORRECT\nStack Trace: " input))]
          [(equal? (regexp-match (pregexp (string-append optionalSpace operator requiredSpace numericExp requiredSpace numericExp)) input) #f) (error (string-append "Syntax Error: Second Expression is MISSING or NOT CORRECT\nStack Trace: " input))]
          [else (error (string-append "Syntax Error: Missing ')'\nStack Trace: " input))])))
```
Regular expression which was used for error checking was replaced by `...`, please check the coded for more information.

Once the error checking process is done without terminating the program, the string will be parsed and recursed:
```
(cond 
          [(and (list? (regexp-match phrase firstParam)) (list? (regexp-match phrase secondParam))) 
           (computeExpression sign firstParam secondParam)
           (extractString (string-replace input (first validExpression) firstParam) registerCount)]
          [(list? (regexp-match numberExpression firstParam)) 
           (moveValue firstParam registerCount) 
           (extractString (string-replace input extractedElements (string-replace extractedElements firstParam replaceString #:all? #f) #:all? #f) (+ registerCount 1))]
          [(list? (regexp-match numberExpression secondParam)) 
           (moveValue secondParam registerCount) 
           (extractString (string-replace input extractedElements (string-replace extractedElements secondParam replaceString #:all? #f) #:all? #f) (+ registerCount 1))]
          [else (error "Something went wrong during parsing")])))))
```
The program replaces the input string with "register-x" after that expression is compiled, and pass the new input string to recursive process.
For example:
`(+ 3 2)` -> `(+ register-1 2)` -> `(+ register-1 register-2)` -> `register-1` as the result is stored in the 1st register of the operation.

## Errors Catching:
The program will catch simple syntax error such as missing "(", "+", "-", "*", "/", "/".
Invalid characters that are not "(", "+", "-", "*", "/", "/", digits, ".", space

The expression valid syntax are: 
```
 <arithmetic-expression> → (<op> <arithmetic-expression> <arithmetic-expression>)
                          | <constant>
 <op> → + | - | * | /
```

The validation of arithmetic expression are done at runtime, it will parse from the first valid Expression. Until the program hits an invalid expression
that is not "register-x" or a number in <constant> case.

## Improvements:
The error catching can be improved to show the location of the error in original input string.
The program can be modified to implement stacks to parse expression and catch errors earlier during execution instead of runtime. This will improve performance greately when a big arithmetic opertaion is used.
