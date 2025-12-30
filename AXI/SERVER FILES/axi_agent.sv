
class axi_agent extends uvm_agent;
	`uvm_component_utils(axi_agent)
	`NEW_COMP

	axi_sqr sqr;
	axi_drv drv;
	axi_res res;
	axi_mon mon;
	axi_cov cov;

	SL_MS_en master_slave_f;

	function void build();
		assert(uvm_config_db#(SL_MS_en)::get(this,"","master_slave_f",master_slave_f));
		if(master_slave_f==MASTER)begin
			sqr=axi_sqr::type_id::create("sqr",this);
			drv=axi_drv::type_id::create("drv",this);
			mon=axi_mon::type_id::create("mon",this);
			cov=axi_cov::type_id::create("cov",this);
		end
		else begin
			res=axi_res::type_id::create("res",this);
			mon=axi_mon::type_id::create("mon",this);
		end
	endfunction

	function void connect();
		if(master_slave_f==MASTER) begin
			drv.seq_item_port.connect(sqr.seq_item_export);
			mon.ap_port.connect(cov.analysis_export);
		end
	endfunction
endclass
