class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)
	`NEW_COMP
	axi_sbd sbd;
	axi_agent m_agent,s_agent;
	//SL_MS_en slave_master_f;

	function void build();
		m_agent=axi_agent::type_id::create("m_agent",this);
		s_agent=axi_agent::type_id::create("s_agent",this);
		$display("**********************************");
		uvm_config_db#(SL_MS_en)::set(this,"m_agent*","master_slave_f",MASTER);
		uvm_config_db#(SL_MS_en)::set(this,"s_agent*","master_slave_f",SLAVE);
		$display("**********************************");

		sbd=axi_sbd::type_id::create("sbd",this);
	endfunction

	function void connect();
		m_agent.mon.ap_port.connect(sbd.sbd_master_imp);
		s_agent.mon.ap_port.connect(sbd.sbd_slave_imp);
	endfunction
endclass
