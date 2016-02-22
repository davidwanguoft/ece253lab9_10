				.include "address_map_arm.s"
/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed.  If KEY3 it stops/starts the timer.
****************************************************************************************/
					.global	KEY_ISR
KEY_ISR: 		LDR		R0, =KEY_BASE			// base address of KEYs parallel port
				LDR		R1, [R0, #0xC]			// read edge capture register
				STR		R1, [R0, #0xC]			// clear the interrupt

CHK_KEY3:		MOVS 	R3, #0b1000				
				ANDS 	R3, R1					// Check for KEY3
				BEQ 	END_KEY_ISR 			// if equal then, key3 has not been pressed

START_STOP:		LDR		R0, =MPCORE_PRIV_TIMER		// timer base address
				LDR		R1, [R0, #0x8]			// read timer control register
				MOV 	R3, #1					// move 1 into R3
				EOR 	R1, R3 					// EOR the enable bit with #1
				STR 	R1, [R0, #0x8]			// store enable bit to control register

END_KEY_ISR:	MOV	PC, LR
					.end
	
