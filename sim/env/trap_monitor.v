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


module trap_monitor();

integer		trap_count;

initial
  trap_count = 0;

always @(`PICOJAVAII.end_of_simulation)
  $display("Total number of traps taken: %d", trap_count);

 // Trap monitor
always @(posedge `PICOJAVAII.`DESIGN.clk) begin

 // Trap Monitor
  if(`PICOJAVAII.`DESIGN.iu.ex.tbase_tt_we_e) begin
	trap_count = trap_count + 1;
	case (`PICOJAVAII.`DESIGN.iu.ex.tbase_tt_e[7:0])
	    8'h01:
		$write("asynchronous_error ");
	    8'h02:
		$write("memory_protection_error ");
	    8'h03:
		$write("data_access_mem_error ");
	    8'h04:
		$write("instruction_access_error ");
	    8'h05:
		$write("privileged_instruction ");
	    8'h06:
		$write("illegal_instruction ");
	    8'h07:
		$write("breakpoint1 ");
	    8'h08:
		$write("breakpoint2 ");
	    8'h09:
		$write("mem_address_not_aligned ");
	    8'h0a:
		$write("data_access_io_error ");
	    8'h0c:
		$write("oplim_trap ");
	    8'h62:
		$write("fadd ");
	    8'h63:
		$write("dadd ");
	    8'h66:
		$write("fsub ");
	    8'h67:
		$write("dsub ");
	    8'h6A:
		$write("fmul ");
	    8'h6B:
		$write("dmul ");
	    8'h6E:
		$write("fdiv ");
	    8'h6F:
		$write("ddiv ");
	    8'h72:
		$write("frem 1 ");
	    8'h73:
		$write("drem 2 ");
	    8'h86:
		$write("i2f ");
	    8'h87:
		$write("I2d ");
	    8'h89:
		$write("l2f ");
	    8'h8A:
		$write("l2d  ");
	    8'h8B:
		$write("f2i ");
	    8'h8C:
		$write("f2l ");
	    8'h8E:
		$write("d2i ");
	    8'h8F:
		$write("d2l ");
	    8'h8D:
		$write("f2d ");
	    8'h90:
		$write("d2f ");
	    8'h96:
		$write("fcmpg ");
	    8'h95:
		$write("fcmpl ");
	    8'h98:
		$write("dcmpg ");
	    8'h97:
		$write("dcmpl  ");
	    8'h0d:
		$write("soft_trap ");
	    8'h6d:
		$write("ldiv3 ");
	    8'h69:
		$write("lmul3 ");
	    8'h71:
		$write("lrem3 ");
	    8'h12:
		$write("ldc ");
	    8'h13:
		$write("ldc_w ");
	    8'h14:
		$write("ldc2_w ");
	    8'hB2:
		$write("getstatic ");
	    8'hB3:
		$write("putstatic ");
	    8'hB4:
		$write("getfield ");
	    8'hB5:
		$write("putfield ");
	    8'hBB:
		$write("new ");
	    8'hBC:
		$write("newarray ");
	    8'hBD:
		$write("anewarray ");
	    8'hC0:
		$write("checkcast ");
	    8'hC1:
		$write("instanceof ");
	    8'hC5:
		$write("multianewarray ");
	    8'hDD:
		$write("new_quick ");
	    8'hDE:
		$write("anewarray_quick ");
	    8'hE0:
		$write("checkcast_quick ");
	    8'hE1:
		$write("instanceof_quick ");
	    8'hDF:
		$write("multianewarray_quick ");
	    8'hB6:
		$write("invokevirtual ");
	    8'hB7:
		$write("invokespecial ");
	    8'hB8:
		$write("invokestatic ");
	    8'hB9:
		$write("invokeinterface ");
	    8'hDA:
		$write("invokeinterface_quick ");
	    8'hDB:
		$write("unimplemented_instr_0xdb ");
	    8'hE4:
		$write("putfield_quick_w ");
	    8'hE3:
		$write("getfield_quick_w ");
	    8'h53:
		$write("aastore ");
	    8'hBF:
		$write("athrow ");
	    8'hCA:
		$write("breakpoint  ");
	    8'hAB:
		$write("lookupswitch ");
	    8'hC4:
		$write("wide ");
	    8'hDC:
		$write("unimplemented_instr_0xdc ");
	    8'hEE:
		$write("unimplemented_instr_0xee ");
	    8'hEF:
		$write("unimplemented_instr_0xef ");
	    8'hF0:
		$write("unimplemented_instr_0xf0 ");
	    8'hF1:
		$write("unimplemented_instr_0xf1 ");
	    8'hF2:
		$write("unimplemented_instr_0xf2 ");
	    8'hF3:
		$write("unimplemented_instr_0xf3 ");
	    8'hF4:
		$write("unimplemented_instr_0xf4 ");
	    8'hF5:
		$write("unimplemented_instr_0xf5 ");
	    8'hF6:
		$write("unimplemented_instr_0xf6 ");
	    8'hF7:
		$write("unimplemented_instr_0xf7 ");
	    8'hF8:
		$write("unimplemented_instr_0xf8 ");
	    8'hF9:
		$write("unimplemented_instr_0xf9 ");
	    8'hFA:
		$write("unimplemented_instr_0xfa ");
	    8'hFB:
		$write("unimplemented_instr_0xfb ");
	    8'hFC:
		$write("unimplemented_instr_0xfc ");
	    8'hFD:
		$write("unimplemented_instr_0xfd ");
	    8'hFE:
		$write("unimplemented_instr_0xfe ");
	    8'h16:
		$write("runtime_ArithmeticException ");
	    8'h19:
		$write("runtime_IndexOutOfBndsException ");
	    8'h1B:
		$write("runtime_NullPtrException ");
	    8'h23:
		$write("LockCountOverflowTrap ");
	    8'h24:
		$write("LockEnterMissTrap ");
	    8'h25:
		$write("LockReleaseTrap ");
	    8'h26:
		$write("LockExitMissTrap ");
	    8'h27:
		$write("gc_notify ");
	    8'h29:
		$write("ZeroLineEmulationTrap4 ");
	    8'h30:
		$write("nmi ");
	    8'h31:
		$write("Interrupt_level_1 ");
	    8'h32:
		$write("Interrupt_level_2 ");
	    8'h33:
		$write("Interrupt_level_3 ");
	    8'h34:
		$write("Interrupt_level_4 ");
	    8'h35:
		$write("Interrupt_level_5 ");
	    8'h36:
		$write("Interrupt_level_6 ");
	    8'h37:
		$write("Interrupt_level_7 ");
	    8'h38:
		$write("Interrupt_level_8 ");
	    8'h39:
		$write("Interrupt_level_9 ");
	    8'h3a:
		$write("Interrupt_level_a ");
	    8'h3b:
		$write("Interrupt_level_b ");
	    8'h3c:
		$write("Interrupt_level_c ");
	    8'h3d:
		$write("Interrupt_level_d ");
	    8'h3e:
		$write("Interrupt_level_e ");
	    8'h3F:
		$write("Interrupt_level_f ");
	    default:
		$write("Undefined ");
	endcase

	$display ("trap taken ... with tt= [%h] vars= [%h]",
                                `PICOJAVAII.`DESIGN.iu.ex.tbase_tt_e[7:0], `PICOJAVAII.`DESIGN.iu.lvars[31:0]);
  end

/*
 // Return from Trap monitor
  if(`PICOJAVAII.`DESIGN.iu.datapath.regs.priv_ret_from_trap_op_e & `PICOJAVAII.`DESIGN.iu.datapath.regs.help0_op_e) $display (
  " Returning from Trap0 ... with frame= [%h], lvars= [%h]",
                              `PICOJAVAII.`DESIGN.iu.ex.ex_regs.frame_w[31:0], `PICOJAVAII.`DESIGN.iu.ex.ex_regs.vars_w[31:0]);
*/
end


endmodule 
