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

module ucode_dec (
                  opcode_1_op_r,
                  opcode_2_op_r,
                  valid_op_r,
                  iu_trap_r,
                  next_addr,
                  u_done_l,
                  rom_addr,
                  ucode_in_r,
                  sel_wd_inc_r,
                  sel_offset_add1_r
                 );

//  `include  "../../../common/ucode.h"

input    [7:0] opcode_1_op_r;      // top first  byte of ibuffer of R_stage
input    [7:0] opcode_2_op_r;      // top second byte of ibuffer of R_stage
input          valid_op_r;         // the opcode is valid        of R_stage
input          iu_trap_r;          // IU issue trap operation    of R_stage

input    [8:0] next_addr;          // ucode calculated rom_addr  of E_stage
input          u_done_l;           // the ucode is done, active low

output   [8:0] rom_addr;           // next_state of the ucode sequencer
output         ucode_in_r;         // valid ucode opcode         of R_stage
output         sel_wd_inc_r;       // select {index_byte1,index_byte2} + 1
output         sel_offset_add1_r;  // select (offset+1) as the offset

reg      [8:0] rom_start;
wire     [8:0] rom_start_r;        // ucode_ROM start address    of R_stage
wire     [8:0] rom_addr;           // next_state of the ucode sequencer

  always @(opcode_1_op_r or opcode_2_op_r or valid_op_r ) begin

    casex({valid_op_r,opcode_1_op_r,opcode_2_op_r}) //synopsys parallel_case
      17'h12exx: rom_start = `IALOAD     ;
      17'h12fxx: rom_start = `LALOAD     ;
      17'h130xx: rom_start = `FALOAD     ;
      17'h131xx: rom_start = `DALOAD     ;
      17'h132xx: rom_start = `AALOAD     ;
      17'h133xx: rom_start = `BALOAD     ;
      17'h134xx: rom_start = `CALOAD     ;
      17'h135xx: rom_start = `SALOAD     ;
      17'h14fxx: rom_start = `IASTORE    ;
      17'h150xx: rom_start = `LASTORE    ;
      17'h151xx: rom_start = `FASTORE    ;
      17'h152xx: rom_start = `DASTORE    ;
      17'h154xx: rom_start = `BASTORE    ;
      17'h155xx: rom_start = `CASTORE    ;
      17'h156xx: rom_start = `SASTORE    ;
      17'h1bexx: rom_start = `ARRAYLENGTH;
	
      17'h1acxx: rom_start = `IRETURN;
      17'h1adxx: rom_start = `LRETURN;
      17'h1aexx: rom_start = `FRETURN;
      17'h1afxx: rom_start = `DRETURN;
      17'h1b0xx: rom_start = `ARETURN;
      17'h1b1xx: rom_start = `RETURN ;

      17'h1d6xx: rom_start = `INVOKEVIRTUAL_QUICK    ;
      17'h1d7xx: rom_start = `INVOKENONVIRTUAL_QUICK ;
      17'h1d8xx: rom_start = `INVOKESUPER_QUICK      ;
      17'h1d9xx: rom_start = `INVOKESTATIC_QUICK     ;
      17'h1e2xx: rom_start = `INVOKEVIRTUAL_QUICK_W  ;

      17'h1aaxx: rom_start = `TABLESWITCH     ;
      17'h1e0xx: rom_start = `CHECKCAST_QUICK ;
      17'h1e1xx: rom_start = `INSTANCEOF_QUICK;
      17'h1ecxx: rom_start = `EXIT_SYNC_METHOD;

      17'h1ff37: rom_start = `GET_CUR_CLASS;
      17'h1ff3d: rom_start = `CALL         ;
      17'h1ff0d: rom_start = `RETURN0      ;
      17'h1ff1d: rom_start = `RETURN1      ;
      17'h1ff2d: rom_start = `RETURN2      ;

      17'h15axx: rom_start = `DUP_X1 ;
      17'h15bxx: rom_start = `DUP_X2 ;
      17'h15cxx: rom_start = `DUP2   ;
      17'h15dxx: rom_start = `DUP2_X1;
      17'h15exx: rom_start = `DUP2_X2;
      17'h15fxx: rom_start = `SWAP   ;

      17'h1cbxx: rom_start = `LDC_QUICK        ;
      17'h1ccxx: rom_start = `LDC_W_QUICK      ;
      17'h1cdxx: rom_start = `LDC2_W_QUICK     ;
      17'h1cexx: rom_start = `GET_FIELD_QUICK  ;
      17'h1cfxx: rom_start = `PUT_FIELD_QUICK  ;
      17'h1d0xx: rom_start = `GET_FIELD2_QUICK ;
      17'h1d1xx: rom_start = `PUT_FIELD2_QUICK ;
      17'h1d2xx: rom_start = `GET_STATIC_QUICK ;
      17'h1d3xx: rom_start = `PUT_STATIC_QUICK ;
      17'h1d4xx: rom_start = `GET_STATIC2_QUICK;
      17'h1d5xx: rom_start = `PUT_STATIC2_QUICK;
      17'h1e6xx: rom_start = `AGET_FIELD_QUICK ;
      17'h1e7xx: rom_start = `APUT_FIELD_QUICK ;
      17'h1e8xx: rom_start = `AGET_STATIC_QUICK;
      17'h1e9xx: rom_start = `APUT_STATIC_QUICK;
      17'h1eaxx: rom_start = `ALDC_QUICK       ;
      17'h1ebxx: rom_start = `ALDC_W_QUICK     ;
 
      17'h1ff05: rom_start = `PRI_RET_FR_TRAP;
      17'h1dcxx: rom_start = `AASTORE_QUICK;
      17'h1c2xx: rom_start = `MONITORENTER;

      default:   rom_start = `DEFAULT_ADDR;

    endcase

  end

  assign rom_start_r[8:0] = rom_start[8:0] | ({9{iu_trap_r}} & `IU_TRAP);

  assign rom_addr[8:0]    = !u_done_l ? rom_start_r[8:0] : next_addr[8:0];

  assign ucode_in_r       = (|rom_start_r[8:0]);

  assign sel_wd_inc_r      = (opcode_1_op_r==8'he6) ||       // AGET_FIELD_QUICK
                             (opcode_1_op_r==8'he7);         // APUT_FIELD_QUICK

  assign sel_offset_add1_r = (opcode_1_op_r==8'hce) ||       // GET_FIELD_QUICK
                             (opcode_1_op_r==8'hcf) ||       // PUT_FIELD_QUICK
                             (opcode_1_op_r==8'hd0) ||       // GET_FIELD2_QUICK
                             (opcode_1_op_r==8'hd1) ||       // PUT_FIELD2_QUICK
                             (opcode_1_op_r==8'he6) ||       // AGET_FIELD_QUICK
                             (opcode_1_op_r==8'he7);         // APUT_FIELD_QUICK

endmodule
	
// ======== UCODE_ADD =============================================================
module ucode_add (
                  opcode_1_op_r,
                  opcode_2_op_r,
                  valid_op_r,
                  iu_trap_r,
                  nxt_addr_1,
                  nxt_addr_2,
                  nxt_addr_3,
                  u_f18_6,
                  u_f18_5,
                  u_f08_rd_rs1_a,
                  rs1_0_l,
                  rs2_0_l,
                  u_done_l,
                  rom_addr,
                  rom_addr_l,
                  ucode_in_r,
                  sel_wd_inc_r,
                  sel_offset_add1_r
                 );

//  `include  "../../../common/ucode.h"

input    [7:0] opcode_1_op_r;      // top first  byte of ibuffer of R_stage
input    [7:0] opcode_2_op_r;      // top second byte of ibuffer of R_stage
input          valid_op_r;         // the opcode is valid        of R_stage
input          iu_trap_r;          // IU issue trap operation    of R_stage

input    [8:0] nxt_addr_1;         // ucode calculated rom_addr + 1        
input    [8:0] nxt_addr_2;         // ucode calculated rom_addr + 2        
input    [8:0] nxt_addr_3;         // ucode calculated rom_addr + 3        
input          u_f18_6;            // field_18: Branching in ucode, bit[6]
input          u_f18_5;            // field_18: Branching in ucode, bit[5]
input          u_f08_rd_rs1_a;     // Field_08: Read_port_A of RS1
input          rs1_0_l;            // rs1[0], active low, from IU
input          rs2_0_l;            // rs2[0], active low, from IU
input          u_done_l;           // the ucode is done, active low

output   [8:0] rom_addr;           // next_state of the ucode sequencer
output   [8:0] rom_addr_l;         // next_state of the ucode sequencer, active low
output         ucode_in_r;         // valid ucode opcode         of R_stage
output         sel_wd_inc_r;       // select {index_byte1,index_byte2} + 1
output         sel_offset_add1_r;  // select (offset+1) as the offset

wire     [8:0] next_addr;          // ucode calculated rom_addr  of E_stage
wire     [8:0] rom_addr;           // next_state of the ucode sequencer
wire     [8:0] rom_addr_l;         // next_state of the ucode sequencer, active low
wire           bit1, bit0;

/* Logic 
  assign rsx_0_l         = u_f08_rd_rs1_a ? rs1_0_l : rs2_0_l;

  assign check_handle2   = (!u_f18[6]  &&  u_f18[5]);  // jump_2
  assign check_handle    = ( u_f18[6]  && !u_f18[5]);  // jump_3, [0]=0
  assign check_handle_p  = ( u_f18[6]  &&  u_f18[5]);  // jump_3, [0]=1

  assign bit1 = (check_handle   && !a_oprd_0) || 
                (check_handle_p &&  a_oprd_0) ||
                (check_handle2  &&  a_oprd_0); 
 
  assign bit0 = (check_handle   && !a_oprd_0) ||
                (check_handle_p &&  a_oprd_0) || 
               !(check_handle2  &&  a_oprd_0);
*/ 

  branch_bit branch_bit_0 ( 
                           .u_f18_6 (u_f18_6),
                           .u_f18_5 (u_f18_5), 
                           .u_f08_rd_rs1_a(u_f08_rd_rs1_a), 
                           .rs1_0_l (rs1_0_l),
                           .rs2_0_l (rs2_0_l),
                           .bit1    (bit1), 
                           .bit0    (bit0) 
                          ); 
 
/* Logic
  always @(bit1 or bit0 or nxt_addr_1 or nxt_addr_2 or nxt_addr_3) 
    case({bit1,bit0})                         //synopsys parallel_case 
      2'h2:    next_addr = nxt_addr_2[8:0];
      2'h3:    next_addr = nxt_addr_3[8:0]; 
      default: next_addr = nxt_addr_1[8:0];
    endcase 
*/
 
  mx3_9 mx3_next_addr ( 
                       .inp1(nxt_addr_1[8:0]), 
                       .inp2(nxt_addr_2[8:0]), 
                       .inp3(nxt_addr_3[8:0]), 
                       .sel({bit1,bit0}), 
                       .out(next_addr[8:0]) 
                      ); 


  assign rom_addr_l = ~rom_addr[8:0];

  ucode_dec ucode_dec_0 (
                         .opcode_1_op_r(opcode_1_op_r[7:0]),
                         .opcode_2_op_r(opcode_2_op_r[7:0]),
                         .valid_op_r   (valid_op_r),
                         .iu_trap_r    (iu_trap_r),
                         .next_addr    (next_addr[8:0]),
                         .u_done_l     (u_done_l),
                         .rom_addr         (rom_addr[8:0]),
                         .ucode_in_r       (ucode_in_r),
                         .sel_wd_inc_r     (sel_wd_inc_r),
                         .sel_offset_add1_r(sel_offset_add1_r)
                        );

endmodule
	
