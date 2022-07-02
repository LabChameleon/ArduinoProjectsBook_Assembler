/*
 * Love_o_Meter.asm
 *
 *  Created: 17.07.2015 12:46:41
 *   Author: Julian
 */
	
		.equ oneLED = 38				; ~ 24/25 degrees
		.equ twoLED = 40				; ~ 27/28 degrees
		.equ threeLED = 42				; ~ 30 degrees
 
		ldi r16, high(RAMEND)			; Initiate Stack
		out SPH,r16 
		ldi r16, low(RAMEND)
		out SPL,r16 

		ldi R16, 0b0110_0000			; Reference Voltage 5V & Left adjust Result & Use PC0/ADC0
		sts ADMUX, R16					; Load R16 in ADMUX

		sbi DDRD, 2						; set PORT2 to output
		sbi DDRD, 3						; set PORT3 to output
		sbi DDRD, 4						; set PORT4 to output

MLoop:	RCALL RADC						; get Analog-In
		cpi R16, threeLED				; compare Analog-In (R16) to 30 degrees
		brge TrLED						; if Analog-In is greater or equal jump to TrLED
		cpi R16, twoLED					; compare Analog-In (R16) to 27/28 degrees
		brge TwLED						; if Analog-In is greater or equal jump to TwLED
		cpi R16, oneLED					; compare Analog-In (R16) to 24/25 degrees
		brge OLED						; if Analog-In is greater or equal jump to OLED
		rjmp ZLED						; jump to ZLED if Analog-In is smaller then 24/25 degrees

ZLED:	cbi PORTD, 2					; deactivate PORT 2-4
		cbi PORTD, 3
		cbi PORTD, 4
		rjmp MLoop						; start Main Loop again

OLED:	sbi PORTD, 2					; activate PORT 2
		cbi PORTD, 3					; deactivate PORT 3/4
		cbi PORTD, 4
		rjmp MLoop						; start Main Loop again

TwLED:	sbi PORTD, 2					; activate PORT 2/3
		sbi PORTD, 3
		cbi PORTD, 4					; deactivate PORT 4
		rjmp MLoop						; start Main Loop again

TrLED:	sbi PORTD, 2					; activate PORT 2-4
		sbi PORTD, 3
		sbi PORTD, 4
		rjmp MLoop						; start Main Loop again


RADC:	ldi R16, 0b1100_0111			; Start ADC & Start conversion & Set Frequenz to 125 Mhz
		sts ADCSRA, R16					; load R16 in ADCSRA

RLoop	lds R16, ADCSRA					; move ADCSRA in R16 temporaly
		sbrs R16, 4						; Check if ADIF Flag is set and therefore conversion is complete
		rjmp RLoop						; Else wait until ADC is ready
		
		lds R16, ADCH					; move Analog-In result to R16
		ret								; return to main programm