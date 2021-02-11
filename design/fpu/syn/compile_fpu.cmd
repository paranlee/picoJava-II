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
sh ln -s ../rtl/fpu.h .

include ../../lib_setup/mj_synopsys.setup

/**** read in primary design file  ****/

read -f verilog { \
                 ../rtl/f_fpu.v \
		 ../rtl/mult_array.v \
		 ../rtl/exponent_dp.v \
		 ../rtl/exponent_cntl.v \
		 ../rtl/exponent.v \
		 ../rtl/rsadd_dp.v \
		 ../rtl/rsadd_cntl.v \
		 ../rtl/rsadd.v \
		 ../rtl/multmod_dp.v \
		 ../rtl/multmod_cntl.v \
		 ../rtl/multmod.v \
		 ../rtl/fp_roms.v \
		 ../rtl/mantissa.v \
		 ../rtl/mantissa_dp.v \
		 ../rtl/mantissa_cntl.v \
		 ../rtl/mantissa_cntl_sub.v \
		 ../rtl/prils.v \
		 ../rtl/prils_dp.v \
		 ../rtl/prils_cntl.v \
		 ../rtl/code_seq.v \
		 ../rtl/code_seq_cntl.v \
		 ../rtl/code_seq_dp.v \
		 ../rtl/incmod.v \
		 ../rtl/nxsign.v \
		  ../../rtl/spare.v \
		 }

sh rm fpu.h

/* Set the current_design */
sh date

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list =  { fpu, mult_array, signgen, highlow, guesscout, \
		        mpselect, mpmux, fpu_booth, propagate_end, \
		        multadd2, tree34, tree29, tree27, tree23, \
       		        addnegi, exponent_dp, excon_dec, exponent_cntl, \
 		        expreg_dec, exple_dec, exptop_dec, expbot_dec, \
			expbot_muxlimd, expbot_muxsad, expbot_muxaed, \
			expbot_muxpaed, exponent, rsadd_dp, rsadd_cntl, \
		 	incin_dec, rsadd_dec, round_dec, rsadd, multmod_dp, \
			mult_add, spdec, mult_addinc, multmod_cntl, mult_dec, \
 			multmod,  fp_roms, mantissa, mantissa_dp, mantissa_cntl, \
			mantissa_dec, prils, prils_dp, prils_round_dec, prils_cntl, \
			pri_dec, code_seq, code_seq_cntl, opcode_dec, fpu_dec, \
			branch_dec, branch_decode1, branch_decode2, branch_decode3, \
			branch_decode4, code_seq_dp, acode_dec, map, incmod, \
			div_decode, inc_decode, inc_t1mda_rom, inc_t0md_rom, \
			inc_l1md_rom, inc_l0md_rom, nxsign}

dont_touch_list = first_design_list - second_design_list
 
set_dont_touch dont_touch_list
 
current_design {fpu}

/* set operation conditions */
set_operating_conditions "WCCOM" -library TARLIB

create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* set don't use the cells which are slow */

/* add the default driving / loading condition */
set_drive DRIVE_OF_INV1 all_inputs()
set_load LOAD_10_INV all_outputs()

include constraint_fpu.con
 
set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}

set_flatten false
set_structure true

uniquify
link
check_design

sh date
set_max_transition MAX_TRANSITION current_design
compile -map_effort medium 
sh date

/* print out a report file for area and timing violations */
report_area > db/fpu_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/fpu_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/fpu_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/fpu_violators.rpt
report_constraints -all_violators -verbose >> db/fpu_violators.rpt
 
/* write out the results */
write -f db -h -o db/fpu.db {fpu}
current_design fpu
ungroup -flatten -all
write -f verilog -o db/fpu_gate.vSyn {fpu}

sh rm defines.h

exit
