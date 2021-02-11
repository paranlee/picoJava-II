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




 module display_picoJavaII;

   parameter SPACE = " ";
   parameter EOS = 32'b0;
   reg [8*512:1] picoJava_status; 
   reg [63:0] optop, vars, pc, psr, oplim, trapbase, frame, cp, numInst;
   reg [63:0] stack_top1, stack_top2, stack_top3, stack_top4, stack_top5;
   reg [63:0] lockaddr0, lockaddr1, lockcount0, lockcount1, gcconfig, global0, global1, global2, global3, brk1a, brk2a, brk12c, userrange1, userrange2, versionid, hcr;
    
   task int2ascii;
      input  [31:0] int_val;
      output [63:0] ascii_val;
      
      begin
	if ((int_val && 32'b1) === 1'bx) begin
	 ascii_val = "xxxxxxxx";
	end
	else
	 begin
         if (int_val[3:0] <= 9)                 // 1st hex digit
            ascii_val[7:0] = int_val[3:0] + 48; //  0 -> '0' ...
         else
            ascii_val[7:0] = int_val[3:0] + 87; // 10 -> 'a' ...

         if (int_val[7:4] <= 9)                  // 2nd hex digit
            ascii_val[15:8] = int_val[7:4] + 48; //  0 -> '0' ...
         else
            ascii_val[15:8] = int_val[7:4] + 87; // 10 -> 'a' ...
         
         if (int_val[11:8] <= 9)                   // 3rd hex digit
            ascii_val[23:16] = int_val[11:8] + 48; //  0 -> '0' ...
         else
            ascii_val[23:16] = int_val[11:8] + 87; // 10 -> 'a' ...

         if (int_val[15:12] <= 9)                   // 4th hex digit
            ascii_val[31:24] = int_val[15:12] + 48; //  0 -> '0' ...
         else
            ascii_val[31:24] = int_val[15:12] + 87; // 10 -> 'a' ...

         if (int_val[19:16] <= 9)                   // 5th hex digit
            ascii_val[39:32] = int_val[19:16] + 48; //  0 -> '0' ...
         else
            ascii_val[39:32] = int_val[19:16] + 87; // 10 -> 'a' ...

         if (int_val[23:20] <= 9)                   // 6th hex digit
            ascii_val[47:40] = int_val[23:20] + 48; //  0 -> '0' ...
         else
            ascii_val[47:40] = int_val[23:20] + 87; // 10 -> 'a' ...

         if (int_val[27:24] <= 9)                   // 7th hex digit
            ascii_val[55:48] = int_val[27:24] + 48; //  0 -> '0' ...
         else
            ascii_val[55:48] = int_val[27:24] + 87; // 10 -> 'a' ...

         if (int_val[31:28] <= 9)                   // 8th hex digit
            ascii_val[63:56] = int_val[31:28] + 48; //  0 -> '0' ...
         else
            ascii_val[63:56] = int_val[31:28] + 87; // 10 -> 'a' ...
	 end
      end
   endtask
         
        
   task get_status;
      reg [31:0] register;
      reg [31:0] int_val;
      reg [63:0] ascii_val;

      begin
         
         // all subsequent register assignments in this task.
         // register = 'h12345678;

	 // OPTOP Register
         register = `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.shadow_optop[31:0];
         int2ascii(register, ascii_val);
         optop = ascii_val;
         
	 // VARS Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.vars_w[31:0];
         int2ascii(register, ascii_val);
         vars = ascii_val;

         // PC Register
         register =  `PICOJAVAII.`DESIGN.iu.pipe.pipe_dpath.pc_w[31:0];
         int2ascii(register, ascii_val);
         pc = ascii_val;

	 // PSR Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.psr_w[31:0];
         int2ascii(register, ascii_val);
         psr = ascii_val;

	 // OPLIM Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.oplim_w[31:0];
         int2ascii(register, ascii_val);
         oplim = ascii_val;
         
	 // TRAPBASE Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.trapbase_w[31:0];
         int2ascii(register, ascii_val);
         trapbase = ascii_val;

	 // FRAME Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.frame_w[31:0];
         int2ascii(register, ascii_val);
         frame = ascii_val;

         // CP Register
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.const_pool_w[31:0];
         int2ascii(register, ascii_val);
         cp = ascii_val;

// remaining regs (16) except sc_bottom introduced for comparison 
	     // lockaddr0 
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.lockaddr0_w[31:0];
         int2ascii(register, ascii_val);
         lockaddr0 = ascii_val;

	     // lockaddr1
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.lockaddr1_w[31:0];
         int2ascii(register, ascii_val);
         lockaddr1 = ascii_val;

	     // lockcount0 
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.lockcount0_w[31:0];
         int2ascii(register, ascii_val);
         lockcount0 = ascii_val;

	     // lockcount1
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.lockcount1_w[31:0];
         int2ascii(register, ascii_val);
         lockcount1 = ascii_val;

         // globals are to be got from RCU, not ex_regs
	     // global0 
         register = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.gl_reg0[31:0];
         int2ascii(register, ascii_val);
         global0 = ascii_val;

	     // global1
         register = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.gl_reg1[31:0];
         int2ascii(register, ascii_val);
         global1 = ascii_val;

	     // global2
         register = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.gl_reg2[31:0];
         int2ascii(register, ascii_val);
         global2 = ascii_val;

	     // global3 
         register = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.gl_reg3[31:0];
         int2ascii(register, ascii_val);
         global3 = ascii_val;

	     // userrange1
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.userrange1_w[31:0];
         int2ascii(register, ascii_val);
         userrange1 = ascii_val;

	     // userrange2
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.userrange2_w[31:0];
         int2ascii(register, ascii_val);
         userrange2 = ascii_val;

	     // brk1a 
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.brk1a_w[31:0];
         int2ascii(register, ascii_val);
         brk1a = ascii_val;

	     // brk2a
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.brk2a_w[31:0];
         int2ascii(register, ascii_val);
         brk2a = ascii_val;

	     // brk12c 
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.brk12c_w[31:0];
         int2ascii(register, ascii_val);
         brk12c = ascii_val;

	     // gcconfig
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.gc_config_w[31:0];
         int2ascii(register, ascii_val);
         gcconfig = ascii_val;

	     // versionid
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.versionid_w[31:0];
         int2ascii(register, ascii_val);
         versionid = ascii_val;

	     // hcr
         register = `PICOJAVAII.`DESIGN.iu.ex.ex_regs.hcr_w[31:0];
         int2ascii(register, ascii_val);
         hcr = ascii_val;

         // Top of stack cache
         
         int2ascii(`PICOJAVAII.top1, ascii_val);
         stack_top1 = ascii_val;

         int2ascii(`PICOJAVAII.top2, ascii_val);
         stack_top2 = ascii_val;

         int2ascii(`PICOJAVAII.top3, ascii_val);
         stack_top3 = ascii_val;

         int2ascii(`PICOJAVAII.top4, ascii_val);
         stack_top4 = ascii_val;

         int2ascii(`PICOJAVAII.top5, ascii_val);
         stack_top5 = ascii_val;

         register = `PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w[2:0];
         int2ascii(register, ascii_val);
         numInst = ascii_val;

         // COMPILE STATUS STRING FOR COSIMULATION:
         picoJava_status = 0;
         // Add command for string comparision during cosimulation
         picoJava_status = {picoJava_status, "compareResults {"};  
         
	 // Add registers, stack cache ... etc. separated by spaces
         picoJava_status= {picoJava_status, 
     optop, SPACE, vars, SPACE, pc, SPACE, psr, SPACE, 
     oplim, SPACE, trapbase, SPACE, frame, SPACE, cp, SPACE, 
     lockaddr0, SPACE, lockaddr1, SPACE, lockcount0, SPACE, lockcount1, SPACE,
     global0, SPACE, global1, SPACE, global2, SPACE, global3, SPACE,
     userrange1, SPACE, userrange2, SPACE, brk1a, SPACE, brk2a, SPACE,
     brk12c, SPACE, gcconfig, SPACE, versionid, SPACE, hcr, SPACE,
     stack_top1, SPACE, stack_top2, SPACE, stack_top3, SPACE, stack_top4, SPACE,
     stack_top5, SPACE, numInst};

         // Add end delimiters
         picoJava_status = {picoJava_status, "}", EOS};      
         // $display ("\nPICOJAVA STATUS is = %s, %s, %s\n", picoJava_status, stack_top0, stack_top1);
      end
   endtask

   task dumpReg;

      begin
         get_status;
         $display ("\n");
         $display ("Optop = %s\n", optop);
         $display ("Vars = %s\n", vars);
         $display ("PC = %s\n", pc);
  	     $display ("PSR = %s\n", psr);
         $display ("Oplim = %s\n", oplim);
         $display ("Trapbase = %s\n", trapbase);
         $display ("Frame = %s\n", frame);
         $display ("CP = %s\n", cp);
         $display ("Lockaddr0 = %s\n", lockaddr0);
         $display ("Lockaddr1 = %s\n", lockaddr1);
         $display ("Lockcount0 = %s\n", lockcount0);
         $display ("Lockcount1 = %s\n", lockcount1);
         $display ("Global0 = %s\n", global0);
         $display ("Global1 = %s\n", global1);
         $display ("Global2 = %s\n", global2);
         $display ("Global3 = %s\n", global3);
         $display ("Userrange1 = %s\n", userrange1);
         $display ("Userrange2 = %s\n", userrange2);
         $display ("Brk1a = %s\n", brk1a);
         $display ("Brk2a = %s\n", brk2a);
         $display ("Brk12c = %s\n", brk12c);
         $display ("GCconfig = %s\n", gcconfig);
         $display ("VersionId = %s\n", versionid);
         $display ("HCR = %s\n", hcr);
         $display ("\n");
      end   

   endtask


   task dumpStack;

      begin
         get_status;
         $display ("Top1 = %s\n", stack_top1);     
         $display ("Top2 = %s\n", stack_top2);     
         $display ("Top3 = %s\n", stack_top3);     
         $display ("Top4 = %s\n", stack_top4);     
         $display ("Top5 = %s\n", stack_top5);     
      end

   endtask
         
endmodule



