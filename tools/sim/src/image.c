/****************************************************************
 ***
 ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
 ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
 ***    The contents of this file are subject to the current
 ***    version of the Sun Community Source License, picoJava-II
 ***    Core ("the License").  You may not use this file except
 ***    in compliance with the License.  You may obtain a copy
 ***    of the License by searching for "Sun Community Source
 ***    License" on the World Wide Web at http://www.sun.com.
 ***    See the License for the rights, obligations, and
 ***    limitations governing use of the contents of this file.
 ***
 ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 ***
 *****************************************************************/




#pragma ident "@(#)image.c 1.4 Last modified 02/01/99 13:13:04 SMI"

#include <stdio.h>
#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "sim.h"
#include "cm.h"
#include "global_regs.h"


/* argv[1]=type, argv[2]=start_addr, argv[3]=num_bytes, argv[4]=filename
*/

int
createImageCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int start_addr;
   unsigned int len;
   unsigned int temp;
   unsigned char c, *cptr;
   FILE *fp;
   unsigned int checksum, srecord_length;
   char str[8], *type;
   int i;

   if (argc <= 4) {
    sprintf(interp->result, "Usage: createImage <B|S> <start_addr> <num_bytes> <filename>");
    return TCL_ERROR;
   }
   else {
    type = argv[1];
    start_addr = strtoul (argv[2], (char **) NULL, 0);
    len = strtoul (argv[3], (char **) NULL, 0);
    fp = fopen(argv[4], "a");
    if (fp == NULL) {
       sprintf(interp->result, "Cannot create image file");
       return TCL_ERROR;
    }
   }

   /* printf("type = %s, start_addr = 0x%x, num_bytes = 0x%x, filename = %s\n", argv[1], start_addr, len, argv[4]); */

   if (strcmp(type, "B")==0) {
      temp = start_addr;
      while(temp < (start_addr+len)) {
         if (temp >= CM_SIZE) {
           sprintf(interp->result, "Error: Address out of range of PICOJAVA_MEMORY_SIZE");
           fclose(fp);
           return TCL_ERROR;
         }
         cptr = (unsigned char*)getAbsAddr(temp);
         fprintf(fp, "%c", *cptr);
         temp++;   
      }
   }
   else if (strcmp(type, "S")==0) {
      /* Motorola S-record Format Type 3 */

      checksum = 0x00000000;

      /* Write 'S' */
      fprintf(fp, "%c", 'S');

      /* Write type */
      fprintf(fp, "%c", '3');

      /* Write 1/2 number of chars for address+data+checksum */
      srecord_length = (len*2+8+2)/2;

      if (srecord_length > 255) {
         sprintf(interp->result, "Error: S-Record length > 255");
         fclose(fp);
         return TCL_ERROR;
      }
      sprintf(str,"%02X", (unsigned char) srecord_length);
      checksum += str[0]; checksum += str[0];
      fprintf(fp, "%s", str);

      /* Write address */
      sprintf(str,"%08X", start_addr);
      checksum += str[0]; checksum += str[1]; 
      checksum += str[2]; checksum += str[3];   
      checksum += str[4]; checksum += str[5];   
      checksum += str[6]; checksum += str[7];   

      fprintf(fp, "%s", str);

      temp = start_addr;
      while(temp < (start_addr+len)) {
         if (temp >= CM_SIZE) {
           sprintf(interp->result, "Error: Address out of range of PICOJAVA_MEMORY_SIZE");
           fclose(fp);
           return TCL_ERROR;
         }
         cptr = (unsigned char*)getAbsAddr(temp);
         sprintf(str, "%02X", *cptr);
         checksum += str[0];
         fprintf(fp, "%s", str);
         temp++;   
      }
      checksum = ~checksum;
      fprintf(fp, "%02X", (unsigned char) (checksum&0xFF));


      /* Motorola S-record Format Type 7 */

      checksum = 0x00000000;
      start_addr = 0x00000000;

      /* Write 'S' */
      fprintf(fp, "%c", 'S');

      /* Write type */
      fprintf(fp, "%c", '7');

      /* Write 1/2 number of chars for address+data+checksum */
      srecord_length = (8+2)/2;

      sprintf(str,"%02X", (unsigned char) srecord_length);
      checksum += str[0]; checksum += str[0];
      fprintf(fp, "%s", str);

      /* Write address */
      sprintf(str,"%08X", start_addr);
      checksum += str[0]; checksum += str[1]; 
      checksum += str[2]; checksum += str[3];   
      checksum += str[4]; checksum += str[5];   
      checksum += str[6]; checksum += str[7];   
      fprintf(fp, "%s", str);

      /* No data for terminating type 7 record */

      checksum = ~checksum;
      fprintf(fp, "%02X", (unsigned char) (checksum&0xFF));
   }
   else {
      sprintf(interp->result, "Type must be B or S (B = binary, S = srecord)");
      return TCL_ERROR;
   }

   fclose(fp);
   return TCL_OK;
}




