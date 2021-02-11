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




 sh date

sh ln -s ../../../rtl/defines.h 

/* Read in general set up file to set path to technology library and synopsys files*/ 
include ../../../lib_setup/mj_synopsys.setup

/* Read in corresponding verilog files to be synthesised */
read -f verilog { \
             ../rtl/imdr/lib_imdr.v \
             ../rtl/imdr/imdr_ctrl.v \
             ../rtl/imdr/imdr_dpath.v \
             ../rtl/imdr/imdr.v \
             ../rtl/ex_regs.v \
	     ../rtl/ex_decode.v \
             ../rtl/ex_ctl.v \
             ../rtl/ex_dpath.v \
             ../rtl/ex.v \
		  ../../../rtl/spare.v \
           }

/* Define high level module name */ 
current_design {ex}

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list = {rsh16_33, compl_32, mx2_compl_32, mx2_neg_33, \
               mx4_clr_reg_33, mx4_clr_reg_32, mx4_clr_reg_nxt_32, \
               booth, b_recoder, zero_a_32, zero_b_32, zero_det, \
               sign_bit, dpath_ctrl, inv1_32, an2_32, an2_33, \
               imdr_ctrl, imdr_dpath, imdr, ex_regs, mux21_32, \
               ex_decode, ex_ctl, branch_logic, ex_dpath, ex}

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list 

current_design {ex}

/* set transition time of any cells or nets */
set_max_transition MAX_TRANSITION current_design

/* set operation conditions */
set_operating_conditions "WCCOM" -library TARLIB

/* set clock period and set don't touch of clock network */ 
create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* add default loading / driving condition */
set_drive DRIVE_OF_INV1 all_inputs()
set_load LOAD_10_INV all_outputs()

/* read in input delay and load, output delay and load constraint */
include constraint_ex.con
set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}
 
/* Optimization effort */
uniquify
set_structure true
set_flatten false
group_path -name "pin" -critical_range PIN_GROUP -to all_outputs()
compile_ok_to_buffer_during_inplace_opt = false
compile_ignore_area_during_inplace_opt = true

sh date
compile -map_effort high 
sh date
link

/* print out a report file for area and timing violations */

report_area > db/ex_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/ex_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/ex_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/ex_violators.rpt
report_constraints -all_violators -verbose >> db/ex_violators.rpt

/* write out the results */
write -f db -h -o db/ex.db {ex} 
write -f verilog -h -o db/ex.vSyn {ex} 

sh rm defines.h
sh date

quit
