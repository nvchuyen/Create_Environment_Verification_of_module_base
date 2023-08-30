 //////////////////////////////////////////////
 // Testcase for 
 //////////////////////////////////////////////


 program testcase(my_interface intf);
	environment env = new(intf);
	initial
	begin
		env.drvr.reset();
		env.drvr.enable();
		env.drvr.drive_mode0SPI(1);

		#100ns;
		$display("[%t ns]",$time);
		$display("end simulation for testcase mode 0 of SPI.");
	end

endprogram