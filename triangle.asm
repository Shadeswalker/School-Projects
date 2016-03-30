;Program : triangle.asm
;Author : Arjun Boris Gupta
;Date : 2015
.model small
.stack 100h
.code
jmp start
;====================================
;			  FUNCTIONS				;
;====================================



;====================================
;			   MACROS				;
;====================================


;====================================
;			   DATA				;
;====================================
	x_add			dw	50d
	y_add			dw	16000	;= 320 * 50
	row				dw	24000	;row 126 (320*125)
	col				dw	135		;col 135
	x_start			dw	135		;|
	y_start			dw	75		;|}_ used only for counting purposes,
	x_end			dw	185		;|}	 makes it easier for the movement
	y_end			dw	125		;|
	trngl_counter	dw  49		;used to plot the right side of the triangle
	trngl_sides		db  00		
	startaddr		dw	0a000h	;start of video memory
	colour			db	1		;1=blue
	del_shape		db  0
	movement		db  0		;First Case scenario of movement : shape going right

;====================================
;			   START				;
;====================================
start:
	mov ah, 00				;subfunction 0
	mov al, 19				;select mode 19 (or 13h if prefer)
	int 10h					;call graphics interrupt
	mov es, startaddr		;put segment address in es
	
start_drawing:
	mov al, 1d				;move colour to al, for later move from register to memory
	triangle:
	base:
		mov di, row	 		;row 76 (320*75)
		add di, y_add		;row 126
		add di, col			;column 135
		mov cx, 50			;loop counter
		base_plot:
			mov es:[di], al	;set pixel to colour
			inc di			;move to next pixel
		loop base_plot
	sides:
		mov di, row			;row 76 (320*75)
		add di, y_add		;row 126
		add di, col			;column 135
		mov cx, 50
		sides_plot:
			mov es:[di], al			;set pixel to colour
			add di, trngl_counter	;move right 50 columns
			mov es:[di], al			;set pixel to colour
			sub di, trngl_counter	;move back to left side
			
			inc trngl_sides
			and trngl_sides, 00000001b	;check the least significant byte
			jnp loop_end				;allows the same pixel to be plotted just above the previous one(without moving left or right)
			
			inc di						;moves right a pixel for left side
			sub trngl_counter, 2		;moves left a pixel for right side
			
			loop_end:
				sub di, 320				;move up a pixel
		loop sides_plot
;====================================
;			    END					;
;====================================
keypress:
	mov ah, 00
	int 16h				;wait for keypress
terminate:
	mov ah,00
	mov al,03 			; set mode back to text mode 3
	int 10h
	mov ah,4ch
	mov al,00 			;terminate program
	int 21h
	
end start