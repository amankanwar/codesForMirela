#include<reg51.h>

#define ADCP	P1
#define OUTP	P2	

void sysInit();					// setting up system
void storeData();				// reading the data and storing the same
void captureADCdata();				// general ADC conversion

sbit 		CS	=	P3^0;
sbit 		RDpin	=	P3^1;
sbit 		WRpin	=	P3^2;
sbit 		INTR	=	P3^3;

volatile unsigned short xdata ramAddr _at_ 0x4000;
volatile unsigned short xdata externalAddr;


void delay()					// Delay for 100 us
{
	char counter = 49;
	for(; counter >0; counter--);
}


int main(void)
{
	sysInit();				// calling for system initialization
	storeData();				// storing 1000 ADC values

	while(1)				// for general functionality
	{
		captureADCdata();	
	}		
	return  0;
}

void sysInit()
{
	ADCP		=	0xFF;
	externalAddr	=	ramAddr;
}

void storeData()
{
	short int counter = 1000;
	
	for(counter; counter>0; counter--)	// this will run 1000 times
	{
		captureADCdata();
		externalAddr	=	ADCP;
		++externalAddr;			// incrementing the externalAddr
		
		delay();			// 100 us delay
	}

}

void captureADCdata()
{
		//----------resetting pins--------
		RDpin		=	1;
		WRpin		=	1;
		INTR		=	1;
		//-------------------------------------
		
		//---------converting the data Low-To-High Pulse----
		WRpin	=	0;
		WRpin	=	1;
		//---------------------------------------------------------------------
	
		//--------Motinoring the INTR pin	--------------------------
		while(INTR);			// stay here till INTR is HIGH
		
		//---------reading the data High-To-Low Pulse----
		RDpin		=	1;
		RDpin		=	0;
		//---------------------------------------------------------------------
			
		// now data is there on the Port 1
		// displaying the data on port 2
		OUTP		=	ADCP;
}
