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




 `include "defines.h"

task init_icache;
integer i;
begin
`ifdef NO_ICACHE
`else
       for (i =  0; i <= `it_mxblks ; i = i+1) begin
        `PICOJAVAII.`DESIGN.itag_shell.itag_top.itag.itram.t_ram[i]  = 19'b0 ;
        end
        for (i =  0; i <= `ic_size  ; i = i+1) begin
        `PICOJAVAII.`DESIGN.icram_shell.icram_top.icram.iram.ic_ram[i] = 8'b0 ;
        end
          $display("ICache initialized to 0");
`endif
end
endtask

task init_dcache ;
integer i;
begin
`ifdef NO_DCACHE
`else
         for(i =  0; i <= `dt_mxblks ; i = i+1) begin
         `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.status_ram.stram[i] = 5'b0 ;
         `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.dtag_ram1.t_ram[i] = 19'b0 ;
         `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.dtag_ram0.t_ram[i] = 19'b0 ;
        end

	for (i =  0; i <= `dc_size ; i = i+1) begin
        `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.dcache_ram1.dc_ram[i] = 8'b0 ; 
        `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.dcache_ram0.dc_ram[i] = 8'b0 ; 
        end

        $display("Dcache initialized to 0");
`endif
end
endtask

task init_scache;
integer	i;
begin 
	for(i=0; i<=63; i = i+1) begin
	   `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[i] = 32'hdeadbeef;
	end
        $display("Scache initialized to 0xdeadbeef");
end
endtask

