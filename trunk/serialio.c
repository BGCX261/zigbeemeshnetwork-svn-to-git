/*****************************************************************************/
/*                                                                           */
/*  serialio.c      ;low-level serial I/O for the Handy Board                */
/*                  ;also works with the 6.270 board                         */
/*                                                                           */
/*  by                                                                       */
/*                                                                           */
/*  Dr. Fred G. Martin                                                       */
/*  Learning and Epistemology Group                                          */
/*  Media Laboratory                                                         */
/*  Massachusetts Institute of Technology                                    */
/*  fredm@media.mit.edu                                                      */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  VERSION HISTORY:                                                         */
/*                                                                           */
/*  Whenever the program is updated, record it here.  Add new version info   */
/*  to the top of this list, so the newest version is always first.          */
/*                                                                           */
/*  1.0     16 May 1997         ;initial code by Fred G. Martin              */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  PUBLIC FUNCTIONS:                                                        */
/*                                                                           */
/*  These functions may be used freely by user programs.                     */
/*                                                                           */
/*  void disable_pcode_serial()     ;disable board handshaking with IC       */
/*                                  ;on the host computer, allowing user     */
/*                                  ;programs to receive serial data         */
/*                                                                           */
/*  void enable_pcode_serial()      ;enable board handshaking with IC on     */
/*                                  ;the host computer                       */
/*                                                                           */
/*  void serial_putchar(int c)      ;send a serial character.  Note:  the    */
/*                                  ;program hangs until the character is    */
/*                                  ;sent!  There is no timeout!             */
/*                                                                           */
/*  int serial_getchar()            ;read a serial character.  Note:  the    */
/*                                  ;program hangs until a character is      */
/*                                  ;received!  There is no timeout!         */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  PUBLIC GLOBAL VARIABLES:                                                 */
/*                                                                           */
/*  These global variables may be accessed freely by user programs.  Any     */
/*  restrictions on their use (e.g., flags which are read-only) should be    */
/*  noted here.  It is suggested that global variables be named in all       */
/*  capital letters, to avoid confusion with local varibles which are        */
/*  defined within functions.                                                */
/*                                                                           */
/*      None.                                                                */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  PRIVATE FUNCTIONS:                                                       */
/*                                                                           */
/*  These are internal functions which have no public entry points, and      */
/*  which user programs should not access directly.  It is suggested that    */
/*  private functions be named with a leading underscore (_), to avoid       */
/*  confusion with user-defined functions which might have the same name.    */
/*                                                                           */
/*      None.                                                                */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  PRIVATE GLOBAL VARIABLES:                                                */
/*                                                                           */
/*  These are internal global variables which user programs should not       */
/*  access directly.  It is suggested that private global variables be       */
/*  named in all capital letters with a leading underscore (_), to avoid     */
/*  confusion with user-defined global variables which might have the same   */
/*  name.                                                                    */
/*                                                                           */
/*      None.                                                                */
/*                                                                           */
/*****************************************************************************/
/*                                                                           */
/*  EXTERNAL LIBRARY FILE DEPENDENCIES:                                      */
/*                                                                           */
/*  Any external functions or variables which are used but not defined in    */
/*  this file should be noted here.  List the external library filename,     */
/*  the library function, and the local calling function.                    */
/*                                                                           */
/*      None.                                                                */
/*                                                                           */
/*****************************************************************************/


/*****************************************************************************/
/*                                                                           */
/*                        global variable declarations                       */
/*                                                                           */
/*****************************************************************************/

/* declare global variables here */

/*****************************************************************************/
/*                                                                           */
/*                            function declarations                          */
/*                                                                           */
/*****************************************************************************/

void disable_pcode_serial()     /* disable board handshaking with IC   */
                                /* on the host computer, allowing user */
                                /* programs to receive serial data     */
{
    poke(0x3c, 1);
}

/*****************************************************************************/

void enable_pcode_serial()      /* enable board handshaking with IC on */
                                /* the host computer                   */
{
    poke(0x3c, 0);
}

/*****************************************************************************/

void serial_putchar(int c)      /* send a serial character.  Note:  the */
                                /* program hangs until the character is */
                                /* sent!  There is no timeout!          */
{
    while (!(peek(0x102e) & 0x80));     /* wait until it's okay to send */
    poke(0x102f, c);                    /* send the character */
}

/*****************************************************************************/

int serial_getchar()            /* read a serial character.  Note:  the */
                                /* program hangs until a character is   */
                                /* received!  There is no timeout!      */
{
    while (!(peek(0x102e) & 0x20));     /* wait until a character arrives */
    return (peek(0x102f));              /* return it as an int */
}

/*****************************************************************************/


