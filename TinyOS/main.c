
 // Lab3P1.c
 //
 // Created: 1/30/2018 4:04:52 AM
 // Author : Eugene Rockey
 // Copyright 2018, All Rights Reserved
 
 //no includes, no ASF, no libraries
 #include <stdio.h>
 #include <stdlib.h>
 
 const char MS1[] = "\r\nECE-412 ATMega328P Tiny OS";
 const char MS2[] = "\r\nby Eugene Rockey Copyright 2018, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)CD, (E)EPROM, (U)SART\r\n";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = "Volts\r";
 const char MS7[] = "Please Input the Desired Baud Rate: ";
 const char MS8[] = "\r\nPlease Input the Desired Number of Data Bits: ";
 const char MS9[] = "\r\nPlease Input the Desired Parity: ";
 const char MS10[] = "\r\nPlease Input the Desired Number of Stop Bits: ";
 
 

void LCD_Init(void);			//external Assembly functions
void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Put(void);
void LCD_Write_Data(void);
void LCD_Write_Command(void);
void LCD_Read_Data(void);
void Mega328P_Init(void);
void ADC_Get(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void USART(void);
void ChangeBaud(void);
void ChangeBaudAux(unsigned int);
void Baud4800(void);
void Baud9600(void);
void Baud14400(void);
void Baud19200(void);
void Baud38400(void);
void Baud57600(void);
void ChangeDataBits(void);
void ChangeParity(void);
void ChangeStopBits(void);
void WriteEEPROM(void);
void ReadEEPROM(void);

unsigned char ASCII;			//shared I/O variable with Assembly
unsigned char DATA;				//shared internal variable with Assembly
unsigned int UCSR0B;
unsigned int UCSR0C;
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly
char addrH;
char addrL;
char eepromData;
unsigned char UBRR0H;
unsigned char UBRR0L;
unsigned int UBBR;

char volts[5];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use

void UART_Puts(const char *str)	//Display a string in the PC Terminal Program
{
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
	}
}

void LCD_Puts(const char *str)	//Display a string on the LCD Module
{
	while (*str)
	{
		DATA = *str++;
		LCD_Write_Data();
	}
}


void Banner(void)				//Display Tiny OS Banner on Terminal
{
	UART_Puts(MS1);
	UART_Puts(MS2);
	UART_Puts(MS4);
}

void HELP(void)						//Display available Tiny OS Commands on Terminal
{
	UART_Puts(MS3);
}

void LCD(void)						//Lite LCD demo
{
	DATA = 0x34;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x08;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x02;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x06;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x0f;					//Student Comment Here
	LCD_Write_Command();
	LCD_Puts("Hello ECE412!");
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}

void ADC(void)						//Lite Demo of the Analog to Digital Converter
{
	volts[0x1]='.';
	volts[0x3]=' ';
	volts[0x4]= 0;
	ADC_Get();
	Acc = (((int)HADC) * 0x100 + (int)(LADC))*0xA;
	volts[0x0] = 48 + (Acc / 0x7FE);
	Acc = Acc % 0x7FE;
	volts[0x2] = ((Acc *0xA) / 0x7FE) + 48;
	Acc = (Acc * 0xA) % 0x7FE;
	if (Acc >= 0x3FF) volts[0x2]++;
	if (volts[0x2] == 58)
	{
		volts[0x2] = 48;
		volts[0x0]++;
	}
	UART_Puts(volts);
	UART_Puts(MS6);
	/*
		Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
		The potentiometer simulates a thermistor, its varying resistance simulates the
		varying resistance of a thermistor as it is heated and cooled. See the thermistor
		equations in the lab 3 folder. User must always be able to return to command line.
	*/
	
}

void EEPROM(void)
{
	UART_Puts("\r\n(R)ead or (W)rite");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case 'R' | 'r':
			ReadEEPROM();
		break;
		case 'W' | 'w':
			WriteEEPROM();
		break;
		default:
			UART_Puts(MS5);
		break;
	}
			
	/*
	Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.
	*/
	/*UART_Puts("\r\n");
	EEPROM_Write();
	UART_Puts("\r\n");
	EEPROM_Read();
	UART_Put();
	UART_Puts("\r\n"); */
}

void ReadEEPROM(void)
{
	UART_Puts("\r\nEnter the upper bit of a valid EEPROM address to read from: ");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	addrH = ASCII;
	UART_Puts("\r\nEnter the lower bit of a valid EEPROM address to read from: ");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	addrL = ASCII;
	EEPROM_Read();
	UART_Put();
}

void WriteEEPROM(void)
{
	UART_Puts("\r\nEnter the upper bit of a valid EEPROM address to write to: ");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	addrH = ASCII;
	UART_Puts("\r\nEnter the lower bit of a valid EEPROM address to write to: ");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	addrL = ASCII;
	UART_Puts("\r\nEnter the data to be stored: ");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	eepromData = ASCII;
	EEPROM_Write();
	UART_Puts("\r\nThe data has been successfully written to the desired EEPROM address");
}

void USART(void)
{
	UART_Puts(MS7);
	ChangeBaud();
	UART_Puts(MS8);
	ChangeDataBits();
	UART_Puts(MS9);
	ChangeParity();
	UART_Puts(MS10);
	ChangeStopBits();
}

void ChangeBaudAux(unsigned int UBBR)
{
	UBRR0H = (unsigned char)(UBBR>>8);
	UBRR0L = (unsigned char)UBBR;
}

void ChangeBaud(void)
{
	UART_Puts("\r\nWhat Baud Rate would you like?\n");
	UART_Puts("\r\n(1)4800\r\n(2)9600\r\n(3)14400\r\n(4)19200\r\n(5)38400\r\n(6)57600");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case '1':
			UART_Puts("\r\nBaud rate successfully changed to 4800");
			ChangeBaudAux(4800);
			Baud4800();
		break;
		case '2':
			UART_Puts("\r\nBaud rate successfully changed to 9600");
			ChangeBaudAux(9600);
			Baud9600();
		break;
		case '3':
			UART_Puts("\r\nBaud rate successfully changed to 14400");
			ChangeBaudAux(14400);
			Baud14400();
		break;
		case '4':
			UART_Puts("\r\nBaud rate successfully changed to 19200");
			ChangeBaudAux(19200);
			Baud19200();
		break;
		case '5':
			UART_Puts("\r\nBaud rate successfully changed to 38400");
			ChangeBaudAux(38400);
			Baud38400();
		break;
		case '6':
			UART_Puts("\r\nBaud rate successfully changed to 57600");
			ChangeBaudAux(57600);
			Baud57600();
		break;
		default:
			UART_Puts(MS5);
			ChangeBaud();
		break;
	}
}

void ChangeDataBits(void)
{
	UART_Puts("\r\nHow many data bits are desired? (5,6,7,8,9)");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case '5':
			UCSR0C |= (0<<1)&&(0<<2);
			UCSR0B |= (0<<2);
			UART_Puts("\r\nNumber of data bits has been changed to 5");
		break;
		case '6':
			UCSR0C |= (1<<1)&&(0<<2);
			UCSR0B |= (0<<2);
			UART_Puts("\r\nNumber of data bits has been changed to 6");
		break;
		case '7':
			UCSR0C |= (0<<1)&&(1<<2);
			UCSR0B |= (0<<2);
			UART_Puts("\r\nNumber of data bits has been changed to 7");
		break;
		case '8':
			UCSR0C |= (1<<1)&&(1<<2);
			UCSR0B |= (0<<2);
			UART_Puts("\r\nNumber of data bits has been changed to 8");
		break;
		case '9':
			UCSR0C |= (1<<1)&&(1<<2);
			UCSR0B |= (1<<2);
			UART_Puts("\r\nNumber of data bits has been changed to 9");
		break;
		default:
			UART_Puts(MS5);
			ChangeDataBits();
		break;
	}
}

void ChangeParity(void)
{
	UART_Puts("\r\nSelect a parity:\r\n(1)None\r\n(2)Odd\r\n(3)Even");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case '1':
			UCSR0C |= (0<<5)&&(0<<4);
			UART_Puts("\r\nNo parity was set");
		break;
		case '2':
			UCSR0C |= (1<<5)&&(1<<4);
			UART_Puts("\r\nAn odd parity was set");
		break;
		case '3':
			UCSR0C |= (1<<5)&&(0<<4);
			UART_Puts("\r\nAn even parity was set");
		break;
		default:
			UART_Puts(MS5);
			ChangeParity();
		break;
	}
}

void ChangeStopBits(void)
{
	UART_Puts("\r\nSelect how many stop bits are desired: 1 or 2");
	ASCII = '\0';
	while(ASCII == '\0')
	{
		UART_Get();
	}
	switch(ASCII)
	{
		case '1':
			UCSR0C |= (1<<3);
			UART_Puts("\r\nOne stop bit will be provided");
		break;
		case '2':
			UCSR0C |= (0<<3);
			UART_Puts("\r\nTwo stop bits will be provided");
		break;
		default:
			UART_Puts(MS5);
			ChangeStopBits();
		break;
	}
}


void Command(void)					//command interpreter
{
	UART_Puts(MS3);
	ASCII = '\0';						
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case 'L' | 'l': LCD();
		break;
		case 'A' | 'a': ADC();
		break;
		case 'E' | 'e': EEPROM();
		break;
		case 'U' | 'u': USART();
		break;
		default:
		UART_Puts(MS5);
		HELP();
		break;  			//Add a 'USART' command and subroutine to allow the user to reconfigure the 						//serial port parameters during runtime. Modify baud rate, # of data bits, parity, 							//# of stop bits.
	}
}

int main(void)
{
	Mega328P_Init();
	Banner();
	while (1)
	{
		Command();				//infinite command loop
	}
}

