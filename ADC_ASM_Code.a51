/***************************************************************************
Author: Aman Kanwar
V 1.0.1

ADC Conversion, pin connections are provided below:

***************************************************************************/

;------------------------ Pin Definitions	------------------------------------------
CS		EQU	P3.0
RDpin		EQU	P3.1
WRpin		EQU	P3.2
INTR		EQU	P3.3
ADCP		EQU	P1
OUTP		EQU	P2	
ADDR		EQU	4000H			; This address will be loaded in DPTR
;----------------------------------------------------------------------------------------

ORG 0000H
	SJMP		MAIN



MAIN:
	MOV 		ADCP,	#0FFH		; Making the port as input
		
	MOV		DPTR,	#ADDR
	
	ACALL		STORE_DATA

STAY:
	ACALL		CAPTURE
	SJMP 		STAY
	
;################################################################
STORE_DATA:					; Here we will store the data 1000 times
	MOV		R0, #4			; counter value
	
	STORE_DATA_LOOP1:			
	MOV 		R1, #250D		; counter value

	STORE_DATA_LOOP2:	
	ACALL 		DELAY			; 100 us delay
	DJNZ		R1,	MOVE_DATA	
	DJNZ		R0, STORE_DATA_LOOP1
	RET
	
	MOVE_DATA:
	ACALL	 	CAPTURE
	
	;  Writing data to the extended memory locations
	MOV 		A,	 ADCP				
	MOVX		@DPTR,	A 
	INC 		DPTR

	SJMP		STORE_DATA_LOOP2 	
	
	DELAY:
	MOV R2,#49				;Machine Cycle = 1
	HERE: 
	DJNZ R2,HERE				;Machine Cycle = 2
	RET					;Machine Cycle = 1
		;we have a time delay of [(49 x 2) + 1 + 1] x 1 = 100 us	
;################################################################	
	
;################################################################	
CONVERT_DATA:					; Low to High Pulse on ADC
	CLR		WRpin
	SETB		WRpin
	RET
;################################################################	

;################################################################	
READ_DATA:					; High to low pulse for reading
	SETB		RDpin
	CLR		RDpin
	RET
;################################################################	

;################################################################	
CAPTURE:					; Here we will send the data to the memory locations
	SETB		RDpin
	SETB		WRpin
	SETB		INTR
	
	ACALL		CONVERT_DATA
	WAIT:		JB	INTR,	WAIT
	ACALL		READ_DATA

	MOV		OUTP, ADCP	
	RET
;################################################################	

END
