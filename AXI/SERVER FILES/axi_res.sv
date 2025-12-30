//
////res

class axi_res extends uvm_component;
	`uvm_component_utils(axi_res)
	`NEW_COMP
	virtual axi_intf vif;
	axi_tx tx_wr[15:0];
	axi_tx tx_rd[15:0];
	bit[`ADDR_WIDTH-1:0]UPPER_BOUNDARY,LOWER_BOUNDARY;

	byte mem[int];
	byte memQ[int][$];

	semaphore smp_wa,smp_w,smp_ra,smp_b,smp_r;
	event e[15:0];
	
	function void build();
		assert(uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif));
		foreach(tx_wr[i]) tx_wr[i]=axi_tx::type_id::create($sformatf("tx_wr_res_id[%0d]",i));
		foreach(tx_rd[i]) tx_rd[i]=axi_tx::type_id::create($sformatf("tx_rd_res_id[%0d]",i));
		
		smp_wa=new(1);
		smp_w =new(1);
		smp_ra=new(1);
		smp_b =new(1);
		smp_r =new(1);
	endfunction

	task run();
		wait(vif.ARESETn==0);
		forever begin
		 @(posedge vif.ACLK);
		
		//fork
			write_addr_phase();	
		   write_data_phase();
		//	write_resp_phase();
			read_addr_phase();
		//	read_data_phase();
		//join_none

		end
	endtask

	task write_addr_phase();
			if(vif.AWVALID)begin
				vif.AWREADY=1;
				tx_wr[vif.AWID]=new;
				//signal
				tx_wr[vif.AWID].burst_len=vif.AWLEN;
				tx_wr[vif.AWID].burst_size=vif.AWSIZE;
				tx_wr[vif.AWID].burst_type=vif.AWBURST;
				tx_wr[vif.AWID].addr=vif.AWADDR;
				tx_wr[vif.AWID].id=vif.AWID;

						UPPER_BOUNDARY=calc_upper_addr(tx_wr[vif.AWID].addr,tx_wr[vif.AWID].burst_len,tx_wr[vif.AWID].burst_size);
						LOWER_BOUNDARY=calc_lower_addr(tx_wr[vif.AWID].addr,tx_wr[vif.AWID].burst_len,tx_wr[vif.AWID].burst_size);
		//	$display("write_addr_PHASE print");
		//	tx_wr[vif.AWID].print;
		//write_data_phase();
			end
			else begin 
				vif.AWREADY=0;
			end
	endtask

	task write_data_phase();
	//	int WID;
			if(vif.WVALID)begin
				vif.WREADY=1;
				smp_r.get(1);
				if(tx_wr[vif.WID].burst_type==WRAP)
						$display("UPPER_BOUNDARY=%0h LOWER_BOUNDARY=%0h",UPPER_BOUNDARY,LOWER_BOUNDARY);

				case(tx_wr[vif.WID].burst_type)
					
					FIXED:begin
						for(int i=0;i<2**tx_wr[vif.WID].burst_size;i++)begin
							memQ[tx_wr[vif.WID].addr].push_back(vif.WDATA[8*(i)+:8]);
						end
						
					end

					INCR:begin
						int valid_mem_pos,align_addr;
							align_addr=((tx_wr[vif.WID].addr)/(2**tx_wr[vif.WID].burst_size))*(2**tx_wr[vif.WID].burst_size);
							$display("%h %h %h",align_addr,tx_wr[vif.WID].addr,tx_wr[vif.WID].burst_size);
						for(int i=0;i<`DATA_WIDTH/8;i++)begin
							if(vif.WSTRB[i])begin
								if(tx_wr[vif.WID].addr%(2**tx_wr[vif.WID].burst_size)!=0)begin //not aligned
									if(tx_wr[vif.WID].addr==align_addr+valid_mem_pos)	 mem[align_addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
										$display("unaligned: ad=%0h al=%0h",tx_wr[vif.WID].addr,align_addr);
								end
								else begin//aligned
									if(tx_wr[vif.WID].addr==align_addr) mem[align_addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
										$display("aligned: ad=%0h al=%0h",tx_wr[vif.WID].addr,align_addr);
								end
								valid_mem_pos++;
							end
						end
						
						align_addr+=2**tx_wr[vif.WID].burst_size;
						tx_wr[vif.WID].addr=align_addr;
						end

					WRAP:begin
							int valid_mem_pos,align_addr;
							align_addr=((tx_wr[vif.WID].addr)/(2**tx_wr[vif.WID].burst_size))*(2**tx_wr[vif.WID].burst_size);
							$display("%h %h %h",align_addr,tx_wr[vif.WID].addr,tx_wr[vif.WID].burst_size);
						for(int i=0;i<`DATA_WIDTH/8;i++)begin
							if(vif.WSTRB[i])begin
								if((tx_wr[vif.WID].addr+valid_mem_pos)>UPPER_BOUNDARY)
									tx_wr[vif.WID].addr=LOWER_BOUNDARY;
									//	if(tx_wr[vif.WID].addr%(2**tx_wr[vif.WID].burst_size)!=0)begin //not aligned
									//		if(tx_wr[vif.WID].addr==align_addr+valid_mem_pos)	 mem[align_addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
									//			$display("unaligned: ad=%0h al=%0h",tx_wr[vif.WID].addr,align_addr);
									//	end
									//	else begin//aligned
									//		if(tx_wr[vif.WID].addr==align_addr) mem[align_addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
									//			$display("aligned: ad=%0h al=%0h",tx_wr[vif.WID].addr,align_addr);
									//	end
									//valid_mem_pos++;

									mem[tx_wr[vif.WID].addr+valid_mem_pos]=vif.WDATA[8*(i)+:8];
									valid_mem_pos++;
								end
						end
						tx_wr[vif.WID].addr+=2**tx_wr[vif.WID].burst_size;
					//	align_addr+=2**tx_wr[vif.WID].burst_size;
					//	tx_wr[vif.WID].addr=align_addr;
						end
				endcase
				//		WID=vif.WID;
				//	$display(" \twid:%0h \ttime:%0h",WID,$time);
			//->e[vif.WID];
		//	wait(e[id].triggered);
		//	$display($time," event[%0h],triggered",vif.WID);

					if(vif.WLAST)begin
					//	fork
							write_resp_phase(tx_wr[vif.WID].id);
					//	join_none
					end

				$displayh($time," %h, %p",vif.WDATA,mem);
		end
			else begin 
				vif.WREADY=0;
			end
				smp_r.put(1);
	endtask
	
	task write_resp_phase(int id);
				smp_b.get(1);
	fork
		begin
	//		while(!vif.WLAST) 
	//	 		@(posedge vif.ACLK);
				vif.BVALID=1;
				vif.BRESP=EXOKAY;
				vif.BID=id;

				wait(vif.BREADY);
		 		@(posedge vif.ACLK);
			   vif.BVALID=0 ;
			   vif.BRESP=0 ;
			   vif.BID=0 ;
		end
	join_none
				smp_b.put(1);
	endtask

	task read_addr_phase();
		//if(vif.BREADY)begin
			if(vif.ARVALID)begin
				vif.ARREADY=1;
				tx_rd[vif.ARID]=new;
				tx_rd[vif.ARID].burst_len=vif.ARLEN;
				tx_rd[vif.ARID].burst_size=vif.ARSIZE;
				tx_rd[vif.ARID].burst_type=vif.ARBURST;
				tx_rd[vif.ARID].id=vif.ARID;
				tx_rd[vif.ARID].addr=vif.ARADDR;
				//tx_rd[vif.ARID].addr=(tx_rd[vif.ARID].addr)/(2**tx_wr[vif.ARID].burst_size)*(2**tx_wr[vif.ARID].burst_size);

						UPPER_BOUNDARY=calc_upper_addr(tx_rd[vif.ARID].addr,tx_rd[vif.ARID].burst_len,tx_rd[vif.ARID].burst_size);
						LOWER_BOUNDARY=calc_lower_addr(tx_rd[vif.ARID].addr,tx_rd[vif.ARID].burst_len,tx_rd[vif.ARID].burst_size);
				read_data_phase(vif.ARID);
			end
			else begin 
				vif.ARREADY=0;
			end
	//	end
	endtask

	task read_data_phase(int id);
	int align_read_addr;
	fork
		begin
				smp_r.get(1);
	//	repeat(2*tx_rd[id].burst_len)@(posedge vif.ACLK);
		//	$display($time," event[%0h] is waiting",id);
			//repeat($urandom_range(0,20))@(posedge vif.ACLK);
			 for(int i=0;i<=tx_rd[id].burst_len;i++)begin
			//	smp_r.get(1);
			 	vif.RVALID=1 ;
				while(vif.RREADY==0)begin
					@(posedge vif.ACLK);
		   	end
						vif.RID=id;
				align_read_addr=(tx_rd[vif.RID].addr)/(2**tx_wr[vif.RID].burst_size)*(2**tx_wr[vif.RID].burst_size);

				case(tx_rd[vif.RID].burst_type)
					
					FIXED:begin
						for(int i=0;i<2**tx_rd[vif.RID].burst_size;i++)begin
							vif.RDATA[8*(i)+:8]=memQ[tx_rd[vif.RID].addr].pop_front();
						end
					end

					INCR:begin
						for(int i=0;i<2**tx_rd[vif.RID].burst_size;i++)begin
							vif.RDATA[8*(i)+:8]=mem[align_read_addr+i];//part-select
						end
						tx_rd[vif.RID].addr+=2**tx_rd[vif.RID].burst_size;
						align_read_addr+=2**tx_rd[vif.RID].burst_size;
					end
					
					WRAP:begin

						for(int i=0;i<2**tx_rd[vif.RID].burst_size;i++)begin
						//for(int i=0;i<`DATA_WIDTH/8;i++)begin
							if((tx_rd[vif.RID].addr+i)>UPPER_BOUNDARY)
								tx_rd[vif.RID].addr=LOWER_BOUNDARY;
							vif.RDATA[8*(i)+:8]=mem[tx_rd[vif.RID].addr+i];
						//	vif.RDATA[8*(i)+:8]=mem[align_read_addr+i];//part-select
						end
						tx_rd[vif.RID].addr+=2**tx_rd[vif.RID].burst_size;
					//	align_read_addr+=2**tx_rd[vif.RID].burst_size;
					end
				//	$display("\tradta=%0h\trid=%0h\ttime=%0h",vif.RDATA,vif.RID,$time);
				endcase

					vif.RLAST=(i==tx_rd[vif.RID].burst_len)? 1:0;
					vif.RRESP=EXOKAY;
			@(posedge vif.ACLK);
			vif.RLAST=0;
			vif.RVALID=0;
			vif.RDATA=0;
			vif.RRESP=0;
			vif.RID=0;
			//	smp_r.put(1);
		   end
				smp_r.put(1);
		end
	join_none
	endtask

	function int calc_lower_addr(bit[`ADDR_WIDTH-1:0]addr, int burst_len,burst_size);
		int rem;
		rem=addr%((burst_len+1)*(2**burst_size));
		return addr-rem;
	endfunction

	function int calc_upper_addr(bit[`ADDR_WIDTH-1:0]addr, int burst_len,burst_size);
		int rem,tx_size;
		tx_size=(burst_len+1)*(2**burst_size);
		rem=addr%tx_size;
		return (addr-rem)+tx_size-1;
	endfunction

endclass


