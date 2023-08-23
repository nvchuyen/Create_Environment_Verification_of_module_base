
//---------------------------------------------
//
//---------------------------------------------


`ifndef MUL_TRANSACTION
`define MUL_TRANSACTION


class transaction extends uvm_sequence_item /* base class*/;
	
	`uvm_object_utils(transaction)

  	rand bit rst;
  	rand bit din;
       	 bit dout;


	function new( input string path = "transaction");
		super.new(path);
	endfunction

 // `uvm_object_utils_begin(transaction)
 // 	`uvm_field_int(a, UVM_DEFAULT)
 // 	`uvm_field_int(b, UVM_DEFAULT)
 // 	`uvm_field_int(y, UVM_DEFAULT)
 // `uvm_object_utils_end

endclass : transaction


`endif
