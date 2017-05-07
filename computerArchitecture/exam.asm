;Program : assess.asm
;Author : Arjun Boris Gupta
;Date : 2015
.model small
.stack 100h
.data
	intro db "Press 'S' to speed up, 'D' to speed down, and any other key to quit.$", 13, 10, "$"
	message db "Press any key to start...", 13, 10, "$"
.code
jmp start
;====================================
;			    DATA				;
;====================================
	mode			db	19 		;320 x 200
	row				dw	24000	;row 76 (320*75)
	col				dw	135		;col 135
	x_add			dw	50
	y_add			dw	16000	;= 320 * 50
	x_start			dw	135		;|
	y_start			dw	75		;|}_ used only for counting purposes,
	x_end			dw	185		;|}	 makes it easier for the movement
	y_end			dw	125		;|
	trngl_counter	dw  50		;used to plot the right side of the triangle
	trngl_sides		db  00
	pixel_p_line	dw	47		;pixel per line in hour glass triangle
	lines_gap		dw  49		;row gap between first line of sand up, and first line of sand down
	startaddr		dw	0a000h	
	colour			db	1		;1=blue
	del_shape		db  0
	x_movement		db  0		;First Case scenario of movement : shape going right
	y_movement		db	0		;First Case scenario of movement : shape going down
	bounces			db	0 		;number of time the shaped reached a side of the screen
	shape			db	0		;different shapes : 0=>square, 1=>triangle
	timer_delay		dw	4000h	

;====================================
;			   MACROS				;
;====================================
delay macro timer
	mov cx, 00h
	mov dx, timer			
	mov ah, 86h					;timer is in DX:CX
	int 15h
endm
;====================================
display_string macro
	mov ah, 9h
	int 21h
endm
;====================================
read_key macro
mov ah, 1h
int 21h
endm
;====================================
new_line macro
mov dl, 13d
mov ah, 2h
int 21h
mov dl, 10d
mov ah, 2h
int 21h
endm

;====================================
;			  FUNCTIONS				;
;====================================
hour_glass:
	cmp al, 00
	je horizontal_bases
		mov al, 6				;brown
	horizontal_bases:
		mov di, row				;row 76 (320*75)
		add di, col				;column 135
		mov cx, 51				;loop counter
		bases_plot:
			mov es:[di], al		;set pixel to colour
			add di, y_add		;move down 50 rows
			mov es:[di], al		;set pixel to colour
			sub di, y_add		;move up 50 rows
			inc di				;move to next pixel
		loop bases_plot
	diagonals:
		mov di, row				;row 76 (320*75)
		add di, y_add			;row 126
		add di, col				;column 135
		mov cx, 50
		mov trngl_counter, 50		;reset counter(else it wouldn't work while moving)
		diag_plot:
			mov es:[di], al			;set pixel to colour
			add di, trngl_counter	;move right 50 columns
			mov es:[di], al			;set pixel to colour
			sub di, trngl_counter	;move back to left side
			inc di					;moves right a pixel for left side
			sub trngl_counter, 2	;moves left a pixel for right side
			sub di, 320				;move up a pixel
		loop diag_plot
	sand:
		mov di, 39680			;row 125(320*124)
		add di, 138
		mov cx, 23				;number of lines in a triangle
		mov pixel_p_line, 45
		cmp al, 00
		je triangle_fill
			mov al, 43d
		triangle_fill:
			push cx
			mov cx, pixel_p_line
			line_fill:
				mov es:[di], al			;set pixel to colour
				inc di					;move to next pixel in line
			loop line_fill
			pop cx
			sub di, pixel_p_line		;go back to first pixel
			sub pixel_p_line, 2			;reduce length of line by 2
			sub di, 320					;go to upper line
			inc di						;go one pixel right
		loop triangle_fill
ret

;====================================
hour_glass_2:
	cmp al, 00
	je vertical_bases
		mov al, 6				;brown
	vertical_bases:
		mov di, row			;row 76 (320*75)
		add di, col			;column 135
		mov cx, 51
		vbases_plot:
			mov es:[di], al	;set pixel to colour
			add di, x_add	;move right 50 columns
			mov es:[di], al	;set pixel to colour
			sub di, x_add	;move back left 50 columns
			add di, 320		;move down to next pixel
		loop vbases_plot
	diagonals_2:
		mov di, row				;row 76 (320*75)
		add di, col				;column 135
		mov cx, 50
		mov trngl_counter, 50		;reset counter(else it wouldn't work while moving)
		diag_plot_2:
			mov es:[di], al			;set pixel to colour
			add di, trngl_counter	;move right 50 columns
			mov es:[di], al			;set pixel to colour
			sub di, trngl_counter	;move back to left side
			inc di					;moves right a pixel for left side
			sub trngl_counter, 2	;moves left a pixel for right side
			add di, 320				;move down a pixel
		loop diag_plot_2
	sand_2:
		mov di, 24960			;row 78(320*77)
		add di, 136
		mov cx, 23				;number of columns in the triangle
		mov pixel_p_line, 45
		cmp al, 00
		je triangle_fill_2
			mov al, 43d
		triangle_fill_2:
			push cx
			mov cx, pixel_p_line		;number of pixels per line
			column_fill:
				mov es:[di], al			;set pixel to colour
				add di, 320				;move to next pixel in line
			loop column_fill
			pop cx
			push ax
			mov ax, pixel_p_line
			mov bx, 320
			mul bx
			sub di, ax					;go back to first pixel
			pop ax
			sub pixel_p_line, 2			;reduce length of line by 2
			inc di						;go to next column
			add di, 320					;go one pixel down
		loop triangle_fill_2
ret

;====================================
hour_glass_3:
	cmp al, 00
	je horizontal_bases_2
		mov al, 6				;brown
	horizontal_bases_2:
		mov di, row				;row 76 (320*75)
		add di, col				;column 135
		mov cx, 51				;loop counter
		bases_plot_2:
			mov es:[di], al		;set pixel to colour
			add di, y_add		;move down 50 rows
			mov es:[di], al		;set pixel to colour
			sub di, y_add		;move up 50 rows
			inc di				;move to next pixel
		loop bases_plot_2
	diagonals_3:
		mov di, row				;row 76 (320*75)
		add di, y_add			;row 126
		add di, col				;column 135
		mov cx, 50
		mov trngl_counter, 50		;reset counter(else it wouldn't work while moving)
		diag_plot_3:
			mov es:[di], al			;set pixel to colour
			add di, trngl_counter	;move right 50 columns
			mov es:[di], al			;set pixel to colour
			sub di, trngl_counter	;move back to left side
			inc di					;moves right a pixel for left side
			sub trngl_counter, 2	;moves left a pixel for right side
			sub di, 320				;move up a pixel
		loop diag_plot_3
	sand_3:
		mov di, 24320			;row 77(320*76)
		add di, 138
		mov cx, 23				;number of lines in a triangle
		mov pixel_p_line, 45
		cmp al, 00
		je triangle_fill_3
			mov al, 43d
		triangle_fill_3:
			push cx
			mov cx, pixel_p_line
			line_fill_3:
				mov es:[di], al			;set pixel to colour
				inc di					;move to next pixel in line
			loop line_fill_3
			pop cx
			sub di, pixel_p_line		;go back to first pixel
			sub pixel_p_line, 2			;reduce length of line by 2
			add di, 320					;go to upper line
			inc di						;go one pixel right
		loop triangle_fill_3
	sand_animation:
		mov di, 32640				;row 102 ()
		add di, 160
		mov cx, 23
		sand_line:
			mov es:[di], al			;set pixel to colour
			add di, 320
			push cx
			push dx
			push ax
			delay 05000h
			pop ax
			pop dx
			pop cx
		loop sand_line
		
		mov di, 24320				;row 77(320*76)
		add di, 138
		mov cx, 23					;number of lines
		mov pixel_p_line, 45
		mov lines_gap, 15360		;row gap between first line of sand up, and first line of sand down
		sand_falling:
			push cx
			mov al, 00					; black to delete
			mov cx, pixel_p_line		;counter number of pixel per line
			falling_top:
				mov es:[di], al			;set pixel to colour
				inc di
			loop falling_top
			
			sub di, pixel_p_line		;go back to first pixel
			add di, lines_gap
			mov al, 43					;sand colour (yellowish)
			mov cx, pixel_p_line		;number of pixel per line
			falling_down:
				mov es:[di], al			;set pixel to colour
				inc di
			loop falling_down
			sub di, pixel_p_line		;go back to first pixel
			pop cx						;take back counter for number of lines per triangle
			;sub lines_gap, 320			;when going back up, will go back immediately one pixel down
			sub di, lines_gap			;go back up
			sub lines_gap, 640			;reduce length of gap by 2
			sub pixel_p_line, 2			;reduce length of line by 2
			add di, 320					;move one pixel down
			inc di						;move one pixel right
			
			push cx
			push dx
			push ax
			delay 0F000h
			pop ax
			pop dx
			pop cx
		loop sand_falling
ret

;====================================
square_fnct:				;DRAWS A SQUARE SIDE 50px
	horiz:
		mov di, row			;row 76 (320*75)
		add di, col			;column 135
		mov cx, 51			;loop counter
		horiz_plot:
			mov es:[di], al	;set pixel to colour
			add di, y_add	;move down 50 rows
			mov es:[di], al	;set pixel to colour
			sub di, y_add	;move up 50 rows
			inc di			;move to next pixel
		loop horiz_plot
	vertic:
		mov di, row			;row 76 (320*75)
		add di, col			;column 135
		mov cx, 51
		vertic_plot:
			mov es:[di], al	;set pixel to colour
			add di, x_add	;move right 50 columns
			mov es:[di], al	;set pixel to colour
			sub di, x_add	;move back left 50 columns
			add di, 320		;move down to next pixel
		loop vertic_plot
ret
;====================================
up_triangle:				;DRAWS A TRIANGLE BASE 50px
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
		mov trngl_counter, 49		;reset counter(else it wouldn't work while moving)
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
ret

;====================================
down_triangle:				;DRAWS A TRIANGLE BASE 50px, pointing down
	base_2:
		mov di, row	 		;row 76 (320*75)
		add di, col			;column 135
		mov cx, 50			;loop counter
		base_plot_2:
			mov es:[di], al	;set pixel to colour
			inc di			;move to next pixel
		loop base_plot_2
	sides_2:
		mov di, row			;row 76 (320*75)
		add di, col			;column 135
		mov cx, 50
		mov trngl_counter, 49		;reset counter(else it wouldn't work while moving)
		sides_plot_2:
			mov es:[di], al			;set pixel to colour
			add di, trngl_counter	;move right 50 columns
			mov es:[di], al			;set pixel to colour
			sub di, trngl_counter	;move back to left side
			
			inc trngl_sides
			and trngl_sides, 00000001b	;check the least significant byte
			jnp loop_end_2				;allows the same pixel to be plotted just above the previous one(without moving left or right)
			
			inc di						;moves right a pixel for left side
			sub trngl_counter, 2		;moves left a pixel for right side
			
			loop_end_2:
				add di, 320				;move down a pixel
		loop sides_plot_2
ret

;====================================
delay_2:
	mov cx, 0FFFFh
	useless_loop:
		push cx
		pop cx
	loop useless_loop
ret

;====================================
;			   START				;
;====================================
start:
	mov ax, @data
	mov ds, ax
	mov dx,offset intro 	;set address of data, string, to DX
	display_string
	new_line
	mov dx,offset message 	;set address of data, string, to DX
	display_string
	read_key
	mov ah, 00				;subfunction 0
	mov al, mode			;select mode 19 (or 13h if prefer)
	int 10h					;call graphics interrupt
	mov es, startaddr		;put segment address in es
	mov al, 1d				;move colour to al, for later move from register to memory
	
call hour_glass
call delay_2				;for some reason doesn't work with normal timer, so had to create another less precise
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
mov al, 00d					;colour black
call hour_glass


mov al, 1					;colour blue
call hour_glass_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
mov al, 00d					;colour black
call hour_glass_2
mov al, 01d


mov al, 1					;colour blue
call hour_glass_3
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
call delay_2
mov al, 00d					;colour black
call hour_glass
mov al, 01d


start_drawing:
cmp shape, 00d
je square
cmp shape, 01d
je triangle
cmp shape, 02d
je shape_mix_1

;====================================
square:
	call square_fnct
jmp delete_shape
	
;====================================
triangle:
	call up_triangle
jmp delete_shape

;====================================
shape_mix_1:
	call up_triangle
	call down_triangle
	call square_fnct
jmp delete_shape

;====== Delete previous shape =======
delete_shape:
	inc del_shape
	and del_shape, 00000001b	;check the least significant byte
	jp next_shape				;will delete shape once, then pass to following lines
	push ax						;al is in ax, so we store the colour
	mov al, 00					;change colour to black
	
push cx
push dx
push ax
mov bx, timer_delay
delay bx						;adding delay for the shape NOT black
pop ax
pop dx
pop cx


jmp start_drawing


next_shape:
pop ax
inc al

cmp al, 0d						;checking if al contains 0, which gives black colour
jne black_2
	inc al						;if al stores 0(ergo the colour black), then go to next colour
black_2:
cmp al, 16d
jne black_3
	inc al
black_3:
cmp al, 247						;248 to 255 colours are black
jne horiz_movement
	mov al, 1
;===========   Movement  ============
horiz_movement:
	cmp x_end, 319d
	je mov_left
	cmp x_start, 0d
	je mov_right

	cmp x_movement, 0d		;memorises previous state (0=> shape going right, 1=> shape going left)
	je mov_right
	cmp x_movement, 1d
	je mov_left

mov_right:
	cmp x_movement, 1d		;checks if previous state was different	
	jne moving_right
		inc bounces			;increment the number of time the shape reached a border
	moving_right:
	mov x_movement, 0d
	inc x_start				;used to check conditions only
	inc x_end				;(to see when it reaches end of screen)
	inc col					;this one actually moves to right pixel
	jmp vertic_movement
	
mov_left:
	cmp x_movement, 0d		;checks if previous state was different	
	jne moving_left
		inc bounces			;increment the number of time the shape reached a border
	moving_left:
	mov x_movement, 1d
	dec x_start				;used to check conditions only
	dec x_end				;(to see when it reaches end of screen)
	dec col					;this one actually moves to left pixel
	jmp vertic_movement

;=====================================
vertic_movement:
	cmp y_end, 199d
	je mov_up
	cmp y_start, 0d
	je mov_down

	cmp y_movement, 0d
	je mov_down
	cmp y_movement, 1d
	je mov_up

mov_down:
	cmp y_movement, 1d		;checks if previous state was different	
	jne moving_down
		inc bounces			;increment the number of time the shape reached a border
	moving_down:
	mov y_movement, 0d
	inc y_start				;used to check conditions only
	inc y_end				;(to see when it reaches end of screen)
	add row, 320			;this one actually moves down a pixel
	jmp change_shape
	
mov_up:
	cmp y_movement, 0d		;checks if previous state was different	
	jne moving_up
		inc bounces			;increment the number of time the shape reached a border
	moving_up:
	mov y_movement, 1d
	dec y_start				;used to check conditions only
	dec y_end				;(to see when it reaches end of screen)
	sub row, 320			;this one actually moves down a pixel
	jmp change_shape

;========= Shape Shifting ===========
change_shape:
	cmp bounces, 3
	jne keypress			;will only change after the third bounce
		mov bounces, 00d
		cmp shape, 02d		;check if the "shape cycle" is at the last shape (shape cycle=number of different shapes - 1)
		jne shape_cycle
			mov shape, 00d	;when the "shape cycle" reaches the last shape, go back to 0.
			jmp keypress
		shape_cycle:
		inc shape
;====================================
keypress:
	mov ah, 01h
	int 16h					;checks if a key is pressed
	jnz check_key			;not zero = a key has been pressed
	jmp start_drawing

check_key:
	mov ah, 00h 			;get the key that has been pressed in al
	int 16h
	
	cmp al, 115				;check if key is 's'
	je speed_up
	cmp al, 100
	je speed_down
	jmp terminate
	
	speed_up:
		sub timer_delay, 500h
		jmp start_drawing
	speed_down:
		add timer_delay, 500h
		jmp start_drawing
	start_drawing_2:			;has to be there, else relative jump out of range
		jmp start_drawing
		
;====================================
;			    END					;
;====================================
terminate:
	mov ah,00
	mov al,03 			; set mode back to text mode 3
	int 10h
	mov ah,4ch
	mov al,00 			;terminate program
	int 21h
	
end start