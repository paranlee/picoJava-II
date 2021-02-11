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


/* ************************************************************************
 * This powerdown monitor interfaces to PCSU 
 * and performs the following tasks:
 *
 * 1) Drive pj_standby, nmi, and irl at random fashion. 
 *
 * 2) Test powerdown features.
 *
 * 3) Record the powerdown cycles as low-power performance meter.  
 *
 *  Command line arguments
 *
 *   +standy                            ; default: pj_standby is low  
 *   +int_random			; default: pj_nmi is low 
 *                           		; default: pj_irl[3:0] is low 
 *   +int_cntl				; default: interrupt controller  
 *					           is off
 *   +int_cmd				; default: interrupt commands  
 *					           are off
 * 
 * Note:
 *   1) If +int_cntl plug is used, +int_random will be ignored.
 *      With +int_cntl being used, the interrupt controller becomes
 *      active and initiates the basic interrupt patterns including:
 *        a. Nested interrupts
 *	  b. Priority of interrupts
 *
 *   2) If +int_cmd plug is used, it overrides +int_cntl and +int_cmd.
 *      For this case the command file will be in charge of scheduling
 *      nmi, and irl[3:0] events to check:
 *        a. Priority of traps and interrupts    
 *        b. other units' interrupt-related functions
 *
 *   3) POWERDOWN_WAIT_NUMBER is used as the upper limit of the 
 *   wait cycles for the function units to enter powerdown state 
 *   after the pcsu asserts the pcsu_powerdown. 
 * 
 *   In order to have more aggressive powersaving design,
 *   this number can always be changed to a smaller number 
 *   to make simulation stop. So the design engineer can study 
 *   the unit that exceeds the limit.  
 *
 * *********************************************************************** */

module powerdown_monitor(
        pj_clk,
        pj_standby_out,
        pj_irl,
        pj_nmi,
        pj_standby,
        pj_address,
        pj_tv,
        pj_reset
	);

`define POWERDOWN_WAIT_NUMBER 16'h0100

input		pj_clk;	
input		pj_standby_out;	
input  [29:0]	pj_address;	
input		pj_tv;
input		pj_reset;

output 		pj_standby;
output 		pj_nmi;
output [3:0]    pj_irl;
 

reg	 	pj_standby;
reg		pj_nmi;
reg	[3:0]	pj_irl;

integer		seed_num;

real            total_standby_cyc_count;// total powerdown meters
real            total_sys_cyc_count;	 
real            save_power_percent;	// powersaving percentage 

reg             standby_flag;		// standby plug
reg             int_random_flag;	// int_random plug
reg             int_cntl_flag;		// int_cntl plug 
reg             int_cmd_flag;		// int_cmd plug 

reg     [31:0]  standby_rand_cyc;	// random number of cycles 
					// for standby high pulse

reg     [31:0]  icu_wait_pwdn_count;	// icu powderdown monitor
reg     [31:0]  dcu_wait_pwdn_count;	// dcu powderdown monitor

reg     [31:0]  standby_cyc_count;	
reg     [9:0]   random_int_cyc;	
reg     [10:0]  int_timeout_count;	

reg     [16:1] pending_reg;             // interrupt pending register
					// bit 16 : nmi
					// bit 15 : irl_15
					// bit 14 : irl_14
					// bit 13 : irl_13 ...
					// bit  1 : irl_1

reg     [16:1] pending_reg_temp;

reg     [16:1] random_int_reg;          // interrupt random generation 
					// registers

reg	[3:0]  random_sel;

reg     int_ack;  			// interrupt ack from pico 
reg     stop_int; 			// stop random interrupt, 
          				// issued by the software. 
reg	en_int_timeout;


always @(posedge pj_clk) begin
  int_ack  <= #1 (pj_tv === 1'b1) &
                 (pj_address === `PENDING_REGISTER) &
                 (`PICOJAVAII.pj_type === 4'b0111);

  stop_int <= #1 (pj_tv === 1'b1) &
                 (pj_address === `STOP_RANDOM_INTERRUPT) &
		 (`PICOJAVAII.pj_type === 4'h7);

  end
  

initial   
  begin
        int_ack = 0;
        stop_int = 0;
        seed_num = 0; 
        standby_flag = 1'b0;
        int_random_flag = 1'b0;
        int_cntl_flag = 1'b0;
        int_cmd_flag = 1'b0;
        pending_reg = 16'h0000;
        pending_reg_temp = 16'h0000;
        random_int_reg = 16'h0000; 
        random_int_cyc = 10'b0000000000;
	standby_rand_cyc = 32'h0000003C; //default powerdown cycle is 60 cycles 

        icu_wait_pwdn_count = 0;
        dcu_wait_pwdn_count = 0;
        int_timeout_count = 0;
        en_int_timeout = 1'b0;

        standby_cyc_count = 0; 

        total_standby_cyc_count = 0; 

        pj_standby = 1'b0; 
        pj_nmi = 1'b0; 
        pj_irl = 4'b0000; 

    if($test$plusargs("int_cmd"))  int_cmd_flag = 1'b1;
    else 
      if($test$plusargs("int_cntl")) int_cntl_flag = 1'b1;
      else 
        if($test$plusargs("int_random")) int_random_flag = 1'b1;

    if($test$plusargs("standby")) standby_flag = 1'b1;

  end


  always @(posedge `PICOJAVAII.end_of_simulation)
     begin
     total_sys_cyc_count = `PICOJAVAII.clk_count; 
     save_power_percent=(total_standby_cyc_count/total_sys_cyc_count)*100;
     $display("Total Standby cycle counts = %g",total_standby_cyc_count); 
     $display("Saving Power = %% %g",save_power_percent); 
     end


always @ (pj_standby_out) begin
        if (pj_standby_out == 1'b1)  
           $display("Enter powerdown Mode");
        if (pj_standby_out == 1'b0)  
           $display("Exit powerdown mode");
        end
 
always @ (posedge pj_clk) begin // {

        if (`PICOJAVAII.`DESIGN.pcsu_powerdown) begin
           if (!`PICOJAVAII.`DESIGN.icu_in_powerdown) 
              icu_wait_pwdn_count <= #1 icu_wait_pwdn_count + 1;
           if (!`PICOJAVAII.`DESIGN.dcu_in_powerdown) 
              dcu_wait_pwdn_count <= #1 dcu_wait_pwdn_count + 1;
        end else begin
        icu_wait_pwdn_count <= #1      0;
        dcu_wait_pwdn_count <= #1      0;
        end


       if (icu_wait_pwdn_count > `POWERDOWN_WAIT_NUMBER) begin
          $display("Warning! icu_wait_pwdn_count = %d, It exceeds the limit.",
                   icu_wait_pwdn_count); 
          end

       if (dcu_wait_pwdn_count > `POWERDOWN_WAIT_NUMBER) begin
          $display("Warning! dcu_wait_pwdn_count = %d, It exceeds the limit.",
                   dcu_wait_pwdn_count); 
          end


	if (pj_standby_out)  
	   total_standby_cyc_count <= #1 total_standby_cyc_count + 1;

        if (standby_cyc_count >= standby_rand_cyc) begin

           standby_cyc_count <= #1 32'h00000000;
	   
           if(standby_flag) begin
             standby_rand_cyc = {$random(seed_num)}%100;
             pj_standby <= #1 ~pj_standby ;
             seed_num = seed_num + 1;
           end
        end

        else standby_cyc_count <= #1 standby_cyc_count + 1;
  end  // }

/* ******************************************************
 * Interrupt Controller schedules the following events: * 	
 *							*
 *   1) Fill the pending register to create nested 	*
 *      interrupts, and prioritized interrupts.		* 
 *   2) Fire NMI if an internl trap occurs.		*		
 *							*
 * **************************************************** */   
     

// Include int_cmd_file


`include "int_cmd_file.v" 
`include "interrupt_table.v"

`define MIN_INT_GAP 150

integer i;

// Fill the pending register

initial begin // {

 repeat(5) @(posedge pj_clk); 
  wait(!pj_reset ) begin // { 

   if (!int_cmd_flag && (int_cntl_flag | int_random_flag)) begin
       $display("IRL_1 is asserted.");
       pending_reg[1] <= #1 1'b1;
       pending_reg_temp[1] <= #1 1'b1;
       end

   if (int_cntl_flag) begin // {
       for (i= 0; i < 16 ; i = i+1 ) begin // {
         @(posedge int_ack) 
             pending_reg_temp[16:1] <= #1 {pending_reg[15:1] , 1'b1};  
       end // }
       @(posedge int_ack) #3 
       pending_reg_temp = 16'h0000;
       pending_reg = 16'h0000;
   end // }

  end // }

end // }


wire any_int = |pending_reg;

always @(pending_reg)
         #1 if (any_int) en_int_timeout = 1'b1; 

always @(posedge pj_clk or posedge int_ack) begin 
         if (int_ack)  begin
             int_timeout_count = 0; 
             en_int_timeout = 1'b0;
             end 
         else if (en_int_timeout) 
                  int_timeout_count = int_timeout_count + 1;
                  if(int_timeout_count == 11'b11111111111) begin 
                  pending_reg = 0;
                  int_timeout_count = 0;
                  en_int_timeout = 1'b0;
                  $display("Time out! Interrupt Ack Return exceeds the max cycles:");
                  $display("         **** Clear Pending Register ****             ");
                  end
        end
                  
             
// interrupt_table interrupt_table ();

always @(posedge int_ack or negedge en_int_timeout) begin // {

 #2
       if(int_random_flag) begin
          random_sel = $random % 16;
          random_int_reg = 0;
          if (random_sel == 15) random_int_reg[16] = 1'b1; 
          else if (random_sel == 14) begin
                if ($test$plusargs("powerdown"))
                        random_int_reg[15] = 1'b1;
                else begin
                        random_sel = 13;
                        random_int_reg[14] = 1'b1;
                end
          end
          else if (random_sel == 13) random_int_reg[14] = 1'b1;
          else if (random_sel == 12) random_int_reg[13] = 1'b1;
          else if (random_sel == 11) random_int_reg[12] = 1'b1;
          else if (random_sel == 10) random_int_reg[11] = 1'b1;
          else if (random_sel == 9) random_int_reg[10] = 1'b1;
          else if (random_sel == 8) random_int_reg[9] = 1'b1;
          else if (random_sel == 7) random_int_reg[8] = 1'b1;
          else if (random_sel == 6) random_int_reg[7] = 1'b1;
          else if (random_sel == 5) random_int_reg[6] = 1'b1;
          else if (random_sel == 4) random_int_reg[5] = 1'b1;
          else if (random_sel == 3) random_int_reg[4] = 1'b1;
          else if (random_sel == 2) random_int_reg[3] = 1'b1;
          else if (random_sel == 1) random_int_reg[2] = 1'b1;
          else if (random_sel == 0) random_int_reg[1] = 1'b1;
      end

// Clear the pending bit if the core sends ack

      if (pending_reg[16])      begin
          pending_reg[16] = 1'b0 ; 
          $display("The pending NMI is acknowledged.");  
          end
      else if (pending_reg[15]) begin
          pending_reg[15] = 1'b0 ; 
          $display("The pending IRL_15 is acknowledged.");  
          end
      else if (pending_reg[14]) begin
          pending_reg[14] = 1'b0 ; 
          $display("The pending IRL_14 is acknowledged.");  
          end
      else if (pending_reg[13]) begin
          pending_reg[13] = 1'b0 ; 
          $display("The pending IRL_13 is acknowledged.");  
          end
      else if (pending_reg[12]) begin
          pending_reg[12] = 1'b0 ; 
          $display("The pending IRL_12 is acknowledged.");  
          end
      else if (pending_reg[11]) begin
          pending_reg[11] = 1'b0 ; 
          $display("The pending IRL_11 is acknowledged.");  
          end
      else if (pending_reg[10]) begin
          pending_reg[10] = 1'b0 ; 
          $display("The pending IRL_10 is acknowledged.");  
          end
      else if (pending_reg[9])  begin
          pending_reg[9] = 1'b0 ; 
          $display("The pending IRL_9 is acknowledged.");  
          end
      else if (pending_reg[8])  begin
          pending_reg[8] = 1'b0 ; 
          $display("The pending IRL_8 is acknowledged.");  
          end
      else if (pending_reg[7])  begin
          pending_reg[7] = 1'b0 ; 
          $display("The pending IRL_7 is acknowledged.");  
          end
      else if (pending_reg[6])  begin
          pending_reg[6] = 1'b0 ; 
          $display("The pending IRL_6 is acknowledged.");  
          end
      else if (pending_reg[5])  begin
          pending_reg[5] = 1'b0 ; 
          $display("The pending IRL_5 is acknowledged.");  
          end
      else if (pending_reg[4])  begin
          pending_reg[4] = 1'b0 ; 
          $display("The pending IRL_4 is acknowledged.");  
          end
      else if (pending_reg[3])  begin
          pending_reg[3] = 1'b0 ; 
          $display("The pending IRL_3 is acknowledged.");  
          end
      else if (pending_reg[2])  begin
          pending_reg[2] = 1'b0 ; 
          $display("The pending IRL_2 is acknowledged.");  
          end
      else if (pending_reg[1])  begin
          pending_reg[1] = 1'b0 ; 
          $display("The pending IRL_1 is acknowledged.");  
          end


      if (int_cntl_flag) pending_reg = pending_reg |pending_reg_temp; 

      if (int_cntl_flag && (pending_reg == 16'h0000)) begin
          $display("All interrupt signals, irl, nmi have been asserted"); 
          $display("Wait for the simulation to complete ...");
          end

      if (int_random_flag) begin
          random_int_cyc = ($random % 1024);
	  random_int_cyc[9] = 1'b0;
	  random_int_cyc = random_int_cyc + `MIN_INT_GAP;
          repeat(random_int_cyc) @(posedge pj_clk);
          pending_reg = pending_reg |random_int_reg;
          end

      if (pending_reg[16])      begin
          $display("Another NMI is asserted.");
          end
      else if (pending_reg[15]) begin
           $display("Another IRL_15 is asserted.");
          end
      else if (pending_reg[14]) begin
           $display("Another IRL_14 is asserted.");
          end
      else if (pending_reg[13]) begin
           $display("Another IRL_13 is asserted.");
          end
      else if (pending_reg[12]) begin
           $display("Another IRL_12 is asserted.");
          end
      else if (pending_reg[11]) begin
           $display("Another IRL_11 is asserted.");
          end
      else if (pending_reg[10]) begin
           $display("Another IRL_10 is asserted.");
          end
      else if (pending_reg[9])  begin
           $display("Another IRL_9 is asserted.");
          end
      else if (pending_reg[8])  begin
           $display("Another IRL_8 is asserted.");
          end
      else if (pending_reg[7])  begin
           $display("Another IRL_7 is asserted.");
          end
      else if (pending_reg[6])  begin
           $display("Another IRL_6 is asserted.");
          end
      else if (pending_reg[5])  begin
           $display("Another IRL_5 is asserted.");
          end
      else if (pending_reg[4])  begin
           $display("Another IRL_4 is asserted.");
          end
      else if (pending_reg[3])  begin
           $display("Another IRL_3 is asserted.");
          end
      else if (pending_reg[2])  begin
           $display("Another IRL_2 is asserted.");
          end
      else if (pending_reg[1])  begin
           $display("Another IRL_1 is asserted.");
          end
end // } 


always @(posedge stop_int)
  if (int_random_flag)begin
      int_random_flag = 1'b0;  
      random_int_reg = 16'h0000;
      pending_reg = 16'h0000;  
      standby_flag = 1'b0; 
      pj_standby = 1'b0;
      $display("STOP asserting pj_standby and random interrupt signals!");
      $display("Wait for the simulation to complete ...");
      end


always @(posedge pj_clk)
  if (int_cmd_flag == 1'b1) {pj_nmi,pj_irl[3:0]} = 5'b00000;

  
// Priority encoding ( nmi, irl[15:1]) -> (nmi, irl[3:0])

always @(pending_reg) begin

  casex (pending_reg[15:1])
  15'b1xxxxxxxxxxxxxx : pj_irl[3:0]=4'b1111; 
  15'b01xxxxxxxxxxxxx : pj_irl[3:0]=4'b1110; 
  15'b001xxxxxxxxxxxx : pj_irl[3:0]=4'b1101; 
  15'b0001xxxxxxxxxxx : pj_irl[3:0]=4'b1100; 
  15'b00001xxxxxxxxxx : pj_irl[3:0]=4'b1011; 
  15'b000001xxxxxxxxx : pj_irl[3:0]=4'b1010; 
  15'b0000001xxxxxxxx : pj_irl[3:0]=4'b1001; 
  15'b00000001xxxxxxx : pj_irl[3:0]=4'b1000; 
  15'b000000001xxxxxx : pj_irl[3:0]=4'b0111; 
  15'b0000000001xxxxx : pj_irl[3:0]=4'b0110; 
  15'b00000000001xxxx : pj_irl[3:0]=4'b0101; 
  15'b000000000001xxx : pj_irl[3:0]=4'b0100; 
  15'b0000000000001xx : pj_irl[3:0]=4'b0011; 
  15'b00000000000001x : pj_irl[3:0]=4'b0010; 
  15'b000000000000001 : pj_irl[3:0]=4'b0001; 
  15'b000000000000000 : pj_irl[3:0]=4'b0000; 
  endcase
  pj_nmi = pending_reg[16];

  if (int_cmd_flag == 1'b1) {pj_nmi,pj_irl[3:0]} = 5'b00000;

  end

endmodule
