//-----------------------------------------------
// 
//
//
//------------------------------------------------
//
// Class Driver Description 
// 
 
`include "driver.svh"
// `include "mul_if.sv"
// `include "transaction.svh"


class agent extends uvm_agent;
    `uvm_component_utils(agent)
 
    function new(input string inst = "agent", uvm_component parent = null);
        super.new(inst,parent);
    endfunction
 
    driver d;
    uvm_sequencer#(transaction) seqr;
    monitor m;
 
    ///////////////////
    config_dff cfg;

    //-------------------------------------------
    // build phase 
    //-------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m = monitor::type_id::create("m",this);
        cfg = config_dff::type_id::create("cfg"); 

        ////////////////////////////////////////////////////////////
        if(!uvm_config_db#(config_dff)::get(this, "", "cfg", cfg))
        `uvm_error("AGENT", "FAILED TO ACCESS CONFIG");
  
        if(cfg.agent_type == UVM_ACTIVE) begin
            d = driver::type_id::create("d",this); 
            seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); 
        end 
    endfunction
 
    //--------------------------------------------
    // connect phase
    //-------------------------------------------- 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export);
    endfunction
 
endclass : agent