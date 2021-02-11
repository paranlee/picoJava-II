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

/* Read in general set up file to set path to technology library and synopsys files*/
include ../../../lib_setup/mj_synopsys.setup
 
/* Read in corresponding verilog files to be synthesised */
read -f verilog { \
		../rtl/index_adders.v \
		../rtl/ex_len_dec.v \
		../rtl/length_dec.v \
		../rtl/valid_dec.v \
		../rtl/fdec.v \
		../rtl/fold_dec.v \
		../rtl/rs1_dec.v \
		../rtl/rs2_dec.v \
		../rtl/rsd_dec.v \
		../rtl/main_dec.v \
		../rtl/fold_logic.v \
		../rtl/ifu.v \
  		  ../../../rtl/spare.v \
              }

current_design {ifu}

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list = {index1_add, index2_add, index3_add, index4_add, \
 		      index5_add, index6_add, ex_len_dec, length_dec, \
 		      sp_mux4_8, sp_mux8_8, valid_dec, fdec, fold_dec, \
 		      rs1_dec, rs2_dec, rsd_dec, main_dec, fold_logic, ifu}

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list

current_design {ifu}

create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}
include constraint_ifu.con;

/* set transition time of any cells or nets */
set_max_transition MAX_TRANSITION current_design

set_operating_conditions "WCCOM" -library TARLIB
uniquify

group_path -name "pin" -critical_range PIN_GROUP -to all_outputs()

set_structure -boolean false
set_flatten -phase true -effort medium

sh date
compile -map_effort high;
sh date
 
report_timing -path end -delay max -max_paths PATHS_FULL -nosplit > db/ifu_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL -nosplit > db/ifu_maxtim.rpt
report_area -nosplit > db/ifu_area.rpt
report_constraints -all_violators -verbose > db/ifu_violators.rpt
 
write -f db -h -o db/ifu.db ifu
write -f verilog -h -o db/ifu.vSyn ifu

sh date

quit
