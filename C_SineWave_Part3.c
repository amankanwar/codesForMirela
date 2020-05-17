/**************************************************************************************************************************
Author	: 	Aman Kanwar
Version	: 	1.0.1

Description:
				This program perform sine wave generation with the help of DAC0808 and an Op-Amp LF351,
				connections are as follows:
				P1--->DAC0808---> LF351
				The sine wave generated can be seen on a logic analyzer.
				
				50 samples for generating the sine wave are used and stored in the code address space
				and are accessed using an array, internally which uses MOVC instruction
				
				Important notes for proteus: Use Clock Frequency of 12 Mhz in At89c51 settings
**************************************************************************************************************************/

//============================================================================
//								Importing the libraries needed
//============================================================================
#include<reg51.h>																// for 8051 registers
#include <intrins.h>															// for the nop instruction used in the program
//============================================================================

//============================================================================
//								50 Samples for Sine wave generation on Port 1 (do not alter the values)
//============================================================================
unsigned char code sin_value[50] =  {	0xfe, 0xfc, 0xfa, 0xf5, 0xee, 0xe5, 0xdb, 0xcf, 0xc3, 0xb5,
																												0xa6, 0x96, 0x86, 0x77, 0x67, 0x57, 0x48, 0x3a, 0x2e, 0x22,
																												0x18, 0xf, 0x8, 0x3, 0x1, 0x0, 0x1, 0x3, 0x8, 0xf, 0x18, 0x22,
																												0x2e, 0x3a, 0x48, 0x57, 0x67, 0x77, 0x86, 0x96, 0xa6, 0xb5,
																												0xc3, 0xcf, 0xdb, 0xe5, 0xee, 0xf5, 0xfa, 0xfc};
//============================================================================


//#######################################################################################
//								Main Program
//#######################################################################################
int main(void)
{
	
	int sample;																			// Taking a counter to index the required sample
	P1	=	0x00;   																	// Making Port 1 as output port

		//------------------ Endless Loop for continues sine wave generation---------------------------------------
		while(1)
			{ 
								//------------ This loop will generate one complete cycle -----------------------------------------
								for(sample=0; 			sample<50; 		sample++)
								{
										P1 = sin_value[sample];		// Sending the samples to Port 1
										_nop_ ();													// do nothing (for adjusting the wave)
										_nop_ ();													// do nothing (for adjusting the wave)
								}
								//----------------------------------------------------------------------------------------------------------------------
		 }
		//----------------------------------------------------------------------------------------------------------------------------------
		 return 0;																					// code will never come here (warning will appear)
}
//#######################################################################################
//#######################################################################################