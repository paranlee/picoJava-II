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


module dcu_mon(

        clk,
        clk_count,
	dc_inst_c,
        iu_inst_c,
        smu_inst_c,
        dcu_addr_c,
        dcu_data_c,
	dcu_data,
	iu_data_vld,
	smu_data_vld
);


input        	clk;
input [63:0]   	clk_count;
input      	dc_inst_c;
input [7:0]     iu_inst_c;
input [3:0]     smu_inst_c;
input [31:0]    dcu_addr_c;
input [31:0]    dcu_data_c;
input [31:0]    dcu_data;
input     iu_data_vld;
input     smu_data_vld;


always @(negedge clk) begin

if ($test$plusargs("dcu_debug")) 
begin

  if (iu_inst_c[3] || iu_inst_c[2] || smu_inst_c[1] || smu_inst_c[0]) 
  begin


    $display("\nDCU Operation at clk:%d",clk_count);

    $display("iu_inst_c:%b  smu_inst_c:%b  Addr:%x ",iu_inst_c,smu_inst_c,dcu_addr_c);

    if (iu_inst_c[3] || smu_inst_c[1] || smu_inst_c[3]) 
      $display("Store Data:%x\n",dcu_data_c);
    else
      $display("\n");

  end
end

#1;

end

always @(posedge iu_data_vld or posedge smu_data_vld) begin

if ($test$plusargs("dcu_debug")) 
begin

      @(negedge clk);
        $display("clk:%d   Load Data:%x\n",clk_count,dcu_data);
end

end


endmodule

