//align addr
	int valid_mem_pos,align_addr;
							align_addr=((tx_wr[vif.WID].addr)/(2**tx_wr[vif.WID].burst_size))*(2**tx_wr[vif.WID].burst_size);
							$display("%h %h %h",align_addr,tx_wr[vif.WID].addr,tx_wr[vif.WID].burst_size);
//	int valid_mem_pos;
						for(int i=0;i<`DATA_WIDTH/8;i++)begin
							if(vif.WSTRB[i])begin
									if(tx_wr[vif.WID].addr<=align_addr+valid_mem_pos) mem[align_addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
								$display("ad=%0h al=%0h",tx_wr[vif.WID].addr,align_addr+valid_mem_pos);
								valid_mem_pos++;
							end
						end
						tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;
						//align_addr+=2**tx_wr[vif.WID].burst_size;


//
	
				case(tx_wr[vif.WID].burst_type)
					
					FIXED:begin
						vif.WDATA[7:0]  =mem[tx_wr[vif.WID].addr];
						vif.WDATA[15:8] =mem[tx_wr[vif.WID].addr];
						vif.WDATA[23:16]=mem[tx_wr[vif.WID].addr];
						vif.WDATA[31:24]=mem[tx_wr[vif.WID].addr];
					end

					INCR:begin
						vif.WDATA[7:0]  =mem[tx_wr[vif.WID].addr];
						vif.WDATA[15:8] =mem[tx_wr[vif.WID].addr+1];
						vif.WDATA[23:16]=mem[tx_wr[vif.WID].addr+2];
						vif.WDATA[31:24]=mem[tx_wr[vif.WID].addr+3];
						tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;
					end
					
					WRAP:begin
						vif.WDATA[7:0]  =mem[tx_wr[vif.WID].addr];
						vif.WDATA[15:8] =mem[tx_wr[vif.WID].addr+1];
						vif.WDATA[23:16]=mem[tx_wr[vif.WID].addr+2];
						vif.WDATA[31:24]=mem[tx_wr[vif.WID].addr+3];
						tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;
						if(tx_wr[vif.WID].burst_type==WRAP)begin
							if((tx_wr[vif.WID].addr+3)>=UPPER_BOUNDARY)
								tx_wr[vif.WID].addr=LOWER_BOUNDARY;
						end
					end
				//	$display("\trdata=%0h\twid=%0h\ttime=%0h",vif.WDATA,vif.WID,$time);
				endcase

				case(tx_rd[vif.RID].burst_type)
					
					FIXED:begin
						vif.RDATA[7:0]  =mem[tx_rd[vif.RID].addr];
						vif.RDATA[15:8] =mem[tx_rd[vif.RID].addr];
						vif.RDATA[23:16]=mem[tx_rd[vif.RID].addr];
						vif.RDATA[31:24]=mem[tx_rd[vif.RID].addr];
					end

					INCR:begin
						vif.RDATA[7:0]  =mem[tx_rd[vif.RID].addr];
						vif.RDATA[15:8] =mem[tx_rd[vif.RID].addr+1];
						vif.RDATA[23:16]=mem[tx_rd[vif.RID].addr+2];
						vif.RDATA[31:24]=mem[tx_rd[vif.RID].addr+3];
						tx_rd[vif.RID].addr+=2**tx_rd[vif.RID].burst_size;
					end
					
					WRAP:begin
						vif.RDATA[7:0]  =mem[tx_rd[vif.RID].addr];
						vif.RDATA[15:8] =mem[tx_rd[vif.RID].addr+1];
						vif.RDATA[23:16]=mem[tx_rd[vif.RID].addr+2];
						vif.RDATA[31:24]=mem[tx_rd[vif.RID].addr+3];
						tx_rd[vif.RID].addr+=2**tx_rd[vif.RID].burst_size;
						if(tx_rd[vif.RID].burst_type==WRAP)begin
							if((tx_rd[vif.RID].addr+3)>=UPPER_BOUNDARY)
								tx_rd[vif.RID].addr=LOWER_BOUNDARY;
						end
					end
				//	$display("\tradta=%0h\trid=%0h\ttime=%0h",vif.RDATA,vif.RID,$time);
				endcase

//res

class axi_res extends uvm_component;
	`uvm_component_utils(axi_res)
	`NEW_COMP
	virtual axi_intf vif;
	axi_tx tx[15:0];

	byte mem[int];

	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
		tx=axi_tx::type_id::create("tx_res");
	endfunction

	task run();
		wait(vif.ARESETn==0);
		forever begin
		 @(posedge vif.ACLK);
		 
			write_addr_phase();	
			write_data_phase();
			write_resp_phase();
			read_addr_phase();
			read_data_phase();

		end
	endtask

	task write_addr_phase();
			if(vif.AWVALID)begin
				vif.AWREADY=1;

				//signal
				tx[vif.AWID].burst_len=vif.AWLEN;
				tx[vif.AWID].burst_size=vif.AWSIZE;
				tx[vif.AWID].burst_type=vif.AWBURST;
				tx[vif.AWID].addr=vif.AWADDR;
				tx[vif.AWID].id=vif.AWID;
			end
			else begin 
				vif.AWREADY=0;
			end
	endtask

	task write_data_phase();
		for(int i=0;i<=tx[vif.AWID].burst_len;i++)begin
			if(vif.WVALID)begin
				vif.WREADY=1;
				@(posedge vif.ACLK);
				//$display("Handshake from slave_write_data initiated");
					mem[tx[vif.WID].addr]=vif.WDATA[7:0];
					mem[tx[vif.WID].addr+1]=vif.WDATA[15:8];
					mem[tx[vif.WID].addr+2]=vif.WDATA[23:16];
					mem[tx[vif.WID].addr+3]=vif.WDATA[31:24];
					tx[vif.WID].addr+=4;
					$displayh($time,"%d %h, %p",i,vif.WDATA,mem);

			end
			else begin 
				vif.WREADY=0;
			end
		end
	endtask
	
	task write_resp_phase();
	fork
		begin
			while(!vif.WLAST) 
		 		@(posedge vif.ACLK);
				vif.BVALID=1;
				vif.BRESP=EXOKAY;
				vif.BID=tx[vif.WID].id;

				wait(vif.BREADY);
		 		@(posedge vif.ACLK);
			   vif.BVALID=0 ;
			   vif.BRESP=0 ;
			   vif.BID=0 ;
		end
	join_none
	endtask

	task read_addr_phase();
			if(vif.ARVALID)begin
				vif.ARREADY=1;
				tx[vif.ARID].burst_len=vif.ARLEN;
				tx[vif.ARID].burst_size=vif.ARSIZE;
				tx[vif.ARID].burst_type=vif.ARBURST;
				tx[vif.ARID].id=vif.ARID;
				tx[vif.ARID].addr=vif.ARADDR;
			end
			else begin 
				vif.ARREADY=0;
			end
	endtask

	task read_data_phase();
		if(vif.ARREADY==1) begin
//		for(int i=0;i<=tx.burst_len;i++)begin
//			 vif.RVALID=1 ;
//			 if(i==tx.burst_len) vif.RLAST=1;
//				//$display("Handshake from slave_read_data initiated");
//				//$display("Write_data_PHASE completed successfully");
//					vif.RDATA[7:0]  =mem[tx.addr];
//					vif.RDATA[15:8] =mem[tx.addr+1];
//					vif.RDATA[23:16]=mem[tx.addr+2];
//					vif.RDATA[31:24]=mem[tx.addr+3];
//					@(posedge vif.ACLK);
//					tx.addr+=4;
//					vif.RRESP=OKAY;
//					$display($time,"  vif_rdata::%h",vif.RDATA);
//		   end
//			@(posedge vif.ACLK);
//			vif.RLAST=0;
//			vif.RVALID=0;
//			vif.RDATA=0;
//		end

			 for(int i=0;i<=tx[vif.ARID].burst_len;i++)begin
				//$display("Handshake from slave_read_data initiated");
			 	vif.RVALID=1 ;
				while(vif.RREADY==0)begin
					@(posedge vif.ACLK);
		   	end
				//$display("Write_data_PHASE completed successfully");
					vif.RDATA[7:0]  =mem[tx[vif.ARID].addr];
					vif.RDATA[15:8] =mem[tx[vif.ARID].addr+1];
					vif.RDATA[23:16]=mem[tx[vif.ARID].addr+2];
					vif.RDATA[31:24]=mem[tx[vif.ARID].addr+3];
					tx[vif.ARID].addr+=4;
					vif.RLAST=(i==tx[vif.ARID].burst_len)? 1:0;
					vif.RRESP=EXOKAY;
					vif.RID=tx[vif.ARID].id;
					//$display($time,"  vif_rdata::%h",vif.RDATA);
			@(posedge vif.ACLK);
			vif.RLAST=0;
			vif.RVALID=0;
			vif.RDATA=0;
			vif.RRESP=0;
			vif.RID=0;
		   end
		end
	endtask
endclass
//mon

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
					tx.dataQ.push_back(vif.mon_cb.WDATA);
			end

			if(vif.mon_cb.BVALID && vif.mon_cb.BREADY)begin
				tx.id=vif.mon_cb.BID;
				tx.respQ.push_back(vif.mon_cb.BRESP);
				ap_port.write(tx);
				$display($time," *******MASTER__WR_MON******");
				tx.print();
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
					if(vif.mon_cb.RLAST) begin
						ap_port.write(tx_rd);
					$display($time," *******MASTER_RD_MON******");
						tx_rd.print;
					end
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
				ap_port.write(tx);
				$display($time," *******SLAVE__WR_MON******");
				tx.print();
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
					if(vif.mon_cb.RLAST) begin
						ap_port.write(tx_rd);
					$display($time," *******SLAVE_RD_MON******");
						tx_rd.print;
					end
			end
		end
	end
	endtask
endclass

//
if(tx_wr[vif.RID].burst_type==INCR)
						tx_wr[vif.RID].addr+=2**tx_wr[vif.RID].burst_size;

					if(tx_wr[vif.RID].burst_type==WRAP)begin
						UPPER_BOUNDARY=calc_upper_addr(tx_wr[vif.RID].addr,tx_wr[vif.RID].burst_len,tx_wr[vif.RID].burst_size);
						LOWER_BOUNDARY=calc_lower_addr(tx_wr[vif.RID].addr,tx_wr[vif.RID].burst_len,tx_wr[vif.RID].burst_size);
						if((tx_wr[vif.RID].addr+3)!=UPPER_BOUNDARY)
							tx_wr[vif.RID].addr+=2**tx_wr[vif.RID].burst_size;
						else tx_wr[vif.RID].addr=LOWER_BOUNDARY;

	function int calc_upper_addr(bit[`ADDR_WIDTH-1:0]addr, int burst_len,burst_size);
		int rem;
		rem=addr%((burst_len+1)*(2**burst_size));
		return addr-rem;
	endfunction

	function int calc_lower_addr(bit[`ADDR_WIDTH-1:0]addr, int burst_len,burst_size);
		int rem,tx_size;
		tx_size=(burst_len+1)*(2**burst_size);
		rem=addr%tx_size;
		return (addr-rem)+tx_size;
	endfunction
endclass
					if(tx_wr[vif.WID].burst_type==INCR)
						tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;

					if(tx_wr[vif.WID].burst_type==WRAP)begin
						UPPER_BOUNDARY=calc_upper_addr(tx_wr[vif.WID].addr,tx_wr[vif.WID].burst_len,tx_wr[vif.WID].burst_size);
						LOWER_BOUNDARY=calc_lower_addr(tx_wr[vif.WID].addr,tx_wr[vif.WID].burst_len,tx_wr[vif.WID].burst_size);
						if((tx_wr[vif.WID].addr+3)!=UPPER_BOUNDARY)
							tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;
						else tx_wr[vif.WID].addr=LOWER_BOUNDARY;
					end


