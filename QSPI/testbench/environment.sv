////////////////////////////////////////
// initial enviroment
////////////////////////////////////////

class environment; 
	driver drvr;
	virtual my_interface intf;

	function new (virtual my_interface intf);
		this.intf = intf;
		drvr 	  = new(intf);
	endfunction 
	
endclass
