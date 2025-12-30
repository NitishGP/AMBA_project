
class axi_drv extends uvm_driver #(axi_tx);
	`uvm_component_utils(axi_drv)
	`NEW_COMP
	virtual axi_intf vif;

	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
	endfunction

	task run();
	endtask

	task drive();
	endtask
endclass
