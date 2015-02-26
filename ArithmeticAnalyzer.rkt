#lang racket
; Student Name: Nhat Minh Ho - 100815111
; The software below acts as compiler for scheme numerical expressions
; It uses solely regular expression and recursion to perform this task
;
; NOTICE: as extra feature, this program can take in real number: +2322.1231, -.123123, -1231., 312.1412 as well as regular integer
; Therefore, you can go crazy with the input, sample: "        (         +         -.123123123             (-       (    *  3           5          )          (/ 123. 4234.2) ))"
; Since the implementation of this program is different, it will parse from inside out. Therefore, register 1 can be used in the middle of expression.
(define result "") ;The result variable which contains the compilation phrases
(define number "[-+]?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)")
; Main function which users call to run the program, it will read in user input and call extractString
(define (compile)
  (set! result "")
  (define user-input (read-line))
  (let* 
      ([constantDetector (pregexp (string-append "\\([\\s]*" number "[\\s]*\\)|^[\\s]*" number))]
       [validCharacter #px"[(|)|+|\\-|*|/|\\d|\\s|.]"])
    ;Check if the input string contains any strange character or not
    (if (equal? (string-length user-input) (length (regexp-match* validCharacter user-input)))
        ; Check if the input string is just a constant or an expression
      (if (list? (regexp-match constantDetector user-input))
          (extractConstant user-input 1) ;call function to compile a constant
          (extractString user-input 1)) ;call function to compile expression
      (error "Syntax Error: Input string contains strange characters -> only +, -, *, /, (, ), number and space are accepted"))))

; This function is used to extract 1 single constant from the input string
; If the input string is "3.221", "3", "(3.2121)" or "(3)" this function will be called
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

; Recursive function which parse and modify the input string until it reaches final register or run into syntax error
; This function at first will parse through the expression to find any valid expression (<op> <exp> <exp>)
; If it cannot find any expression in that format and the input string is not "register-n" then it has a syntax error
; After it detects a valid expression, it will parse that expression, create compile string and replace expression with "register-n"
; It recurses with new input string which contains the replaced string in place of previous expression.
; The process continues until it hit a syntax error or "register-n" which stores the final result
(define (extractString input registerCount)
  ;(print (string-append "Input: " input)) (newline)
  (let* ([openBracket "\\("]
         [closeBracket "\\)"]
         [operator "[+|\\-|*|/]"]
         [numericExp (string-append "(" number "|register-[\\d]+)")]
         [optionalSpace "[\\s]*"]
         [requiredSpace "[\\s]+"]
         [numberExpression (pregexp (string-append "^" number))]
         [phrase #px"^[\\s]*register-[\\d]+"]
         [expression (string-append optionalSpace operator requiredSpace numericExp requiredSpace numericExp optionalSpace)]
         [errorChecking (pregexp (string-append openBracket expression closeBracket))]
         [extractValue (pregexp expression)]
         [validExpression (regexp-match errorChecking input)])
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
    ; Make sure that validExpression exists, then evaluate and make recursive calls
    (when (list? validExpression)
      (let* ([extractedElements (first (regexp-match extractValue input))]
             [listElements (string-split extractedElements)]
             [sign (first listElements)]
             [firstParam (first (rest listElements))]
             [secondParam (first (rest (rest listElements)))]
             [replaceString (string-append " register-" (number->string registerCount))])
        ; Either move numeric value to register or print out add, subtract, times and divide
        ; The input string is modified as explained above and make recursive call to itself
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

; Function which add times, add, subtract, and divide string to result
(define (computeExpression sign param1 param2)
  (define tempResult "")
  (cond 
    ((equal? sign "*") (set! tempResult "times "))
    ((equal? sign "+") (set! tempResult "add "))
    ((equal? sign "-") (set! tempResult "subtract "))
    ((equal? sign "/") (set! tempResult "divide "))
    (else (error "missing computation sign")))
  (set! result (string-append result tempResult param1 " " param2 "\n")))

; Function to add move command to result
(define (moveValue value registerCount)
  (set! result (string-append result "move " value " register-" (number->string registerCount) "\n")))