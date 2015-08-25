#include "6811regs.asm"

	ORG	MAIN_START

subroutine_initialize_module:

variable_tempvar:
	RMB	1

#include "ldxibase.asm"
* X now has base pointer to interrupt vectors ($FF00 or $BF00)

* get current vector poke such that when we finish, we go there
	ldd	TOC4INT,X	;SystemInt on TOC4
	std	interrupt_code_exit+1

* install ourself as new vector
	LDD	#interrupt_code_start
	std	TOC4INT,X

	LDAA	#0
	STAA	variable_tempvar

	rts

interrupt_code_start:

	PSHA
	LDAA	variable_tempvar
	INCA
	CMPA	#$FF
	STAA	variable_tempvar
	BNE	interrupt_code_exit
	LDAA	#0
	STAA	variable_tempvar
	BRA	interrupt_code_exit
	
interrupt_code_exit:
	PULA
	JMP	$0000

subroutine_retval:
	LDAA	#0
	LDAB	variable_tempvar
	RTS