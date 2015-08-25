* icb file: uart.asm
*
* @author Peter Fyon
* 

#include "6811regs.asm"

	ORG	MAIN_START

* Note: Using RMB instead of RMW because apparently as11 doesn't support RMW
* We need to reserve 2 bytes so we can use them to store 16 bit addresses.

BUFSIZE	EQU	50	; Size of the ring buffer
NOTHING	EQU	0	; OPCode for do nothing

variable_ring_buffer:
	RMB	BUFSIZE	; Create a buffer of BUFSIZE length

variable_readptr:
	RMB	2	; where to read bytes from

variable_writeptr:
	RMB	2	; where to write bytes to

variable_bufferend:
	RMB	2	; end of buffer

variable_num_entries:
	RMB	1

	PSHA		; Push all the registers
	PSHB
	PSHX
	PSHY

subroutine_initialize_module:

#include "ldxibase.asm"

* X now has base pointer to interrupt vectors

*-------------------------------------
* Beginning of example found online

* get current vector. Set such that when we finish, we go there

	LDD	SCIINT,X ; SCI Interrupt
	STD	interrupt_code_exit+1

* install ourself as new vector
	LDD	#interrupt_code_start
	STD	SCIINT,X

* End of example found online
*-------------------------------------


* Initialize variables

* Store pointer to beginning of buffer in readptr/writeptr
	LDD	variable_ring_buffer
	STD	variable_readptr
	STD	variable_writeptr
	
* Store pointer to end of buffer in bufferend
	ADDD	BUFSIZE
	STD	variable_bufferend

* Set variable_num_entries to 0 to indicate no entries in the buffer
	LDAA	#0
	STAA	variable_num_entries

	PULY		; Return registers
	PULX
	PULB
	PULA

	RTS


* interrupt program begins here

interrupt_code_start:

	PSHX				; Push registers to maintain data
	PSHY
	PSHA
	PSHB

	LDAA	SCSR			; load status register into A
	ANDA	#$20			; Check to see if bit 5 (RDRF) is set
	BNE	interrupt_code_exit	; If bit isn't set, exit interrupt

	LDAA	SCDR			; Load SCI data register into A (will clear the interrupt bit(s))
	LDAB	variable_num_entries
	CMPB	BUFSIZE
	BEQ	interrupt_code_exit	; If num entries = buffer size, ignore new commands on SCI

	LDY	variable_writeptr	; Load writeptr into Y
	STAA	0, Y			; Store into location pointed to by writeptr.
	INCB				; Increment num_entries
	STAB	variable_num_entries	; Store B back into variable_num_entries

	CPY	variable_bufferend	; Is Y at the end of the buffer?
	BEQ	interrupt_code_wraparound_write
	INY				; Increment Y
	STY	variable_writeptr	; Store Y back into variable_writeptr
	BRA	interrupt_code_exit	; Just in case we move the position of interrupt_code_exit in the file

interrupt_code_exit:
	PULB				; Return registers
	PULA
	PULY
	PULX
	JMP	$0000

interrupt_code_wraparound_write:
	LDY	variable_ring_buffer	; Store location of start of buffer in writeptr
	STY	variable_writeptr
	BRA	interrupt_code_exit


subroutine_readbuffer:

	PSHX				; Although we don't actually use X here, good to make sure we don't mess it up
	PSHY				; D normally contains an parameter for the function, but we don't expect anything
	LDAA	variable_num_entries	; Load up the current number of entries
	CMPA	#0			; Check to see if anything is in the buffer
	BEQ	emptybuffer		; If nothing is in the buffer, branch
	LDY	variable_readptr	; Load read pointer into Y
	LDAB	0,Y			; Load value we want from the buffer into B
	DECA				; Decrement num_entries
	STAA	variable_num_entries	; Store the new number of entries back into variable_num_entries
	CPY	variable_bufferend	; Is Y at the end of the buffer?
	BEQ	wraparound_read		; If so, deal with it
	INY				; If it isn't at the end, increment Y
	STY	variable_readptr	; Store the new value back into variable_readptr
	BRA	finished	

emptybuffer:
	CLRA				; (Just in case)
	LDD	NOTHING			; If buffer's empty, return DONOTHING
	PULY				; Set registers back to what they were before
	PULX
	RTS

wraparound_read:
	LDY	variable_ring_buffer	; Store location of start of buffer in readptr
	STY	variable_readptr
	BRA	finished

finished:
	CLRA				; Pad top byte of D with zeroes (second byte has our value)
	PULY				; Return registers to original state
	PULX
	RTS				; Finished, return. Value is returned in register D