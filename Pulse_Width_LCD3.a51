/****************************************************************************************
Author	: Aman Kanwar
Version	: 1.1.2

This code, perform the pulse width calculations and display the Data on 16*2 LCD
Only the registers containing the data will be displayed on the LCD, registers containing
zeros will not be displayed on the LCD.

This code uses the lookup table for the data display, data will be
displayed till the $ sign

New Functionality:
welcome message will be shown on the first line of the LCD
"us" will be shown at the end of the LCD's previous data


LCD- PORT 1 (LSB to MSB)
Connections
RS - P2.0
RW - P2.1
EN - P2.2
*****************************************************************************************/


;#########################################################################################
;				System Variables and Flag Defnitions
;#########################################################################################
;--------------- Definitions for Timer ----------------------------------------------------
WIDTH_FLAG	 	EQU	00H	; Flag for motinoring
TIMER_MODE		EQU 	09H	; Timer Mode (GATE Mode)
INTERRUPT_ENABLE	EQU 	81H	; Enabling Interrupt for external T0
TCON_Flags		EQU	01H	; Enabling 
INT0_ADDR		EQU	0003H	; Interrupt vector address
LCD_PORT		EQU 	P1	; LCD is connected to the port 1	
;------------------------------------------------------------------------------------------

;----------------LCD Control Pins----------------------------------------------------------
RS 			EQU P2.0	; 0 for Command, 1 for data
RW 			EQU P2.1	; 0 for write, 1 for read
EN			EQU P2.2	; For latching information High to Low pulse needs to be sent	
;------------------------------------------------------------------------------------------
;#########################################################################################
;#########################################################################################

		;XXXXXXXXX Start of Code XXXXXXXXX
		ORG 0000H
		SJMP MAIN
		;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;###############--Interrupt Routine for the external Interrupt################
		ORG INT0_ADDR
		JBC TR0, DONE		; Jump if timer was already running
		SETB TR0		; Start the timer
		RETI
	DONE:
		SETB WIDTH_FLAG		; Set the flag to notify
		RETI
;#############################################################################


;###########################################################################
;			MAIN subroutine
;###########################################################################
MAIN:
	ACALL SYSINIT			; Timer, Interrupt related init
MAIN_STAY:
	JBC WIDTH_FLAG, MAIN_OUTPUT	; Monitor the flag
	SJMP MAIN_STAY			; stay here

MAIN_OUTPUT:				
	ACALL OUTPUT			; Call for calculations
	SJMP MAIN_STAY
;###########################################################################
;###########################################################################



;###########################################################################
;		Output subroutine to call conversion subroutines
;###########################################################################
OUTPUT:
	MOV IE,	#00H			; Disable interrupts
	MOV R2, TL0			; MSB byte
	MOV R1, TH0			; LSB byte

	ACALL LCDINIT			; Initialize LCD
	ACALL Hex2BCD			; conversion to BCD
	ACALL Bcd2ASCII			; conversion to ASCII

	;------Display on Line 1, printing the string-----------------------
	MOV DPTR,#MYTABLE1		; displaying at 0x80 location	
	ACALL DISPLAY_STRING		; Display data from LookUp Table

	;------Changing the cusor to Line 2---------------------------------
	MOV A, #0C0H			; line 2			
	ACALL COMMAND			; Command subroutine

	;------Display on Line 2, printing the string-----------------------
	MOV DPTR,#MYTABLE2		; displaying at 0xC0 location	
	ACALL DISPLAY_STRING		; Display data from LookUp Table

	;------Display ASCII Data one Line2----------------------------------
	ACALL DISPLAY_ASCII		; Display data from R7 - R3 registers
	
	RET
;###########################################################################
;###########################################################################


;###########################################################################
;				Display ASCII
;###########################################################################
DISPLAY_ASCII:
	MOV R0,	#07H			; loading R7's address to pointer
	MOV R1,	#05			; entring count value

MOVE_AGAIN:				; Subroutine for Zero adjustments
	
	CJNE @R0,#30H, NO_ADJ		; Compare if register has '0'
	SJMP ADJUSTMENT			; If contains, perform adjustment

NO_ADJ:					; If no adjust is needed
	SJMP DISPLAY_DATA		; start displaying ASCII

ADJUSTMENT:
	DEC R0
	DEC R1
	SJMP MOVE_AGAIN

DISPLAY_DATA:				; routine to display converted data
	MOV A, @R0	
	ACALL DATAWRT			; send data to LCD	
	DEC R0
	DJNZ R1, DISPLAY_DATA 

;----------displaying 'uS' on LCD after data--------
	MOV A, #'u'
	ACALL DATAWRT
	MOV A, #'s'
	ACALL DATAWRT
;---------------------------------------------------
	
	RET
;###########################################################################
;###########################################################################




;###########################################################################
;     Display Subroutine (Generic code), load DPTR with table to display
;###########################################################################
DISPLAY_STRING:
	CLR A				; Clear the Accumulator

AGAIN:					; Table reading subroutine

	MOVC A, @A+DPTR			; Capture data from Table into A
	CJNE A, #'$', TABLEDATA		; Keep on Jumping until '$'
	RET				; once done, return to caller

TABLEDATA:				; String display subroutine
	ACALL DATAWRT			; LCD data display
	CLR A				; Clear A for next read
	INC DPTR			; increment the Data Pointer
	SJMP AGAIN			; All over again
;###########################################################################
;###########################################################################




;###########################################################################
;	System Init and Timer Init subroutine
;###########################################################################
SYSINIT:
	MOV SP, #30H			; Shifting stack pointer
	MOV TMOD, #TIMER_MODE		; Setting the timer mode
	
	MOV TL0, #00H			; timer values
	MOV TH0, #00H
	
	MOV TCON, #TCON_Flags		; Level Trigerred
	MOV IE, #INTERRUPT_ENABLE	; Global interrupt | external enable

	RET
;###########################################################################
;###########################################################################



;###########################################################################
;			LCD Related Code
;###########################################################################
;----------------------------------------------
LCDINIT:	
	MOV A,	#38H			; selecting 2 lines and 5x7 matrix
	ACALL COMMAND			; sending commands to LCD
	
	MOV A, 	#0EH			; Display on, cursor blinking
	ACALL COMMAND			; sending commands to LCD
	
	MOV A, 	#01H			; Clear display screen
	ACALL COMMAND			; sending commands to LCD

	MOV A, 	#06H			; Increment cursor (shift to right)
	ACALL COMMAND			; sending commands to LCD

	MOV A, 	#80H			; Force cursor to 1st line
	ACALL COMMAND			; sending commands to LCD
RET
;----------------------------------------------
;----------------------------------------------
COMMAND:
	MOV P1, A			; Sending data to LCD
	CLR RS				; command mode
	CLR RW				; write mode to LCD
	
	SETB EN				; High Pulse
	CLR EN				; Low pulse
	ACALL DELAY			; Calling delay for Latching
	RET
;----------------------------------------------
;----------------------------------------------
DATAWRT:
	MOV P1, A			; Sending data to LCD
	
	SETB RS				; data mode
	CLR RW				; Write to the LCD
	
	SETB EN				; High Pulse to LCD
	CLR EN				; Low Pulse to LCD
	ACALL DELAY			; Calling delay for Latching
	RET
;----------------------------------------------	
;###########################################################################
;###########################################################################


;###########################################################################
;				Software DELAY
;###########################################################################
DELAY: 
	SETB PSW.3			; Selecting register bank 1 for delays
	MOV R3,	#50 			; 50 or higher for fast CPUs
HERE2: 
	MOV R4,	#255 			; R4 = 255
HERE: 
	DJNZ R4, HERE 			; stay until R4 becomes 0
	DJNZ R3, HERE2
	CLR PSW.3			; Selecting register bank 1 for delays
	RET
;###########################################################################
;###########################################################################



;#################################################################
;		BCD to ASCII conversion for LCD
;#################################################################
Bcd2ASCII:
	MOV R0, #03H			; Loading the address pointer
	MOV R1, #5			; loading the counter
	
	STAY_HERE:
	MOV A, @R0
	ORL A, #30H			; Converting the data into ASCII
	MOV @R0, A
	INC R0				; Increment the Address into R0
	DJNZ R1, STAY_HERE		; Conversion till R7

RET
;#################################################################
;#################################################################



;#################################################################
;		Hex To BCD data conversion code
;#################################################################
;----------------------------------------------
Hex2BCD:

 	MOV R3,#00D
	MOV R4,#00D
    	MOV R5,#00D
    	MOV R6,#00D
    	MOV R7,#00D
 
	MOV B,#10D
	MOV A,R2
    	DIV AB
    	MOV R3,B        	  	; Resto en R3   
    	MOV B,#10      	    		; R7,R6,R5,R4,R3
    	DIV AB
    	MOV R4,B			; Resto en R4		
    	MOV R5,A
    	CJNE R1,#0H,HIGH_BYTE    	; CHECK FOR HIGH BYTE
        
	RET
;----------------------------------------------
;----------------------------------------------		
HIGH_BYTE:
	MOV A,#6
    	ADD A,R3
	MOV B,#10
	DIV AB
    	MOV R3,B
	ADD A,#5
    	ADD A,R4
	MOV B,#10
	DIV AB
    	MOV R4,B
	ADD A,#2
    	ADD A,R5
	MOV B,#10
	DIV AB
    	MOV R5,B
    	CJNE R6,#00D,ADD_IT
    	SJMP CONTINUE
;----------------------------------------------
;----------------------------------------------		
ADD_IT:
     	ADD A,R6
CONTINUE:
     	MOV R6,A
     	DJNZ R1,HIGH_BYTE
     	MOV B,#10D
     	MOV A,R6
     	DIV AB
     	MOV R6,B
     	MOV R7,A
		
	RET
;----------------------------------------------		
;#################################################################
;#################################################################


;----------LOOKUP TABLE-----------
MYTABLE1: 
DB	"MEASURING PULSE$" 
MYTABLE2:	
DB	"Width: $" 
;---------------------------------

END
