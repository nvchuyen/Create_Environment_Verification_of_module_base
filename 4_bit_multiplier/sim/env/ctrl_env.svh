//-----------------------------------------------
// NGUYEN VAN CHUYEN
// 08/18/2023
// Environment test 
//-----------------------------------------------

`include "agent.svh"


class ctrl_env extends  uvm_env /* base class*/;

	`uvm_component_utils(ctrl_env)
 
	function new(input string inst = "ctrl_env", uvm_component c);
		super.new(inst,c);
	endfunction
 
	agent a;
	scoreboard s;
 
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
  		a = agent::type_id::create("a",this);
  		s = scoreboard::type_id::create("s", this);
	endfunction
 
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		a.m.send.connect(s.recv);
	endfunction

endclass : ctrl_env




