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




 
`include "mem.h"
module	bus_monitor (
	clk,
	reset,
	pj_tv,
	pj_type,
	pj_size,
	pj_ack,
	pj_data_in,
	pj_data_out,
	pj_standby_out,
	pj_address
	// pj_ale
	);


input			clk;
input			reset;
input	[1:0]		pj_ack;
input	[31:0]		pj_data_in;
input			pj_standby_out;


input	[31:0]		pj_data_out;
input	[29:0]		pj_address;
input			pj_tv;
input	[3:0]		pj_type;
input    [1:0]     	pj_size;
// input			pj_ale;

reg		pj_tv_d;
reg		last_ack;
integer		acks;



/****************** Detect Xs on the buses  ***************************/

always @(negedge clk) begin
if (pj_tv == 1'b1) begin
	if (^pj_address === 1'bx) begin
	$display("Bus Monitor :ERROR: Address bus has x's %h",pj_address);
	`PICOJAVAII.end_of_simulation = 'b1;
	end

	if (^pj_type === 1'bx) begin
	 $display("Bus Monitor :ERROR: pj type bus has x's %h",pj_type);
        `PICOJAVAII.end_of_simulation = 'b1;
        end

	if (^pj_size === 1'bx) begin
         $display("Bus Monitor :ERROR: pj size bus has x's %h",pj_size);
        `PICOJAVAII.end_of_simulation = 'b1;
        end

	if ((pj_type[0] == 1'b1)&&(^pj_data_out === 1'bx)) begin
	$display("Bus Monitor :ERROR: Store Data bus from picoJava-II has x's %h",pj_data_out);
        `PICOJAVAII.end_of_simulation = 'b1;
        end

	if ((pj_type[0] == 1'b0)&&(pj_ack=== 1'b1)&&(^pj_data_in === 1'bx)) begin
        $display("Bus Monitor :ERROR: Load Data from Memory has x's %h",pj_data_out);
        `PICOJAVAII.end_of_simulation = 'b1;
        end
end
end


/******************** Erroneous Transactions 	************************/

wire mem_error_range = ((pj_address >= `MEM_ERROR_ADDR_LOW)&&(pj_address <= `MEM_ERROR_ADDR_HIGH));
wire io_error_range = ((pj_address >= `IO_ERROR_ADDR_LOW)&&(pj_address <= `IO_ERROR_ADDR_HIGH));

reg [5:0] ack_wait_count;

initial begin
 ack_wait_count = 0;
end


always @(negedge clk) begin
if(pj_tv == 1'b1) begin
	 if (mem_error_range) begin
	        if (pj_ack[1] == 1'b0 | pj_ack[0] == 1'b1) begin
                        if (ack_wait_count >= 50) begin
			  $display("Bus Monitor :ERROR: Incorrect Ack generated for erroneous transaction %h",pj_ack);
        		  `PICOJAVAII.end_of_simulation = 'b1;
                          end
                          else ack_wait_count = ack_wait_count + 1;
        	end 
                else ack_wait_count = 0; 
         end
         if (io_error_range)  begin
	        if (pj_ack[1] == 1'b0 | pj_ack[0] == 1'b0) begin
                        if (ack_wait_count >= 50) begin
                        $display("Bus Monitor :ERROR: Incorrect Ack generated for erroneous transaction %h",pj_ack);
                        `PICOJAVAII.end_of_simulation = 'b1;
                        end
                        else ack_wait_count = ack_wait_count + 1;
                end 
                else ack_wait_count = 0; 

	end
end
end


/******************  Illegal Types 	 **************************/
always @(negedge clk) begin
if(pj_tv == 1'b1) begin
	if ((pj_type === 3'b001)||(pj_type === 3'b011)) begin
	$display("Bus Monitor :ERROR: Incorrect pj type %h",pj_type);
        `PICOJAVAII.end_of_simulation = 'b1;
        end 

end
end


/******************  illegal sizes 	***************************/
always @(negedge clk) begin
if(pj_tv == 1'b1) begin

	// dcache 
	if ((pj_type[2] == 1'b1)&&(pj_size == 2'b11)) begin
	$display("Bus Monitor :ERROR: Incorrect size of dcache transaction %h",pj_size);
        `PICOJAVAII.end_of_simulation = 'b1;
         end 

	//icache
	if ((pj_type[2] == 1'b0)&&(pj_size == 2'b11)) begin
        $display("Bus Monitor :ERROR: Incorrect size of icache transaction %h",pj_size);
        `PICOJAVAII.end_of_simulation = 'b1;
        end 

end
end




/****************** check for standby mode ************************/

always @(negedge clk) begin
	if((pj_standby_out == 1'b1)&&(pj_tv == 1'b1)) begin
	$display("Bus Monitor :ERROR: picoJava-II in standby,but pj_tv high");
        `PICOJAVAII.end_of_simulation = 'b1;
        end
end


/***************** Incorrect number of Acks  **********************/

always @(negedge clk) begin
#1 ;
pj_tv_d = pj_tv ;
end

always @(negedge clk) begin
if((pj_tv == 1'b1)&&((last_ack == 1'b1)||(pj_tv_d == 1'b0))) begin
	last_ack = 1'b0 ;
	case(pj_type[2:0]) 
	3'b000: acks = 2;
	3'b001: acks = 0 ;
	3'b010: acks = 1 ;
	3'b011: acks = 0 ;
	3'b100: acks = 4 ;
	3'b101: acks = 4 ;
	3'b110: acks = 1 ;
	3'b111: acks = 1 ;
	endcase
end
end

always @(negedge clk) begin
#2 ;
	if(pj_tv == 1'b1) begin
		if(pj_ack == 2'b01) begin
		acks = acks - 1 ;
		if(acks == 0) begin 
			last_ack = 1'b1;
		end
			if(acks < 0 ) begin
			$display("Bus Monitor :ERROR: Incorrect number of acks in this transaction");
			`PICOJAVAII.end_of_simulation = 'b1;
			end
		end
end
end
	
endmodule
