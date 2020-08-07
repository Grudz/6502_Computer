PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

value = $0200 ; refer to ben eater algo. Stores right 2 bytes of algo
mod10 = $0202 ; stores left 2 bytes of algo at 0202 hex
message = $0204 ; 6 bytes

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

	lda #0 ; null string
	sta message
	
	; Initialize value to be the number we want convert
	lda number ; Copying number in RAM
	sta value
	lda number + 1 ; Loading in second byte (complete right half)
	sta value + 1

divide:
	; Initialize remainder to zero
	lda #0 ; Setting up left half
	sta mod10
	sta mod10 + 1
	clc ; clear carry bit

	ldx #16 ; arbitrary

divloop:	
	; rotate quotient and remainder
	rol value ; rotate all bytes left starting at the right
	rol value + 1
	rol mod10
	rol mod10 + 1

	; a,y = dividend - divisor
	sec ; set carry bit
	lda mod10
	sbc #10 ; subtract with carry from 10
	tay ; transfer a to y register (save low byte in Y)
	lda mod10 + 1
	sbc #0 ; subtract 0 from high byte
	bcc ignore_result ; branch if carry clear, if dividend < divisor
	sty mod10
	sta mod10 + 1

ignore_result:
	dex ; decrement x until 0
	bne divloop ; branches if 0 flag not set (16 down to 0)
	rol value ; shift the last bit of quotient (need final carry bit)
	rol value + 1	

	lda mod10
	clc
	adc #"0" ; add this 0 so we can use ascii function 
	jsr push_char
	
	; if value !=0, then keep dividing
	lda value
	ora value + 1 ; or everything
	bne divide ; or will be 1 if everything not 0

	ldx #0
print:
	lda message,x
	beq loop ; Null byte at end of asciiz
	jsr print_char
	inx ; x is index reg storing message
	jmp print

loop:		
	jmp loop

number: .word 1729 ; Decimal here, will be converted, ROM here

; Add char in A reg to beg of null string 'message'
push_char:
	pha ; Push new first char to stack
	ldy #0

char_loop:
	lda message,y ; Get char on string and put into x reg
	tax
	pla
	sta message,y ; Pull char off stack and add it to the string
	iny ; increment y to next char
	txa ; put x back in a reg
	pha
	bne char_loop ; checks for null

	pla
	sta message,y ;  Pull the null off stack and add to end
	

lcd_wait: ; Check busy flag for 1Mhz Clock w/ LCD fix
	pha
	lda #%00000000 ; Port B as input
	sta DDRB
lcd_busy:
	lda #RW
	sta PORTA
	lda #(RW | E)
	sta PORTA
	lda PORTB
	and #%10000000 ; Zeros out all bits but top, which is Busy Flag
	bne lcd_busy

	lda #RW
	sta PORTA
	lda #%11111111 ; Port B as output again
	sta DDRB
	pla ; push then pulls A b/c A is dependent for next func
	rts

lcd_instruction: 
	jsr lcd_wait
	sta PORTB
	lda #0 ; Clear RS/RW/E bits
	sta PORTA
	lda #E ; Enable for instructions
	sta PORTA
	lda #0 ; Clear RS/RW/E bits
	sta PORTA
	rts

print_char:
	jsr lcd_wait
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
