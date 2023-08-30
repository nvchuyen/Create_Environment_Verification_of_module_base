/////////////////////////////////////////////
// interface for qspi_mater.v
//
////////////////////////////////////////////

interface my_interface (input bit clk);

	// for i_clk
	logic 			reset;
	logic [31:0] 	data;
	logic [23:0] 	addr;
	logic [7:0 ] 	command;
	logic 			rw;
	logic 			enable;
	logic 			burst_enable;
	logic [15:0]	burst_count;
	logic [15:0]	divider;
	logic 			cpha;
	logic 			cpol;
	logic [1:0 ]	mode;
	logic 			sclk;
	logic [31:0]	read_word;
	logic 			busy;
	logic 			done;
	logic 			cs;
	logic 			burst_read_data_valid;
	logic 			burst_write_word_request;

	wire 			sio0;
	wire 			sio1;
	wire 			sio2;
	wire 			sio3;

endinterface 
