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




 
// mechanism to schedule interrupt arrival at predetermined clock cycles
// pairs of integers are read in, in **hex** format from a fixed file 
// called "interrupt_table" in the current directory

// first number in the pair is the clk cycle in which to signal an
// interrupt
// second number in the pair is the IRL level
// no support for NMI

// max 5000 pairs of integers (change defn of interrupt_table below to 
// increase)

reg[31:0] interrupt_table [0:9999];
integer current_intr_clk_index;
integer using_interrupt_table;

initial
begin
    using_interrupt_table = 0;
    if($test$plusargs("scheduled_interrupts")) 
	begin
        using_interrupt_table = 1;
        $display ("*************************************************************\"");
        $display ("Interrupts scheduled according to file \"interrupt_table\"");
        $display ("*************************************************************\"");
        $readmemh ("interrupt_table", interrupt_table);
    	current_intr_clk_index = 0;
    end
end

always @(posedge `PICOJAVAII.pj_clk)
begin
    if (using_interrupt_table)
    begin
        while (`PICOJAVAII.clk_count > interrupt_table[current_intr_clk_index])
	        current_intr_clk_index = current_intr_clk_index + 2;

        if (`PICOJAVAII.clk_count == interrupt_table[current_intr_clk_index])
		begin
		    $display ("RAISING SCHEDULED INTERRUPT at clk %d, irl=%d", `PICOJAVAII.clk_count, interrupt_table[current_intr_clk_index+1]);
    	    force `PICOJAVAII.pj_irl = interrupt_table[current_intr_clk_index+1];
		end
    end
end

always @(posedge `PICOJAVAII.pj_clk) 
begin
    if (using_interrupt_table == 1)
	begin
        if ((`PICOJAVAII.pj_tv === 1'b1) & (`PICOJAVAII.pj_address === `PENDING_REGISTER) &
           (`PICOJAVAII.pj_type === 4'b0111))
		begin
		    release `PICOJAVAII.pj_irl;
            $display ("Releasing PJ_IRL due to acknowledge, pj_irl value is now %d", `PICOJAVAII.pj_irl); 
        end
	end
end
	    
