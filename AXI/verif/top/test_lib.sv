class axi_base_test extends uvm_test;
	`uvm_component_utils(axi_base_test)
	`NEW_COMP
	axi_env env;

	function void build();
		env=axi_env::type_id::create("env",this);
	endfunction

	function void end_of_elaboration();
		uvm_top.print_topology;
	endfunction

	function void report();
		
	endfunction
endclass
