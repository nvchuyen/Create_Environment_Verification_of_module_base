////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s     testcase for test enable         s////
////s                                      s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////


program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.enable();
		env.drvr.enable_negative();
		env.drvr.enable();
		#10000ns;
		$display("[%0t ns] end simulation for enable", $time);
		$display("================================================");
	end

endprogram