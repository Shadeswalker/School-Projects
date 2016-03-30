; Program: TEST.ASM
; A Program to display the letter X on the screen
.model small
.stack 100h
.code

start:
	mov ah, 1h
	int 21h
	
	mov bl, al ; save character in bl

	;display Return

	mov dl, 13d ; dl = CR

	mov ah, 2h ; display subprogram

	int 21h ; display CR

	;display Line-feed

	mov dl, 10d ; dl = LF

	mov ah, 2h ; display subprogram

	int 21h ; display LF

	; display character read from keyboard

	mov dl, bl ; copy character to dl

	mov ah, 2h ; display subprogram

	int 21h ; display character in dl
	
; All programs use the following 3 lines to terminate
mov ax, 4c00h
int 21h
end start