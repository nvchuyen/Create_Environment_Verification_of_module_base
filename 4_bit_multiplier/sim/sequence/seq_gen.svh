
//--------------------------------------------------------
// 08/18/2013
// 
//
//--------------------------------------------------------

`include "transaction.svh"

/********************************************************
 * 
 * ******************************************************/
// class seq_gen_base extends uvm_sequence #(transaction)/* base class*/;
// 	`uvm_object_utils(seq_gen_base)

// 	function new(string name = "seq_gen_base", uvm_component parent = null);
// 		super.new(name, parent);		
// 	endfunction : new


// 	virtual function void build_phase( uvm_phase phase);
// 		super.build_phase(phase);
// 	endfunction : build_phase

// endclass : seq_gen_base


/*******************************************************
 * 
 * 
 * ******************************************************/
class seq_gen extends uvm_sequence #(transaction) /* base class*/;
	
	`uvm_object_utils(seq_gen)
  
    transaction tr;
 
   	function new(input string path = "seq_gen");
    	super.new(path);
   	endfunction
   
   
   	virtual task body(); 
   	repeat(15)begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        `uvm_info("SEQ", $sformatf("a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
        finish_item(tr);     
    end
   	endtask
endclass : seq_gen
