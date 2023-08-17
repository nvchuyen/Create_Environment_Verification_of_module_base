// ///////////////////////////////////////////////////
//
// testbench
//
/////////////////////////////////////////////////////
`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////// Transaction

class transaction extends uvm_sequence_item;
  rand bit clk, rst, din;
  	   bit dout;
  
  function new(input string inst = "transaction");
    super.new(inst);
  endfunction 
  
  `uvm_object_utils_begin(transaction)
  	`uvm_field_int(clk, UVM_DEFAULT)
  	`uvm_field_int(rst, UVM_DEFAULT)
  	`uvm_field_int(din, UVM_DEFAULT)
  `uvm_object_utils_end
  
endclass

//////////////////////////////////////////////////////// generator
class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  
  transaction t;
  
  function new(input string inst = "GEN")
    super.new(inst);
  endfunction
    
  virtual task body();
    t = transaction::type_id::create("t");
    repeat(10)
      begin 
        start_item(t);
        `uvm_info("GEN", $sformatf("Data send to Driver clk:%0d, ", t.clk ), UVM_NONE);
        t.randomize();
        finish_item(t);
      end
  endtask
  
endclass
    
/////////////////////////////////////////////////////// Driver
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  virtual dff_if dif;
  
  function new (input string inst = "DRV", uvm_component c);
    super.new(inst, c);
  endfunction 
  
  transaction data;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data = transaction::type_id::create("data");
    
    if(!uvm_config_db #(virtual dff_if)::get)
    
  endfunction 
  
  virtual task run_phase(uvm_phase phase);
    
    reset_signals();
    forever begin
      seq_item_port.get_next_item(req);
      	// call task here
      seq_item_port.item_done();
    end 
  endtask : run_phase
  
  ///// RESET signals (initial)
  virtual task reset_signals();
  	dif.rst <= 1'b1;
    dif.din <= 0;
    repeat(5) @(posedge dif.clk);
    dif.rst <= 1'b0;
    uvm_info("DRV", "Reset done", UVM_NONE);
  endtask : reset_signals 
 
  virtual task drive();
  	
  endtask
     
endclass : driver
    
class monitor extends uvm_monitor
  `uvm_component_utils(monitor)
  
  //-----------------------------------
  // Component members 
  //-----------------------------------
  uvm_analysis_port #(transaction) send;
  
  //-----------------------------------
  // construction
  //-----------------------------------
  function new(input string inst = "monitor", uvm_component parent = null);
    super.new(name, parent);  
  endfunction 
  
  //-----------------------------------
  //
  //-----------------------------------
  transaction t;
  virtual dff_if dif;
  
  virtual function void build_phase(uvm_phase phase)
    super.build_phase(phase);
    t = transaction::type_id::create("TRANS");
    if(!uvm_config_db#(virtual dff_if)::get(this, "","dff_if", dif))
      `uvm_error("MON", "unable to access uvm_config_db");
  endfunction 
  
  //----------------------------------
  //
  //----------------------------------
  virtual task run_phase(uvm_phase phase);
    @(negedge dif.rst);
    forever begin
      repeat(2) @(posedge dif.clk);
      
    end 
  endtask : run_phase
  
  
endclass : monitor

////////////////////////////////////////////////////////////////// TEST
class test extends uvm_test;

  `uvm_component_utils(test)
  
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);  	
  endfunction
  
  //--------------------------------------
  // run_phase
  //--------------------------------------
  
  task run_phase (uvm_phase phase);
    phase.raise_objection(this);
    
    #100;
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : test

    
////////////////////////////////////////////////////////////////  
module tb_dff

  dff_if dff_if0;
  
  initial begin
  	clock <= 1'b0;
  	reset <= 1'b1;
    #100 reset <= 1'b0;
  end 
  
  // Generate clock
  always
  	#10 clock = ~clock;
    
  initial begin
    uvm_config_db #(virtual dff_if)::set(null, "uvm_test_top*", "dff_if0", dif0 );
  end 
  
  initial begin
    run_test("test");  
  end 
  
  initial begin
  	
  end 
  
endmodule : tb_dff
  




