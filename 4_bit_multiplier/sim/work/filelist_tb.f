+libext+.svh+.vh+.v+.sv
+define+LITLE_ENDIAN 
+define+UART_ABV_ON 
+define+UVM_RGM_NO_BACKDOOR_DPI
+define+UVM_CMDLINE_NO_DPI
+define+UVM_REGEX_NO_DPI
+incdir+$UVM_HOME/src
$UVM_HOME/src/uvm_pkg.sv
$UVM_HOME/src/uvm.sv
//-v ${UVM_HOME}/src/dpi/uvm_dpi.svh
//-v ${UVM_HOME}/src/dpi/uvm_dpi.cc
//-y ${UVM_HOME}/src/dpi
//+incdir+${UVM_HOME}/src/dpi

+incdir+../env
+incdir+../agents
+incdir+../sequence
+incdir+../test
+incdir+../top_tb

-y ../env
-y ../agents
-y ../sequence
-y ../test
-y ../top_tb

//top_tb
../top_tb/top_tb.sv
