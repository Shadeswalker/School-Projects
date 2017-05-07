; Program: TEST.ASM
; A Program to display the letter X on the screen
.model small
.stack 100h
.data
message db 'Weight program', 13, 10, '$'
prompt1 db 'Enter the number of apples to buy: $'
prompt2 db 'Enter the number of oranges to buy: $'
prompt100 db '100-g weight : $'
prompt50 db '50-g weight : $'
prompt20 db '20-g weight : $'
prompt10 db '10-g weight : $'
prompt5 db '5-g weight : $'


.code

start:

	mov ax, @data
	mov ds, ax
	mov dx, offset message
	call puts
	
	mov dx, offset prompt1
	call puts
	call getc
	mov bl, al   				;saves number of apples in bl
	call carret
	call linef
	
	mov dx, offset prompt2
	call puts
	call getc
	mov cl, al					; saves number of oranges in cl
	call carret
	call linef
	
	mov al, 105				; move in al weight of apple
	mul bl					; multiply weight by number
	mov bx, ax				; mov result back to bx
	
	mov al, 120				; move in al weight of oranges
	mul cl					; multiply weight by number
	mov cx, ax				; mov result back to bx
	
	add bx, cx				;now bx contains total weight
	mov ax, bx
	mov cx, 100
	div cx
	cmp ax, 0
	je weight100
	mov dx, offset message
	weight100:
	mov dx, offset prompt100
	call puts
	
	

	mov ax, 4c00h
	int 21h

	getc: ; read character into al
		mov ah, 1h
		int 21h
	ret

	puts: ; display string terminated by $ ; dx contains address of string
		mov ah, 9h
		int 21h
	ret
	
	carret:
		mov dl, 13d ; dl = CR
		mov ah, 2h ; display subprogram
		int 21h ; display CR
	ret
	
	linef:
		mov dl, 10d ; dl = LF
		mov ah, 2h ; display subprogram
		int 21h ; display LF
	ret

end start