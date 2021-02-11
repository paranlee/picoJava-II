/* Sample input/output library for extending the capabilities of the 
   picoJava-II simulation environment using the syscall feature */

#include "stdio.h"
#include "stdlib.h"
#include "pico_io.h"

/* see the code for these functions in tools/dsv/ldr/src/cm.c 
- the input/output data is required to be aligned in weird ways... */

extern int cmMemoryRead(unsigned int addr, int *data, int size);
extern int cmMemoryWrite(unsigned int addr, int data, int size);

static int verbose = 0;

static int memoryRead (unsigned int addr)
{
    int data;
    
    cmMemoryRead (addr, &data, 2);
    return data;
}

static char memoryReadByte (unsigned int addr)

{
    int data;
    cmMemoryRead (addr & 0x3FFFFFFC, &data, 2);
    data >>= ((3 - (addr & 3)) * 8);
    return data;
}

static void memoryWrite (unsigned int addr, int data)
{
    cmMemoryWrite (addr, data, 2);
}

static void memoryWriteByte (unsigned int addr, char data)
{
    /* byte shift input data to the correct point in a word */
    int wdata = ((unsigned int) data) << ((3 - (addr & 3)) * 8);
    cmMemoryWrite (addr, wdata, 0);
}

int picojava_syscall_init ()
{
   const char* s;

   /* Do some system checks here before returning Pass=1 or Fail=0 */
   if ((s = getenv ("PICOJAVA_TRUSS")) != NULL)
       {
            long l = strtol (s, (char **) NULL, 0);
            if (l > 0) verbose = 1;
            else verbose = 0;
       }
   return 1;
}

void picojava_syscall ()
{
    char type;
    char c;
    float *f;
    int i, j;
    double *d;
    long l[2];
    long n;

    int operation, file_operation;

    operation = (int) (memoryRead((PICO_IO_CALL_ADDR_H << 16)|
                                    PICO_IO_CALL_ADDR_L) >> 24);
    
    switch (operation) {
    case CONSOLE_OPERATION:
      {   if (verbose)
             fprintf(stderr, "PICOJAVA_SYSCALL_LIB: Console Operation\n");
          type = (char) memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_TYPE_ADDR);
          switch (type) {
	  case 'I': case 'B': case 'S': 
             i = (int) memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1);
             fprintf(stderr, "0x%x (%d)", i, i);
             break;
          case 'C':
             c = (char) 
              (memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1) & 0xff);
             fprintf(stderr, "%c", c);
             break;
          case 'Z':
             if (memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1))
                fprintf(stderr, "true");
             else
                fprintf(stderr, "false");
             break;
          case 'F':
             l[0] = memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1);
             f = (float *) l;
             fprintf(stderr, "%f", *f);
             break;
          case 'J':
             l[0] = (long) 
              memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1);
             l[1] = (long) 
              memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_2);
             fprintf(stderr, "0x%8x %8x", l[1], l[0]);
             break;
          case 'D':
             l[0] = (long) 
              memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_1);
             l[1] = (long) 
              memoryRead((PICO_IO_ADDR_H << 16)|CONSOLE_DATA_ADDR_2);
             d = (double *) l;
             fprintf(stderr, "%f", *d);
             break;
          default: 
             break; 

          }
         if (verbose)
             fprintf(stderr, "PICOJAVA_SYSCALL_LIB: Console Operation Done\n");
         return;
      }

    case FILE_OPERATION:
      {
          if (verbose)
             fprintf(stderr, "PICOJAVA_SYSCALL_LIB: File Operation\n");

          file_operation = memoryRead((PICO_IO_ADDR_H << 16)|
                                       FILE_OPERATION_ADDR);

          switch (file_operation) {
       /* case OPEN_READ_FILE:
          case OPEN_WRITE_FILE:
          case OPEN_APPEND_FILE:
          case OPEN_UPDATE_FILE:
          case READ_FILE:
          case WRITE_FILE:
          case CLOSE_FILE:
          case AVAILABLE_FILE:
          case LENGTH_FILE:
          case EXISTS_FILENAME:
          case DELETE_FILENAME:
	  */
	  default:
             fprintf(stderr, "PICOJAVA_SYSCALL_LIB: File I/O Not Yet Implemented\n");
	  }
      }
    default: {
         fprintf (stderr, "PICOJAVA_SYSCALL_LIB: Unknown I/O operation 0x%x requested!\n", operation);
      }
    }
}
