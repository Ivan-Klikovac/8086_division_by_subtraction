org 100h

; prints input1
MOV AH, 09h
LEA DX, string_input1
INT 21h

; input the first number
MOV AH, 01h
INT 21h; getchar
SUB AL, '0'; get the digit from its ascii code
MOV CL, AL; cx will be the storage

input1_loop:
MOV AH, 01h
INT 21h
CMP AL, 13; is it enter?
JE input1_end; if so, input is done
SUB AL, '0'
MOV buffer, AL; save the input
MOV AX, CX; multiplication is in ax
MUL ten; multiply the previous number by 10
MOV BL, buffer; turning buffer into an 8 bit value in order to add it with a register
MOV BH, 0
ADD AX, BX
MOV CX, AX; save it for the next iteration
JMP input1_loop


input1_end:
MOV AH, 02h
MOV DL, 10
INT 21h; newline

MOV number1, CX

; prints input2
MOV AH, 09h
LEA DX, string_input2
INT 21h

; input the second number
MOV AH, 01h
INT 21h
SUB AL, '0'
MOV CL, AL

input2_loop:
MOV AH, 01h
INT 21h
CMP AL, 13
JE input2_end
SUB AL, '0'
MOV buffer, AL
MOV AX, CX
MUL ten
MOV BL, buffer
MOV BH, 0
ADD AX, BX
MOV CX, AX
JMP input2_loop

input2_end:
MOV number2, CX

; divide two numbers by subtraction, without DIV
; ...
; 14 / 5 = 2 (4)
; subtract 5 from 14 2 times, 4 remains
; subtract the second number from the first
; so long as the first number is greater than the second
; and count how many times it was subtracted
; the count will be the quotient 
; and what remains of the first number will be, well, the remainder

MOV AX, number1
MOV BX, number2
MOV CX, 0; CX will count how many times it was subtracted

division_loop:
CMP AX, BX
JGE more
JL no_more

more:
INC CX
SUB AX, BX
JMP division_loop

no_more:
CALL proc_save_results; puts the results into the RAM

MOV AH, 02h
MOV DL, 10
INT 21h
MOV AH, 09h
LEA DX, string_quotient
INT 21h

; now just printing
; it'll go digit by digit, and '0' must be added to each one
; 345 / 10 = 34 (5)
; push 5 onto the stack and proceed
; 34 / 10 = 3 (4)
; push 4, stack now has 54
; 3 / 10 = 0 (3)
; push 3, stack is now 543
; pop dl -> add dl, '0' -> putchar(dl) -> repeat until
; until uhh...
; make a counter!
; increment cx whenever I push and decrement whenever I pop

MOV AX, quotient

quotient_print_loop:
DIV ten
CMP AL, 0; are there more digits remaining?
JNE quotient_yes
JE quotient_last; the first time al is 0, the last digit remains in ah

quotient_yes:
MOV buffer, AL
MOV AL, AH
MOV AH, 0
PUSH AX; push remainder
INC CX; counter
MOV AL, buffer
JMP quotient_print_loop

quotient_last:
MOV buffer, AL
MOV AL, AH
MOV AH, 0
PUSH AX
INC CX
MOV AL, buffer
JMP quotient_no; all digits are on the stack now

quotient_no:; print now
CMP CX, 0; are there more digits on the stack?
JNE quotient_print
JE quotient_done

quotient_print:
MOV DX, 0
POP DX
ADD DX, '0'
MOV AH, 02h
INT 21h; putchar(dl)
DEC CX
JMP quotient_no

quotient_done:
MOV DL, 10
INT 21h; putchar(\n)
MOV DL, 13
INT 21h; put the cursor to line start
MOV AH, 09h
LEA DX, string_remainder
INT 21h

; quotient done ----------

MOV CX, 0
MOV AX, remainder

remainder_print_loop:
DIV ten
CMP AL, 0; same stuff
JNE remainder_yes
JE remainder_last

remainder_yes:
MOV buffer, AL
MOV AL, AH
MOV AH, 0
PUSH AX
INC CX
MOV AL, buffer
JMP remainder_print_loop
                    
remainder_last:
MOV buffer, AL
MOV AL, AH
MOV AH, 0
PUSH AX
INC CX
MOV AL, buffer
JMP remainder_no                    
                    
remainder_no:       
CMP CX, 0
JNE remainder_print
JE remainder_done

remainder_print:
MOV DX, 0
POP DX
ADD DX, '0'
MOV AH, 02h
INT 21h
DEC CX
JMP remainder_no

remainder_done:
; put the results in ax and dx, why not
MOV AX, quotient
MOV DX, remainder

RET; fin.

string_input1 DB "Enter the first number: $"
string_input2 DB "Enter the second number: $"
string_quotient DB "Quotient: $"
string_remainder DB "Remainder: $"
number1 DW 0
number2 DW 0
buffer DB 10; stores al while I'm messing with ax
ten DB 10; construct the base-10 digit using this
quotient DW 0
remainder DW 0

proc_save_results PROC
    MOV DX, AX
    MOV AX, CX
    MOV quotient, AX
    MOV remainder, DX
    MOV BX, 0
    MOV CX, 0
    RET