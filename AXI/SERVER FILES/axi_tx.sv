class axi_tx extends uvm_sequence_item;
	`NEW_OBJ
	rand bit[`ID_WIDTH-1:0] id;
	rand bit[`ADDR_WIDTH-1:0] addr;
	rand bit[`DATA_WIDTH-1:0] dataQ[$];
	rand bit wr_rd;
	rand bit[3:0] burst_len;
	rand bit[1:0] burst_size;
	bit[`STRB_WIDTH-1:0] wstrb[$];
	rand burst_type_en burst_type;
	resp_type_en respQ[$];

	`uvm_object_utils_begin(axi_tx)
		`uvm_field_int(id,UVM_DEFAULT)
		`uvm_field_int(addr,UVM_DEFAULT)
		`uvm_field_queue_int(wstrb,UVM_DEFAULT)
		`uvm_field_queue_int(dataQ,UVM_DEFAULT)
		`uvm_field_int(wr_rd,UVM_DEFAULT)
		`uvm_field_int(burst_len,UVM_DEFAULT)
		`uvm_field_int(burst_size,UVM_DEFAULT)
		`uvm_field_enum(burst_type_en,burst_type,UVM_DEFAULT)
		`uvm_field_queue_enum(resp_type_en,respQ,UVM_DEFAULT)
	`uvm_object_utils_end

	function void post_randomize();
		int temp_addr,strb;
		bit[$clog2(`STRB_WIDTH)]valid_pos;
		strb=0;
		temp_addr=addr;
		for(int k=0;k<=burst_len;k++)begin
			valid_pos=((temp_addr-(temp_addr%(2**burst_size)))%(`DATA_WIDTH/8));
			strb='b0;
			for(int j=0;j<2**burst_size;j++)begin
				strb[valid_pos]=1;
				valid_pos++;
			end
			if(burst_type==FIXED)	wstrb.push_back(strb);

			else begin
				repeat(k*(2**burst_size))begin
					strb={strb[`STRB_WIDTH-2:0],strb[`STRB_WIDTH-1]};
				end
					wstrb.push_back(strb);
			end
		end

	//temp=(8*(2**burst_size))-1;
	//	if(!wr_rd) foreach(dataQ[i]) dataQ[i]=0;
	//	foreach(dataQ[i]) 
	//		foreach(dataQ[i][j]) if(!(j inside {[0:temp]})) dataQ[i][j]=1'b0;
	endfunction
	
	constraint tx_c{
		dataQ.size()==burst_len+1;
		burst_len inside {[0:8]};
		(burst_type==WRAP) -> (burst_len inside {1,3,7,15});
		(burst_type==WRAP) -> (addr%(2**burst_size)==0);
		burst_type!=RSVD_BURST;

		
		
		(2**burst_size)<=`DATA_WIDTH/8;
		//(wr_rd==0) -> (foreach(dataQ[i]) dataQ[i]==0);
	}
endclass
