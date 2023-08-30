 //////////////////////////////////////////////
 // Testcase for testcase mode 1 SPI
 //////////////////////////////////////////////


 program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.reset();
		env.drvr.enable();
		env.drvr.drive_mode1SPI(1);
		
		#10ns;
		$display("[%t ns]",$time);
		$display("end simulation for testcase mode 1 of SPI.");
	end

endprogram