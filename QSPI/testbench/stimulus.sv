////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s                                      s////
////s           input random for code      s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////

class stimulus;

  rand logic  [0:31]   data;
  rand logic  [0:23]   addr;
  rand logic  [0:7 ]   command;
  rand logic           rw;
  rand logic           enable;
  rand logic           burst_enable;
  rand logic  [0:15]   burst_count;
  rand logic  [0:15]   divider;
  rand logic           cpha;
  rand logic           cpol;
  rand logic  [0:1]    mode;

  // constraint distribution {value dist { 0  := 1 , 1 := 1 }; } 
     // constraint  c_addr{  }
     constraint c_input {
          addr           < 10      ;
          divider        < 10      ;   
          burst_count    < 10      ;   
     }
     constraint  command_t {command dist { 'h0b:=1,  'hbb:=1, 'heb:=1 }; }
endclass
