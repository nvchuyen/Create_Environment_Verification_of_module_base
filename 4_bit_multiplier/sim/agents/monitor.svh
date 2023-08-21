

//////////////////////////////////////////////////////////////////////////
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
 
  uvm_analysis_port#(transaction) send;
  transaction tr;
  virtual mul_if mif;
 
    function new(input string inst = "monitor", uvm_component parent = null);
      super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tr = transaction::type_id::create("tr");
      send = new("send", this);
      
      if(!uvm_config_db#(virtual mul_if)::get(this,"","mif",mif))//uvm_test_top.env.agent.drv.aif
        `uvm_error("drv","Unable to access Interface");
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
    forever begin
      #20;
      tr.a = mif.a;
      tr.b = mif.b;
      tr.y = mif.y;
      `uvm_info("MONITOR", $sformatf("a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
      send.write(tr);
    end
   endtask 
 
endclass