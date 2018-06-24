
 // Lab3P1.c
 //
 // Created: 1/30/2018 4:04:52 AM
 // Author : Eugene Rockey
 // Copyright 2018, All Rights Reserved
    
#include <math.h>   
#include <string.h>  
 
 const char MS1[] = "\r\nECE-412 ATMega328P Tiny OS";
 const char MS2[] = "\r\nby Eugene Rockey Copyright 2018, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)CD, (E)EPROM\r\n";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = " Fahrenheit\r";
 
 

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
void ADC_Poll(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void UART_Poll(void);
void substring(char*, char*, int);
void scrollingLCD(char*);
void LCD_Delay(void);

unsigned char ASCII;			//shared I/O variable with Assembly
unsigned char DATA;				//shared internal variable with Assembly
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly

char lastTemperature[5] = "     ";
char temperature[5];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use
int isADC;



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
	
	char message[50] = "Group 4 is the best group in the world. ";
	
	scrollingLCD(message);
		
	
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}


void scrollingLCD(char * message) {
	
	int exitScroll = 1;
	int incrementer = 0;	

	int sizeOfOrigin = strlen(message);
	
	while(exitScroll) {
		
		char destination[17] = "                ";
		
		int input = incrementer % sizeOfOrigin;
		substring(message, destination, input);
		
		LCD_Puts(destination);
		
		for(int iter = 0; iter < 5000; iter++){}
			
		UART_Poll();
		if(incrementer == 25){
			exitScroll = 0;
			break;
		}	
		
		incrementer++;
	}
	
}


void substring(char *origin, char *destination, int arStart){
	
	int sizeOfOrigin = strlen(origin);
	int sizeOfDestination = strlen(destination);
	int destinationIndex = 0;
	
	for(int i=arStart;i<(sizeOfDestination + arStart);i++){
		int originIndex = 0;
		originIndex  = (i % sizeOfOrigin);
		
		destination[destinationIndex]=origin[originIndex];
		destinationIndex++;
	}
	
	destination[sizeOfDestination]='\0';
	return;
}


void ADC(void)						//Lite Demo of the Analog to Digital Converter
{
	//int stayInLoop = 1;

	//while(stayInLoop){
		
		//Mega328P_Init();
		isADC = 1;
		
		ADC_Get();		
		
		double celsius = 0;
		double kelvin = 0;
		int fahrenheit = 0;
		
		
		Acc = (((int)HADC) * 0x100 + (int)(LADC));
		
			
		double r = (10000.0 * ((double)Acc))/(1024.0 - ((double)Acc));
		const double t0 = 295.37;
		const double B = 3950.0;
		double r0 = ((double)10000 * (double)512)/((double)1024 - (double)512);
		r = r/r0;
	
		kelvin = (B * t0)/(t0 * log(r) + B);

		celsius = kelvin - 273.15;
	
		fahrenheit = floor(celsius*(9.0/5.0) + 32.0);
	
		char f0 = (fahrenheit/100) + '0';
		fahrenheit = fahrenheit % 100;
		char f1 = (fahrenheit/10) + '0';
		fahrenheit = fahrenheit % 10;
		char f2 = fahrenheit + '0';

		if(f0 == '0'){
			f0 = ' ';
		}
	
		temperature[0] = f0;
		temperature[1] = f1;
		temperature[2] = f2;
		temperature[3] = 167;
		temperature[4] = 0;
	
		if(strcmp(lastTemperature, temperature) != 0){
	
		UART_Puts(temperature);
		UART_Puts(" F\r");
		
		strcpy(lastTemperature, temperature);
		}
		
		//UART_Get();
		UART_Poll();
		if(ASCII == 'x'){
			//stayInLoop = 0;
			//break;
			isADC = 0;
		}

	//}

	/*
		Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
		The potentiometer simulates a thermistor, its varying resistance simulates the
		varying resistance of a thermistor as it is heated and cooled. See the thermistor
		equations in the lab 3 folder. User must always be able to return to command line.
	*/
	
}




void EEPROM(void)
{
	UART_Puts("\r\nEEPROM Write and Read.");
	/*
	Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.
	*/
	UART_Puts("\r\n");
	EEPROM_Write();
	UART_Puts("\r\n");
	EEPROM_Read();
	UART_Put();
	UART_Puts("\r\n");
}


void Command(void)					//command interpreter
{
	if(!isADC){
	UART_Puts(MS3);	
	ASCII = '\0';						
	while (ASCII == '\0')
	{
		UART_Get();
	}
	}
	else {
		ASCII = 'a';
	}
	switch (ASCII)
	{
		case 'L' | 'l': LCD();
		break;
		case 'A' | 'a': ADC();
		break;
		case 'E' | 'e': EEPROM();
		break;
		case 'X' | 'x':
		break;
		default:
		UART_Puts(MS5);
		HELP();
		break;  			//Add a 'USART' command and subroutine to allow the user to reconfigure the 						
							//serial port parameters during runtime. Modify baud rate, # of data bits, parity, 							
							//# of stop bits.
	}
}

int main(void)
{
	Mega328P_Init();
	Banner();
	isADC =  0;
	while (1)
	{
		Command();				//infinite command loop
	}
}
