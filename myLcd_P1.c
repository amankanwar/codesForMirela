#include "myLcd.h"

const unsigned char lcdCommands[] = {0x38, 0x0E, 0x01, 0x06, 0x80};

sbit RSbit			=	P2^0;
sbit RWbit			=	P2^1;
sbit ENbit			=	P2^2;

//--------------------------------------------------------------------------------------------------------------------
/*********************************************************************************************
Description:
	LCD initialization for a given port.

Usage:
	Just calling the function will initialize the LCD connected on port addressed by the
	SFR pointer '*LcdPort'.

Parameters:
	No Parameters needed
*********************************************************************************************/
void lcdInit()
{
		char count	=	0;
		for(count; count <5; count++)
		{
			sendDataCommand(lcdCommands[count],commandMode);
		}
}
/*********************************************************************************************/
/*********************************************************************************************/


/*********************************************************************************************
Description:
	This is a generic function for both command and data sending to the given port

Usage:
	Just calling the function will either send command or data on the LCD (connected on port 
	addressed by the SFR pointer '*LcdPort').  

Parameters: 2
	const unsigned char dataCommand:
				This constant variable "dataCommand" will have the command or data passed
				by any calling function or user.
	
	enum lcdMode selectedMode:
				This "selectedMode" will decide whether the calling function wishes to write
				command on LCD or data on LCD.
				For sending command => commandMode  | For sending command => dataMode
*********************************************************************************************/
void sendDataCommand(const unsigned char dataCommand, enum lcdMode selectedMode)
{
	P1			=	dataCommand;
	
	if(selectedMode	==	dataMode)
	{
		RSbit	=	1;		// data mode	
	}
	else if(selectedMode	==	commandMode)
	{
		RSbit	=	0;		// command mode
	}

	RWbit		=	0;		// writing to LCD
	
	ENbit		=	1;		// high pulse
	ENbit		=	0;		// low pulse to latch data	
	delay(100);				// calling delay for latching
}
/*********************************************************************************************/
/*********************************************************************************************/


/*********************************************************************************************
Description:
	Delay for the LCD

Usage:
	Just a simple delay of 4 byte or 2 bytes (depending on compiler)

Parameters: 1
	unsigned int a:
		Just a neumeric value needs to be passed
*********************************************************************************************/
void delay(unsigned int a)
{
	for(a; a!=0; --a);
}
/*********************************************************************************************/
/*********************************************************************************************/



/*********************************************************************************************
Description:
	This function will be sending the Integer data on lcd, implemented in a way that the 
	BCD data packets will be sent on the LCD for a given integer value, by breaking the data

Usage:
	Just call this function with any short int value that you wish to display on LCD
	
Parameters: 1
	short int value:
		The neumeric value hold by "value" variable will be displayed on LCD
*********************************************************************************************/
void lcdSendInt(unsigned int value)
{
	
	char number[5]="";
	char length;
	
	sprintf(number, "%ud", value);
	length	=	strlen((const char *)number);
	
	
  lcdSendString(		(const char *)number		,		(length-1)		);	
	
	if(value != 0)
	{
			lcdSendChar('0');			// to show the multiply by 10
	}

	lcdSendString((const char *)"Hz",2);
		 
}
/*********************************************************************************************/
/*********************************************************************************************/



/*********************************************************************************************
Description:
	This function is for sending the characters on the Lcd, uses the generic function

Usage:
	Call this function by typecasting to (const unsigned char)value

Parameters: 1
	const unsigned char val:
		This value will be displayed on LCD, type casted is preferred to reduce warnings
*********************************************************************************************/
void lcdSendChar(const unsigned char val)
{
	// this will display the data on the LCD
	sendDataCommand((const unsigned char)val, dataMode);
}
/*********************************************************************************************/
/*********************************************************************************************/


/*********************************************************************************************
Description:
	This function is for sending string on the Lcd, uses the char function and generic function

Usage:
	Call this function with typecasted (const char *)"value"

Parameters: 2
	const char *myStr:
		myStr will be pointing to the string passed to the function, we should not modify this
		string that's why const type character pointer is used.
	char len:
	
*********************************************************************************************/
void lcdSendString(const char *myStr, char len)
{
	char *ptr	=	(char *)myStr;
	
	while(len != 0)
	{
		// this will display the data on the LCD
		sendDataCommand((const unsigned char)(*ptr), dataMode);
		ptr++;	// point to next character
		len--;	// decrement remaining characters
	}
}
/*********************************************************************************************/
/*********************************************************************************************/