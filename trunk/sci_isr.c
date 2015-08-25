/* C program to read serial port with interrupt service routine */
/* First version:  Written by Anton Wirsch   20 Nov 1997 */

/*

   Second Version: Written by Tim Gold   27 May 1998
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
              1. Change the BUFFER_SIZE constant below to the
          desired number of bytes.
       2. Edit the line(s) in the serial_isr.asm which contain
          the word "EDIT" in the comment so that the value
   matches that of BUFFER_SIZE.
       3. Recreate the serial_isr.icb file by typing the following:
          > as11_ic serial_isr.asm 

 */

//Peter Fyon, Feb 5, 2010: Changed filename from serial_isr.c to sci_isr.c as some
// older programs have issues with filenames greater than 8 characterss


#define BUFFER_SIZE 4  /* change buffer size here  -- see above */

/* various constants used by the program... */
#define BAUD 0x102b   /* baud rate set to 9600 */
#define SCCR2 0x102d
#define SCCR1 0x102c
#define SCSR 0x102e
#define SCDR 0x102f
#use "SCI_ISR.ICB"

int buffer[BUFFER_SIZE]; /* this is the actual buffer */
int return_char;

void initSerial()
{
    /* Call this routine to activate the serial interrupt handler. */
    int i,temp;
    
    /* clear out buffer */
    for(i=0; i<BUFFER_SIZE; i++)
      {
        buffer[i] = 0;
    }
    
    /* clear vairous flags */
    DATA_FLAG = 0;
    INCOMING = 0;
    CURRENT = 0;
    return_char = 0;
    
    /* pass address of buffer to interrupt routine */
    buffer_ptr = (int) buffer; 
    BASE_ADDR = (int) buffer;
    
    /* activate interrupt routine */
    temp = peek(SCCR2);
    temp |= 0x24;
    poke(SCCR2, temp);
    poke(0x3c, 1);
}

void closeSerial() 
{
    int temp;
    
    /* deactivate the interrupt routine */
    temp = peek(SCCR2);
    temp &= 0xdf;
    poke(SCCR2, temp);
    //Peter Fyon: Not sure why this line is here, READ_SERIAL doesn't even exist in the asm routine
    //READ_SERIAL = 0x0000;
    poke(0x3c, 0);
    
}

void serialPutChar(int c)
{
    /* call this function to write a character to the serial port */
    
    while (!(peek(0x102e) & 0x80));
    poke(0x102f, c);               
    
}


int dataAvailable()
{
    /* This function can be used to check to see if any data is available */
    return DATA_FLAG;
}


int serialGetChar()
{
    /* Create blocking getchar for serial port... */
    
    /* loop until data is available */
    while(!DATA_FLAG){};
    
    /* get the character to return */
    return_char = buffer[CURRENT];
    
    /* check for wrap around... */
    CURRENT++;
    if(CURRENT == BUFFER_SIZE)
      CURRENT = 0;
    if(CURRENT == INCOMING)
      DATA_FLAG = 0;
    return return_char;
    
}
