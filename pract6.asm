; Program: TEST.ASM
; A Program to display the letter X on the screen
.model small
.stack 100h
.data
mode	db	18 		;640 x 480
x_start	dw	100
y_start	dw	100
x_end	dw	540
y_end	dw	380
colour	db	1		;1=blue

.code
start:
	mov ax, @data
	mov ds, ax
	mov ah, 00			;subfunction 0
	mov al, mode		;select mode 18 (or 12h if prefer)
	int 10h				;call graphics interrupt
	;==========================
	mov al, colour		;colour goes in al
	mov ah, 0ch
	mov cx, x_start		;start drawing lines along x

drawhoriz:
	mov dx, y_end		;put point at bottom
	int 10h
	mov dx, y_start		;put point on top
	int 10h 
	inc cx				;move to next point
	cmp cx, x_end		;but check to see if its end
	jnz drawhoriz

drawvert:				;(y value is already y_start)
	mov cx, x_start		;plot on left side
	int 10h
	mov cx, x_end		;plot on right side
	int 10h
	inc dx				;move down to next point
	cmp dx, y_end		;check for end
	jnz drawvert
	
;==========================
readkey:
	mov ah, 00
	int 16h				;wait for keypress

;==========================

	mov ah, 00			;again subfunc 0
	mov al, 03			;text mode 3
	int 10h				;call int
	mov ah, 04ch
	mov al, 00
	int 21h
	
end start