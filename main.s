// ACredits: A. Pan

	.include "address_map_arm.s"
/* 
 * This program demonstrates the use of interrupts using the KEY and timer ports. It
 * 	1. displays a sweeping red light on LEDR, which moves left and right
 * 	2. stops/starts the sweeping motion if KEY3 is pressed
 * Both the timer and KEYs are handled via interrupts
*/
			.text
			.global	_start
_start:					// initialize the IRQ stack pointer ...
			MOV 		R0, #0b10010 			
			MSR 		CPSR, R0				// change into IRQ mode
			LDR 		SP, =0xFFFFFFFC 			// set stack pointer to on chip memory
						// initialize the SVC stack pointer ...
			MOV 		R0, #0b10011  
			MSR 		CPSR, R0				// change into SVC mode
			LDR 		SP, =0x3FFFFFFC			// set stack pointer

			BL			CONFIG_GIC				// configure the ARM generic interrupt controller
			BL			CONFIG_PRIV_TIMER		// configure the MPCore private timer
			BL			CONFIG_KEYS				// configure the pushbutton KEYs
			
						//... enable ARM processor interrupts ...
			MSR 		CPSR, #0b01010011			// change 7th bit to 0 in SVC mode 

			LDR			R6, =0xFF200000 		// red LED base address
MAIN:
			LDR			R4, LEDR_PATTERN		// LEDR pattern; modified by timer ISR
			STR 		R4, [R6] 				// write to red LEDs
			B 			MAIN

/* Configure the MPCore private timer to create interrupts every 1/10 second */
CONFIG_PRIV_TIMER:
			LDR			R8, =0xFFFEC600 		// Timer base address
			LDR 		R1, =20000000		// 20000000 is 0.1s
			STR 		R1, [R8]			// put load into timer address
			MOV			R1, #0b111			// number to set to enable, auto reload, interrupts
			STR 		R1, [R8, #8]		// write to control address
			MOV 		PC, LR 					// return

/* Configure the KEYS to generate an interrupt */
CONFIG_KEYS:
			LDR 		R0, =0xFF200050 		// KEYs base address
/*			MOV 		R1, #0xF 				// set interrupt mask bits */
			MOV 		R1, #0b1000 			// set interrupt mask bits (KEY 3)
			STR 		R1, [R0, #0x8] 			// store in interrupt mask register
			MOV 		PC, LR 					// return

			.global		LEDR_DIRECTION
LEDR_DIRECTION:
			.word 		0							// 0 means left, 1 means right

			.global		LEDR_PATTERN
LEDR_PATTERN:
			.word 		0x1
