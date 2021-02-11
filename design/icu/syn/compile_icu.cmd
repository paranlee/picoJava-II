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

sh ln -s ../../rtl/defines.h .

include ../../lib_setup/mj_synopsys.setup

/* Read in corresponding verilog files to be synthesised */
read -f verilog { \
                  ../rtl/ibuf_ctl.v \
                  ../rtl/ic_cntl.v \
                  ../rtl/icctl.v \
                  ../rtl/ibuffer.v \
                  ../rtl/icu_dpath.v \
                  ../rtl/icu.v \
		  ../../rtl/spare.v \
                }

/* Define high level module name */
current_design {icu}

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list = {ibuf_ctl, encode_shift_module, ibuf_ctl_slice, \
                      ic_cntl, icctl, ibuffer, ibuf_slice, icu_dpath, \
                      ic_aligner, ic_len_decoder, icu}

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list

current_design {icu}

/* set operation conditions */
set_operating_conditions "WCCOM" -library TARLIB
 
/* set clock period and set don't touch of clock network */
create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* set don't use cells which are slow */
 
/* add the default driving / loading condition */
set_drive DRIVE_OF_INV3 all_inputs()
set_load LOAD_20_INV all_outputs()
 
/* read in input delay and load, output delay and load constraint */
include constraint_icu.con
 
set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}
 
/* Optimization effort */
uniquify
ungroup -flatten -all;
group_path -name CLOCK -critical_range CLK_GROUP -to clk
group_path -name "pin" -critical_range PIN_GROUP -to all_outputs()

compile_ok_to_buffer_during_inplace_opt = false
compile_ignore_area_during_inplace_opt = true
 
sh date
 
set_max_transition MAX_TRANSITION current_design
compile -map_effort high
sh date 

/* print out a report file for area and timing violations */
report_area > db/icu_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/icu_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/icu_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/icu_violators.rpt
report_constraints -all_violators -verbose >> db/icu_violators.rpt
 
/* write out the results */
write -f db -h -o db/icu.db {icu}
write -f verilog -o db/icu.vSyn {icu}
current_design icu
ungroup -flatten -all
write -f verilog -o db/icu_gate.vSyn {icu}
 
sh rm defines.h

quit
