///////////////////////////////////////////////
// @program: Testcase for Sending command wrong
// program use address constant to check data receive 
// from FLASH
///////////////////////////////////////////////


 program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.reset();
		env.drvr.enable();
		env.drvr.drive_check_data(1);
		env.drvr.reset();
		
		#10ns;
		$display("[%t ns]",$time);
		$display("end simulation for testcase 8 mode 0 of SPI.");
	end

endprogram
