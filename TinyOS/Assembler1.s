 // Lab3P1.s
 //
 // Created: 1/30/2018 4:15:16 AM
 // Author : Eugene Rockey
 // Copyright 2018, All Rights Reserved


.section ".data"					//Defines a code section named .data
.equ	DDRB,0x04					//Gives the label DDRB the value 0x04, essentially giving the data direction register B the value stored in memory address 0x04
.equ	DDRD,0x0A					//Data direction register D is assigned the value stored in 0x0A memory address
.equ	PORTB,0x05					//Port B is assigned the 0x05 memory address
.equ	PORTD,0x0B					//Port D is assigned the value of 0x0B
.equ	U2X0,1						//Assigns UART U2X0 the value 1
.equ	UBRR0L,0xC4					//Sets lower half of BAUD rate
.equ	UBRR0H,0xC5					//Sets upper half of BAUD rate
.equ	UCSR0A,0xC0					//Sets status data register to 0xC0
.equ	UCSR0B,0xC1					//Sets config register to 0xC1
.equ	UCSR0C,0xC2					//Sets second config register to 0xC2
.equ	UDR0,0xC6					//Sets UDR0 UART label to 0xC6
.equ	RXC0,0x07					//Sets recieving UART bit to 0x07
.equ	UDRE0,0x05					//Sets USART data register empty bit to 0x0f
.equ	ADCSRA,0x7A					//Sets ADC register to 0x7A
.equ	ADMUX,0x7C					//Sets the ADC multiplexer register to 0x7C
.equ	ADCSRB,0x7B					//Sets status B register to 0x7B
.equ	DIDR0,0x7E					//Sets digital input disable register 0 to 0x7E
.equ	DIDR1,0x7F					//Sets digital input disable register 1 to 0x7F
.equ	ADSC,6						//Sets ADC start conversion bit to 6
.equ	ADIF,4						//Sets ADC interrupt flag to 4
.equ	ADCL,0x78					//Sets ADC low register to 0x78
.equ	ADCH,0x79					//Sets ADC high register to 0x79
.equ	EECR,0x1F					//Sets eeprom control register to 0x1F
.equ	EEDR,0x20					//Sets eeprom data register to 0x20
.equ	EEARL,0x21					//Sets eeprom address low register to 0x21
.equ	EEARH,0x22					//Sets eeprom address high register to 0x22
.equ	EERE,0						//Sets the eeprom read enabled bit to 0
.equ	EEPE,1						//Sets eeprom program enable bit to 1
.equ	EEMPE,2						//Sets eeprom master program enable bit to 2
.equ	EERIE,3						//Sets eeprom ready interrupt enable bit to 3

.global HADC				//Makes symbol HADC visible to ld, makes label externally available to the linker
.global LADC				//Makes symbol LADC visible to ld, makes label externally available to the linker
.global ASCII				//Makes symbol ASCII visible to ld, makes label externally available to the linker
.global DATA				//Makes symbol DATA visible to ld, makes label externally available to the linker

.global addrH
.global addrL
.global eepromData
.global baudH
.global baudL

.set	temp,0				//Sets the value of temp to 0, can be changed later

.section ".text"			//Defines a new section called .text
.global Mega328P_Init
Mega328P_Init:
		ldi	r16,0x07		;PB0(R*W),PB1(RS),PB2(E) as fixed outputs
		out	DDRB,r16		//Sets all bits of Port B to outputs
		ldi	r16,0			//Zeroes the r16 register
		out	PORTB,r16		//Sets all of Port B to zero
		out	U2X0,r16		;initialize UART, 8bits, no parity, 1 stop, 9600
		ldi	r17,0x0			//Loads 0x0 into r17
		ldi	r16,0x67		//Loads 0x67 into r16
		sts	UBRR0H,r17		//Sets high part of Baud Rate 
		sts	UBRR0L,r16		//Sets low part of Baud Rate
		ldi	r16,24			//Loads 24 into r16
		sts	UCSR0B,r16		//Stores r24 in the the configuration register for serial communications. Enables RX complete interrupt and TX complete interrupt
		ldi	r16,6			//loads 6 into r16
		sts	UCSR0C,r16		//sets characters size to 8-bits
		ldi r16,0x87		//initialize ADC
		sts	ADCSRA,r16		//stores 0x87 into ADC configuration SRAM  location
		ldi r16,0x40		//Loads 0x40 into r16
		sts ADMUX,r16		//Stores the value of r16 into the ADC multiplexer selection memory space in SRAM
		ldi r16,7			//Loads 0 into r16
		sts ADCSRB,r16		//Stores 0 into ADCSRB memory space which puts ADC in free roaming mode
		ldi r16,0xFE		//Loads 0xFE int r16
		sts DIDR0,r16		//Stores 0xFE into DIDR0 which is the data input disable register
		ldi r16,0xFF		//student comment here
		sts DIDR1,r16		//student comment here
		ret					//student comment here
	
.global LCD_Write_Command
LCD_Write_Command:
	call	UART_Off		//student comment here
	ldi		r16,0xFF		;PD0 - PD7 as outputs
	out		DDRD,r16		//student comment here
	lds		r16,DATA		//student comment here
	out		PORTD,r16		//student comment here
	ldi		r16,4			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	ldi		r16,0			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

.global LCD_Delay
LCD_Delay:
	ldi		r16,0xFA		//student comment here
D0:	ldi		r17,0xFF		//student comment here
D1:	dec		r17				//student comment here
	brne	D1				//student comment here
	dec		r16				//student comment here
	brne	D0				//student comment here
	ret						//student comment here

.global LCD_Write_Data
LCD_Write_Data:
	call	UART_Off		//student comment here
	ldi		r16,0xFF		//student comment here
	out		DDRD,r16		//student comment here
	lds		r16,DATA		//student comment here
	out		PORTD,r16		//student comment here
	ldi		r16,6			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	ldi		r16,0			//student comment here
	out		PORTB,r16		//student comment here
	call	LCD_Delay		//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

.global LCD_Read_Data
LCD_Read_Data:
	call	UART_Off		//student comment here
	ldi		r16,0x00		//student comment here
	out		DDRD,r16		//student comment here
	out		PORTB,4			//student comment here
	in		r16,PORTD		//student comment here
	sts		DATA,r16		//student comment here
	out		PORTB,0			//student comment here
	call	UART_On			//student comment here
	ret						//student comment here

.global UART_On
UART_On:
	ldi		r16,2				//student comment here
	out		DDRD,r16			//student comment here
	ldi		r16,24				//student comment here
	sts		UCSR0B,r16			//student comment here
	ret							//student comment here

.global UART_Off
UART_Off:
	ldi	r16,0					//student comment here
	sts UCSR0B,r16				//student comment here
	ret							//student comment here

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			//student comment here
	sbrs	r16,RXC0			//student comment here
	ret							//student comment here
	lds		r16,UDR0			//student comment here
	rjmp	UART_Clear			//student comment here

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			//student comment here
	sbrs	r16,RXC0			//student comment here
	rjmp	UART_Get			//student comment here
	lds		r16,UDR0			//student comment here
	sts		ASCII,r16			//student comment here
	ret							//student comment here

.global UART_Poll
UART_Poll:
	lds		r16, UDR0
	sts		ASCII, r16
	ret

.global UART_Put
UART_Put:
	lds		r17,UCSR0A			//student comment here
	sbrs	r17,UDRE0			//student comment here
	rjmp	UART_Put			//student comment here
	lds		r16,ASCII			//student comment here
	sts		UDR0,r16			//student comment here
	ret							//student comment here

.global ADC_Get
ADC_Get:
		ldi		r16,0xE7			//student comment here
		sts		ADCSRA,r16			//student comment here
A2V1:	lds		r16,ADCSRA			//student comment here
		sbrc	r16,ADSC			//student comment here
		rjmp 	A2V1				//student comment here
		lds		r16,ADCL			//student comment here
		sts		LADC,r16			//student comment here
		lds		r16,ADCH			//student comment here
		sts		HADC,r16			//student comment here
		ret							//student comment here

.global EEPROM_Write
EEPROM_Write:      
		sbic    EECR,EEPE
		rjmp    EEPROM_Write		; Wait for completion of previous write
		lds		r18,addrH			; Set up address (r18:r17) in address register
		lds		r17,addrL
		lds		r16,eepromData				; Set up data in r16    
		out     EEARH, r18      
		out     EEARL, r17			      
		out     EEDR,r16			; Write data (r16) to Data Register  
		sbi     EECR,EEMPE			; Write logical one to EEMPE
		sbi     EECR,EEPE			; Start eeprom write by setting EEPE
		ret 

.global EEPROM_Read
EEPROM_Read:					    
		sbic    EECR,EEPE    
		rjmp    EEPROM_Read		; Wait for completion of previous write
		lds		r18,addrH		; Set up address (r18:r17) in EEPROM address register
		lds		r17,addrL
		ldi		r16,0x00   
		out     EEARH, r18   
		out     EEARL, r17		   
		sbi     EECR,EERE		; Start eeprom read by writing EERE
		in      r16,EEDR		; Read data from Data Register
		sts		ASCII,r16  
		ret
.global BaudChange
BaudChange:
		out		U2X0, r16
		lds		r17, baudH
		lds		r16, baudL
		sts		UBRR0H, r17
		sts		UBRR0L, r16
		ret

		.end

