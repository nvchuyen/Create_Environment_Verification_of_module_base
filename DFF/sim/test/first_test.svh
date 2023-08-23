//-------------------------------------------------
// 08/22/2023
// Nguyen Van Chuyen
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
 
	ctrl_env 	 e;
	valid_din    vdin;
	rst_dff      rff;
	rand_din_rst rdin;

 	//-------------------------------
 	// build phase
 	//-------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
  		e 	 = ctrl_env::type_id::create("ctrl_env",this);
  		vdin = valid_din::type_id::create("vdin");
  		rff  = rst_dff::type_id::create("rff");
  		rdin = rand_din_rst::type_id::create("rdin");
	endfunction
 

	//------------------------------------
	// run phase
	//------------------------------------
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
  			rff.start(e.a.seqr);
  			#40;
  			$display("[%0t] reset done", $time());
  			$display("*************************", );
  			vdin.start(e.a.seqr);
  			#40;
  			$display("[%0t] din 2 done", $time());
  			$display("*************************", );
  			
  			rdin.start(e.a.seqr);
  			#40;
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


