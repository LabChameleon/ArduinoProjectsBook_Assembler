/*
 * Spaceship_Interface.asm
 *
 *  Created: 16.07.2015 14:53:22
 *   Author: Julian
 */ 

 .include "./m328Pdef.inc"
 .equ msec = 4000
 .equ time = 1000

		ldi r16, high(RAMEND) ; Initiate Stack
		out SPH,r16 
		ldi r16, low(RAMEND)
		out SPL,r16

		cbi DDRD, 2						; set Port to input
		sbi DDRD, 3						; set Port to output
		sbi DDRD, 4						; set Port to output
		sbi DDRD, 5						; set Port to output

		sbi PORTD, 3					; set Port to HIGH
		cbi PORTD, 4					; set Port to LOW
		cbi PORTD, 5					; set Port to LOW

MLoop:	sbic PIND, 2					; check if PinD2 input is clear
		RCALL BPress					; if PinD2 is not clear button is pressed
		sbi PORTD, 3					; set Port to HIGH
		cbi	PORTD, 4					; set Port to LOW
		cbi PORTD, 5					; set Port to LOW
		rjmp MLoop						; Main Loop

BPress:	cbi PORTD, 3					; set Port to LOW
		sbi	PORTD, 4					; set Port to HIGH
		cbi PORTD, 5					; set Port to LOW

		ldi R25, HIGH(time)				; set Register to 1000
		ldi R24, LOW(time)				; set Register to 1000
		RCALL DxT						; start Timer

		cbi PORTD, 3					; set Port to LOW
		cbi	PORTD, 4					; set Port to LOW
		sbi PORTD, 5					; set Port to HIGH

		ldi R25, HIGH(time)				; set Register to 1000
		ldi R24, LOW(time)				; set Register to 1000
		RCALL DxT						; start Timer
		ret								; return to main programm
	
DxT:	mov R17, R24					; save R24 temporaly in R17
		mov R18, R25					; save R25 temporaly in R18
		RCALL Dmsec						; start one milisecond timer
		mov R24, R17					; reset R24 with R17
		mov R25, R18					; reset R25 with R18
		sbiw R24, 0x01					; decrease R24/R25
 		brne DxT						; loop if R24/R25 != 0
		ret								; return to main programm

Dmsec:	ldi R25, HIGH(msec)				; save milisecond timer in R25 (4000)
		ldi R24, LOW(msec)				; save milisecond timer in R24 (4000)
DsLoop: sbiw R24, 0x01					; decrease R24/25
		brne DsLoop						; loop if R24/25 != 0
		ret								; return to main programm

