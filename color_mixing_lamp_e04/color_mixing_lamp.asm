/*
 * Color_Mixing_Lamp.asm
 *
 *  Created: 18.07.2015 21:37:53
 *   Author: Julian
 */ 

  .include "./m328Pdef.inc"
  .equ msec = 400
  .equ time = 10

		ldi R16, LOW(RAMEND)			; Initiate Stack
		out SPL, R16
		ldi R16, HIGH(RAMEND)			
		out SPH, R16  

		sbi DDRB, 1						; set PORTB 1 to output
		sbi DDRB, 2						; set PORTB 2 to output
		sbi DDRB, 3						; set PORTB 3 to output

		; Prepare counter 1

		ldi R16, 0x04					; load 4 in register 16
		sts ICR1H, R16					; set PORT ICR1 to 65536 (TOP)
		ldi R16, 0x00					; load 00 in register 16
		sts ICR1L, R16					; load 1024 in ICR1L (because analogIn can only read 10 bit values)

		ldi R16, 0b1010_0010			; activate PORTB 1/ PORTB 2 & set fast PWM mode using ICR1 as top
		sts TCCR1A, R16					; load register 16 to TCCR1A

		ldi R16, 0b0001_1001			; set fast PWM mode using ICR1 as top
		sts TCCR1B, R16					; load register 16 to TCCR1B
		
		; Prepare counter 2

		ldi R16, 0b1000_0011			; activate PORTB 3 & set fast PWM mode using 0xFF as top
		sts TCCR2A, R16					; load register 16 to TCCR2A

		ldi R16, 0b0000_0001			; set fast PWM mode using 0xFF as top
		sts TCCR2B, R16					; load register 16 to TCCR2B

MLoop:	ldi R16, 0b0100_0000			; Reference Voltage 5V & Left adjust Result & Use PC0/ADC0
		rcall RADC						; start ADC with new channel

		sts OCR1AH, R16					; set brightness of conected LED
		sts OCR1AL, R17					; set brightness of conected LED
		
		ldi R16, 0b0100_0001			; Reference Voltage 5V & Left adjust Result & Use PC1/ADC1
		rcall RADC						; start ADC with new channel
			
		sts OCR1BH, R16					; set brightness of conected LED	
		sts OCR1BL, R17					; set brightness of conected LED

		ldi R16, 0b0110_0010			; Reference Voltage 5V & Left adjust Result & Use PC2/ADC2
		rcall RADC						; start ADC with new channel

		sts OCR2A, R16					; set brightness of conected LED

		rjmp MLoop						; main loop

RADC:	sts ADMUX, R16					; load new analog input channel
		
		ldi R25, HIGH(time)				; set Register to 10 
		ldi R24, LOW(time)				; set Register to 10
		rcall DxT						; 10 microsecond delay to change analog input channel

		ldi R16, 0b1100_0111			; Start ADC & Start conversion & Set Frequenz to 125 Mhz
		sts ADCSRA, R16					; load R16 in ADCSRA

RLoop:	lds R16, ADCSRA					; move ADCSRA in R16 temporaly
		sbrs R16, 4						; Check if ADIF Flag is set and therefore conversion is complete
		rjmp RLoop						; Else wait until ADC is ready-
				
		lds R17, ADCL					; move Analog-In result to R17
		lds R16, ADCH					; move Analog-In result to R16
		ret								; return to main programm

DxT:	mov R17, R24					; save R24 temporaly in R17
		mov R18, R25					; save R25 temporaly in R18
		rcall Dmsec						; start one milisecond timer
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