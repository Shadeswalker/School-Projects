; Program: TEST.ASM
; A Program to display the letter X on the screen
.model small
.stack 256
.code
start:
mov dl, 'X'
mov ah, 2h
int 21h
; All programs use the following 3 lines to terminate
mov ax, 4c00h
int 21h
end start