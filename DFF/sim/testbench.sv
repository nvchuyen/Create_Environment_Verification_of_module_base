// ///////////////////////////////////////////////////
//
// testbench
//
//////////////////////////////////////////////////////

`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////// Transaction

class transaction extends uvm_sequence_item;
  rand bit din;
  bit dout;
  
  function new(input string inst = "transaction");
    super.new(inst);
  endfunction 
  
  `uvm_object_utils_begin(transaction)
  	`uvm_field_int(din, UVM_DEFAULT)
    `uvm_field_int(dout, UVM_DEFAULT)
  `uvm_object_utils_end
  
endclass : transaction

//////////////////////////////////////////////////////// Generator
class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  
  transaction t;
  
  function new(input string path = "generator");
    super.new(path);
  endfunction


  virtual task body();
    t = transaction::type_id::create("t");
    repeat(10)
      begin 
        start_item(t);
        t.randomize();
        finish_item(t);
        `uvm_info("GEN", $sformatf("GEN send dat din: %0d ", t.din), UVM_NONE);
      end
  endtask
  
endclass : generator
    
/////////////////////////////////////////////////////// Driver
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  function new (input string inst = "DRV", uvm_component c);
    super.new(inst, c);
  endfunction 
  
  transaction data;
  virtual dff_if dif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data = transaction::type_id::create("data");
    
    if(!uvm_config_db #(virtual dff_if)::get(this, "", "dff_if0", dif))
      `uvm_error("DRV","Unable to access uvm_config_db");
  endfunction 
  
  virtual task run_phase(uvm_phase phase);
    reset_signals();
    forever begin
      seq_item_port.get_next_item(data);
      	// call task here
      dif.din  <= data.din;
      dif.dout <= data.dout;
      
      `uvm_info("DRV", $sformatf("Data of Driver din: %0d, dout: %0d ", data.din, data.dout), UVM_NONE);
      `uvm_info("DRV", $sformatf("Data of Driver dif din: %0d, dout: %0d ", dif.din, dif.dout), UVM_NONE);

      $display("[%0t]-------------------------------------------------------", $time());
      seq_item_port.item_done();
      @(posedge dif.clk);
      @(posedge dif.clk);
    end 
  endtask : run_phase
  
  ///// RESET signals (initial)
  virtual task reset_signals();
  	dif.rst <= 1'b1;
    dif.din <= 0;
    repeat(5) @(posedge dif.clk);
    dif.rst <= 1'b0;
    `uvm_info("DRV", "Reset done", UVM_NONE);
  endtask : reset_signals 
 
     
endclass : driver
    
////////////////////////////////////////////////// monitor
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  //-----------------------------------
  // Component members 
  //-----------------------------------
  uvm_analysis_port #(transaction) send;
  
  //-----------------------------------
  // construction
  //-----------------------------------
  function new(input string name = "monitor", uvm_component parent = null);
    super.new(name, parent);  
    send = new("send", this);
  endfunction 
  
  //-----------------------------------
  //
  //-----------------------------------
  transaction t;
  virtual dff_if dif;
  
  //-----------------------------------
  // build phase
  //-----------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("TRANS");
    if(!uvm_config_db#(virtual dff_if)::get(this, "","dff_if0", dif))
      `uvm_error("MON", "unable to access uvm_config_db");
  endfunction 
  
  //----------------------------------
  //
  //----------------------------------
  virtual task run_phase(uvm_phase phase);
    @(negedge dif.rst);
    forever begin
      repeat(2) @(posedge dif.clk);
      t.din = dif.din;
      t.dout= dif.dout;
      `uvm_info("MON", $sformatf("Data send to scoreboard"), UVM_NONE);
      send.write(t);
    end 
  endtask : run_phase
  
endclass : monitor

////////////////////////////////////////////////////////////////// Scoreboard
class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(transaction,scoreboard) recv;
  
  transaction data;
  
  function new(input string inst = "SCO", uvm_component c);
    super.new(inst, c);
    recv = new("READ", this);
  endfunction 
  
  virtual function void write (input transaction t);
    data = t;
    `uvm_info("SCO", $sformatf("Data rcvd from monitor din: %0d, dou: %0d", t.din, t.dout), UVM_NONE);
   // write code here 
    if(data.din == data.dout)begin
      $display("------------------- check --------------------");
      `uvm_info("SCO", $sformatf("Test Passed"), UVM_NONE)   
     end 
    else
      `uvm_info("SCO", $sformatf("Test Failed"), UVM_NONE);    

  endfunction
  
endclass : scoreboard

//////////////////////////////////////////////////////////////// Agent    
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  function new(input string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction 
  
  monitor m;
  driver d;
  uvm_sequencer #(transaction) seqr;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m",this);
    d = driver::type_id::create("d",this);
    seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
  endfunction 
  

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction 
  
endclass : agent

////////////////////////////////////////////////////////////////// ENV
class env extends uvm_env;
  `uvm_component_utils(env)
  
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction 
  
  scoreboard s;
  agent 	a;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("s", this);
    a = agent::type_id::create("a", this);
  endfunction 
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction 
  
endclass : env
    
    
////////////////////////////////////////////////////////////////// TEST
class test extends uvm_test;

  `uvm_component_utils(test)
  
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);  	
  endfunction
 
  generator gen;
  env e;
  
  //--------------------------------------
  // build_phase
  //--------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen = generator::type_id::create("gen", this);
    e = env::type_id::create("env", this);
  endfunction 
  
  //--------------------------------------
  // run_phase
  //--------------------------------------
  task run_phase (uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seqr);
    #100;
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : test

    
////////////////////////////////////////////////////////////////  
module tb_dff();

  dff_if dif0();
  
  initial begin
  	dif0.clk <= 1'b0;
  	dif0.rst <= 1'b1;
    dif0.din <= 1'b0;
    #100 dif0.rst <= 1'b0;
  end 
    
  // Generate clock
  always
  	#10 dif0.clk = ~dif0.clk;
 
  // DUT
  dff dut_dff0(.clk(dif0.clk), .rst(dif0.rst), .din(dif0.din), .dout(dif0.dout));
    
  initial begin
    uvm_config_db #(virtual dff_if)::set(null, "*", "dff_if0", dif0);
  end 
  
  initial begin
    run_test("test");  
  end 
  
  initial begin
    $dumpfile("dump1.vcd");
	$dumpvars;
  end
  
endmodule : tb_dff
  




