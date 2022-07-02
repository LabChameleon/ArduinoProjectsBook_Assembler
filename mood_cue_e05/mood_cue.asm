/*
 * Mood_Cue__E05_.asm
 *
 *  Created: 17.12.2015 19:22:58
 *   Author: Julian
 */ 

 .include "./m328Pdef.inc"

		ldi R16, high(RAMEND)			; Initiate Stack
		out SPH,R16 
		ldi R16, low(RAMEND)
		out SPL,R16

		sbi DDRB, 1						; set Port to output

		ldi R16, 0b1000_0010			; activate PORTB 1 & set fast PWM mode using ICR1 as top
		sts TCCR1A, R16					; load register 16 to TCCR1A

		ldi R16, 0b0001_1001			; set fast PWM mode using ICR1 as top
		sts TCCR1B, R16					; load register 16 to TCCR1B

		ldi R16, 0xFF					; load FF in register 16
		sts ICR1H, R16					; set PORT ICR1 to 65536 (TOP)
		ldi R16, 0xFF					; load FF in register 16
		sts ICR1L, R16					; set PORT ICR1 to 65536 (TOP)

		ldi R16, 0b0100_0000			; Reference Voltage 5V & Left adjust Result & Use PC0/ADC0
		sts ADMUX, R16					; load new analog input channel

MLoop:	
		
		rcall RADC						; start ADC with new channel
		rcall mapTo29696

		ldi R18, 0x22					; load high-byte of 8704 (0.544ms) to R18
		add R17, R18					; add 8704 (0.544ms) to R17 

		sts OCR1AH, R17					; set update Value of PWM
		sts OCR1AL, R16					; set update Value of PWM

		jmp MLoop						; Main Loop


mul16B:									; Reduce 16bit*16bit multiplication to:
										; (65535 * 1H * 2H) + (256 * 1H * 2L) + (256 * 1L * 2H) + (1L * 2L)
										; (65535 * R3 * R5) + (256 * R3 * R4) + (256 * R2 * R5) + (R2* R4)
										; Move the solution to the register 16-19

		ldi R20, 0x00					; Zero for multiplying Carrys

		mul R2, R4						; (1L * 2L)
		mov R16, R0						; Save low-byte solution in R16
		mov R17, R1						; Save high-byte solution in R17

		mul R3, R5						; (65535 * 1H * 2H)
		mov R18, R0						; Save low-byte solution in R18
		mov R19, R1						; Save high-byte soltuion in R19

		mul R2, R5						; (256 * 1L * 2H)
		add R17, R0						; add low-byte solution to R17
		adc R18, R1						; add high-byte solution with Carry to R18
		adc R19, R20					; add Carry to R19

		mul R3, R4						; (256 * R3 * R4)
		add R17, R0						; add low-byte solution to R17
		adc R18, R1						; add high-byte solution with Carry to R18
		adc R19, R20					; add Carry to R19

		ret

mapTo29696:								; divide number with 1024 and multiply with 29696 (1.856ms)
										; to get the PWM signal between 0-29696 (0-1.856ms)
		ldi R18, 0x1D					; load 29 to R18
		ldi R19, 0x00					; load 0 to R19
		mov R2, R18						; move 29 to R2 for the function (mul16B)
		mov R3, R19						; move 0 to R3 for the function (mul16B)

		mov R4, R16						; move R16 (function input) to R4 for the function (mul16B)
		mov R5, R17						; move R17 (function input) to R5 for the function (mul16B)

		rcall mul16B					; 29 * (user input)
		ret

RADC:	ldi R16, 0b1100_0111			; Start ADC & Start conversion & Set Frequenz to 125 Mhz
		sts ADCSRA, R16					; load R16 in ADCSRA

RLoop:	lds R16, ADCSRA					; move ADCSRA in R16 temporaly
		sbrs R16, 4						; Check if ADIF Flag is set and therefore conversion is complete
		rjmp RLoop						; Else wait until ADC is ready
				
		lds R16, ADCL					; move Analog-In result to R17
		lds R17, ADCH					; move Analog-In result to R16
		ret								; return to main programm
		
		