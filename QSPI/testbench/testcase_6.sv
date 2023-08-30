 //////////////////////////////////////////////
 // Testcase for MODE3 SPI
 //////////////////////////////////////////////


 program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.reset();
		env.drvr.enable();
		env.drvr.drive_mode3SPI(1);
		env.drvr.reset();
		
		#10ns;
		$display("[%t ns]",$time);
		$display("end simulation for testcase mode 3 of SPI.");
	end

endprogram