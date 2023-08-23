//------------------------------------------------
// Nguyen Van Chuyen
// 08/21/2023
//
//
//-------------------------------------------------
//
// Class Description
//
class config_dff extends uvm_object /* base class*/;
	
	`uvm_object_utils(config_dff)

	uvm_active_passive_enum agent_type = UVM_ACTIVE;

	function new( input string path = "config_dff");
		super.new(path);
	endfunction 

endclass : config_dff
