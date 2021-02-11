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

module ucode_rom (
                             nxt_ucode_cnt,
                             rom_fxx 
                            );

//  `include  "../../common/ucode.h"

input    [8:0] nxt_ucode_cnt;      // next_state of_the ucode sequencer

output [(`USED_BITS-1):0] rom_fxx; // actual used rom data_out

// ------------- declarations ---------------------------------------------

// synopsys translate_off

reg      [1:0] f00;                // field_00: IU_zero_comparator
reg      [2:0] f01;                // Field_01: Ucode and StacK         WT
reg      [1:0] f02;                // Field_02: Ucode and Stack         RD
reg      [1:0] f03;                // Field_03: Ucode and Data_cache
reg      [6:0] f04;                // Field_04: Ucode and Architech_reg RD
reg      [2:0] f05;                // Field_05: Ucode and Architech_reg WT
reg      [3:0] f06;                // Field_06: Integer Unit ALU a_operand
reg      [2:0] f07;                // Field_07: Integer Unit ALU b_operand
reg      [2:0] f08;                // Field_08: Read_port_A of temp_regs
reg      [2:0] f09;                // Field_09: Read_port_B of temp_regs
reg      [2:0] f10;                // Field_10: Write_port_A of temp_reg SEL
reg      [2:0] f11;                // Field_11: Write_port_A of temp_reg WT
reg      [1:0] f12;                // Field_12: Write_port_B0 of temp_reg SEL
reg      [1:0] f13;                // Field_13: Write_port_B1 of temp_reg SEL
reg      [1:0] f14;                // Field_14: Write_port_B0 of temp_reg WT
reg            f15;                // Field_15: Write_port_B1 of temp_reg WT
reg      [1:0] f16;                // Field_16: Sel reg2/3/6->dat/stk cache
reg      [1:0] f17;                // field_17: IU_adder operations
reg     [11:0] f18;                // field_18: Branching in ucode
reg      [3:0] f19;                // field_19: Mem_adder a_operand
reg      [3:0] f20;                // field_20: Mem_adder b_operand
reg      [1:0] f21;                // field_21: Mem_adder operations
reg            f22;                // field_22: Sel stack_cache address
reg      [1:0] f23;                // field_23: Sel alu_adder input port_a

wire [(`USED_BITS-1):0] rom_fxx;   // actual used rom data_out


  assign rom_fxx = {f00,f01,f02,f03,f04,f05,f06,f07,
                    f08,f09,f10,f11,f12,f13,f14,f15,
                    f16,f17,f18,f19,f20,f21,f22,f23};

// ------------- state machine --------------------------------------------
  always @(nxt_ucode_cnt
          ) begin

    f00 = `F00_DEFAULT;
    f01 = `F01_DEFAULT;
    f02 = `F02_DEFAULT;
    f03 = `F03_DEFAULT;
    f04 = `F04_DEFAULT;
    f05 = `F05_DEFAULT;
    f06 = `F06_DEFAULT;
    f07 = `F07_DEFAULT;
    f08 = `F08_DEFAULT;
    f09 = `F09_DEFAULT;
    f10 = `F10_DEFAULT;
    f11 = `F11_DEFAULT;
    f12 = `F12_DEFAULT;
    f13 = `F13_DEFAULT;
    f14 = `F14_DEFAULT;
    f15 = `F15_DEFAULT;
    f16 = `F16_DEFAULT;
    f17 = `F17_DEFAULT;
    f18 = `F18_DEFAULT;
    f19 = `F19_DEFAULT;
    f20 = `F20_DEFAULT;
    f21 = `F21_DEFAULT;
    f22 = `F22_DEFAULT;
    f23 = `F23_DEFAULT;

      case (nxt_ucode_cnt)         //synopsys parallel_case

        `U_IDLE: begin
               end 

// ####### Ucode Operations ######################################

// ---- 9'd1 ~1/3 of arraylength ------------- Offset  9'd0 ------

// ------- start "arraylength" -----------------------------------

        9'd1:  begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK_M8;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f22 = `F22_SEL_IALU;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_1CYC_LENG;

               end

        9'd2:  begin
               end

        9'd3:  begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK_M8;
f18 = `F18_U_LAST;
 
               end

// ======= end of "arraylength" ==================================

// ---- 9'd1 ~3/5 of baload ------------------ Offset  9'd3 ------

// ------- start "baload" ----------------------------------------

        9'd4:  begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f06 = `F06_A_CONST_01;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd5:  begin

f18 = `F18_CHK_ARY_NEG;

               end

        9'd6:  begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd7:  begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd8:  begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_03;
f21 = `F21_MADD_pApB;
f03 = `F03_ARY_LD;
f01 = `F01_WT_DREG_STK;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF;
 
               end

// ======= end of "baload" =======================================

// ---- 9'd1 ~3/5 of caload ------------------ Offset  9'd8 ------

// ------- start "caload" ----------------------------------------

        9'd9:  begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f06 = `F06_A_CONST_01;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd10: begin

f18 = `F18_CHK_ARY_NEG;

               end

        9'd11: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd12: begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f06 = `F06_A_LSH1;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd13: begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_02;
f21 = `F21_MADD_pApB;
f03 = `F03_ARY_LD;
f01 = `F01_WT_DREG_STK;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF;
 
               end

// ======= end of "caload" =======================================

// ---- 9'd1 ~3/5 of iaload ------------------ Offset  9'd13 -----

// ------- start "iaload" ----------------------------------------

        9'd14: begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f06 = `F06_A_CONST_01;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd15: begin

f18 = `F18_CHK_ARY_NEG;

               end

        9'd16: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd17: begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f06 = `F06_A_LSH2;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd18: begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF;
 
               end

// ======= end of "iaload" =======================================

// ---- 9'd1 ~4/6 of laload ------------------ Offset  9'd18 -----

// ------- start "laload" ----------------------------------------

        9'd19: begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f06 = `F06_A_CONST_01;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd20: begin

f18 = `F18_CHK_ARY_NEG;

               end

        9'd21: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd22: begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f06 = `F06_A_LSH3;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd23: begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_CHK_ARY_OVF;
 
               end

        9'd24: begin
 
f16 = `F16_SEL_R2_CACHE;                  
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f01 = `F01_WT_DREG_STK;
f18 = `F18_U_LAST;

               end

// ======= end of "laload" =======================================

// ---- 9'd1 ~5/7 of bastore ----------------- Offset  9'd24 -----

// ------- start "bastore" ---------------------------------------

        9'd25: begin
 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG5_B0;

               end                                  
 
        9'd26: begin
 
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
 
               end
 
        9'd27: begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd28: begin
               end

        9'd29: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_DCACHE_BM2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd30: begin
 
f08 = `F08_RD_REG2_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_01;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd31: begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF | `F18_CHK_ARY_NEG;
 
               end

// ======= end of "bastore" ======================================

// ---- 9'd1 ~5/7 of castore ----------------- Offset  9'd31 -----

// ------- start "castore" ---------------------------------------

        9'd32: begin
 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG5_B0;

               end                                  
 
        9'd33: begin
 
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
 
               end
 
        9'd34: begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd35: begin
               end

        9'd36: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_DCACHE_BM2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd37: begin
 
f08 = `F08_RD_REG2_A;
f06 = `F06_A_LSH1;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_01;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd38: begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF | `F18_CHK_ARY_NEG;
 
               end

// ======= end of "castore" ======================================

// ---- 9'd1 ~5/7 of iastore ----------------- Offset  9'd38 -----

// ------- start "iastore" ---------------------------------------

        9'd39: begin
 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG5_B0;

               end                                  
 
        9'd40: begin
 
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
 
               end
 
        9'd41: begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd42: begin
               end

        9'd43: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_DCACHE_BM2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd44: begin
 
f08 = `F08_RD_REG2_A;
f06 = `F06_A_LSH2;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_01;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd45: begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_U_LAST | `F18_CHK_ARY_OVF | `F18_CHK_ARY_NEG;
 
               end

// ======= end of "iastore" ======================================

// ---- 9'd1 ~6/8 of lastore ----------------- Offset  9'd45 -----

// ------- start "lastore" ---------------------------------------

        9'd46: begin
 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;

               end                                  
 
        9'd47: begin
 
f02 = `F02_RD_STK;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
 
               end
 
        9'd48: begin

f02 = `F02_RD_STK;
f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd49: begin

f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd50: begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_DCACHE_BM2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd51: begin
 
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_RS1_LH3_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f19 = `F19_SEL_RS1_MA;
f20 = `F20_MB_CONST_01;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG5_B0;
 
               end

        9'd52: begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_CHK_ARY_OVF | `F18_CHK_ARY_NEG;
 
               end

        9'd53: begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R6_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;
 
               end

// ======= end of "lastore" ======================================

// ---- 9'd1 ~ 11 of invoke_static_quick ----- Offset  9'd53 -----

// ------- start "invoke_static_quick" ---------------------------

        9'd54: begin
 
f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd55: begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A; 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG6_B0;

               end

        9'd56: begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG3_A;

               end

        9'd57: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_03;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd58: begin

f19 = `F19_SEL_OPTOP_MA; 
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pAsB;   
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB; 
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd59: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;

               end

        9'd60: begin 
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_DCACHE_A;
f06 = `F06_EXTR_16_RSH0;
f09 = `F09_RD_REG6_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd61: begin

f16 = `F16_SEL_R3_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;

               end

        9'd62: begin 
 
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd63: begin

f06 = `F06_A_CONST_04; 
f09 = `F09_RD_AREG0_B; 
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB; 
f17 = `F17_IALU_sApB; 
f13 = `F13_SEL_ALU_B1; 
f15 = `F15_WT_AREG0_B1; 
f01 = `F01_WT_CONST_P_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd64: begin

f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;

               end

// ======= end of "invoke_static_quick" ==========================

// ---- 9'd1 ~ 13 of invoke_nonvirtual_quick - Offset  9'd64 -----

// ------- start "invoke_nonvirtual_quick" -----------------------

        9'd65: begin
 
f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd66: begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A; 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG6_B0;

               end

        9'd67: begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG3_A;

               end

        9'd68: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_03;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd69: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f08 = `F08_RD_DCACHE_A;
f06 = `F06_EXTR_16_RSH0;
f09 = `F09_RD_REG6_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;

               end

        9'd70: begin

f02 = `F02_RD_STK;
f19 = `F19_SEL_OPTOP_MA; 
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pAsB;   
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB; 
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd71: begin 

f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL;

               end

        9'd72: begin 

f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;

               end

        9'd73: begin 
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd74: begin

f16 = `F16_SEL_R3_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;

               end

        9'd75: begin 
 
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd76: begin

f06 = `F06_A_CONST_04; 
f09 = `F09_RD_AREG0_B; 
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB; 
f17 = `F17_IALU_sApB; 
f13 = `F13_SEL_ALU_B1; 
f15 = `F15_WT_AREG0_B1; 
f01 = `F01_WT_CONST_P_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd77: begin

f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;

               end

// ======= end of "invoke_nonvirtual_quick" ======================

// ---- 9'd1 ~ 15 of invoke_virtual_quick ---- Offset  9'd77 -----

// ------- start "invoke_virtual_quick" --------------------------

        9'd78: begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_RD_A8_LSH2_MB;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;

               end

        9'd79: begin

f02 = `F02_RD_STK;

               end

        9'd80: begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL;

               end

        9'd81: begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;

               end

        9'd82: begin
 
f19 = `F19_SEL_DCACHE_MA3;
f20 = `F20_RD_I8_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd83: begin

f06 = `F06_A_CONST_03;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd84: begin
 
f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG3_A;

               end

        9'd85: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;

               end

        9'd86: begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd87: begin
 
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;
 
               end

        9'd88: begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd89: begin

f16 = `F16_SEL_R3_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;

               end

        9'd90: begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd91: begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_CONST_P_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd92: begin
 
f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;
 
               end
 
// ======= end of "invoke_virtual_quick" =========================

// ---- 9'd1 ~ 19 of invoke_virtual_quick_w -- Offset  9'd92 -----

// ------- start "invoke_virtual_quick_w" ------------------------

        9'd93: begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd94: begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;

               end

        9'd95: begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd96: begin

               end

        9'd97: begin
 
f08 = `F08_RD_DCACHE_A;
f06 = `F06_EXTR_16_RSH0;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;

               end

        9'd98: begin

f02 = `F02_RD_STK;
f08 = `F08_RD_DCACHE_A;
f06 = `F06_EXTR_16_RSH16;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd99: begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL;

               end

        9'd100:begin
 
f08 = `F08_RD_REG2_A;
f06 = `F06_A_LSH2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd101:begin
 
f19 = `F19_SEL_DCACHE_MA3;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd102:begin

f06 = `F06_A_CONST_03;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd103:begin
 
f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG3_A;

               end

        9'd104:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;

               end

        9'd105:begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd106:begin
 
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;
 
               end

        9'd107:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd108:begin

f16 = `F16_SEL_R3_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;

               end

        9'd109:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd110:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_CONST_P_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd111:begin
 
f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;
 
               end
 
// ======= end of "invoke_virual_quick_w" ========================

// ---- 9'd1 ~ 21 of invoke_super_quick ------ Offset  9'd111 ----

// ------- start "invoke_super_quick" ----------------------------

        9'd112:begin

f06 = `F06_A_CONST_16;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd113:begin
 
f02 = `F02_RD_STK;
f06 = `F06_A_CONST_32;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
 
               end
 
        9'd114:begin
 
f19 = `F19_SEL_RS1_MA;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
 
               end

        9'd115:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_REG5_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd116:begin

f19 = `F19_SEL_DCACHE_MA;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd117:begin

f06 = `F06_A_CONST_32;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd118:begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd119:begin

f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;

               end

        9'd120:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd121:begin

f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A; 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG6_B0;

               end

        9'd122:begin

f19 = `F19_SEL_DCACHE_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG3_A;

               end

        9'd123:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_03;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd124:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f08 = `F08_RD_DCACHE_A;
f06 = `F06_EXTR_16_RSH0;
f09 = `F09_RD_REG6_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;

               end

        9'd125:begin

f02 = `F02_RD_STK;
f19 = `F19_SEL_OPTOP_MA; 
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pAsB;   
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB; 
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd126:begin 

f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL;

               end

        9'd127:begin 

f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;

               end

        9'd128:begin 
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd129:begin

f16 = `F16_SEL_R3_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_28;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;

               end

        9'd130:begin 
 
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd131:begin

f06 = `F06_A_CONST_04; 
f09 = `F09_RD_AREG0_B; 
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB; 
f17 = `F17_IALU_sApB; 
f13 = `F13_SEL_ALU_B1; 
f15 = `F15_WT_AREG0_B1; 
f01 = `F01_WT_CONST_P_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd132:begin

f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;

               end

// ======= end of "invoke_super_quick" ===========================

// ---- 9'd1 ~  8 of return ------------------ Offset  9'd132 ----

// ------- start "return" ----------------------------------------

        9'd133:begin
 
f06 = `F06_A_CONST_16;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd134:begin
 
f04 = `F04_RD_FRAME;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;
 
               end
 
        9'd135:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
 
               end

        9'd136:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;
 
               end

        9'd137:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_FRAME;
 
               end

        9'd138:begin 
  
f02 = `F02_RD_STK;  
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG1_A;
f05 = `F05_WT_V_OPTOP;
  
               end

        9'd139:begin
 
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;
 
               end

        9'd140:begin
 
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;
 
               end

// ======= end of "return" =======================================

// ---- 9'd1 ~  8 of ireturn ----------------- Offset  9'd140 ----

// ------- start "ireturn" ---------------------------------------

        9'd141:begin
 
f06 = `F06_A_CONST_16;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd142:begin
 
f04 = `F04_RD_FRAME;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;
 
               end
 
        9'd143:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
 
               end

        9'd144:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;
 
               end

        9'd145:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f06 = `F06_A_CONST_04;
f04 = `F04_RD_VARS;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_FRAME;
 
               end

        9'd146:begin 
  
f06 = `F06_A_CONST_04;
f09 = `F09_RD_REG5_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;  
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;
  
               end

        9'd147:begin
 
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;
 
               end

        9'd148:begin
 
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;
 
               end

// ======= end of "ireturn" ======================================

// ---- 9'd1 ~ 8  of lreturn ----------------- Offset  9'd148 ----

// ------- start "lreturn" ---------------------------------------

        9'd149:begin
 
f06 = `F06_A_CONST_16;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd150:begin
 
f04 = `F04_RD_FRAME;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;
 
               end
 
        9'd151:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG3_A;
 
               end

        9'd152:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;
 
               end

        9'd153:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f06 = `F06_A_CONST_08;
f04 = `F04_RD_VARS;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_FRAME;
 
               end

        9'd154:begin 
  
f06 = `F06_A_CONST_04;
f09 = `F09_RD_REG5_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;  
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_OPTOP;
  
               end

        9'd155:begin
 
f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;
 
               end

        9'd156:begin
 
f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_CONST_P;
f18 = `F18_U_LAST;
 
               end

// ======= end of "lreturn" ======================================

// ---- 9'd1 ~  3 of call -------------------- Offset  9'd156 ----

// ------- start "call" ------------------------------------------

        9'd157:begin

f23 = `F23_SEL_RS1_LH2_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
f04 = `F04_RD_PC;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_02;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_RS2_A;
f05 = `F05_WT_A_PC;

               end

        9'd158:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_VARS;

               end

        9'd159:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;

               end

// ======= end of "call" =========================================

// ---- 9'd1 ~  4 of return0 ----------------- Offset  9'd159 ----

// ------- start "return0" ---------------------------------------

        9'd160:begin

f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;

               end

        9'd161:begin

f05 = `F05_WT_V_OPTOP;

               end

        9'd162:begin
 
f08 = `F08_RD_RS2_A;
f05 = `F05_WT_A_VARS;
 
               end

        9'd163:begin
 
f18 = `F18_U_LAST;
 
               end

// ======= end of "return0" ======================================

// ---- 9'd1 ~  4 of return1 ----------------- Offset  9'd163 ----

// ------- start "return1" ---------------------------------------

        9'd164:begin

f06 = `F06_A_CONST_12;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f04 = `F04_RD_VARS;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
f08 = `F08_RD_RS2_A;
f05 = `F05_WT_A_PC;

               end

        9'd165:begin

f06 = `F06_A_CONST_00;
f04 = `F04_RD_VARS;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;

               end

        9'd166:begin

f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd167:begin
 
f18 = `F18_U_LAST;
 
               end

// ======= end of "return1" ======================================

// ---- 9'd1 ~  5 of return2 ----------------- Offset  9'd167 ----

// ------- start "return2" ---------------------------------------
 
        9'd168:begin

f06 = `F06_A_CONST_12;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f04 = `F04_RD_VARS;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;

               end

        9'd169:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;

               end

        9'd170:begin

f06 = `F06_A_CONST_04;
f04 = `F04_RD_VARS;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;

               end

        9'd171:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG2_A;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_VARS;

               end

        9'd172:begin
 
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "return2" ======================================

// ---- 9'd1 ~ 12 of tableswitch ------------- Offset  9'd172 ----

// ------- start "tableswitch" -----------------------------------

        9'd173:begin

f06 = `F06_A_CONST_04;
f04 = `F04_RD_PC;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;

               end

        9'd174:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd175:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd176:begin 
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_B;
f06 = `F06_A_U_PORTA;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG0_A;
  
               end

        9'd177:begin 
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;  
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_DCACHE_A;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_sApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_DCACHE_B0;
f14 = `F14_WT_REG5_B0;

               end

        9'd178:begin

f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
f08 = `F08_RD_REG0_A;
f05 = `F05_WT_A_PC;
 
               end

        9'd179:begin

f19 = `F19_SEL_AREG0_MA;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f09 = `F09_RD_RS1_B;
f08 = `F08_RD_REG5_A;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_sApB;
f18 = `F18_CHK_LS_BRANCH1;

               end

        9'd180:begin

f19 = `F19_SEL_AREG0_MA;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f09 = `F09_RD_RS1_B;
f08 = `F08_RD_DCACHE_A;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1;
f17 = `F17_IALU_pAsB;
f18 = `F18_CHK_LS_BRANCH2;
 
               end

        9'd181:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
 
               end

        9'd182:begin
               end

        9'd183:begin

f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;

               end

        9'd184:begin
 
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_PC;
f18 = `F18_U_LAST;

               end

// ======= end of "tableswitch" ==================================

// ---- 9'd1 ~  6 of checkcast_quick --------- Offset  9'd184 ----

// ------- start "checkcast_quick" -------------------------------

        9'd185:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_EQ_BRANCH;

               end

        9'd186:begin
 
f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
 
               end
 
        9'd187:begin

f19 = `F19_SEL_DCACHE_MA3;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;

               end

        9'd188:begin

f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG0_A;
 
               end
 
        9'd189:begin
 
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
 
               end

        9'd190:begin

f08 = `F08_RD_REG5_A;
f00 = `F00_A_COMP_ZERO;
f18 = `F18_U_LAST | `F18_CHK_PTR_TRAP;

               end

// ======= end of "checkcast_quick" ==============================

// ---- 9'd1 ~  7 of instanceof_quick -------- Offset  9'd190 ----

// ------- start "instanceof_quick" ------------------------------

        9'd191:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_EQ_BRANCH;

               end

        9'd192:begin
 
f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
 
               end
 
        9'd193:begin

f19 = `F19_SEL_DCACHE_MA3;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_01;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;

               end

        9'd194:begin

f10 = `F10_SEL_DCACHE_A;
f11 = `F11_WT_REG0_A;
 
               end
 
        9'd195:begin
 
f08 = `F08_RD_REG0_A;
f09 = `F09_RD_DCACHE_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
 
               end

        9'd196:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG5_A;
f00 = `F00_A_COMP_ZERO;
f18 = `F18_CHK_PTR_TRAP;

               end

        9'd197:begin

f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;

               end

// ======= end of "instanceof_quick" =============================

// ---- 9'd1 ~  3 of "exit_sync_method" ------ Offset  9'd197 ----

// ------- start "exit_sync_method" ------------------------------

        9'd198:begin
 
f04 = `F04_RD_FRAME;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd199:begin
 
f22 = `F22_SEL_AREG0;
f02 = `F02_RD_STK;

               end

        9'd200:begin
 
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;
f18 = `F18_U_LAST;
 
               end

// ======= end of "exit_sync_method" =============================

// ---- 9'd1 ~  3 of get_current_class ------- Offset  9'd200 ----

// ------- start "get_current_class" -----------------------------

        9'd201:begin

f06 = `F06_A_CONST_16;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd202:begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f06 = `F06_A_CONST_32;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_CONST_00;
f17 = `F17_IALU_pApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG2_A;
 
               end
 
        9'd203:begin
 
f19 = `F19_SEL_RS1_MA;
f16 = `F16_SEL_R2_CACHE;
f20 = `F20_SEL_PORTC_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "get_current_class" ============================

// ---- 9'd1 ~  3 of "dup_x1 " --------------- Offset  9'd203 ----

// ------- start "dup_x1" ----------------------------------------

        9'd204:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd205:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_12;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd206:begin

f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "dup_x1" =======================================

// ---- 9'd1 ~  4 of "dup_x2 " --------------- Offset  9'd206 ----

// ------- start "dup_x2" ----------------------------------------

        9'd207:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_16;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd208:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_12;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK_REG0;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd209:begin
 
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd210:begin

f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "dup_x2" =======================================

// ---- 9'd1 ~  2 of "dup2" ------------------ Offset  9'd210 ----

// ------- start "dup2" ------------------------------------------

        9'd211:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd212:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;

               end

// ======= end of "dup2" =========================================

// ---- 9'd1 ~  5 of "dup2_x1" --------------- Offset  9'd212 ----

// ------- start "dup2_x1" ---------------------------------------

        9'd213:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd214:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f02 = `F02_RD_STK_REG0;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd215:begin
 
f06 = `F06_A_CONST_12;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_16;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd216:begin
 
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd217:begin

f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "dup2_x1" ======================================

// ---- 9'd1 ~  6 of "dup2_x2" --------------- Offset  9'd217 ----

// ------- start "dup2_x2" ---------------------------------------

        9'd218:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_20;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd219:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f02 = `F02_RD_STK_REG0;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd220:begin
 
f06 = `F06_A_CONST_12;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd221:begin
 
f19 = `F19_SEL_OPTOP_MA;
f20 = `F20_MB_CONST_16;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK_REG0;
f16 = `F16_SEL_R3_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd222:begin
 
f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;
 
               end

        9'd223:begin

f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "dup2_x2" ======================================

// ---- 9'd1 ~  2 of "swap" ------------------ Offset  9'd223 ----

// ------- start "swap" ------------------------------------------

        9'd224:begin

f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_RS1_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd225:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f22 = `F22_SEL_IALU;
f16 = `F16_SEL_R6_CACHE;
f01 = `F01_WT_R236_STK;
f18 = `F18_U_LAST;

               end

// ======= end of "swap" =========================================

// ---- 9'd1 ~  1 of "ldc_quick" ------------- Offset  9'd225 ----

// ------- start "ldc_quick" -------------------------------------
 
        9'd226:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I8_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;

               end

// ======= end of "ldc_quick" ====================================

// ---- 9'd1 ~  1 of "ldc_w_quick" ----------- Offset  9'd226 ----

// ------- start "ldc_w_quick" -----------------------------------

        9'd227:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;

               end

// ======= end of "ldc_w_quick" ==================================
 
// ---- 9'd1 ~  2 of "ldc2_w_quick" ---------- Offset  9'd227 ----
 
// ------- start "ldc2_w_quick" ----------------------------------

        9'd228:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;

               end

        9'd229:begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;    
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;
 
               end

// ======= end of "ldc2_w_quick" =================================
 
// ---- 9'd1 ~1/4 of "get_field_quick" ------- Offset  9'd229 ----
 
// ------- start "get_field_quick" -------------------------------

        9'd230:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_1CYC_DONE;

               end

        9'd231:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd232:begin

f08 = `F08_RD_REG0_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd233:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;
 
               end

// ======= end of "get_field_quick" ==============================
 
// ---- 9'd1 ~1/4 of "put_field_quick" ------- Offset  9'd233 ----
 
// ------- start "put_field_quick" -------------------------------

        9'd234:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_1CYC_DONE;

               end

        9'd235:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd236:begin

f08 = `F08_RD_REG0_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd237:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;
 
               end

// ======= end of "put_field_quick" ==============================
 
// ---- 9'd1 ~2/5 of "get_field2_quick" ------ Offset  9'd237 ----
 
// ------- start "get_field2_quick" ------------------------------

        9'd238:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE2 | `F18_CHK_ABT_RDWT;

               end

        9'd239:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;

               end

        9'd240:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd241:begin

f08 = `F08_RD_REG0_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd242:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
 
               end

        9'd243:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f22 = `F22_SEL_IALU;
f18 = `F18_U_LAST;

               end

// ======= end of "get_field2_quick" =============================
 
// ---- 9'd1 ~3/5 of "put_field2_quick" ------ Offset  9'd243 ----
 
// ------- start "put_field2_quick" ------------------------------

        9'd244:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_RS2_A;
f00 = `F00_RS2_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE_P | `F18_CHK_ABT_RDWT;

               end

        9'd245:begin

f13 = `F13_SEL_PASS_A_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;

               end
 
        9'd246:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;

               end

        9'd247:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;

               end

        9'd248:begin

f08 = `F08_RD_REG0_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd249:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd250:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;

               end

// ======= end of "put_field2_quick" =============================

// ---- 9'd1 ~  3 of "getstatic_quick" ------- Offset  9'd250 ----
 
// ------- start "get_static_quick" ------------------------------

        9'd251:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd252:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd253:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "get_static_quick" =============================
 
// ---- 9'd1 ~  3 of "put_static_quick" ------ Offset  9'd253 ----
 
// ------- start "put_static_quick" ------------------------------

        9'd254:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd255:begin
               end

        9'd256:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;
 
               end

// ======= end of "put_static_quick" =============================
 
// ---- 9'd1 ~  4 of "get_static2_quick" ----- Offset  9'd256 ----
 
// ------- start "get_static2_quick" -----------------------------

        9'd257:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;

               end

        9'd258:begin

f06 = `F06_A_CONST_04;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd259:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;
 
               end

        9'd260:begin
 
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f01 = `F01_WT_DREG_STK;
f18 = `F18_U_LAST;
 
               end

// ======= end of "get_static2_quick" ============================
 
// ---- 9'd1 ~  4 of "put_static2_quick" ----- Offset  9'd260 ----
 
// ------- start "put_static2_quick" -----------------------------

        9'd261:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;

               end

        9'd262:begin
               end

        9'd263:begin
 
f19 = `F19_SEL_DCACHE_MA2;                  
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
 
               end

        9'd264:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R6_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;
 
               end

// ======= end of "put_static2_quick" ============================

// ---- 9'd1 ~  4 of "aput_field_quick" ------ Offset  9'd264 ----
 
// ------- start "aput_field_quick" ------------------------------

        9'd265:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG0_A;
f08 = `F08_RD_RS2_A;
f09 = `F09_RD_RS1_B;
f04 = `F04_RD_GC_CONF;
f00 = `F00_RS2_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_1CYC_DONE | `F18_CHK_GC;

               end

        9'd266:begin

f19 = `F19_SEL_RS2_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd267:begin

f08 = `F08_RD_REG0_A;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pAsB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;

               end

        9'd268:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_SEL_DCACHE_MB;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f18 = `F18_U_LAST;
 
               end

// ======= end of "aput_field_quick" =============================

// ---- 9'd1 ~  3 of "aput_static_quick" ----- Offset  9'd268 ----
 
// ------- start "aput_static_quick" -----------------------------

        9'd269:begin

f04 = `F04_RD_CONST_P;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_RD_I16_LSH2_MB;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG6_B0;

               end

        9'd270:begin
               end

        9'd271:begin
 
f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_RS1_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_DCACHE_A;
f09 = `F09_RD_RS1_B;
f04 = `F04_RD_GC_CONF;
f18 = `F18_U_LAST | `F18_CHK_GC;
 
               end

// ======= end of "aput_static_quick" ============================

// ---- 9'd1 ~  8 of "priv_ret_from_trap" ---- Offset  9'd271 ----
 
// ------- start "priv_ret_from_trap" ----------------------------

        9'd272:begin
 
f06 = `F06_A_CONST_12;
f04 = `F04_RD_FRAME;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_ARCH;
f17 = `F17_IALU_sApB;
f10 = `F10_SEL_ALU_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd273:begin
 
f04 = `F04_RD_FRAME;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_OPTOP;
 
               end
 
        9'd274:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pAsB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
 
               end

        9'd275:begin

f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PC;
 
               end

        9'd276:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_08;
f21 = `F21_MADD_pApB;
f13 = `F13_SEL_MA_B1;
f15 = `F15_WT_AREG0_B1;
f02 = `F02_RD_STK;
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_FRAME;
 
               end

        9'd277:begin 
  
f02 = `F02_RD_STK;  
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG1_A;
f05 = `F05_WT_V_OPTOP;
  
               end

        9'd278:begin
 
f08 = `F08_RD_REG1_A;
f05 = `F05_WT_A_VARS;
 
               end

        9'd279:begin
 
f08 = `F08_RD_RS1_A;
f05 = `F05_WT_A_PSR;
f18 = `F18_U_LAST;
 
               end

// ======= end of "priv_ret_from_trap" ===========================
 
// ---- 9'd1 ~  5 of "iu_trap_r" ------------- Offset  9'd279 ----
 
// ------- start "iu_trap_r" -------------------------------------

        9'd280:begin 

f06 = `F06_A_CONST_16;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f04 = `F04_RD_PC;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG2_A;

               end

        9'd281:begin 

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f04 = `F04_RD_PSR;
f19 = `F19_SEL_ARCH_MA_54; 
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB; 
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG3_A;
f12 = `F12_SEL_ALU_B0;
f14 = `F14_WT_REG5_B0;
f01 = `F01_WT_PSR_STK;
 
               end

        9'd282:begin 

f06 = `F06_A_CONST_08;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f04 = `F04_RD_TBR;
f19 = `F19_SEL_ARCH_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pAsB;
f03 = `F03_RD_DCACHE;
f08 = `F08_RD_REG3_A;
f05 = `F05_WT_A_PSR;
f16 = `F16_SEL_R2_CACHE;
f01 = `F01_WT_R236_STK;

               end

        9'd283:begin

f06 = `F06_A_CONST_04;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f01 = `F01_WT_FRAME_STK;
f08 = `F08_RD_REG5_A;
f05 = `F05_WT_A_FRAME;

               end

        9'd284:begin 
 
f01 = `F01_WT_VARS_STK;
f08 = `F08_RD_DCACHE_A;
f05 = `F05_WT_A_PC;
f18 = `F18_U_LAST;

               end

// ======= end of "iu_trap_r" ====================================

// ---- 9'd1 ~  8 of "aastore_quick" --------- Offset  9'd284 ----

// ------- start "aastore_quick" ---------------------------------

        9'd285:begin
 
f06 = `F06_A_CONST_00;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_OPTOP;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f10 = `F10_SEL_RS2_A;
f11 = `F11_WT_REG2_A;
f12 = `F12_SEL_RS2_B0;
f14 = `F14_WT_REG5_B0;

               end                                  
 
        9'd286:begin
 
f02 = `F02_RD_STK;
f10 = `F10_SEL_RS1_A;
f11 = `F11_WT_REG3_A;
f12 = `F12_SEL_RS1_B0;
f14 = `F14_WT_REG6_B0;
 
               end
 
        9'd287:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_04;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_08;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_RS1_M2;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f08 = `F08_RD_RS1_A;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_NULL | `F18_CHK_HANDLE;

               end

        9'd288:begin
               end

        9'd289:begin

f19 = `F19_SEL_DCACHE_MA2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f06 = `F06_A_CONST_04;
f09 = `F09_RD_DCACHE_BM2;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f18 = `F18_CHK_ARY_NEG;
 
               end

        9'd290:begin
 
f08 = `F08_RD_REG2_A;
f06 = `F06_A_LSH2;
f09 = `F09_RD_AREG0_B;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_pApB;
f13 = `F13_SEL_ALU_B1;
f15 = `F15_WT_AREG0_B1;
f16 = `F16_SEL_R2_CACHE;
f19 = `F19_SEL_PORTC_MA;
f20 = `F20_MB_CONST_01;
f21 = `F21_MADD_pApB;
f10 = `F10_SEL_MA_A;
f11 = `F11_WT_REG1_A;
 
               end

        9'd291:begin
 
f08 = `F08_RD_REG1_A;
f09 = `F09_RD_DCACHE_BM8;
f23 = `F23_SEL_IALU_A;
f07 = `F07_B_U_PORTB;
f17 = `F17_IALU_sApB;
f18 = `F18_CHK_ARY_OVF | `F18_CHK_ARY_NEG;
 
               end

        9'd292:begin
 
f19 = `F19_SEL_AREG0_MA;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f16 = `F16_SEL_R3_CACHE;
f03 = `F03_WT_DCACHE;
f08 = `F08_RD_RS1_A;
f09 = `F09_RD_REG6_B;
f04 = `F04_RD_GC_CONF;
f18 = `F18_U_LAST | `F18_CHK_GC;
 
               end

// ======= end of "aastore_quick" ================================

// ---- 9'd1 ~  3 of "monitorenter" ---------- Offset  9'd292 ----
 
// ------- start "monitorenter" -----------------------------------

        9'd293:begin

f19 = `F19_SEL_RS1_MA_M2;
f20 = `F20_MB_CONST_00;
f21 = `F21_MADD_pApB;
f03 = `F03_RD_DCACHE;
f00 = `F00_RS1_COMP_ZERO;
f18 = `F18_CHK_EQ_BRANCH;

               end

        9'd294:begin
               end

        9'd295:begin

f18 = `F18_U_LAST;

               end

// ======= end of "monitorenter" =================================

// ---- 9'd1 ~  8 of "return2" --------------- Offset  9'd295 ----

// ------- start "return2" ---------------------------------------

        9'd296:begin 
                 // next new instruction
               end

// ======= end of "return2" ======================================


// ####### Final Default #########################################
        default: begin
          f00 = `F00_DEFAULT;
          f01 = `F01_DEFAULT;
          f02 = `F02_DEFAULT;
          f03 = `F03_DEFAULT;
          f04 = `F04_DEFAULT;
          f05 = `F05_DEFAULT;
          f06 = `F06_DEFAULT;
          f07 = `F07_DEFAULT;
          f08 = `F08_DEFAULT;
          f09 = `F09_DEFAULT;
          f10 = `F10_DEFAULT;
          f11 = `F11_DEFAULT;
          f12 = `F12_DEFAULT;
          f13 = `F13_DEFAULT;
          f14 = `F14_DEFAULT;
          f15 = `F15_DEFAULT;
          f16 = `F16_DEFAULT;
          f17 = `F17_DEFAULT;
          f18 = `F18_DEFAULT;
          f19 = `F19_DEFAULT;
          f20 = `F20_DEFAULT;
          f21 = `F21_DEFAULT;
          f22 = `F22_DEFAULT;
          f23 = `F23_DEFAULT;

          $display("Warning: at%d, rom_ucode.v, UNknown nxt_ucode_cnt=%d",
                    $time, nxt_ucode_cnt);
                 end
      endcase

  end // end the state machine's always

// synopsys translate_on

endmodule

