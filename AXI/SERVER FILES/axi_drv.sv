

class axi_drv extends uvm_driver#(axi_tx);
	`uvm_component_utils(axi_drv)
	`NEW_COMP
	virtual axi_intf vif;
   uvm_line_printer lp=new();
	semaphore smp_wa,smp_w,smp_ra,smp_b,smp_r;
		
	function int calc_strb(int strb,n,b_s);
			bit[`STRB_WIDTH-1:0]t;
		begin
			t=strb;
			repeat(n*(2**b_s))begin
				strb={strb[0],strb[`STRB_WIDTH-1:1]};
				t=strb;
			end
		//	$display("%b %b",strb,t);
		return t;
		end
	endfunction
	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
		smp_wa=new(1);
		smp_w =new(1);
		smp_ra=new(1);
		smp_b =new(1);
		smp_r =new(1);
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		wait(vif.ARESETn==0);
		forever begin
			seq_item_port.get_next_item(req);
		//	req.print();
				drive(req);
				
			seq_item_port.item_done();
		end
	endtask

	task drive(axi_tx tx);
		if(tx.wr_rd)begin
			write_addr_phase(tx);
			write_data_phase(tx);
			write_resp_phase(tx);
		end
		else begin
			read_addr_phase(tx);
			read_data_phase(tx);
		end
	endtask

	task write_addr_phase(axi_tx tx);
		smp_wa.get(1);
		@(posedge vif.ACLK);
			vif.AWVALID=1;
			vif.AWLEN=tx.burst_len;
			vif.AWSIZE=tx.burst_size;
			vif.AWBURST=tx.burst_type;
			vif.AWID=tx.id;
			vif.AWADDR=tx.addr;
			wait(vif.AWREADY);
		@(posedge vif.ACLK);
			vif.AWVALID=0;
			vif.AWLEN=0;
			vif.AWSIZE=0;
			vif.AWBURST=0;
			vif.AWID=0;
			vif.AWADDR=0;
		smp_wa.put(1);
	endtask

	task write_data_phase(axi_tx tx);
		smp_w.get(1);
		 for(int i=0;i<tx.burst_len+1;i++)begin
				@(posedge vif.ACLK);
				vif.WVALID=1;
				vif.WID=tx.id;
				vif.WSTRB=tx.wstrb[i];
				vif.WDATA=tx.dataQ[i];
				vif.WLAST=(i==tx.burst_len) ? 1:0;
				wait(vif.WREADY);

				@(posedge vif.ACLK);
				vif.WLAST=0;
				vif.WVALID=0;
				vif.WID=0;
				vif.WDATA=0;
				vif.WSTRB=0;
			end
		smp_w.put(1);
	endtask

	task write_resp_phase(axi_tx tx);
	while(!vif.BVALID) @(posedge vif.ACLK);
			vif.BREADY=1;
			@(posedge vif.ACLK);
			vif.BREADY=0;
	endtask

	task read_addr_phase(axi_tx tx);
	smp_ra.get(1);
		@(posedge vif.ACLK);
			vif.ARVALID=1;
			vif.ARLEN=tx.burst_len;
			vif.ARSIZE=tx.burst_size;
			vif.ARBURST=tx.burst_type;
			vif.ARID=tx.id;
			vif.ARADDR=tx.addr;
			wait(vif.ARREADY);
		@(posedge vif.ACLK);
			vif.ARVALID=0;
			vif.ARLEN=0;
			vif.ARSIZE=0;
			vif.ARBURST=0;
			vif.ARID=0;
			vif.ARADDR=0;
	smp_ra.put(1);
	endtask

	task read_data_phase(axi_tx tx);
		while(!vif.RVALID)
			@(posedge vif.ACLK);

			for(int i=0;i<tx.burst_len+1;i++)begin
				vif.RREADY=1;
				@(posedge vif.ACLK);
			end
		@(posedge vif.ACLK);
				vif.RREADY=0;
	endtask
endclass

class axi_overlap_drv extends axi_drv;
	`uvm_component_utils(axi_overlap_drv)
	`NEW_COMP

		
	task run_phase(uvm_phase phase);
		wait(vif.ARESETn==0);
		forever begin
			seq_item_port.get_next_item(req);
		//	req.print();
		fork
			begin
				drive(req);
			end
		join_none
		#20;
		seq_item_port.item_done();
		end
	endtask


endclass
