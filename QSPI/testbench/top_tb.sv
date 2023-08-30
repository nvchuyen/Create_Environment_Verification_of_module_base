//////////////////////////////////////
// top_tb
//////////////////////////////////////
`timescale 1ns / 1ps


`include "stimulus.sv"
`include "driver.sv"
`include "interface.sv"
`include "environment.sv"
`ifdef TESTCASE_1 
`include "testcase_1.sv" // change include to different testcase
`elsif TESTCASE_2
`include "testcase_2.sv" // change include to different testcase
`elsif TESTCASE_3
`include "testcase_3.sv" // change include to different testcase
`elsif TESTCASE_4
`include "testcase_4.sv" // change include to different testcase
`elsif TESTCASE_5
`include "testcase_5.sv" // change include to different testcase
`elsif TESTCASE_6
`include "testcase_6.sv" // change include to different testcase
`elsif TESTCASE_7
`include "testcase_7.sv" // change include to different testcase
`elsif TESTCASE_8
`include "testcase_8.sv" // change include to different testcase
`endif

`include "assertion.sv"

module top_tb ();
 	reg clk = 0;
  	initial  // clock generator
  	forever #5 clk = ~clk;

  	// DUT/ / testcase instances/ assertion
  	my_interface intf(clk);
    
    qspi_master DUT(.i_clk(clk), .i_rst_n(intf.reset), .i_data(intf.data), .i_addr(intf.addr), .i_command(intf.command),  .i_rw(intf.rw), 
                    .i_enable(intf.enable), .i_burst_enable(intf.burst_enable), .i_burst_count(intf.burst_count), .i_divider(intf.divider),
    				.i_cpha(intf.cpha) , .i_cpol(intf.cpol), .i_mode(intf.mode), .SCLK(intf.sclk), .o_read_word(intf.read_word), 
    				.o_busy(intf.busy), .o_done(intf.done), .SS(intf.cs),   .o_burst_read_data_valid(intf.burst_read_data_valid), 
                    .o_burst_write_word_request(intf.burst_write_word_request),  .SO0(intf.sio0), .SO1(intf.sio1), .SO2(intf.sio2), .SO3(intf.sio3)
                    );

    N25Qxxx  Model_N25Qxxx (
       .S(intf.cs),
       .C_(intf.sclk),
       .HOLD_DQ3(intf.sio3),
       .DQ0(intf.sio0),
       .DQ1(intf.sio1),
       .Vcc('d3300),
       .Vpp_W_DQ2(intf.sio2)
       ); // model for flash


    pullup(intf.sio2);
    pullup(intf.sio3);

    testcase test(intf);
  	my_assertion acov(intf);
endmodule
