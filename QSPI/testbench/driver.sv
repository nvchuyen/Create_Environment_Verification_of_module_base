

class driver; /* base class*/;
	stimulus sti;
	virtual my_interface intf;

   covergroup cov;
         Feature_1: coverpoint intf.command{  bins b1 = {8'h0B} ; 
                                              bins b2 = {8'hBB} ; 
                                              bins b3 = {8'hEB} ;
                                              } 
         Feature_2 :  coverpoint  intf.addr ; 
    endgroup


    function new(virtual my_interface intf);
         this.intf = intf;
         cov = new();
    endfunction

//////////////////////////////////////////////////////
//@ Testcase for reset
//////////////////////////////////////////////////////
    task reset();  // Reset method
     intf.data = 0;
     @ (negedge intf.clk);
     intf.reset = 1;
     @ (negedge intf.clk);
     intf.reset = 0;
     @ (negedge intf.clk);
     intf.reset = 1;
    endtask

//////////////////////////////////////////////////////
//@ Testcase for reset
//////////////////////////////////////////////////////
    task reset_negative();
       intf.data = 0;
       @ (negedge intf.clk);
       intf.reset = 1;
       @ (negedge intf.clk);
       intf.reset = 0;

       @ (negedge intf.clk);
        sti = new();
       @ (negedge intf.clk);
      if(sti.randomize())                 // Generate stimulus
        begin
          intf.data           = sti.data; // connect Drive to DUT using interface
          intf.addr           = sti.addr;
          intf.command        = sti.command;
          intf.rw             = 1'b1;
          intf.enable         = 1'b1;
          intf.burst_enable   = 1'b1;
          intf.burst_count    = sti.burst_count;
          intf.divider        = sti.divider;
          intf.cpha           = 0;
          intf.cpol           = 0;
          intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
        end 
        cov.sample();
        // cov.sample();
        #5000ns;
      @ (negedge intf.clk);
      intf.reset = 1;
    endtask

/////////////////////////////////////////////////////
//@ Method enable 
////////////////////////////////////////////////////
    task enable(); // Enable method
      intf.enable = 0;
      @ (negedge intf.clk)
      intf.enable = 1;
    endtask : enable

/////////////////////////////////////////////////////
//@ Testcase for test enable
/////////////////////////////////////////////////////
    task enable_negative(); // Enable method
      @ (negedge intf.clk);
      intf.enable = 0;
      @ (negedge intf.clk);
        sti = new();
       @ (negedge intf.clk);
      if(sti.randomize())                   // Generate stimulus
        begin
          intf.data           = sti.data;   // connect Drive to DUT using interface
          intf.addr           = sti.addr;
          intf.command        = sti.command;
          intf.rw             = 1'b1;
          intf.burst_enable   = 1'b1;
          intf.burst_count    = sti.burst_count;
          intf.divider        = sti.divider;
          intf.cpha           = 0;
          intf.cpol           = 0;
          intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
        end
        cov.sample();
        #1000ns;
        $display("[%0t ns]",$time);
      @ (negedge intf.clk)
      intf.enable = 1;
    endtask : enable_negative


//////////////////////////////////////////////////////
//@ program: Testcase 3 for mode 0 of SPI
//@ value:  CPOL = 0
//@ value:  CHHA = 0
//////////////////////////////////////////////////////
  	task drive_mode0SPI(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = 24'h333_033;//sti.addr;
            intf.command        = 8'heb; //sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = sti.burst_count;
            intf.divider        = sti.divider;
            intf.cpha           = 0;
            intf.cpol           = 0;
            intf.mode           = 2'b10;//((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
             wait(intf.done);
          end 
      end
	  endtask


//////////////////////////////////////////////////////
//@ program: Testcase 4 for mode 1 of SPI
//@ value:  CPOL = 0
//@ value:  CHHA = 1
//////////////////////////////////////////////////////
    task drive_mode1SPI(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = sti.addr;
            intf.command        = sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = sti.burst_count;
            intf.divider        = sti.divider;
            intf.cpha           = 0;
            intf.cpol           = 1;
            intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
             wait(intf.done);
          end 
      end
    endtask


//////////////////////////////////////////////////////
//@ program: Testcase 5 for mode 2 of SPI
//@ value:  CPOL = 1
//@ value:  CHHA = 0
//////////////////////////////////////////////////////
    task drive_mode2SPI(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = sti.addr;
            intf.command        = sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = sti.burst_count;
            intf.divider        = sti.divider;
            intf.cpha           = 1;
            intf.cpol           = 0;
            intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
             wait(intf.done);
          end 
      end
    endtask


//////////////////////////////////////////////////////
//@ program: Testcase 6 for mode 3 of SPI
//@ value:  CPOL = 1
//@ value:  CHHA = 1
//////////////////////////////////////////////////////
    task drive_mode3SPI(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = sti.addr;
            intf.command        = sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = sti.burst_count;
            intf.divider        = sti.divider;
            intf.cpha           = 1;
            intf.cpol           = 1;
            intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
            wait(intf.done);
          end 
      end
    endtask


//////////////////////////////////////////////////////
//@ program: Testcase 7 for mode 0 of SPI check data receive 
//@ value:  CPOL = 0
//@ value:  CHHA = 0
//////////////////////////////////////////////////////
    task drive_check_data(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = 24'h000_004;  //
            intf.command        = 8'heb;//sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = 16'h0001;
            intf.divider        = sti.divider;
            intf.cpha           = 0;
            intf.cpol           = 0;
            intf.mode           = ((intf.command == 8'h0B) ? 2'b00 : ((intf.command == 8'hBB)? 2'b01 : ((intf.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
            wait(intf.done);
          end 
      end
    endtask

//////////////////////////////////////////////////////
//@ program: Testcase 8 for check send command wrong
//@ value:  
//@ value:  
//////////////////////////////////////////////////////
    task drive_check_commad_wrong(input integer iteration);
     repeat(iteration)
     begin
          sti = new();
          @ (negedge intf.clk);
          if(sti.randomize())                   // Generate stimulus
          begin
            intf.data           = sti.data;     // connect Drive to DUT using interface
            intf.addr           = sti.addr;  //
            intf.command        = sti.command;
            intf.rw             = 1'b1;
            intf.enable         = 1'b1;
            intf.burst_enable   = 1'b1;
            intf.burst_count    = 16'h0001;
            intf.divider        = sti.divider;
            intf.cpha           = 1;
            intf.cpol           = 1;
            intf.mode           = ((sti.command == 8'h0B) ? 2'b00 : ((sti.command == 8'hBB)? 2'b01 : ((sti.command == 8'hEB)? 2'b10:2'b11)));
            cov.sample();
            wait(intf.done);
          end 
      end
    endtask
endclass
