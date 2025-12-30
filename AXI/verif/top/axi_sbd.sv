
class axi_sbd extends uvm_scoreboard;
	`uvm_component_utils(axi_sbd)
	`NEW_COMP
	`uvm_analysis_imp#(axi_tx,axi_sbd) sbd_imp;

	function void build();
		sbd_imp=new("sbd_imp",this);
	endfunction

	function void write(axi_tx t);
	endfunction
endclass
