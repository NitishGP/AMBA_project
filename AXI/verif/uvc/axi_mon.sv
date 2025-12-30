
class axi_mon extends uvm_monitor;
	`uvm_component_utils(axi_mon)
	`NEW_COMP
	virtual axi_intf vif;
	uvm_analysis_port#(axi_tx) ap_port;
	axi_tx tx;

	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
		ap_port=new("ap_port",this);
	endfunction

	task run();
	endtask
endclass
