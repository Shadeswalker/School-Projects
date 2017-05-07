;Program : assess.asm
;Author : Arjun Boris Gupta
;Date : 2015
.model small
.stack 100h
.data
	mode			db	18 		;640 x 480
	x_start			dw	245
	y_start			dw	165
	x_end			dw	395
	y_end			dw	315
	center_point 	dd  153600
	colour			db	1		;1=blue
	shape			db  0
	x_movement		db  0		;First Case scenario of movement : shape going right
	y_movement		db	0		;First Case scenario of movement : shape going down
.code
;====================================
;			  FUNCTIONS				;
;====================================



;====================================
;			   MACROS				;
;====================================



;====================================
;			   START				;
;====================================
start:
	mov ax, @data
	mov ds, ax
	mov ah, 00			;subfunction 0
	mov al, mode		;select mode 18 (or 12h if prefer)
	int 10h				;call graphics interrupt
	
	mov al, colour		;colour goes in al
	mov ah, 0ch
	
start_drawing:
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
	
;====== Delete previous shape =======
inc shape
and shape, 00000001b   ;check the least significant byte
jp horiz_movement
mov al, 00				;change colour to black
jmp start_drawing

;===========   Movement  ============
horiz_movement:
	cmp x_end, 640d
	je mov_left
	cmp x_start, 1d
	je mov_right

	cmp x_movement, 0d
	je mov_right
	cmp x_movement, 1d
	je mov_left

mov_right:
	mov x_movement, 0d
	inc x_start
	inc x_end
	inc al				;change colour
	jmp vertic_movement
	
mov_left:
	mov x_movement, 1d
	dec x_start
	dec x_end
	inc al				;change colour
	jmp vertic_movement

;=====================================
vertic_movement:
	cmp y_end, 480d
	je mov_up
	cmp y_start, 1d
	je mov_down

	cmp y_movement, 0d
	je mov_down
	cmp y_movement, 1d
	je mov_up

mov_down:
	mov y_movement, 0d
	inc y_start
	inc y_end
	inc al				;change colour
	jmp start_drawing
	
mov_up:
	mov y_movement, 1d
	dec y_start
	dec y_end
	inc al				;change colour
	jmp start_drawing

;====================================
;			    END					;
;====================================

terminate:
	mov ah,00
	mov al,03 ; set mode back to text mode 3
	int 10h
	mov ah,4ch
	mov al,00 ;terminate program
	int 21h
	
end start