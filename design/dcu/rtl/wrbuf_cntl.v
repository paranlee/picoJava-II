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


module wrbuf_cntl( 	
			wb_ce,
			wb_sel,
			wb_idle,
			wb_req,
			real_wb_req,
			error_ack,
			lru_bit,
			nc_write_c,
			flush_inst_c2,
			flush_set_sel,
			flush_inst_c_or_c1,
			nc_write_cyc,
			normal_ack,
			repl_addr,
			repl_start,
			smu_na_st_fill,
			repl_busy,
			dc_error,
			miss_idle,
			first_fill_cyc,
			dcu_addr_c,
			stall_valid,
			clk,
			sin,
			so,
			sm,
			reset_l 
			);


output	[1:0]		wb_ce;		// Clock enables to latch data into writebuffer	
output	[3:0]           wb_sel;     	// Select which entry in writebuffer to be put on data bus            
output			wb_idle;	// The writeback state machine is in idle state
output	[3:0]		repl_addr;	// Word offset in the line being replaced (one for each bank).
output			repl_busy;	// Replacing 1st 64 bits currently
output			wb_req	;	// Request memory for writing data back to memory
output			real_wb_req;	// Request memory for write back only ,no NC_Wr
output			nc_write_cyc;	// Noncacheable write transaction currently going on..

input			smu_na_st_fill;  // it's a non_allocationg store in c+2 stage 
input	[3:2]		dcu_addr_c;	// word offset in a cache line
input                   error_ack;     	// Current transaction returned an error acknowledge
input                   normal_ack;    	// Current transaction completed normally
input			flush_inst_c2;	// Flush instruction in C2 stage( 2 cycles after C stage)
input			flush_inst_c_or_c1;	// flush instruction in C stage or C1 stage
input			flush_set_sel;	// select set to be flushed
input			lru_bit;	// used for determining line to be replaced
input                   repl_start;	// Line exists to be replaced. start state mc
input			stall_valid;	// need to recirculate inst in C stage due to stall
input                   dc_error;	// Erroneous transaction took place
input			miss_idle;	// miss state machine is in idle state
input                   first_fill_cyc;	// first cycle of cache fill transaction is taking place 
input			nc_write_c;	// Noncacheable store in C stage
input                   clk;		// clock
input                   sin;       	// Scan In port
output                  so;	// Scan out port
input                   sm;		// Scan enable
input                   reset_l ;       	// Reset


wire	[7:0]	wb_state;
wire	[7:0]	wb_next_state;
wire		wb_start;
wire	[1:0]	repl_state;
wire	[1:0]	repl_addr0;
wire	[1:0]	repl_addr1;
wire		start_wb;



/*******  Replace Dirty Line *****************/

ff_sr		repl_state_reg0(.out(repl_state[0]),
				.din(repl_start),
				.clk(clk),
				.reset_l(reset_l) );

ff_sr           repl_state_reg1(.out(repl_state[1]),
                                .din(repl_state[0]),
                                .clk(clk),
                                .reset_l(reset_l) );


assign	wb_ce[1:0]	 =  repl_state[1:0] ;
assign  repl_addr0[0]=  lru_bit&!flush_inst_c_or_c1 | flush_set_sel&flush_inst_c_or_c1;
assign  repl_addr0[1]=  repl_state[0] ;

assign  repl_addr1[0]=  !lru_bit&!flush_inst_c_or_c1  | !flush_set_sel&flush_inst_c_or_c1;
assign  repl_addr1[1]=  repl_state[0] ;

assign  repl_addr[3:0] = (stall_valid)?{dcu_addr_c[3:2],dcu_addr_c[3:2]}:{repl_addr1[1:0],repl_addr0[1:0]};


assign	repl_busy	=   repl_state[0] ;

assign	start_wb	=	first_fill_cyc | flush_inst_c2 |  smu_na_st_fill| dc_error  ;
/****************** State machine : wb_state ******************************/

assign	wb_next_state[7:0]	=	writeback_state( wb_state[7:0],
						normal_ack,
						start_wb,
						repl_busy,
						nc_write_c,
						error_ack,
						miss_idle );

ff_sr_7         wb_state_reg( .out(wb_state[7:1]),
                                .din(wb_next_state[7:1]),
                                .clk(clk),
                                .reset_l(reset_l));

ff_s		wb_state_reg_0(.out(wb_state[0]),
				.din(!reset_l | wb_next_state[0]),
				.clk(clk));


assign	wb_idle   = wb_state[0]  ;
assign	wb_sel[0] = !wb_state[3]& !wb_state[4] & !wb_state[5]  ;
assign  wb_sel[1] = wb_state[3] ;
assign  wb_sel[2] = wb_state[4] ;
assign  wb_sel[3] = wb_state[5] ;
assign	wb_start  = wb_state[2] ;
assign	wb_req	  =  wb_state[7] | wb_state[2];

assign  real_wb_req = wb_state[2];
	
assign	nc_write_cyc = wb_state[7] ;

/*****************************************************************************/


// STATE MACHINE FUNCTIONS

function	[7:0]  writeback_state;

input	[7:0]	cur_state ;
input		normal_ack;
input		start_wb;
input		repl_busy;
input		nc_write_c;
input		error_ack ;
input		miss_idle;

// Description: This state machine is responsible for writing data from
// writeback buffer into memory. It sends a write request to memory 
// only if the complete dirty line is present in the writeback buffer.
// It starts transaction once the first cache fill is done.(first_fill_cyc).
// At this point, check is done to see if writebuffer is full. 

// If there is no dirty line, the writebuffer is empty and the
// replacement state m/c is not busy. Thus this state m/c remains
// in idle state except for non-cacheable stores. When a non-cacheable
// store is in C stage, a store request is sent to memory.
// If there is an error ack, it goes into error state for a cycle.

reg	[7:0]	next_state;
parameter 
        IDLE            =       8'b00000001,
	WAIT		=	8'b00000010,
        REQ_WR_0        =       8'b00000100,
        REQ_WR_1        =       8'b00001000,
        REQ_WR_2        =       8'b00010000,
        REQ_WR_3        =       8'b00100000,
        ERROR_STATE     =       8'b01000000,
	NC_WR		=	8'b10000000;

begin

// If this is the last cycle of fill operation and the wbuffer is full,
// start wb transaction. If during last cycle of fill, replacement
// of dirty line is continuiing , wait till it is done. If there is
// no replacement of dirty line and wbuffer is not full, stay in idle state.
case (cur_state)        // synopsys full_case parallel_case
        IDLE:        begin
                        if(repl_busy) begin
                        next_state =  WAIT ;
			end
			else if(nc_write_c) begin
			next_state = NC_WR ;
			end
                        else    next_state = cur_state ;
                        end

	WAIT:		begin
			if(start_wb) begin
			next_state = REQ_WR_0;
			end
			else next_state = cur_state;
			end

	REQ_WR_0:	begin
			if(normal_ack & miss_idle ) begin
			next_state = REQ_WR_1 ;
			end
			else if (error_ack) begin
			next_state = ERROR_STATE ;
			end
			else next_state = cur_state ;
			end

	NC_WR:		begin
			if(normal_ack) begin
			next_state = IDLE ;
			end
			else if(error_ack) begin
			next_state = ERROR_STATE ;
			end
			else next_state = cur_state;
			end

	REQ_WR_1:	begin
			if(normal_ack) begin
                        next_state = REQ_WR_2 ;
			end
                        else if (error_ack) begin
                        next_state = ERROR_STATE ;
                        end
                        else next_state = cur_state ;
                        end
	
	REQ_WR_2:	begin
			if(normal_ack) begin  
                        next_state = REQ_WR_3 ;
			end
                        else if (error_ack) begin      
                        next_state = ERROR_STATE ;     
                        end    
                        else next_state = cur_state ;  
                        end    

	REQ_WR_3:	begin
			 if(normal_ack) begin  
                        next_state = IDLE ;
			end
                        else if (error_ack) begin      
                        next_state = ERROR_STATE ;     
                        end    
                        else next_state = cur_state ;  
                        end    

	ERROR_STATE:	begin
			next_state = IDLE;
			end

	default:	begin
			next_state = 8'bx;
			end
endcase
writeback_state[7:0]	= next_state[7:0] ;
end
endfunction

	
mj_spare spare (	.clk(clk),
			.reset_l(reset_l));

endmodule
