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




 
// This memory controller interfaces to the picoJava-II Core
// Performs the following functions
// Want to simulate with arbitrary delays between subsequent acks for a
// given cycle.
// Also latency to drive 1st Ack should be programmable to be random or
// fixed.
//

`include		"mem.h"

module memc(decaf_clk,
	mem_data_bus_in,
	mem_data_bus_out,
	mem_addr_bus,
	mem_size,
	mem_type,
	mem_tv,
	mem_ack,
	reset);

input 			decaf_clk;
input 	[31:0] 	mem_data_bus_in;
output	[31:0]	mem_data_bus_out;
input 	[31:0]	mem_addr_bus;
input 	[1:0]	mem_size;
input 	[3:0]	mem_type;
input 			mem_tv;
output	[1:0]	mem_ack;
input			reset;

reg	[1:0] 	tx_size;
reg	[2:0]	num_acks;
reg			type;
reg	[1:0]	ack;
reg	[31:0]	data_out;
reg		reset_internal;

integer		rand1 ;
integer		rand2 ;
integer		seed;

// on a reset,  all memory tasks are nullified.(disabled)

assign 	mem_ack = (reset) ? 2'b00:ack,
		mem_data_bus_out =data_out;

  always @(reset)
	begin
	  disable generate_transfer ;
          disable wait_decaf_clk ;
  end
 



initial   
begin
	rand1 =0; rand2 =0;
    if($test$plusargs("rand_ack2"))    rand2 = 1;
    else if($test$plusargs("rand_ack1"))  rand1 = 1;
	if($test$plusargs("s1"))	seed = 100;
	else if($test$plusargs("s2")) seed = 200;
	else if($test$plusargs("s3")) seed = 300;
	else if($test$plusargs("s4")) seed = 400;
	else if($test$plusargs("s5")) seed = 500;
	else if	($test$plusargs("s6")) seed = 600;
	else	seed = 50;
end

     
always @ (posedge decaf_clk) begin
	#1;		
	if (mem_tv&!reset) begin	
		//#1;
		// Check address
		if (mem_addr_bus === 1'bx) begin
			$display("MEMC :ERROR: Address bus has x's %h",mem_addr_bus);
			$stop;
		end
		if ((mem_addr_bus >= `MEM_ERROR_ADDR_LOW)&&(mem_addr_bus <= `MEM_ERROR_ADDR_HIGH)) begin
			wait_decaf_clk(5);
			#1 ack = `MEM_ERROR_ACK;
			   data_out = 32'h0bad0bad;
			wait_decaf_clk(1);
		end
		else if ((mem_addr_bus >= `IO_ERROR_ADDR_LOW)&&(mem_addr_bus <= `IO_ERROR_ADDR_HIGH))  begin
			wait_decaf_clk(5);
               #1 ack = `IO_ERROR_ACK; 
			   data_out = 32'h1bad1bad;
			wait_decaf_clk(1);
		end
		// If error address, generate error Ack
		else begin
			case(mem_type[2:0])
			`ICACHE_LOAD: begin
				type = `READ;
				if ((mem_addr_bus >= `NC_ADDR_LOW) && (mem_addr_bus <= `NC_ADDR_HIGH)) 				begin
					num_acks =3'b001;  tx_size = `WORD;  
				end
				else begin
					num_acks =3'b100;  tx_size = `WORD; 
				end
			end
			`ICACHE_NC_LOAD: begin
					num_acks =3'b001; type = `READ; tx_size = mem_size;
			end
			`DCACHE_LOAD: begin
				if ((mem_addr_bus >= `NC_ADDR_LOW) && (mem_addr_bus <= `NC_ADDR_HIGH))				begin 
                	num_acks =3'b001; tx_size =mem_size;  
				end
                else begin
					num_acks =3'b100; tx_size =`WORD; 
				end
				type =`READ;
			end	
			`WRITE_BACK: begin
				num_acks =3'b100; type = `WRITE; tx_size =`WORD;  
			end
			`DCACHE_NC_LOAD: begin
				num_acks =3'b001; type = `READ; tx_size =mem_size;  
			end
			`DCACHE_NC_STORE: begin
				num_acks =3'b001; type = `WRITE; tx_size =mem_size;  
			end
/*
			`DRIBBLE_LOAD: begin
				num_acks =3'b100; type = `READ; tx_size =`WORD; 
			end
			`DRIBBLE_STORE: begin
				num_acks =3'b100; type = `WRITE; tx_size =`WORD; 
			end
*/
			default: begin
				$display("ERROR: Incorrect Transaction Type");
				$stop;
			end
			endcase	
			generate_transfer(mem_addr_bus, num_acks,type, tx_size );
		end
	end
	#1  ack = `IDLE_ACK;        //after transfer is complete drive idle
end


task generate_transfer;
input	[31:0]	address;
input	[2:0]	nacks;
input			tx_type;
input	[1:0]	size;

reg 	[31:0]	data;	
reg		[2:0]	ack_cnt;
integer			rand;
integer			dsv_status;
reg		[31:0]	new_data;
reg [1:0]		mem_xfer;

begin
	data = 32'b0;		
	ack_cnt = nacks ;
	mem_xfer = 2'b00;
	if(rand1 | rand2) begin
		rand = {$random(seed)}%`MAX_MEM_LATENCY;
		rand = rand +2;
		wait_decaf_clk(rand);
	end
	else
		wait_decaf_clk(`MEM_LATENCY_X1);      //# cycles to 1st Ack

    while (nacks !=0) begin

		if (|mem_xfer) begin
			if (rand2) begin
				rand = {$random(seed)}%`MAX_MEM_LATENCY;
				if (rand) #1  ack = `IDLE_ACK; 
        			wait_decaf_clk(rand);
    			end
			else
				if (mem_xfer == 2'h1)
					wait_decaf_clk(`MEM_LATENCY_X2 - 1);
				else if (mem_xfer == 2'h2)
					wait_decaf_clk(`MEM_LATENCY_X3 - 1);
				else if (mem_xfer == 2'h3)
					wait_decaf_clk(`MEM_LATENCY_X4 - 1);
		end
/*
		else
			mem_xfer = mem_xfer + 1'b1;
*/


		if (tx_type == `READ) begin
    			$decaf_cm_read(address,data, size,dsv_status);
			if ((mem_type[2:0] == `ICACHE_NC_LOAD) && (size == `BYTE)) begin
				new_data = align_data(address,data);
				data = new_data;
			end
//        		#1 data_out = data;
			//data_out = 32'h89abcdef;
			if (dsv_status) begin
        	 		#1 ack = `NORMAL_ACK;
        			   data_out = data;
			end
			else begin
				#1 ack = `MEM_ERROR_ACK;
        			   data_out = 32'h0bad0bad;
			end
		end
		else begin
			#2
			data = mem_data_bus_in;
			$decaf_cm_write(address, data, size,dsv_status);
			if (dsv_status)
        	 		#1 ack = `NORMAL_ACK;
			else
				#1 ack = `MEM_ERROR_ACK;
//			#1 ack = `NORMAL_ACK;
		end
		wait_decaf_clk(1);

		if (!dsv_status)
			disable generate_transfer;

		#1;
        	nacks = nacks - 2'b01;
		mem_xfer = mem_xfer + 1'b1;
		ack = 2'b00;
		if (ack_cnt == 2)
        		address[2:0] = address[2:0] +3'h4;    
		else
			address[3:0] = address[3:0] + 4'h4;
		#3 data_out = 32'hx;
    	end
end
endtask


function [31:0] align_data;
input	[31:0] 	addr;
input	[31:0] 	data;
begin
	case (addr[1:0])
	2'b00: align_data = data;
	2'b01: align_data = data <<8;
	2'b10: align_data = data <<16;
	2'b11: align_data = data <<24;
	default: $display("MEMC: ERROR: Incorrect address");
	endcase	
end
endfunction


task wait_decaf_clk;
input	[31:0]	count;
begin
	while (count !=0) begin
		@(posedge decaf_clk);
		count = count -1;
	end
end
endtask

endmodule
