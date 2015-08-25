/* This sets up the serial interrupt service routine */
/* First Version:	Written by Anton L. Wirsch  20 Nov 1997 */
/* Second Version: Written by Tim Gold   27 May 1998
                              BYU Robotics Lab
		              goldt@et.byu.edu        

     Really, the only thing left from the original code are a few
     lines in the .asm file.  Everything else I pretty much had to
     rewrite from scratch to get it to work the way I wanted to.
     But the orignal code by Anton was a very helpful starting point.

  Needed files:   serial_isr.c
                  serial_isr.icb
		  serial_isr.asm (needed to change the buffer size)

  The buffer size here is 32 bytes (probably much larger than it needs
  to be.)  To change the buffer size, do the following:
              1. Change the BUFFER_SIZE constant in serial_isr.c to the
	         desired number of bytes.
	      2. Edit the line in this fils which contains
	         the word "EDIT" in the comment so that the value
		 matches that of BUFFER_SIZE.
	      3. Recreate the serial_isr.icb file by typing the following:
	         > as11_ic serial_isr.asm 
*/


/* change this line to match your library path... */
#include "6811regs.asm"

        ORG MAIN_START
variable_CURRENT:
	FDB    00        * ptr to next data to be read by user
	
variable_INCOMING:
        FDB    00        * number of bytes received (circular count)

variable_BASE_ADDR:
	FDB    00        * base address of buffer (to be set by init routine)
	
variable_DATA_FLAG:
        FDB    00        * flag set when data is available

variable_buffer_ptr:     
        FDB    00        * pointer to CURRENT buffer

subroutine_initialize_module:
/* change this line to match your library path... */
#include "ldxibase.asm"

        ldd     SCIINT,X
        std     interrupt_code_exit+1
        ldd     #interrupt_code_start
        std     SCIINT,X
        
	rts

interrupt_code_start:
        ldad    variable_INCOMING       * store INCOMING into AB
        cmpb    #00                     * compare B with 0
        bhi     skip                    * goto "skip" if (B > 0)
        ldx     variable_BASE_ADDR      * STORE ADDRESS OF ARRY IN X
        inx                             * SKIP THE FIRST (?)
        inx                             * TWO BYTES      (?)
        inx                             * OFFSET TO THE HIGHER BYTE (?)
        stx     variable_buffer_ptr     * SAVE PTR VALUE 
        bra     cont

skip:
        ldx     variable_buffer_ptr     * load buffer pointer into x
cont:
        ldad    variable_INCOMING       * load INCOMING into AB
        incb                            * increment INCOMING
	cmpb    #4                     * compare B and 4   --EDIT TO CHANGE BUFFER SIZE--
	beq     reset_count             * if a=32, goto reset_count
	bra     cont1
reset_count:
	ldad    #00                     * set count to zero
cont1:	
        stad    variable_INCOMING       * store AB into INCOMING
        
        ldab    SCSR                    * load SCSR (SCI status register) into B (why?)
        ldab    SCDR                    * load SCSR (SCI data register) into B

        stab    ,X                      * store data in array
        inx                             * increment by two bytes
        inx                             
        stx     variable_buffer_ptr     * save the pointer value
	ldad    #01                     * load 1 into AB
	stad    variable_DATA_FLAG      * store AB into DATA_FLAG (indicating data is available)
interrupt_code_exit:
        jmp     $0000
