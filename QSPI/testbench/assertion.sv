///////////////////////////////////
// Assertion for testcase
///////////////////////////////////

`define ADDRESS_WIDTH 24
`define COMMAND_WIDTH 8
// `define USE_CONSTANT  


module my_assertion (my_interface intf);
///////////////////////////////////////////////
//@ Assertion for test protocol 
///////////////////////////////////////////////
reg [31:0]counter = 8'h0; 
  // logic [DWIDTH_ADDRESS-1:0] addr_m_send;
  logic [24-1:0] addr_m_send;
  logic [31:0] data_constant = 32'h01030a0b;


//detect values refer
initial begin
	fork
		forever begin
			@(negedge intf.cs);
    		addr_m_send = intf.addr;
		end
	join_none
end
	// check reset //  disable iff(!pin): disable assertion testing if "pin" is low
	 AP_RESET_CHECK: 	cover property (@(posedge intf.clk)	  	 (intf.enable !=0)  |-> (intf.cs == 0 )) ;//else $display("[%t ns]reset wrong",$time());	// test

	// Check CS
	 AP_CS_CHECK: 		cover property (@(posedge intf.sclk)     (intf.reset !=0)  	|-> (intf.cs == 0 ));

	// Check SCLK:(Using method "$stable" to check data which change in posedge of SCLK, Check CPOL and CPHA is true with mode SPI)
	//......................................................
	//......................................................
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// clock deteg
//////////////////////////////////////
initial begin
	fork
		forever begin
			@(negedge intf.cs); 
				counter = 8'h00;
		end

		forever begin
			@(negedge intf.sclk) 
				if(counter < 8'h08)
					counter = counter + 8'h01;
				else if((counter >= 8'h08) && (intf.command == 8'h0B))
					begin
						counter = counter + 8'h01;	
					end
				else if((counter >= 8'h08) && (intf.command == 8'hBB))
					begin
						counter = counter + 8'h02;	
					end
				else if((counter >= 8'h08) && (intf.command == 8'hEB))
					begin
						counter = counter + 8'h04;	
					end
				else if(counter <= 8'h32)
					begin
						counter = 8'h00;
					end
		end		
	join_none
end


`ifdef  USE_CONSTANT 

///////////////////////////////////////////////////////////////////////////
// @ Assertion for check command
///////////////////////////////////////////////////////////////////////////
	AP_COMMAND_CHECK:	assert property (@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && (counter < 8) )
	 									 	    					|->	 (intf.command[7-counter] == intf.sio0) // Check value command
																	)else begin
																		$display("@%10t counter: %d command:%b intf: %b",$realtime,counter, intf.command[counter], intf.sio0 ); 
																		$error("assertion failed at command"); 
																	end
	

///////////////////////////////////////////////////////////////////////////
// @ Assertion for check address
// @ Include: 	+	SINGLE_DUMMY:	24 cycles
// 				+	DUAL_DUMMY:		12 cycles
//				+	QUAD_DUMMY:		06 cycles 
/////////////////////////////////////////////////////////////////////////// 
 	AP_ADDRESS_CHECK_SINGLE: 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8) < 24) && (intf.mode == 2'b00) && (counter >= 8 ))
	 									 	    									|->	 (intf.addr[23- (counter - 8)] == intf.sio0, $display("@%10t single address done",$realtime)) // Check value command
																			)else $error("assertion failed at address single SPI"); 

	AP_ADDRESS_CHECK_DUAL  :	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8) < 24) && (intf.mode == 2'b01))
	 									 	    									|->	 ((intf.addr[23- (counter - 8)] == intf.sio0) && (intf.addr[23- (counter - 7)] == intf.sio1)) // Check value command
																			)else $error("assertion failed at address dual SPI"); 

	AP_ADDRESS_CHECK_QUAD  : 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8) < 24) && (intf.mode == 2'b10))
																					|->((intf.addr[23-(counter - 5)] == intf.sio0) && 
																						(intf.addr[23-(counter - 6)] == intf.sio1) && 
																						(intf.addr[23-(counter - 7)] == intf.sio2) && 
																						(intf.addr[23-(counter - 8)] == intf.sio3)) // Check value command 
																			)else begin 
																					$error("assertion failed at address quad SPI"); 
																					$display("@%10t  counter - 8:%d addr0-addr1-addr2-addr3:%b intf0-intf1-intf2-intf3: %b", $realtime, counter -8, 
																						intf.addr[23-(counter - 5)], 
																						intf.addr[23-(counter - 6)], 
																						intf.addr[23-(counter - 7)], 
																						intf.addr[23-(counter - 8)], 
																						intf.sio0, intf.sio1, intf.sio2, intf.sio3); 
																				end


///////////////////////////////////////////////////////////////////////////
// @ Assertion for check dummy
// @ Include: 	+	SINGLE_DUMMY:	8 cycles
// 				+	DUAL_DUMMY:		4 cycles
//				+	QUAD_DUMMY:		2 cycles of PEI and 4 cycle dummy 
///////////////////////////////////////////////////////////////////////////
 // 	AP_DUMMY_CHECK_SINGLE: 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8-24) < 8) && (intf.mode == 2'b00))
	//  									 	    									|->	 (intf.addr[23- (counter - 8)] == intf.sio0, $display("@%10t single done",$realtime)) // Check value command
	// 																		)else $error("assertion failed at address single SPI"); 

	// AP_DUMMY_CHECK_DUAL  :	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8-24) < 4) && (intf.mode == 2'b01))
	//  									 	    									|->	 ((intf.addr[23- (counter - 8)] == intf.sio0) && (intf.addr[23- (counter - 7)] == intf.sio1)) // Check value command
	// 																		)else $error("assertion failed at address dual SPI"); 

	// AP_DUMMY_CHECK_QUAD  : 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8-24) < 6) && (intf.mode == 2'b10))
	// 																				|->((intf.addr[23-(counter - 5)] == intf.sio0) && 
	// 																					(intf.addr[23-(counter - 6)] == intf.sio1) && 
	// 																					(intf.addr[23-(counter - 7)] == intf.sio2) && 
	// 																					(intf.addr[23-(counter - 8)] == intf.sio3)) // Check value command 
	// 																		)else begin 
	// 																				$error("assertion failed at address quad SPI"); 
	// 																				$display("@%10t  counter - 8:%d addr0-addr1-addr2-addr3:%b intf0-intf1-intf2-intf3: %b", $realtime, counter -8, 
	// 																					intf.addr[23-(counter - 5)], 
	// 																					intf.addr[23-(counter - 6)], 
	// 																					intf.addr[23-(counter - 7)], 
	// 																					intf.addr[23-(counter - 8)], 
	// 																					intf.sio0, intf.sio1, intf.sio2, intf.sio3); 
	// 																			end

`else 
////////////////////////////////////////////////////////////
// Assertion for check data that having address is constant
// @ address: 		0x000004
// @ burst_count: 	4 (read a word data)	
////////////////////////////////////////////////////////////
 	AP_DATA_CHECK_SINGLE: 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8 - 24 - 8) < 32) && (intf.mode == 2'b00) && (counter >= 40 ))
	 									 	    									|->	(data_constant[31- (counter - 8 - 24 -8)] == intf.sio1) // Check value command
																			)else begin
																					$error("assertion failed at data single SPI");
																					$display("@%10t  counter - 8 -24 -8:%d data0: %b  intf0: %b", $realtime, counter - 8 - 24 - 8, 
																					data_constant[31-(counter - 8 - 24 - 8 )], 
																					intf.sio1); 
																			end

	AP_DATA_CHECK_DUAL  :	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8 - 24 - 16) < 32) && (intf.mode == 2'b01) && (counter >= 48 ))
	 									 	    									|->	((data_constant[31- (counter - 7 - 24 -16)] == intf.sio0) && 
	 									 	    										 (data_constant[31- (counter - 8 - 24 -16)] == intf.sio1),
	 									 	    										 $display("data dual done, counter: %d", counter)) // Check value command
																			)else begin
																					$error("assertion failed at data dual SPI");
																					$display("@%10t  counter - 8 -24 -16:%d data0-data1: %b - %b intf0-intf1-intf2-intf3: %b - %b - %b - %b", $realtime, counter - 8 - 24 - 16, 
																						 data_constant[31-(counter - 7 - 24 - 16)], 
																						 data_constant[31-(counter - 8 - 24 - 16)], 
																						 intf.sio0, intf.sio1, intf.sio2, intf.sio3); 
																					$display("counter is: %d",counter );
																			end 

	AP_DATA_CHECK_QUAD  : 	assert property(@(posedge intf.sclk)		((intf.cs ==0) && (intf.cpol == 0) && (intf.cpha == 0)  && ((counter - 8 - 48 - 16) < 32) && (intf.mode == 2'b10) && (counter >= 72 ))
																					|->((data_constant[31-(counter  - 48 - 16 - 5)] == intf.sio0) && 
																						(data_constant[31-(counter  - 48 - 16 - 6)] == intf.sio1) && 
																						(data_constant[31-(counter  - 48 - 16 - 7)] == intf.sio2) && 
																						(data_constant[31-(counter  - 48 - 16 - 8)] == intf.sio3)) 
																						//$display("quad done")) // Check value command 
																			)else begin 
																					$error("assertion failed at data quad SPI"); 
																					$display("@%10t  counter :%d data0-data1-data2-data3:%b - %b - %b -%b intf0-intf1-intf2-intf3: %b - %b - %b - %b", $realtime, counter , 
																						 data_constant[31-(counter  - 48 - 16 - 5)], 
																						 data_constant[31-(counter  - 48 - 16 - 6)], 
																						 data_constant[31-(counter  - 48 - 16 - 7)], 
																						 data_constant[31-(counter  - 48 - 16 - 8)], 
																						 intf.sio0, intf.sio1, intf.sio2, intf.sio3); 
																				end


`endif 
////////////////////////////////////////////////
//// Assertion for check singal done
//// Check data
////////////////////////////////////////////////
 	AP_SIGNAL_DONE_CHECK: cover property (@(posedge intf.sclk) 		((intf.cs != 1) &&(intf.reset != 0) && (intf.enable != 0)) |-> (intf.done != 0));

endmodule

