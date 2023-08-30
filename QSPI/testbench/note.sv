//	
//
//
// Check command include SINGLE, DUAL, QUAD
// always @(negedge intf.sclk)
// begin
// 	if( intf.cs ) begin
// 		counter = 8'h00;
// 		end
// 	else if((intf.sclk)  && (counter < 8'h08)) begin // command
// 		counter = counter + 8'h01;		
// 		end
// 	else if((counter >= 8'h08) && (intf.command == 8'h0B))
// 		begin
// 			counter = counter + 8'h01;	
// 		end
// 	else if((counter >= 8'h08) && (intf.command == 8'hBB))
// 		begin
// 			counter = counter + 8'h02;	
// 		end
// 	else if((counter >= 8'h08) && (intf.command == 8'hEB))
// 		begin
// 			counter = counter + 8'h04;	
// 		end
// 	else if(counter <= 8'h32)
// 	begin
// 		counter = 8'h00;
// 	end
// end
