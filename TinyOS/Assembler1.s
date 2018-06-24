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
		ldi r16,0xFF		//Loads 0xFF int r16
		sts DIDR1,r16		//Stores 0xFF into DIDR0 which is the data input disable register
		ret					//Return from Mega328P_Init - I/O port and ADC configurations have been set
	
.global LCD_Write_Command
LCD_Write_Command:
	call	UART_Off		//Call subroutine UART_off to temporarily turn UART off
	ldi		r16,0xFF		;PD0 - PD7 as outputs
	out		DDRD,r16		//Set Data Direction Register D
	lds		r16,DATA		//Load contents of Label Data into r16
	out		PORTD,r16		//Move contents of Label Data into Port D from r16
	ldi		r16,4			//Load constant 4 into r16
	out		PORTB,r16		//Move 4 from r16 into Port B
	call	LCD_Delay		//Call subroutine LCD_Delay to do nothing for a constant amount of clock cycles
	ldi		r16,0			//Clear r16
	out		PORTB,r16		//Clear PortB
	call	LCD_Delay		//Call subroutine LCD_Delay to do nothing for a constant amount of clock cycles
	call	UART_On			//Call subroutine UART_On to turn UART back on
	ret						//End of LCD_Write_Command

.global LCD_Delay
LCD_Delay:
	ldi		r16,0xFA		//Load constant 250 into r16
D0:	ldi		r17,0xFF		//Load constant 255 into r17
D1:	dec		r17				//Decrement r17
	brne	D1				//Branch back to D1 while it's still not 0.
	dec		r16				//Decrement r16
	brne	D0				//Branch back to D0 while it's still not 0.
	ret						//End of LCD_Delay

.global LCD_Write_Data
LCD_Write_Data:
	call	UART_Off		//Call subroutine UART_off to temporarily turn UART off
	ldi		r16,0xFF		//Set r16
	out		DDRD,r16		//Set Data Direction Register D
	lds		r16,DATA		//Load contents of Label Data into r16
	out		PORTD,r16		//Move contents of Label Data into Port D
	ldi		r16,6			//Load constant 6 into r16
	out		PORTB,r16		//Move 6 from r16 into Port B
	call	LCD_Delay		//Call subroutine LCD_Delay to do nothing for a constant amount of clock cycles
	ldi		r16,0			//Clear r16
	out		PORTB,r16		//Clear PortB
	call	LCD_Delay		//Call subroutine LCD_Delay to do nothing for a constant amount of clock cycles
	call	UART_On			//Call subroutine UART_On to turn UART back on
	ret						//End of UART_Write_Data

.global LCD_Read_Data
LCD_Read_Data:
	call	UART_Off		//Call subroutine UART_off to temporarily turn UART off
	ldi		r16,0x00		//Clear r16
	out		DDRD,r16		//Clear Data Direction Register D
	out		PORTB,4			//Load constant 4 into Port B 
	in		r16,PORTD		//Read contents of Port D Data Register into r16
	sts		DATA,r16		//Store the contents of Port D Data Register into label Data
	out		PORTB,0			//clear Port B
	call	UART_On			//Call subroutine UART_On to turn UART back on
	ret						//End of LCD_Read_Data

.global UART_On
UART_On:
	ldi		r16,2				//Load constant 2 into r16
	out		DDRD,r16			//Store 2 into Data Direction Register Port D
	ldi		r16,24				//Load constant 24 into r16
	sts		UCSR0B,r16			//Store 24 into USART Control and Status Register 0 B
	ret							//End of UART_On

.global UART_Off
UART_Off:
	ldi	r16,0					//Load constant 0 into r16
	sts UCSR0B,r16				//Move 0 from r16 into USART Control and Status Register 0 B
	ret							//End of UART_Off

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			//Store the contents of USART Control and Status Register 0 A into r16
	sbrs	r16,RXC0			//Skips the next line if USART Receive Complete is set
	ret							//End of UART_Clear
	lds		r16,UDR0			//Store the contents of USART I/O Data Register 0 into r16
	rjmp	UART_Clear			//Loop back to start while RXC0 = 1

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			//Store the contents of USART Control and Status Register 0 A into r16
	sbrs	r16,RXC0			//Skips the next line if USART Receive Complete is set
	rjmp	UART_Get			//Loop back to start while RXC0 = 1
	lds		r16,UDR0			//Store the contents of USART I/O Data Register 0 into r16
	sts		ASCII,r16			//Move the contents of USART I/O Data Register 0 from r16 into label ASCII
	ret							//End of UART_Get

.global UART_Poll
UART_Poll:
	lds		r16,UDR0			//Store the contents of USART I/O Data Register 0 into r16
	sts		ASCII,r16			//Move the contents of USART I/O Data Register 0 from r16 into label ASCII
	ret							//End of UART_Get

.global UART_Put
UART_Put:
	lds		r17,UCSR0A			//Store the contents of USART Control and Status Register 0 A into r17
	sbrs	r17,UDRE0			//Skips the next instruction if USART Data Register Empty is set
	rjmp	UART_Put			//Loop back to start while UDRE0 = 1
	lds		r16,ASCII			//Load Label ASCII into r16
	sts		UDR0,r16			//Move ASCII from r16 to USART Data Register
	ret							//End of UART_Put

.global ADC_Get
ADC_Get:
		ldi		r16,0xE7			//Load 231 into r16
		sts		ADCSRA,r16			//Move 231 from r16 to ADC Control and Status Register A
A2V1:	lds		r16,ADCSRA			//Load the ADC Control and Status Register A into r16
		sbrc	r16,ADSC			//Skip the following instruction if the ADC Start Conversion bit is cleared
		rjmp 	A2V1				//Loop back into A2V1, continually scanning for ADCSRA to be 1
		lds		r16,ADCL			//ADCL must be read first, then ADCH, to ensure that the content of the Data Registers belongsto the same conversion
		sts		LADC,r16			//Store ADCL into SRAM Label LADC
		lds		r16,ADCH			//The rest of ADC is read
		sts		HADC,r16			//Store ADCH into SRAM Label HADC
		ret							//End of ADC_Get				


					
.global EEPROM_Write
EEPROM_Write:      
		sbic    EECR,EEPE
		rjmp    EEPROM_Write		; Wait for completion of previous write
		ldi		r18,0x00			; Set up address (r18:r17) in address register
		ldi		r17,0x05 
		ldi		r16,'F'				; Set up data in r16    
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
		ldi		r18,0x00		; Set up address (r18:r17) in EEPROM address register
		ldi		r17,0x05
		ldi		r16,0x00   
		out     EEARH, r18   
		out     EEARL, r17		   
		sbi     EECR,EERE		; Start eeprom read by writing EERE
		in      r16,EEDR		; Read data from Data Register
		sts		ASCII,r16  
		ret


		.end

