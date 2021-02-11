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

module ucode_reg (
                             rom_fxx,
                             ie_stall_ucode,
                             sel_fxx_default,
                             u_abt_cur,
                             sm,
                             sin,
                             clk,
                             so,
		     	     test_mode, 
                             u_f00,
                             u_f01,
                             u_f02,
                             u_f03,
                             u_f04,
                             u_f05,
                             u_f06,
                             u_f07,
                             u_f08,
                             u_f09,
                             u_f10,
                             u_f11,
                             u_f12,
                             u_f13,
                             u_f14,
                             u_f15,
                             u_f16,
                             u_f17,
                             u_f18,
                             u_f19,
                             u_f20,
                             u_f21,
                             u_f22,
                             u_f23 
                            );

input [(`USED_BITS-1):0] rom_fxx;  // actual used rom data_out

input          ie_stall_ucode;     // IE unit holds off ucode execution
input          sel_fxx_default;    // an ucode exception to squash all ucode ctrls
input          u_abt_cur;          // abort current read/write requested by ucode

input          sm;                 // register scan mode
input          sin;                // register scan_input
input          clk;                // clock
input	       test_mode;          // test mode 

output         so;                 // register scan_output

output   [1:0] u_f00;              // field_00: IU_zero_comparator
output   [2:0] u_f01;              // Field_01: Ucode and StacK         WT
output   [1:0] u_f02;              // Field_02: Ucode and Stack         RD
output   [1:0] u_f03;              // Field_03: Ucode and Data_cache
output   [6:0] u_f04;              // Field_04: Ucode and Architech_reg RD
output   [2:0] u_f05;              // Field_05: Ucode and Architech_reg WT
output   [3:0] u_f06;              // Field_06: Integer Unit ALU a_operand
output   [2:0] u_f07;              // Field_07: Integer Unit ALU b_operand
output   [2:0] u_f08;              // Field_08: Read_port_A of temp_regs
output   [2:0] u_f09;              // Field_09: Read_port_B of temp_regs
output   [2:0] u_f10;              // Field_10: Write_port_A of temp_reg SEL
output   [2:0] u_f11;              // Field_11: Write_port_A of temp_reg WT
output   [1:0] u_f12;              // Field_12: Write_port_B0 of temp_reg SEL
output   [1:0] u_f13;              // Field_13: Write_port_B1 of temp_reg SEL
output   [1:0] u_f14;              // Field_14: Write_port_B0 of temp_reg WT
output         u_f15;              // Field_15: Write_port_B1 of temp_reg WT
output   [1:0] u_f16;              // Field_16: Sel reg2/3/6->dat/stk cache
output   [1:0] u_f17;              // field_17: IU_adder operations
output  [11:0] u_f18;              // field_18: Branching in ucode
output   [3:0] u_f19;              // field_19: Mem_adder a_operand
output   [3:0] u_f20;              // field_20: Mem_adder b_operand
output   [1:0] u_f21;              // field_21: Mem_adder operations
output         u_f22;              // field_22: Sel stack_cache address
output   [1:0] u_f23;              // field_23: Sel alu_adder input port_a


// ------------- declarations ---------------------------------------------

wire     [1:0] u_f00;
wire     [2:0] u_f01;
wire     [1:0] u_f02;
wire     [1:0] u_f03, u_f03_i;
wire     [6:0] u_f04;
wire     [2:0] u_f05;
wire     [3:0] u_f06;
wire     [2:0] u_f07;
wire     [2:0] u_f08;
wire     [2:0] u_f09;
wire     [2:0] u_f10;
wire     [2:0] u_f11;
wire     [1:0] u_f12;
wire     [1:0] u_f13;
wire     [1:0] u_f14;
wire           u_f15;
wire     [1:0] u_f16;
wire     [1:0] u_f17;
wire    [11:0] u_f18;
wire     [3:0] u_f19;
wire     [3:0] u_f20;
wire     [1:0] u_f21;
wire           u_f22;
wire     [1:0] u_f23;

wire [(`ROM_BITS-1):0] fxx_default;
wire [(`ROM_BITS-1):0] fxx;
wire [(`ROM_BITS-1):0] nxt_u_fxx;
wire [(`ROM_BITS-1):0] reg_u_fxx;
wire [(`ROM_BITS-1):0] d_reg_u_fxx;


/*********** Ucode data path registers ***************************************/
  assign fxx_default = { {(`ROM_BITS-`USED_BITS){1'b0}},
                        `F00_DEFAULT,`F01_DEFAULT,`F02_DEFAULT,`F03_DEFAULT,
                        `F04_DEFAULT,`F05_DEFAULT,`F06_DEFAULT,`F07_DEFAULT,
                        `F08_DEFAULT,`F09_DEFAULT,`F10_DEFAULT,`F11_DEFAULT,
                        `F12_DEFAULT,`F13_DEFAULT,`F14_DEFAULT,`F15_DEFAULT,
                        `F16_DEFAULT,`F17_DEFAULT,`F18_DEFAULT,`F19_DEFAULT,
                        `F20_DEFAULT,`F21_DEFAULT,`F22_DEFAULT,`F23_DEFAULT};

  assign fxx = { {(`ROM_BITS-`USED_BITS){1'b0}}, rom_fxx };

  assign {u_f00,u_f01,u_f02,u_f03_i,u_f04,u_f05,u_f06,u_f07,
          u_f08,u_f09,u_f10,u_f11,  u_f12,u_f13,u_f14,u_f15,
          u_f16,u_f17,u_f18,u_f19,  u_f20,u_f21,u_f22,u_f23}
         = reg_u_fxx[(`USED_BITS-1):0]; 

  del1_32 del1_32_0 ( .inp(reg_u_fxx[31:0]),  .out(d_reg_u_fxx[31:0])  );
  del1_32 del1_32_1 ( .inp(reg_u_fxx[63:32]), .out(d_reg_u_fxx[63:32]) );
  del1_16 del1_16_2 ( .inp(reg_u_fxx[(`ROM_BITS-1):64]),
                                                .out(d_reg_u_fxx[(`ROM_BITS-1):64]) );

  //  assign nxt_u_fxx = test_mode ? fxx : sel_fxx_default ? fxx_default :
  //                     ie_stall_ucode  ? reg_u_fxx   : fxx;
  wire [(`ROM_BITS-1):0] ie_stall_ucode_data; 
  wire ie_stall_ucode_sel = ie_stall_ucode & !test_mode; 
  mux2_32 ie_stall_ucode_data0_mux (
                              .out(ie_stall_ucode_data[31:0]),
                              .in1(d_reg_u_fxx[31:0]),
                              .in0(fxx[31:0]),
                              .sel({ie_stall_ucode_sel,~ie_stall_ucode_sel}));
  mux2_32 ie_stall_ucode_data1_mux (
                              .out(ie_stall_ucode_data[63:32]),
                              .in1(d_reg_u_fxx[63:32]),
                              .in0(fxx[63:32]),
                              .sel({ie_stall_ucode_sel,~ie_stall_ucode_sel}));
  mux2_16 ie_stall_ucode_data2_mux (
                              .out(ie_stall_ucode_data[(`ROM_BITS-1):64]),
                              .in1(d_reg_u_fxx[(`ROM_BITS-1):64]),
                              .in0(fxx[(`ROM_BITS-1):64]),
                              .sel({ie_stall_ucode_sel,~ie_stall_ucode_sel}));

  wire sel_fxx_default_sel = sel_fxx_default & !test_mode;
  mux2_32 nxt_u_fxx0_mux (.out(nxt_u_fxx[31:0]),
                          .in1(fxx_default[31:0]),
                          .in0(ie_stall_ucode_data[31:0]),
                          .sel({sel_fxx_default_sel,~sel_fxx_default_sel}));
  mux2_32 nxt_u_fxx1_mux (.out(nxt_u_fxx[63:32]),
                          .in1(fxx_default[63:32]),
                          .in0(ie_stall_ucode_data[63:32]),
                          .sel({sel_fxx_default_sel,~sel_fxx_default_sel}));
  mux2_16 nxt_u_fxx2_mux (.out(nxt_u_fxx[(`ROM_BITS-1):64]),
                          .in1(fxx_default[(`ROM_BITS-1):64]),
                          .in0(ie_stall_ucode_data[(`ROM_BITS-1):64]),
                          .sel({sel_fxx_default_sel,~sel_fxx_default_sel}));

  ff_s_32 ff_s_32_1 (
                     .out(reg_u_fxx[31:0]),
                     .din(nxt_u_fxx[31:0]),
                     .clk(clk)
                    );

  ff_s_32 ff_s_32_2 (  
                     .out(reg_u_fxx[63:32]),
                     .din(nxt_u_fxx[63:32]),
                     .clk(clk)
                    );

  ff_s_16 ff_s_16_1 (
                     .out(reg_u_fxx[(`ROM_BITS-1):64]),
                     .din(nxt_u_fxx[(`ROM_BITS-1):64]),
                     .clk(clk)
                    );
 
  assign u_f03[0] = u_f03_i[0] & !u_abt_cur;
  assign u_f03[1] = u_f03_i[1] & !u_abt_cur;

endmodule

