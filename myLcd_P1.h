#ifndef __myLcd_h
#define __myLcd_h

#include<reg51.h>
#include<stdio.h>
#include<string.h>


enum lcdMode{commandMode, dataMode};
extern const unsigned char lcdCommands[]; 
/*

/*********************************************************************************************
Description:
	LCD initialization for a given port.

Usage:
	Just calling the function will initialize the LCD connected on port addressed by the
	SFR pointer '*LcdPort'.

Parameters:
	No Parameters needed
																																																										*/
void lcdInit();
//*********************************************************************************************

/**********************************************************************************************
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
				command on LCD or data on
 LCD.
				For sending command => commandMode  | For sending command => dataMode
																																																																	*/
void sendDataCommand(const unsigned char dataCommand, enum lcdMode selectedMode);
//*********************************************************************************************


/*********************************************************************************************
Description:
	Delay for the LCD

Usage:
	Just a simple delay of 4 byte or 2 bytes (depending on compiler)

Parameters: 1
	unsigned int a:
		Just a neumeric value needs to be passed
																																																											*/
void delay(unsigned int a);
//*********************************************************************************************


/*********************************************************************************************
Description:
	This function will be sending the Integer data on lcd, implemented in a way that the 
	BCD data packets will be sent on the LCD for a given integer value, by breaking the data

Usage:
	Just call this function with any short int value that you wish to display on LCD
	
Parameters: 1
	short int value:
		The neumeric value hold by "value" variable will be displayed on LCD						*/
void lcdSendInt(unsigned int value);																																			
//********************************************************************************************


/*********************************************************************************************
Description:
	This function is for sending the characters on the Lcd, uses the generic function

Usage:
	Call this function by typecasting to (const unsigned char)value

Parameters: 1
	const unsigned char val:
	This value will be displayed on LCD, type casted is preferred to reduce warnings */
void lcdSendChar(const unsigned char val);
//********************************************************************************************

/*********************************************************************************************
Description:
	This function is for sending string on the Lcd, uses the char function and generic function

Usage:
	Call this function with typecasted (const char *)"value"

Parameters: 2
	const char *myStr:
		myStr will be pointing to the string passed to the function, we should not modify this
		string that's why const type character pointer is used.
	char len:																																																			*/
void lcdSendString(const char *myStr, char len);	
//*********************************************************************************************



#endif