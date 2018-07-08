 ; Lab4
 ;
 ; Created: 3/24/2018 4:15:16 AM
 ; Author : Eugene Rockey

		 .org 0					;student discuss interrupts and vector table in report
		 jmp RESET				;student discuss reset in report
		 jmp INT0_H				;student discuss reset in report
		 jmp INT1_H				;student discuss reset in report
		 jmp PCINT0_H			;student discuss reset in report
		 jmp PCINT1_H			;student discuss reset in report
		 jmp PCINT2_H			;student discuss reset in report
		 jmp WDT				;student discuss reset in report
		 jmp TIM2_COMPA			;student discuss reset in report
		 jmp TIM2_COMPB			;student discuss reset in report
		 jmp TIM2_OVF			;student discuss reset in report
		 jmp TIM1_CAPT			;student discuss reset in report
		 jmp TIM1_COMPA			;student discuss reset in report
		 jmp TIM1_COMPB			;student discuss reset in report
		 jmp TIM1_OVF			;student discuss reset in report
		 jmp TIM0_COMPA			;student discuss reset in report
		 jmp TIM0_COMPB			;student discuss reset in report
		 jmp TIM0_OVF			;student discuss reset in report
		 jmp SPI_TC				;student discuss reset in report
		 jmp USART_RXC			;student discuss reset in report
		 jmp USART_UDRE			;student discuss reset in report
		 jmp USART_TXC			;student discuss reset in report
		 jmp ADCC				;student discuss reset in report
		 jmp EE_READY			;student discuss reset in report
		 jmp ANA_COMP			;student discuss reset in report
		 jmp TWI				;student discuss reset in report
		 jmp SPM_READY			;student discuss reset in report



RESET:	;Initialize the ATMega328P chip for the THIS embedded application.
		;initialize PORTB for Output
		cli
		ldi	r16,0xFF				;PB1 or OC1A Output
		out	DDRB,r16
;initialize and start Timer A, compare match, interrupt enabled
		ldi	r16,0xC0			;set OC to compare match set output to high level
		sts TCCR1A,r16			;Sets bits 7 and 6 in TCCR1A. "Set OC1A (PB1) on compare match"
		ldi r16,0x04			;set clock prescaler, 0x04 = 00000100
		sts TCCR1B,r16			;Sets bit 2 of TCCR1B, sets prescaler "(clk_I/O)/256"
		ldi r16,0x80			;force output compare, set PB1 high
		sts TCCR1C,r16			;Set bit 7 of TCCR1C, Force Output Compare for Channel A
								;Only active when WGM1[3:0] specifies non-PWM mode
								;Since COM1A bits are both set to 1, the effect of the forced compare sets PB1 if there is a match
		ldi r16,0x89			;r16 = 10001001 in 8-bit binary
		sts TCCR1A,r16			;Sets bit 7 in TCCR1A, "Clear OC1A on compare match(PB1 output set to low on match)", sets WGM to mode 9 PWM, Phase and Frequency Correct
		ldi	r18,0x0B			;r18 = 00001011
		ldi r17,0xE8			;r17 = 10111000, 0x0BB8 = 3000 in decimal
		lds r16,TCNT1L			;Load current Timer/Counter 1 low byte value into r16
		add r17,r16				;Low byte of 0x0BB8 added to low byte of Timer/Counter 1
		lds r16,TCNT1H			;Load current Timer/Counter 1 high byte value into r16
		adc r18,r16				;High byte of 0x0BB8 added to high byte of Timer/Counter 1
		sts OCR1AH,r18			;High byte result stored in OCR1AH.
		sts OCR1AL,r17			;Low byte result stored in OCR1AL.
								;The output compare register 1 A (OCR1A) has a value that is essentially decimal 3000 greater than the current TCNT1 value
								;When TCNT1 value matches this value, OC1A (PB1 output) is set to low
		ldi r19,0				;r19 is set to 0
		ldi r16,0x02			;r16 = 00000010
		sts TIMSK1,r16			;TIMSK1 bit 1 set: Timer/Counter 1 Output Compare A Match Interrupt Enable
		out TIFR1,r16			;Clears OCF1A flag by writing logic one to its bit location. 
								;Automatically cleared when Output Compare Match A interrupt vector is executed
								;This flag is set when counter value TCNT1 matches Output Compare Register A OCR1A
		sei						;Sets global interrupt flag. Enables Timer/Counter 1 Output Compare A Match interrupt
here:	rjmp here
		
INT0_H:
		nop			;external interrupt 0 handler
		reti
INT1_H:
		nop			;external interrupt 1 handler
		reti
PCINT0_H:
		nop			;pin change interrupt 0 handler
		reti
PCINT1_H:
		nop			;pin change interrupt 1 handler
		reti
PCINT2_H:
		nop			;pin change interrupt 2 handler
		reti
WDT:
		nop			;watch dog time out handler
		reti
TIM2_COMPA:
		nop			;TC 2 compare match A handler
		reti
TIM2_COMPB:
		nop			;TC 2 compare match B handler
		reti
TIM2_OVF:
		nop			;TC 2 overflow handler
		reti
TIM1_CAPT:
		nop			;TC 1 capture event handler
		reti
TIM1_COMPA:			;TC 1 compare match A handler
		sbrc	r19,0				;If r19 is 0, which it should be the first time this interrupt vector is called, the next instruction is skipped.
		rjmp	ONE					;Skips the next four lines by jumping to label "ONE"
		ldi		r17,0x01			;student comment here
		ldi		r18,0x05			;student comment here
		rjmp	BEGIN				;student comment here	
ONE:	ldi		r17,0xFF			;student comment here
		ldi		r18,0xFA			;student comment here
		lds		r16,OCR1AL			;Current value of OCR1A low byte loaded into r16
		add		r17,r16				;Adds new value to OCR1A low byte
		lds		r16,OCR1AH			;Current value of OCR1A high byte loaded into r16
		adc		r18,r16				;Adds new value to OCR1A high byte, including carry
		sts		OCR1AH,r18			;New value for OCR1A
		sts		OCR1AL,r17			;New value for OCR1A
		ldi		r20,0x00
		cp		r17,r20
		brne	RET2
		ldi		r19,0
RET2:	reti						;return from interrupt vector, address specified by stack pointer
BEGIN:	lds		r16,OCR1AL			;Current value of OCR1A low byte loaded into r16
		add		r17,r16				;Adds new value to OCR1A low byte
		lds		r16,OCR1AH			;Current value of OCR1A high byte loaded into r16
		adc		r18,r16				;Adds new value to OCR1A high byte, including carry
		sts		OCR1AH,r18			;New value for OCR1A
		sts		OCR1AL,r17			;New value for OCR1A
		ldi		r20,0xFF
		cp		r17,r20
		brne	RET1
		ldi		r19,1
RET1:	reti						;return from interrupt vector, address specified by stack pointer

TIM1_COMPB:
		nop			;TC 1 compare match B handler
		reti
TIM1_OVF:
		nop			;TC 1 overflow handler
		reti
TIM0_COMPA:
		nop			;TC 0 compare match A handler
		reti
TIM0_COMPB:			
		nop			;TC 1 compare match B handler
		reti
TIM0_OVF:
		nop			;TC 0 overflow handler
		reti
SPI_TC:
		nop			;SPI Transfer Complete
		reti
USART_RXC:
		nop			;USART receive complete
		reti
USART_UDRE:
		nop			;USART data register empty
		reti
USART_TXC:
		nop			;USART transmit complete
		reti
ADCC:
		nop			;ADC conversion complete
		reti
EE_READY:
		nop			;EEPROM ready
		reti
ANA_COMP:
		nop			;Analog Comparison complete 
		reti
TWI:
		nop			;I2C interrupt handler
		reti
SPM_READY:
		nop			;store program memory ready handler
		reti		

