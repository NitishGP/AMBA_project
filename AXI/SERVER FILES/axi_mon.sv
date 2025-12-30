
class axi_mon extends uvm_monitor;
	`uvm_component_utils(axi_mon)
	`NEW_COMP
	virtual axi_intf vif;
	uvm_analysis_port#(axi_tx) ap_port;
	axi_tx tx,tx_rd;
	SL_MS_en master_slave_f;

	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
		assert(uvm_config_db#(SL_MS_en)::get(this,"","master_slave_f",master_slave_f));
		ap_port=new("ap_port",this);
	endfunction


task run();
	if(master_slave_f==MASTER)begin
	$display("MASTER MON BLOCK INITIATED");
		forever begin
			@(vif.mon_cb);
			if(vif.mon_cb.AWVALID && vif.mon_cb.AWREADY)begin
				tx=axi_tx::type_id::create("tx_mon");
				tx.id=vif.mon_cb.AWID;
				tx.addr=vif.mon_cb.AWADDR;
				tx.burst_len=vif.mon_cb.AWLEN;
				tx.burst_type=vif.mon_cb.AWBURST;
				tx.burst_size=vif.mon_cb.AWSIZE;
				tx.wr_rd=1;
			end

			if(vif.mon_cb.WVALID && vif.mon_cb.WREADY)begin
					tx.id=vif.mon_cb.WID;
					tx.wstrb.push_back(vif.mon_cb.WSTRB);
					tx.dataQ.push_back(vif.mon_cb.WDATA);
			end

			if(vif.mon_cb.BVALID && vif.mon_cb.BREADY)begin
				tx.id=vif.mon_cb.BID;
				tx.respQ.push_back(vif.mon_cb.BRESP);
				ap_port.write(tx);
			//	$display($time," *******MASTER__WR_MON******");
			//	tx.print();
			end

			if(vif.mon_cb.ARVALID && vif.mon_cb.ARREADY)begin
				tx_rd=axi_tx::type_id::create("tx_rd_mon");
				tx.wr_rd=0;
				tx_rd.id=vif.mon_cb.ARID;
				tx_rd.addr=vif.mon_cb.ARADDR;
				tx_rd.burst_len=vif.mon_cb.ARLEN;
				tx_rd.burst_type=vif.mon_cb.ARBURST;
				tx_rd.burst_size=vif.mon_cb.ARSIZE;
			end

			if(vif.mon_cb.RVALID && vif.mon_cb.RREADY)begin
					tx_rd.id=vif.mon_cb.RID;
					tx_rd.dataQ.push_back(vif.mon_cb.RDATA);
				//	if(vif.mon_cb.RLAST) begin
				//		ap_port.write(tx_rd);
			//		$display($time," *******MASTER_RD_MON******");
			//			tx_rd.print;
				//	end
			end
		end
	end
	else begin
	$display("SLAVE MON BLOCK INITIATED");
		forever begin
			@(vif.mon_cb);
			if(vif.mon_cb.AWVALID && vif.mon_cb.AWREADY)begin
				tx=axi_tx::type_id::create("tx_mon");
				tx.id=vif.mon_cb.AWID;
				tx.addr=vif.mon_cb.AWADDR;
				tx.burst_len=vif.mon_cb.AWLEN;
				tx.burst_type=vif.mon_cb.AWBURST;
				tx.burst_size=vif.mon_cb.AWSIZE;
				tx.wr_rd=1;
			end

			if(vif.mon_cb.WVALID && vif.mon_cb.WREADY)begin
					tx.id=vif.mon_cb.WID;
					tx.dataQ.push_back(vif.mon_cb.WDATA);
			end

			if(vif.mon_cb.BVALID && vif.mon_cb.BREADY)begin
				tx.id=vif.mon_cb.BID;
				tx.respQ.push_back(vif.mon_cb.BRESP);
			//	ap_port.write(tx);
			//	$display($time," *******SLAVE__WR_MON******");
			//	tx.print();
			end

			if(vif.mon_cb.ARVALID && vif.mon_cb.ARREADY)begin
				tx_rd=axi_tx::type_id::create("tx_rd_mon");
				tx.wr_rd=0;
				tx_rd.id=vif.mon_cb.ARID;
				tx_rd.addr=vif.mon_cb.ARADDR;
				tx_rd.burst_len=vif.mon_cb.ARLEN;
				tx_rd.burst_type=vif.mon_cb.ARBURST;
				tx_rd.burst_size=vif.mon_cb.ARSIZE;
			end

			if(vif.mon_cb.RVALID && vif.mon_cb.RREADY)begin
					tx_rd.id=vif.mon_cb.RID;
					tx_rd.dataQ.push_back(vif.mon_cb.RDATA);
			//	$display($time," *******SLAVE__WR_MON******");
					if(vif.mon_cb.RLAST) begin
						ap_port.write(tx_rd);
		//			$display($time," *******SLAVE_RD_MON******");
			//			tx_rd.print;
					end
			end
		end
	end
	endtask
endclass
