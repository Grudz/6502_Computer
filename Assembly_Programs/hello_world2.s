PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

	.org $8000

reset:	
	ldx #$ff ; intializes x to stack ands sets SP starting location
	txs

	lda #%11111111 ; Set all pins on port B to output (I/O on VIA)
	sta DDRB

	lda #%11100000 ; Set top 3 pins on port A to output
	sta DDRA

	lda #%00111000 ; Set 8-Bit mode, 2 line display 5x8
	jsr lcd_instruction
	lda #%00001110 ; Display on, cursor on, blink off
	jsr lcd_instruction
	lda #%00000110 ; Increment, shift cursor, no display shift
	jsr lcd_instruction
	lda #%00000001 ; Clears the display
	jsr lcd_instruction

	lda #"H" ; Could copy this block of code for each letter
	jsr print_char
	lda #"e"
	jsr print_char
	lda #"l"
	jsr print_char
	lda #"l"
	jsr print_char
	lda #"o"
	jsr print_char
	lda #","
	jsr print_char
	lda #" "
	jsr print_char
	lda #"W"
	jsr print_char
	lda #"o"
	jsr print_char
	lda #"r"
	jsr print_char
	lda #"l"
	jsr print_char
	lda #"d"
	jsr print_char
	lda #"!"
	jsr print_char


loop:	
	jmp loop

lcd_instruction: 
	sta PORTB
	lda #0 ; Clear RS/RW/E bits
	sta PORTA
	lda #E ; Enable for instructions
	sta PORTA
	lda #0 ; Clear RS/RW/E bits
	sta PORTA
	rts

print_char:
	sta PORTB ; Not memory efficent^^^ 333 bytes
	lda #RS ; Set RS
	sta PORTA
	lda #(RS | E) ; Enable to send instruction
	sta PORTA
	lda #RS ; Clear E bits
	sta PORTA
	rts

	.org $fffc
	.word reset
	.word $0000
