/****************************************************************
 ---------------------------------------------------------------
     Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
     Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
     The contents of this file are subject to the current
     version of the Sun Community Source License, picoJava-II
     Core ("the License").  You may not use this file except
     in compliance with the License.  You may obtain a copy
     of the License by searching for "Sun Community Source
     License" on the World Wide Web at http://www.sun.com.
     See the License for the rights, obligations, and
     limitations governing use of the contents of this file.

     Sun, Sun Microsystems, the Sun logo, and all Sun-based
     trademarks and logos, Java, picoJava, and all Java-based
     trademarks and logos are trademarks or registered trademarks 
     of Sun Microsystems, Inc. in the United States and other
     countries.
 ----------------------------------------------------------------
******************************************************************/




 `include "returncode.h"

task genreport;
input [31:0] code;

begin
   // NEVER change the next line, run script needs it
   $display("DSV return code %x", code);
   case (code)
     `SUCCESS:
	begin
	 $display("rtl : SUCCESS");
	end
     `INITIAL_VALUE:
	begin
	 $display("rtl : The end location is not touched");
	end
     `FAIL_AT_END:
	begin
	 $display("rtl : FAILED at the end of test");
	end
     `LOOP_FOREVER:
	begin
	 $display("rtl : LOOP FOREVER");
	end
     `DETECTED_LAST_INST:
	begin
	 $display("rtl : DETECTED LAST INSTRUCTION");
	end
      `RANDOM_TEST_RETURN:
	begin
	 $display("rtl : RETURN FROM RANDOM TEST");
	end
      `BAD_POR_VALUE:
	begin
	 $display("rtl : BAD POWER-ON-RESET VALUE");
	end
      default:
	begin
	 $display("rtl : Undefined return code %x", code);
	end
   endcase
end

endtask
