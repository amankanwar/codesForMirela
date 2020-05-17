/**************************************************************************************************************************
Author	: 	Aman Kanwar
Version	: 	1.0.1

Description:
				This program perform sine wave generation with the help of DAC0808 and an Op-Amp LF351,
				connections are as follows:
				P1--->DAC0808---> LF351
				The sine wave generated can be seen on a logic analyzer.
				
				90 samples for generating the sine wave are used and stored in the program address space
				and are accessed as lookup table with the help of DPTR register
				
				Important notes for proteus: Use Clock Frequency of 12 Mhz in At89c51 settings
**************************************************************************************************************************/


TABLE EQU  300H

ORG 00H
SJMP MAIN

;#######################################################################################
;					MAIN subroutine
;#######################################################################################
MAIN:

		MOV P1, #00H							; Making the Port 1 as output port
	
		;------------------------This will be called again to reload the DPTR for next wave------------------------------------
		AGAIN:
		MOV DPTR ,#TABLE					; Load the table address in the DPTR
		MOV R0,#90D							; loading the number of samples

		;---------------------This will be called multiple timers for completing one sine wave--------------------------------
		REPEAT:
		MOVC A,@A+DPTR					; loading the samples into Accumulator from table
		MOV P1,A								; sending the data to Port 1
		CLR A										; clearing the accumulator for next sample
		NOP											; do nothing (for adjusting the wave)
		NOP											; do nothing (for adjusting the wave)
		NOP											; do nothing (for adjusting the wave)

		INC DPTR									; Increment the DPTR by one, pointing to next sample
		 
		DJNZ R0,REPEAT						; Decrement counter and move to next sample
		;------------------------------------------------------------------------------------------------------------------------------------------------
		
		SJMP AGAIN							; Reload the DPTR for new wave
		;------------------------------------------------------------------------------------------------------------------------------------------------
;#######################################################################################
;#######################################################################################


;#######################################################################################
;	!!!		DO NOT CHANGE THIS TABLE VALUES WITH ANYTHING (SYSTEM CALIBRATED)   !!!
;#######################################################################################
ORG  TABLE
DB 254, 253, 252, 251, 249, 246, 243, 239, 234, 229, 224, 218, 211
DB 205, 198, 190, 182, 174, 166, 157, 149, 140, 131, 122, 113, 104
DB 96, 87, 79, 71, 63, 55, 48, 42, 35, 29, 24, 19, 14, 10, 7, 4, 2, 1, 0
DB 0, 0, 1, 2, 4, 7, 10, 14, 19, 24, 29, 35, 42, 48, 55, 63, 71, 79, 87
DB 96, 104, 113, 122, 131, 140, 149, 157, 166, 174, 182, 190, 198
DB 205, 211, 218, 224, 229, 234, 239, 243, 246, 249, 251, 252, 253
;#######################################################################################
;#######################################################################################
END 