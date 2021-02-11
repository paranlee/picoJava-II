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
module rf (do_a, do_b, do_c, di_d, di_e, add_a, add_b, add_c,
           add_d, add_e, we_d, we_e);
 
 input [31:0] di_d;
 input [31:0] di_e;
 input [5:0] add_a;
 input [5:0] add_b;
 input [5:0] add_c;
 input [5:0] add_d;
 input [5:0] add_e;
 input we_d;
 input we_e;
 
 output [31:0] do_a;
 output [31:0] do_b;
 output [31:0] do_c;
 
 reg [31:0] ram [63:0];
 
 
/*
 always @(posedge we_d) begin
     ram[add_d[5:0]]= di_d[31:0];
 end
 always @(posedge we_e) begin
     ram[add_e[5:0]]= di_e[31:0];
 end
 
 // Read Cycle                                                        
assign #1 do_a[31:0]= (^(add_a[5:0])===1'bx) ? 32'bx: ram[add_a[5:0]];
assign #1 do_b[31:0]= (^(add_b[5:0])===1'bx) ? 32'bx: ram[add_b[5:0]];
assign #1 do_c[31:0]= (^(add_c[5:0])===1'bx) ? 32'bx: ram[add_c[5:0]];
*/                                                                    
                                                                      
endmodule
