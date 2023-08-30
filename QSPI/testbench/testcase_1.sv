 /////////////////////////////////////
 // testcase for reset
 /////////////////////////////////////

program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		  env.drvr.reset_negative();
		  env.drvr.reset();
		#10000ns;
		$display("end simulation reset");
		$display("===================================================");
	end

endprogram

