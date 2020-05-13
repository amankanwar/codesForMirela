/*
Auther: Aman Kanwar
In this code I am performing the frequency calculations usign the Timers for 8051


Step1: Generate a delay of 0.1 seconds and Start Counting
Step2: Once Delay of 100ms is complete, stop the timer and counter and send the pules on port

Use Timer 1 as Timer 16 bit mode

*/

#include "myLcd.h"

#define CRYSTAL_FREQUENCY (11.0592)
#define MACHINE_CYCLE (12/CRYSTAL_FREQUENCY)


// function prototyping
void sysInit();
void performFreqCal();
//----------------------

volatile char globalCount 							= 	4;			// counter
volatile char calcFlag										=	'F';		// 1 byte in bits
unsigned int unknownFreq	= 0;			// this will hold the value




void timer1(void) interrupt 3
{
	--globalCount;
	if(globalCount)				// if not zero
	{
		TH1					= 0xA5;							// Timer 1 Initialized for 25 ms delay
		TL1						= 0xFE;
		TR1					= 1;	
	}
	else{						// if zero
		TR1					=	0;										// Stop the timer
		TR0					=	0;										// Stop the counter
		calcFlag 		= 'T';										// Raise the flag
	}	
}



int main()
{
	
	sysInit();						// initializing the system	
	
	lcdInit();			// initializing the LCD
	
	//--------Here we will run our timer and enable interrupts-----------------------------------
	TCON		= 	0x50; 							// Starting timer T0 and T1
	IE 				=	0x88;							// Enabling Global Interrupts and the timer 1 interrupt
	//---------------------------------------------------------------------------------------------------------------

	while(1)
	{
				// infinite loop
				if(calcFlag == 'T')
				{
					performFreqCal();
				}
	
	}
	
return 0;
}

void sysInit()
{
	TMOD 	= 0x15;
 	TH0  		= 0x00;								// Timer 0 Initialized with 00 values
	TL0  			= 0x00;
	

	TH1			= 0xA5;							// Timer 1 Initialized for 25 ms delay
	TL1				= 0xFE;

	/*
	//12MHz crystal
	 TH1			=	0x9E;
	 TL1			=	0x58;
*/

}

void performFreqCal()
{
	IE												=	0x00;				// disabing the interrupts 
	calcFlag 							= 'F';	


	unknownFreq				=	(TH0 << 8);
	unknownFreq				&= 0xFF00;	
	unknownFreq				|= TL0;
	unknownFreq				*= MACHINE_CYCLE;


	
	
	lcdSendString((const char *)"***FREQUENCY***", (sizeof("***FREQUENCY***")-1) );	
	
	sendDataCommand((const unsigned char) 0xC0, (enum lcdMode) commandMode);
	
	lcdSendString((const char *)"Freq: ", (sizeof("Freq: ")-1) );
	
	lcdSendInt((unsigned int)unknownFreq);	
}
