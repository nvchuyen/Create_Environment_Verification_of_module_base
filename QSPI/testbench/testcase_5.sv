 //////////////////////////////////////////////
 // Testcase for mode 2 SPI
 //////////////////////////////////////////////


 program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.reset();
		env.drvr.enable();
		env.drvr.drive_mode2SPI(1);
		env.drvr.reset();
		
		#10ns;
		$display("[%t ns]",$time);
		$display("end simulation for testcase mode 2 of SPI.");
	end

endprogram