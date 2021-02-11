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




 
// This is the top level netlist for picoJava-II simulation
// It contains:
//
//   1. picoJava-II RTL core
//   2. memory controller
//   3. clock generator
//   4. support circuit to the RTL core
//   5. command line arguments handler
//   6. Top level debugger
//   7. run-stop-continue control circuit
//   8. co-simulation with instruction simulator
//   9. display monitor
//  10. real address disassembler

`include "sys.h"
`include "returncode.h"

// The top level module

module picoJavaII;   

`include "report.h"
`include "init_icache.h"
`include "defines.h"

// verification flags definition
reg[63:0]   clk_count;
reg         have_trap;
reg        	end_of_simulation;
wire        	monitor_end_sim;
reg        	end_of_address_touched;
reg        [8*256:0]string;
integer        	need_resolution;
reg        [31:0]	return_code;
reg        	cosim;
reg        	pipeline;
reg        	stack;
integer        	opt;
integer         i;
reg [31:0]        oldpc;
integer         hang_count;
integer         dsv_status;
reg[63:0]       max_instr_count[0:0];
reg[63:0]       max_clk_count[0:0];

// no. of instr_complete_w commands recd - could correspond to more than 
// one instr for folded groups
integer        	instr_complete_count;  // this shd really be 64bit

// actual no. of instructions executed so far, counts traps and 
// interrupts as one instruction
reg[63:0]    	total_instr_count;   

reg        	have_interrupt;
reg [63:0]        ascii;
reg [31:0]  top1, top2, top3, top4, top5;
integer        	isize;
integer        	dsize;
reg [2:0] dsz,isz;
integer         stack_bottom;

reg        	wr_optop;

// support recording on/off
reg[31:0] recording_times[0:999];   // this shd really be 64bit
integer current_recording_times_index;
integer recording_on;

// signal definition
// input
reg             sys_clk;
reg        	pj_reset;
reg        	pj_boot8;
reg        	pj_no_fpu;
reg        	pj_scan_mode;
reg        	pj_scan_in;
wire [31:0]        pj_data_in;
wire                 pj_clk;

// inout
wire [1:0] pj_ack;
wire pj_nc;
wire pj_su;
wire pj_tv;
wire [3:0] pj_type;
wire [1:0] pj_size;

wire        	pj_nmi;
wire        [3:0]	pj_irl;

// out
wire pj_reset_out;
wire [31:00] pj_data_out;
wire [29:00] pj_address;
wire pj_brk1_sync;
wire pj_brk2_sync;
wire pj_in_halt;
wire pj_inst_complete;

// Internal module connections....
wire        	pj_icureq;	
wire         [31:0]	pj_icuaddr;
wire        	pj_icutype;	
wire         [1:0]	pj_icusize;
wire         [1:0]	pj_icuack;
wire         [31:0]	pj_datain;
wire        	pj_dcureq;	
wire         [31:0]	pj_dcuaddr;
wire        [2:0]	pj_dcutype;	
wire         [1:0]	pj_dcusize;
wire         [1:0]	pj_dcuack;
wire         [31:0]	pj_dataout;
wire        	pj_clk_out;

// signals for Random SMU hold generator...

integer         sm_hold_seed;
integer		wait_time;
reg [31:0]      rand_time;
//reg             rand_smu_hold;
reg             rand_smu_start;

reg        [8*256:0]filename1;
reg        [8*256:0]filename2;
reg        [8*256:0]filename3;
reg        [8*256:0]filename4;
reg        [8*256:0]filename5;
reg        [8*256:0]filename6;
reg        [8*256:0]filename7;
reg        [8*256:0]filename8;

// pj_halt signals....

wire pj_halt;
wire pj_halt_in;
reg disable_halt;

initial
	disable_halt = 1'b0;


//      Initializing for Random SMU hold...
initial begin

  rand_smu_start = 1'b0;
//  rand_smu_hold = 1'b0;
//  `PICOJAVAII.`DESIGN.rand_smu_hold = 1'b0;

  if ($test$plusargs("hold_seed_2"))
   sm_hold_seed = `RAND_HOLD_SEED_2;
  else if ($test$plusargs("hold_seed_3"))
   sm_hold_seed = `RAND_HOLD_SEED_3;
  else
   sm_hold_seed = `RAND_HOLD_SEED;


  repeat (50)
        @(posedge pj_clk) #1;

  rand_smu_start = 1'b1;

end

// Monitor for testing # resumes

always begin

@(posedge pj_in_halt);

if ($test$plusargs("num_resumes_check")) begin
      if(`PICOJAVAII.`DESIGN.iu.pc_e == `PICOJAVAII.`DESIGN.iu.pc_c)
         $display("Warning: %d: E and C Stage have same PC value for opcode %x. \n Multiple resumes may be required.",clk_count,`PICOJAVAII.  `DESIGN.iu.opcode_c);
end

end


// command line argument processing
// load all the trap handlers
// load the class file(s)
  initial
     begin
        if ($test$plusargs("usage")) begin
         $display(" +usage");
         $display(" \tprint out the usage info");
         $display(" +class+<classfile0>+<classfile1>+...");
         $display(" \tdefine the classes to be loaded");
         $display(" \tdefault: no class file");
         $display(" +restart");
         $display(" \trestart from a checkpointed state");
         $display(" +max_clk_count");
         $display(" \tfile max_clk_count contains maximum no. of clocks to run for");
         $display(" +max_instr_count");
         $display(" \tfile max_instr_count contains maximum no. of instructions to run for");
         $display(" +nofpu");
         $display(" \tno fpu present");
         $display(" \tdefault: fpu present");
         $display(" +le");
         $display(" \tlittle endian mode");
         $display(" \tdefault: big endian");
         $display(" +boot8");
         $display(" \tboot 8-bit mode");
         $display(" \tdefault: boot 32-bit mode");
         $display(" +define+TPL_DBG");
         $display(" \tTurn on top-level debugging flag");
         $display(" +define+IU_DBG");
         $display(" \tTurn on integer unit debugging flag");
         $display(" +define+DCU_DBG");
         $display(" \tTurn on data cache unit debugging flag");
         $display(" +define+ICU_DBG");
         $display(" \tTurn on instr cache unit debugging flag");
         $display(" +define+FPU_DBG");
         $display(" \tTurn on float point unit debugging flag");
         $display(" +define+PSU_DBG");
         $display(" \tTurn on power-on, scan, clock, reset unit debugging flag");
         $display(" +define+SMU_DBG");
         $display(" \tTurn on stack cache dribber unit debugging flag");
         $display(" +define+BIU_DBG");
         $display(" \tTurn on Bus interface unit debugging flag");
         $display(" +cosim+<path>");
         $display(" \tRun with the instruction simulator ias");
         $display(" +dcu_debug");
         $display(" \tEnables the DCU debug monitor, which prints out all accesses");
         $display(" \tmade to the DCU to the log file");
         $display(" +fpu_debug");
         $display(" \tEmits verbose information for FPU debugging in the log file");
         $display(" +sst_control");
         $display(" \tCreates a signalscan dump file for a set of clock-cycle ranges");
         $display(" +dump_ias_stats");
         $display(" \tSends a dumpStats command to ias at the end of the run");
         $display(" +expcount");
         $display(" \tFlags runtime exception handlers to increment an exception counter");
         $display(" \tand return instead of aborting the test");
         $display(" +cacheinvalidate");
         $display(" \tFlags reset code to explicitly invalidate instruction and");
         $display(" \tdata caches before enabling them");
         $display(" +flush");
         $display(" \tFlags reset code to flush the data caches after the test finishes");
         $display(" +dcu_off");
         $display(" \tFlags reset code to keep the data cache disabled");
         $display(" +icu_off");
         $display(" \tFlags reset code to keep the instruction cache disabled");         $display(" +maxwm");
         $display(" \tFlags reset code to set dribbler watermark settings to");
         $display(" \tthe highest legal values of 48 and 56");
         $display(" +minwm");
         $display(" \tFlags reset code to set dribbler watermark settings to");
         $display(" \tthe lowest legal values of 8 and 16");
         $display(" +handle");
         $display(" \tFlags to trap handlers that object references should use handles.");
         $display(" \tThis causes all object references to have the handle bit set.");
         $display(" +ibuf_mon");
         $display(" \tEnables the instruction buffer monitor");
         $display(" +statistics");
         $display(" \tEnables statistics monitor");
         $display(" +smu_check");
         $display(" \tEnables SMU monitor");
         $display(" +rand_ack1");
         $display(" +rand_ack2");
         $display(" \tInitializing the memory control to return memory acks at random intervals.");
         $display(" \trand_ack1 randomizes the number of clocks to the first ack.");
         $display(" \trand_ack2 randomizes the number of clocks to subsequent acks.");
         $display(" +smu_hold");
         $display(" \tInjects random SMU hold signals at the full-chip level");
         $display(" +hold_seed_2");
         $display(" +hold_seed_3");
         $display(" \thold_seed2 and hold_seed3 use different seeds from the default smu_hold.");
         $display(" \thold_seed2 and hold_seed3 must also have +smu_hold specified");
         $display(" +int_cmd");
         $display(" \tGenerates controlled interrupts in relation to the occurrence of");
         $display(" \tthe event specified by INT_TRIGGER");
         $display(" +int_cycle_0");
         $display(" +int_cycle_1");
         $display(" +int_cycle_2");
         $display(" +int_cycle_3");
         $display(" +int_cycle_4");
         $display(" \tThese signals specify how many cycles after the INT_TRIGGER");      
         $display(" \tevent (0, 1, 2, 3, or 4) the interrupt is sent to the cpu");        
         $display(" +int_cntl");
         $display(" \tCreates multiple interrupts simultaneously");
         $display(" +int_random");
         $display(" \tEnables random interrupts to the CPU");
         $display(" +scheduled_interrupts");
         $display(" \tReads pairs of hexadecimal numbers from the file interrupt_table"); 
         $display(" \tin the current directory, one number on each line. ");
         $display(" \tThe first number in a pair indicates the clock cycle in which to signal an interrupt.");
         $display(" \tThe IRL of the interrupt is the second number in the pair.");       
         $display(" +no_io_pin_stats");
         $display(" \tsuppress printing of I/O pin statistics at the end of simulation"); 
         $display(" +no_ucode_mon");
         $display(" \tDisable microcode monitor, which is enabled by default.");
         $display(" +pj_halt");
         $display(" \tForces the pj_halt signal to high for the duration of the test.");
         $display(" +record");
         $display(" \tRecords the pin assertions and dump them to pico_pin.tape and pico_pout.tape");
         $display(" +bmem+<filename>");
         $display(" \tLoads a .binit format file into memory");
         $display(" +tmem+<filename>");
         $display(" \tLoads a .init format file into memory");
         $display(" +halt_check");
         $display(" \tCheck that breakpoint halt mode was entered at least once");

         $finish;
        end

        // +record will activate the recorder during simulation
        if ($test$plusargs("record"))
          picoJavaII_pin_recorder.record_on = 1'b1;
        else 
          picoJavaII_pin_recorder.record_on = 1'b0;

`ifdef SIGNALSCAN

`ifdef TPL_LOCAL_DBG
        // $dumpfile("TPL.dump");
	// $dumpvars(0, `PICOJAVAII);
        $recordfile("TPL.sst", "wrapsize=50M");
        $recordvars("primitives", "drivers");
`endif

        current_recording_times_index = 0;

        // changes to support recording on/off

        if ($test$plusargs("sst_control")) begin
          $display("Generating .sst file with recording control");
          $display("reading start and end time pairs for .sst recording from file: sst_control");
          $readmemh ("sst_control", recording_times);
          $recordoff;   // will be switched on later 
        end

        if ($test$plusargs("define+TPL_DBG")) begin
          // $dumpfile("TPL.dump");
          // $dumpvars(0, `PICOJAVAII);
            $recordfile("TPL.sst", "wrapsize=50M");
          $recordvars("primitives", "drivers");
        end

        if ($test$plusargs("define+IU_DBG")) begin
          $recordfile("IU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.iu);
        end

        if ($test$plusargs("define+FPU_DBG")) begin
          $recordfile("FPU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.fpu);
        end

        if ($test$plusargs("define+PSU_DBG")) begin
          $recordfile("PSU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.pcsu);
        end

        if ($test$plusargs("define+ICU_DBG")) begin
          $recordfile("ICU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.icu);
          $recordvars(`PICOJAVAII.`DESIGN.icram_shell.icram_top.icram);
          $recordvars(`PICOJAVAII.`DESIGN.itag_shell.itag_top.itag);
        end

        if ($test$plusargs("define+DCU_DBG")) begin
          $recordfile("DCU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.dcu);
          $recordvars(`PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram);
          $recordvars(`PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag);
        end

        if ($test$plusargs("define+SMU_DBG")) begin
          $recordfile("SMU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.`DESIGN.smu);
        end

        if ($test$plusargs("define+BIU_DBG")) begin
          $recordfile("BIU.sst", "wrapsize=50M");
          $recordvars(`PICOJAVAII.biu);
        end

`endif // SIGNALSCAN
    
        need_resolution = 0;

        wr_optop = 1'b0;
        have_interrupt = 1'b0;

        // pipeline progress display ?
        pipeline = 'b0;
        if ($test$plusargs("pipeline")) begin
          pipeline = 'b1;
        end

        // stack cache progress display ?
        stack = 'b0;
        if ($test$plusargs("stack")) begin
          stack = 'b1;
        end

        // cosim ?
        cosim = 'b0;
        if ($test$plusargs("cosim")) begin
          cosim = 'b1;
          $decaf_cosim(string);
        end

        if ($test$plusargs("max_instr_count")) begin
            $readmemh ("max_instr_count", max_instr_count);
        end 
        else begin
            max_instr_count[0] = 64'hffffffffffffffff; // set to maxint
        end
        $display ("max_instr_count = %h\n", max_instr_count[0]);

        if ($test$plusargs("max_clk_count")) begin
            $readmemh ("max_clk_count", max_clk_count);
        end 
        else begin
            max_clk_count[0] = 64'hffffffffffffffff;    // set to maxint
        end

        $decaf_load_traphandlers();

        init_scache;
        init_icache;
        init_dcache;
        // check for restart option here.
        // also load any extra classes asked for, AFTER the restart
        if ($test$plusargs("restart")) begin
`ifdef NO_DCACHE
`else
            $readmemh ("dram0", `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.dcache_ram0.dc_ram);
            $readmemh ("dram1", `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.dcache_ram1.dc_ram);
            $readmemh ("dstat", `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.status_ram.stram);
            $readmemh ("dtag0", `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.dtag_ram0.t_ram);
            $readmemh ("dtag1", `PICOJAVAII.`DESIGN.dtag_shell.dtag_top.dtag.dtag_ram1.t_ram);
`endif
`ifdef NO_ICACHE
`else
            $readmemh ("itag", `PICOJAVAII.`DESIGN.itag_shell.itag_top.itag.itram.t_ram);
            $readmemh ("iram", `PICOJAVAII.`DESIGN.icram_shell.icram_top.icram.iram.ic_ram);
`endif
    $display ("Restart completed");
        end

        // load the class file(s)
        // cosim ias also loads the classes
        string = "class";
        if ($test$plusargs(string)) begin
          $display ("loading extra classes:");
          $display ("%s", string);
          $decaf_cm_load (string, need_resolution);
          $display ("Finished loading extra classes");
        end

        if ($test$plusargs("bmem")) 
            $decaf_load_bmem_file;

        if ($test$plusargs("tmem")) 
            $decaf_load_tmem_file;

        // deal with return_code
        return_code = `INITIAL_VALUE;
        $decaf_cm_write(`END_LOCATION, return_code, 2,dsv_status);

        clk_count = 0;

        // support circuit
        if ($test$plusargs("boot8"))
          pj_boot8 = `BOOT8ON;
        else 
          pj_boot8 = `BOOT8OFF;

 /*****
       if ($test$plusargs("nofpu"))
          pj_no_fpu = `NOFPU;
		else
		  pj_no_fpu = `FPU;
*****/

/************************************************************************
When NOT using the fpu in simulations: 
`define NO_FPU

Set this variable in the defines.h file in picoJava-II/design/rtl 
**************************************************************************/
`ifdef NO_FPU
		  pj_no_fpu = 1;
`else
		  pj_no_fpu = 0;
`endif


		pj_scan_mode = `SCANOFF;
		pj_scan_in = `SCAN_IN;

	if (cosim == 'b1) begin
		  // ias initialization
		  if (pj_boot8 == `BOOT8ON) begin
		    $decaf_cosim_cntl("boot8");
		  end

          dsz = `HCR_DCS_POR_VALUE;
      isz = `HCR_ICS_POR_VALUE;

// getting the string to pass to the IAS, for configuring cache size...

        case (isz)

        {3'h1}:
                string = "configure icache 1";
        {3'h2}:
                string = "configure icache 2";
        {3'h3}:
                string = "configure icache 4";
        {3'h4}:
                string = "configure icache 8";
        {3'h5}:
                string = "configure icache 16";
        default:
                string = "configure icache 0";
        endcase
 
        if (! $test$plusargs("restart"))
            $decaf_cosim_cntl(string);

        case (dsz)
 
        {3'h1}:
                string = "configure dcache 1";
        {3'h2}:
                string = "configure dcache 2";
        {3'h3}:
                string = "configure dcache 4";
        {3'h4}:
                string = "configure dcache 8";
        {3'h5}:
                string = "configure dcache 16";
        default:
                string = "configure dcache 0";
        endcase
 
        if (! $test$plusargs("restart"))
            $decaf_cosim_cntl(string);
 
// now configure FPU here - send out a string "configure fpu absent" or "configure fpu present"

        end // of ias initialisation

        return_code = 0;
        // get the value, loader change it if there is <clinit>
        $decaf_cm_read(`FLUSH_LOCATION, return_code, 2,dsv_status);
        // for cache flush
        if ($test$plusargs("flush")) begin
          return_code = 'hf | return_code;
        end

        // for different exception behaviors
        if ($test$plusargs("expcount")) begin
          return_code = 'hf0 | return_code;
        end

        // for cache invalidate
        if ($test$plusargs("cacheinvalidate")) begin
          return_code = 'hf000 | return_code;
        end

        $decaf_cm_write(`FLUSH_LOCATION, return_code, 2,dsv_status);
        display_picoJavaII.int2ascii(return_code, ascii);
        string = {"memPoke 0xfff0 0x", ascii};
        if (cosim == 'b1) 
            $decaf_cosim_cntl(string);

        // by default, we do small comparison
        return_code = 0;
        $decaf_cm_write(`COSIM_LOCATION, return_code, 2,dsv_status);
        display_picoJavaII.int2ascii(return_code, ascii);
        string = {"memPoke 0xffe0 0x", ascii};
        if (cosim == 'b1) 
            $decaf_cosim_cntl(string);

        // For handles
        return_code = 0;
        if ($test$plusargs("handle")) 
            return_code = 'hffffffff;

        $decaf_cm_write(`TRAP_USE_LOCATION, return_code, 2,dsv_status);
        display_picoJavaII.int2ascii(return_code, ascii);
        string = {"memPoke 0xffec 0x", ascii};
        if (cosim == 'b1) 
            $decaf_cosim_cntl(string);

        // For water mark
        return_code = 0;
        // low = 16, high = 48 - default
        if ($test$plusargs("minwm")) begin
          // low = 8, high = 16
          return_code = 32'h1;
        end
        if ($test$plusargs("maxwm")) begin
          // low = 48, high = 56
          return_code = 32'h10;
        end
        if ($test$plusargs("dcu_off")) begin                    // DCU Off
          return_code = return_code | 32'h100;
        end
        if ($test$plusargs("icu_off")) begin                    // ICU Off
          return_code = return_code | 32'h1000;
        end
	$display("return_code=%x",return_code);
        $decaf_cm_write(`WATERMARK_LOCATION, return_code, 2,dsv_status);
        display_picoJavaII.int2ascii(return_code, ascii);
        string = {"memPoke 0xffe4 0x", ascii};
        if (cosim == 'b1) $decaf_cosim_cntl(string);
        if (return_code == 0)
          $display("Water mark low is 16, high is 48");
        if (return_code == 'h1)
          $display("Water mark low is 8, high is 16");
        if (return_code == 'h10)
          $display("Water mark low is 48, high is 56");

        oldpc = 32'b0;
        hang_count = 0;
        total_instr_count = 0;
        instr_complete_count = 0;
        have_trap <= 0;
        have_interrupt = 0;
     end

// reset circuit
  initial begin
    pj_reset = 'b0;
    end_of_simulation = 'b0;
    end_of_address_touched = 'b0;
    #`RESET_START pj_reset = 'b1;
    #`RESET_END pj_reset = 'b0;
  end

// clock circuit

  initial
    sys_clk = 'b0;

  always begin
    #`CLK_HALF_PERIOD sys_clk = ~sys_clk;
  end

// clock counter
  always @(posedge pj_clk) begin
    clk_count = clk_count + 1;
    if (clk_count >= max_clk_count[0]) begin
        $display ("Aborting simulation because clock count now exceeds maximum clock count for this simulation (0x%h)...\n", max_clk_count[0]);
   
        end_of_simulation = 1;
     end
  end

// changes to support recording on/off

`ifdef SIGNALSCAN

  initial
    recording_on = 0;
  always @(posedge pj_clk) begin
    if (recording_on == 0) begin
      if (recording_times[current_recording_times_index] == clk_count) begin
        recording_on = 1;
            $recordon;
            current_recording_times_index = current_recording_times_index+1;
        $display ("Switching on .sst file recording at clk %d, will record till clk %d\n", clk_count, recording_times[current_recording_times_index]);
      end
    end
    else begin // recording_on = 1
      if (recording_times[current_recording_times_index] == clk_count) begin
        recording_on = 0;
        $recordoff;
        $display ("Switching off .sst file recording on at clk %d", clk_count);
        current_recording_times_index = current_recording_times_index+1;
      end
    end
  end

`endif // SIGNALSCAN

/****** COSIM RULES:

cosim calls ias with a step command at the -ve edge of a cycle where it
sees inst_complete_w (aka "Done!") is active. at this time,
ifu.instrs_folded_w[2:0] contains the number of insn's folded corresponding
to this "done". the pc_w used during the comparison is the start pc of
this folded group of instructions (all other register values compared are
the values after execution of that group of instructions).
 
inst_complete_w is also asserted whenever a trap frame setup is completed,
(either due to an interrupt or due to any other source of traps), with
ifu.instrs_folded_w[2:0] = 0 or 1.
 
we compare state between RTL and ias after the end of every instruction,
and do not skip the comparison at the end of a trap frame setup (like pico).
the PC used for comparison for the done corresponding to a trap frame setup
is the PC of the instruction which would have been executed had the interrupt
not occurred, and for an emulation trap is the PC of the trapping instruction.
 
when cosim detects the done signal, it gathers register values from RTL,
and sends them across to a function in sim.tcl.
sim.tcl steps ias as many times as ifu.instrs_folded_w[2:0] indicates. if
instrs_folded_w is 0 (as for a "done" corresponding to trap frame
set up) compareResults still steps ias at least once. this is because
the semantics of ias' "step" command has been changed to include the action
of setting up of one trap frame as a step (equivalent to an instruction).

********/

// disasm and cosim
  always @(negedge `PICOJAVAII.`DESIGN.clk)
  #2
  begin
      if (`PICOJAVAII.`DESIGN.iu.wr_optop_e == 1'b1)
          wr_optop = 1;

      if (pipeline == 'b1)
      begin
	  $display("D:");
	  if (`PICOJAVAII.`DESIGN.icu.icu_vld_d[0] == 1'b1)
              $decaf_disasm(clk_count, `PICOJAVAII.`DESIGN.icu_pc_d, have_trap);
	  $display("E:");
	  if (`PICOJAVAII.`DESIGN.iu.inst_valid[0] == 1'b1)
	      $decaf_disasm(clk_count, `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_e, have_trap);
	  $display("W:");
	  if (`PICOJAVAII.`DESIGN.iu.inst_valid[2] == 1'b1)
	      $decaf_disasm(clk_count, `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w, have_trap);
      end

      /* have_trap is a variable which is assigned to 1 with iu_trap_r
         (which is exactly one cycle after iu_trap_c). it remains 1
         till the pseudo insn inserted into the pipe for building the
         trap frame completes and issues a done.  
         non-blocking assign used for have_trap, since it's used later
         to determine have_interrupt */
 
      if (`PICOJAVAII.`DESIGN.iu.iu_trap_r == 1'b1)
	  have_trap <= 1;
      else if (`PICOJAVAII.`DESIGN.iu.rcu.rcu_ctl.inst_complete_w == 1'b1)
	  have_trap <= 0;

      if (`PICOJAVAII.`DESIGN.iu.rcu.rcu_ctl.inst_complete_w == 1'b1) 
      begin
          instr_complete_count = instr_complete_count + 1;
           
          total_instr_count = total_instr_count 
                              + `PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w;

          // if the instrs_folded_w is 0, still count 1 since traps/interrupts
          // count as one instruction and they may have instrs_folded_w = 0
	  if (`PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w == 2'b00)
              total_instr_count = total_instr_count + 1;

          if (`PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w > 2'b01)
	      $display("The following %d instructions are folded", `PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w);

	  stack_bottom = `PICOJAVAII.`DESIGN.iu.sc_bottom[7:2] - 2;
	  opt = (`PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.shadow_optop[7:2] + 1)%64;

	  // 0xdeeddeed is the magic number which when seen by compareResults
	  // on the other side indicates that the value of top1/2/3/4/5 was
	  // not available in the RTL. on seeing this magic value compareResults 
	  // disable comparison of the respective top1..5 value 

	  if (`PICOJAVAII.`DESIGN.iu.optop_c[31:0] < `PICOJAVAII.`DESIGN.iu.sc_bottom[31:0]) 
	      top1 = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[(opt)%64];
	  else 
	      top1 = 'hdeeddeed;

	  if ((`PICOJAVAII.`DESIGN.iu.optop_c[31:0]+4) <`PICOJAVAII.`DESIGN.iu.sc_bottom[31:0]) 
	      top2 = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[(opt+1)%64];
	  else 
	      top2 = 'hdeeddeed;

	  if ((`PICOJAVAII.`DESIGN.iu.optop_c[31:0]+8) <`PICOJAVAII.`DESIGN.iu.sc_bottom[31:0]) 
	      top3 = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[(opt+2)%64];
	  else 
	      top3 = 'hdeeddeed;


	  if ((`PICOJAVAII.`DESIGN.iu.optop_c[31:0]+12) < `PICOJAVAII.`DESIGN.iu.sc_bottom[31:0])
	      top4 = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[(opt+3)%64];
	  else
	      top4 = 'hdeeddeed;

	  if ((`PICOJAVAII.`DESIGN.iu.optop_c[31:0]+16) < `PICOJAVAII.`DESIGN.iu.sc_bottom[31:0])
	      top5 = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[(opt+4)%64];
	  else
	      top5 = 'hdeeddeed;

          if (have_trap == 1) 
          begin
              if ((`PICOJAVAII.`DESIGN.iu.ex.ex_regs.trapbase_out[10:3] >= 8'h30) &
		  (`PICOJAVAII.`DESIGN.iu.ex.ex_regs.trapbase_out[10:3] <= 8'h3f)) 
	      begin
	          have_interrupt = 1'b1;
	      end
	  end

	  if (have_interrupt == 1'b1)
	      $display ("%d: RTL completed building trap frame due to interrupt\n", clk_count);
	  else
	      $decaf_disasm(clk_count, `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w, have_trap);

     	  if (cosim == 'b1) 
	  begin
	      if (have_interrupt == 1'b1)
	      begin
		  case (`PICOJAVAII.`DESIGN.iu.ex.ex_regs.trapbase_out[10:3])
		    8'h30: string = "intr 0 0";
		    8'h31: string = "intr 0 1";
		    8'h32: string = "intr 0 2";
		    8'h33: string = "intr 0 3";
		    8'h34: string = "intr 0 4";
		    8'h35: string = "intr 0 5";
		    8'h36: string = "intr 0 6";
		    8'h37: string = "intr 0 7";
		    8'h38: string = "intr 0 8";
		    8'h39: string = "intr 0 9";
		    8'h3a: string = "intr 0 10";
		    8'h3b: string = "intr 0 11";
		    8'h3c: string = "intr 0 12";
		    8'h3d: string = "intr 0 13";
		    8'h3e: string = "intr 0 14";
		    8'h3f: string = "intr 0 15";
		  endcase
  	      end


              display_picoJavaII.get_status;

	      if (have_interrupt == 1'b1) 
		  $decaf_cosim_cntl(string);

              $decaf_cosim_cntl(display_picoJavaII.picoJava_status);
              
  	  end

	  // reset have_interrupt
          if (have_interrupt == 1'b1) 
	  begin
	      have_interrupt = 1'b0;  
	  end

    	  // monitoring optop and vars relationship
	  if (`PICOJAVAII.`DESIGN.iu.lvars[31:0] < `PICOJAVAII.`DESIGN.iu.optop_c[31:0]) 
	  begin
	      $display("Warning : var registers %x is less than optop %x!\n",
		    `PICOJAVAII.`DESIGN.iu.lvars[31:0], `PICOJAVAII.`DESIGN.iu.optop_c[31:0]);
	  end

          if (total_instr_count >= max_instr_count[0]) begin
              $display ("Aborting simulation because instruction count now exceeds maximum instruction count for this simulation (0x%h)...", max_instr_count[0]);
              end_of_simulation = 1;
          end
      end // end of if (inst_complete_w)
  end    // end of always (@negedge clk)

// end of simulation control

  always @(monitor_end_sim === 1'b1) 
  begin
    end_of_simulation = 'b1;
  end

  always @end_of_simulation begin
    @(posedge pj_clk);
    if (end_of_simulation == 'b1) begin
      if (cosim == 'b1) begin
        if ($test$plusargs("dump_ias_stats")) begin
            $display ("asking ias to dump stats");
            string = "dumpStats ias.stats";
            $decaf_cosim_cntl(string);
        end
        $decaf_cosim_compare_memory_at_end();
        string = "exit";
        $decaf_cosim_cntl(string);
      end
      // check the end location
      $decaf_cm_read(`END_LOCATION, return_code, 2,dsv_status);
      genreport(return_code); 
      $display("CYCLE COUNT %d", clk_count);
      $display("INSTRUCTION COUNT %d", total_instr_count);
      $display("INSTRUCTIONS FOLDED AWAY %d", total_instr_count - instr_complete_count);
      $finish;
    end
  end

// end of simulation for now
//  always @(posedge `PICOJAVAII.`DESIGN.iu.control.decode_ew.goto_0_w) begin
//    #`END_OF_SIMULATION_DELAY
//    if (end_of_address_touched != 'b1)
//     $decaf_cm_write(`END_LOCATION, `DETECTED_LAST_INST, 2,dsv_status);
//    end_of_simulation = 'b1;
//  end

// check for the end of simulation
   always @(posedge pj_clk) begin
     if (pj_address == `END_LOCATION) begin
	disable_halt = 1'b1;
       #`END_OF_SIMULATION_DELAY
       end_of_simulation = 'b1;
       // end_of_address_touched = 1'b1;
     end
   end

   /*
    * Hanging test detection
    * ckchen, 10/08/97
    */
   always @(posedge pj_clk) begin : hang_detection
      // monitoring hang condition
      if (`PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w[31:0] == oldpc) begin
	 hang_count = hang_count + 1;
	 if (hang_count >= 10000) begin
	    $decaf_cm_write(`END_LOCATION, `LOOP_FOREVER, 2,dsv_status);
	    end_of_simulation = 'b1;
	    $display("Simulation hangs (pc does not move).");
	 end // if (hang_count >= 10000)
      end // if (`PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w[31:0] == oldpc)
      else begin
	 hang_count = 0;
      end // else: !if(`PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w[31:0] == oldpc)
      oldpc = `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w[31:0];
   end // block: hang_detection

// Random SMU Hold logic...

always @(posedge pj_clk)
begin

        #1;

        if ($test$plusargs("smu_hold"))
        begin

          while (!rand_smu_start)
                #1;

             rand_time = $random(sm_hold_seed);

	     if (rand_time[31:25] >= `MIN_HOLD_GAP)
	        wait_time = rand_time[31:25];
	     else
		wait_time = `MIN_HOLD_GAP;

             if (rand_time[31:26] != 4'h0)
             begin
                $display("Asserting SMU Hold at clk:%d",clk_count);
                force `PICOJAVAII.`DESIGN.smu_hold = 1'b1;
                repeat (rand_time[31:26])
                        @(posedge pj_clk) #1;

                $display("Deasserting SMU Hold at clk:%d",clk_count);
                release `PICOJAVAII.`DESIGN.smu_hold;
                repeat (wait_time)
                        @(posedge pj_clk) #1;
             end

        end
end

/***************************************************************************************/


// testing the top level only
`ifdef TEST_BENCH_TEST
   initial
     $monitor($time, " - %b%b%b%b", pj_clk, pj_reset,
                        end_of_simulation, `PICOJAVAII.memc.mem_tv);
`endif


assign pj_halt_in = pj_halt & ~disable_halt;

// picoJavaII RTL core
   `DESIGN        `DESIGN(
        .pj_su(pj_su),
        .pj_boot8(pj_boot8),
        .pj_no_fpu(pj_no_fpu),
        .pj_brk1_sync(pj_brk1_sync),
        .pj_brk2_sync(pj_brk2_sync),
        .pj_in_halt(pj_in_halt),
        .pj_inst_complete(pj_inst_complete),
        .pj_halt(pj_halt_in),
        .pj_resume(pj_resume),
        .pj_irl(pj_irl),
        .pj_nmi(pj_nmi),
//        .pj_standby(pj_standby),
        .pj_standby_out(pj_standby_out),
        .sm(pj_scan_mode),
        .sin(pj_scan_in),
        .so(pj_scan_out),
        .pj_clk_out(pj_clk_out),
        .clk(pj_clk),
        .pj_reset_out(pj_reset_out),
        .reset_l(!pj_reset),

        .pj_dcureq(pj_dcureq),
        .pj_dcusize(pj_dcusize[1:0]),
        .pj_dcutype(pj_dcutype[2:0]),
        .pj_dcuaddr(pj_dcuaddr[31:0]),
        .pj_dataout(pj_dataout[31:0]),
        .pj_dcuack(pj_dcuack[1:0]),
        .pj_icureq(pj_icureq),
        .pj_icusize(pj_icusize[1:0]),
        .pj_icutype(pj_icutype),
        .pj_icuaddr(pj_icuaddr[31:0]),
        .pj_icuack(pj_icuack[1:0]),
        .pj_datain(pj_datain[31:0]),

        // The following are dummy ports for performance counter
        .pj_perf_sgnl(),

        // These are ports for test purpose, they are set to non-test mode
        // now, so it shouldn't affect picoJavaII simulation. 
        .dc_test_err_l(),
        .dt_test_err_l(),
        .ic_test_err_l(),
        .it_test_err_l(),
        .bist_mode(2'b0),
        .bist_reset(1'b0),
        .test_mode(1'b0)

);



// Module BIU [Bus Interface Unit]
biu             biu (
        .icu_req                (pj_icureq),
        .icu_addr               (pj_icuaddr[31:0]),
        .icu_type               ({2'b00,pj_icutype,1'b0}),
        .icu_size               (pj_icusize[1:0]),
        .biu_icu_ack            (pj_icuack[1:0]),
        .biu_data               (pj_datain[31:0]),
        .dcu_req                (pj_dcureq),
        .dcu_addr               (pj_dcuaddr[31:0]),
        .dcu_type               ({pj_dcutype[2],pj_dcureq,pj_dcutype[1:0]}),
        .dcu_size               (pj_dcusize[1:0]),
        .dcu_dataout            (pj_dataout[31:0]),
        .biu_dcu_ack            (pj_dcuack[1:0]),
        .clk                    (pj_clk_out),
        .reset_l                 (~pj_reset),
        .pj_addr                (pj_address[29:0]),
        .pj_data_out            (pj_data_out[31:0]),
        .pj_data_in             (pj_data_in[31:0]),
        .pj_tv                  (pj_tv),
        .pj_size                (pj_size[1:0]),
        .pj_ale                 (pj_ale),
        .pj_type                (pj_type[3:0]),
        .pj_ack                 (pj_ack[1:0]),
        .sin                    (),
        .so                   	(),
        .sm                         (1'b0)
        );


// memory controller

memc        memc(.decaf_clk(pj_clk),
        .mem_data_bus_in(pj_data_out[31:0]),
        .mem_data_bus_out(pj_data_in[31:0]),
        .mem_addr_bus({2'b0, pj_address[29:0]}),
        .mem_size(pj_size[1:0]),
        .mem_type(pj_type[3:0]),
        .mem_tv(pj_tv),
        .mem_ack(pj_ack[1:0]),
        .reset(pj_reset)
);

// recorder
picoJavaII_pin_recorder picoJavaII_pin_recorder();


// monitors
monitor  monitor(
        .pj_standby		(pj_standby),
        .pj_nmi			(pj_nmi),
        .pj_irl			(pj_irl[3:0]),
        .pj_halt		(pj_halt),
        .pj_resume		(pj_resume),
        .pj_clk			(pj_clk),
        .monitor_end_sim	(monitor_end_sim)
);

endmodule
