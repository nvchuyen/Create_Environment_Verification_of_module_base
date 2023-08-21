//-------------------------------------------------
// first test 
// 
//-------------------------------------------------
// `include "ctrl_env.sv"
`include "seq_gen.svh"

class first_test extends uvm_test /* base class*/;
	`uvm_component_utils(first_test)
 
	function new(input string inst = "test", uvm_component c);
		super.new(inst, c);
	endfunction
 
	ctrl_env e;
	seq_gen gen;
 
 	//-------------------------------
 	// build phase
 	//-------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
  		e = ctrl_env::type_id::create("ctrl_env",this);
  		gen = seq_gen::type_id::create("gen");
	endfunction
 
	//------------------------------------
	// run phase
	//------------------------------------
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		gen.start(e.a.seqr);
		#20;
		phase.drop_objection(this);
	endtask

	//------------------------------------
	// print topology
	//------------------------------------
  	function void end_of_elaboration_phase(uvm_phase phase);
    	super.end_of_elaboration_phase(phase);
    	$display("--------------------------------------------------------------",);
    	$display("--------------------------------------------------------------",);
    	`uvm_info("other_test","start of Elaboration Phase Executed", UVM_NONE);
    	uvm_top.print_topology();
    	`uvm_info("other_test","End of Elaboration Phase Executed", UVM_NONE);
  	endfunction


endclass : first_test


