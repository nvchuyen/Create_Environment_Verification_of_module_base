
package seq_lib_pkg;
	
import uvm_pkg::*;
`include "uvm_macros.svh"

import env_pkg::*;
import agent_pkg::*;

		
/************************************************************
 * 
 * 
 * **********************************************************/
class valid_din extends uvm_sequence#(transaction);
`uvm_object_utils(valid_din)
  
   	transaction tr;
 
   	function new(input string path = "valid_din");
    	super.new(path);
   	endfunction
   
   //-------------------------------------------
   // body
   //-------------------------------------------
   virtual task body(); 
   repeat(15)begin
         tr = transaction::type_id::create("tr");
         start_item(tr);
         assert(tr.randomize());
         tr.rst = 1'b0; 
         `uvm_info("SEQ", $sformatf("rst : %0b  din : %0b  dout : %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
         finish_item(tr);     
     end
   endtask
 
endclass


/************************************************************
 * 
 * 
 * **********************************************************/
class valid_dff extends  uvm_sequence/* base class*/;
	`uvm_object_utils(valid_dff)

	transaction tr;

	function new(input string path = "valid_din");
		super.new(path);
	endfunction 

	virtual task body();
		repeat(15) begin
         tr = transaction::type_id::create("tr");
         start_item(tr);
         assert(tr.randomize());
         tr.rst = 1'b0; 
         `uvm_info("SEQ", $sformatf("rst : %0b  din : %0b  dout : %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
         finish_item(tr);     
     	end
	endtask

endclass : valid_dff

/************************************************************
 * 
 * 
 * **********************************************************/
class rst_dff extends  uvm_sequence /* base class*/;
	`uvm_object_utils(rst_dff)
  
    transaction tr;
 
   	function new(input string path = "rst_dff");
    	super.new(path);
   	endfunction
   
   
   	virtual task body(); 
   		repeat(15)begin
         tr = transaction::type_id::create("tr");
         start_item(tr);
         assert(tr.randomize());
         tr.rst = 1'b1;
         `uvm_info("SEQ", $sformatf("rst : %0b  din : %0b  dout : %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
         finish_item(tr);     
     	end
   	endtask

endclass : rst_dff


/***********************************************************
 * 
 * 
 * **********************************************************/
class rand_din_rst extends uvm_sequence /* base class*/;
	`uvm_object_utils(rand_din_rst)
  
    transaction tr;
 
   	function new(input string path = "rand_din_rst");
    	super.new(path);
   	endfunction
   
   
   	virtual task body(); 
   		repeat(15)begin
         tr = transaction::type_id::create("tr");
         start_item(tr);
         assert(tr.randomize());
         `uvm_info("SEQ", $sformatf("rst : %0b  din : %0b  dout : %0b", tr.rst, tr.din, tr.dout), UVM_NONE);
         finish_item(tr);     
     	end
	endtask	

endclass : rand_din_rst


endpackage : seq_lib_pkg

