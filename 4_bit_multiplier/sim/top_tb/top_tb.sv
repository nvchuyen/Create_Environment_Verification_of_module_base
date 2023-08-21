
`include "uvm_macros.svh"
import uvm_pkg::*;

import env_pkg::*;
import agent_pkg::*;


`include "first_test.svh"
`include "mul_if.sv"


////////////////////////////////////////////////////////////////////
module top_tb;
 
  mul_if mif();
  
  mul dut (.a(mif.a), .b(mif.b), .y(mif.y));
 
 	// ----------------------------
  initial begin
  	uvm_config_db #(virtual mul_if)::set(null, "*", "mif", mif);
  	run_test("first_test"); 
  end

  	// ---------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule