
class axi_cov extends uvm_subscriber#(axi_tx);
	`uvm_component_utils(axi_cov)
	
	covergroup axi_cvg;
	endgroup

	function new(string name,uvm_component parent);
		super.new(name,parent);
		axi_cvg=new();
	endfunction
	
	task run();
	endtask

	function void write(axi_tx t);
	endfunction

endclass
