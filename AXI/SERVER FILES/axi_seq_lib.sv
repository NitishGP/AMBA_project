class axi_base_seq extends uvm_sequence#(axi_tx);
	`uvm_object_utils(axi_base_seq)
	`NEW_OBJ
	uvm_phase phase;
	int wr_count,rd_count;

	task pre_body();
	phase=get_starting_phase();
	if(phase!=null)begin
		phase.raise_objection(null);
		phase.phase_done.set_drain_time(this,200);
	end
	endtask

	task post_body();
	if(phase!=null)begin
		phase.drop_objection(null);
	end
	endtask
endclass

class axi_seq_1wr_incr extends axi_base_seq;
	`uvm_object_utils(axi_seq_1wr_incr)
	`NEW_OBJ

	task body();
	count=1;
		`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==1;})
	endtask
endclass

class axi_seq_1rd_incr extends axi_base_seq;
	`uvm_object_utils(axi_seq_1rd_incr)
	`NEW_OBJ

	task body();
	count=1;
		`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==0;})
	endtask
endclass

class axi_seq_1_wr_rd_incr extends axi_base_seq;
	`uvm_object_utils(axi_seq_1_wr_rd_incr)
	`NEW_OBJ
	axi_tx temp;

	task body();
			count=1;
			`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==1;req.addr=='h07;req.burst_len==3;req.burst_size==2;})
			temp= new req;
			`uvm_do_with(req,{req.burst_type==temp.burst_type;req.wr_rd==0;req.addr==temp.addr;req.burst_size==temp.burst_size;req.burst_len==temp.burst_len;req.id==temp.id;})
	endtask
endclass

class axi_seq_5_wr_rd_incr extends axi_base_seq;
	`uvm_object_utils(axi_seq_5_wr_rd_incr)
	`NEW_OBJ
	axi_tx tempQ[$],temp;

	task body();
		repeat(5) begin
			`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==1;})
			tempQ.push_back(req);
		end
		repeat(5)begin
			temp=tempQ.pop_front();
			`uvm_do_with(req,{req.burst_type==temp.burst_type;req.wr_rd==0;req.addr==temp.addr;req.burst_size==temp.burst_size;req.burst_len==temp.burst_len;req.id==temp.id;})
		end
		count=5;
	endtask
endclass

class axi_seq_5_wr_rd_wrap extends axi_base_seq;
	`uvm_object_utils(axi_seq_5_wr_rd_wrap)
	`NEW_OBJ
	axi_tx tempQ[$],temp;

	task body();
		repeat(5) begin
			`uvm_do_with(req,{req.burst_type==WRAP;req.wr_rd==1;})
			tempQ.push_back(req);
		end
		repeat(5)begin
			temp=tempQ.pop_front();
			`uvm_do_with(req,{req.burst_type==temp.burst_type;req.wr_rd==0;req.addr==temp.addr;req.burst_size==temp.burst_size;req.burst_len==temp.burst_len;req.id==temp.id;})
		end
		count=5;
	endtask
endclass

class axi_seq_5_wr_rd_fixed extends axi_base_seq;
	`uvm_object_utils(axi_seq_5_wr_rd_fixed)
	`NEW_OBJ
	axi_tx tempQ[$],temp;

	task body();
		repeat(5) begin
			`uvm_do_with(req,{req.burst_type==FIXED;req.wr_rd==1;})
			tempQ.push_back(req);
		end
		repeat(5)begin
			temp=tempQ.pop_front();
			`uvm_do_with(req,{req.burst_type==temp.burst_type;req.wr_rd==0;req.addr==temp.addr;req.burst_size==temp.burst_size;req.burst_len==temp.burst_len;req.id==temp.id;})
		end
		count=5;
	endtask
endclass



class axi_seq_n_wr_rd_incr extends axi_base_seq;
	`uvm_object_utils(axi_seq_n_wr_rd_incr)
	`NEW_OBJ
	bit[`ADDR_WIDTH-1:0] txQ[$];

	task body();
		uvm_config_db#(int)::get(null,"","WR_COUNT",wr_count);
		uvm_config_db#(int)::get(null,"","RD_COUNT",rd_count);
		repeat(wr_count)begin
			`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==1;})
			txQ.push_back(req.addr);
		end
		repeat(rd_count)`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==0;req.addr==txQ.pop_front();})
		count=rd_count;
	endtask
endclass

class axi_overlap_seq extends axi_base_seq;
	`uvm_object_utils(axi_overlap_seq)
	`NEW_OBJ
	
	axi_tx tempQ[$],temp;

	task body();
		uvm_resource_db#(txn_type_en)::set("GLOBAL","TXN_TYPE","OVERLAP",this);

			repeat(5) begin
				`uvm_do_with(req,{req.burst_type==INCR;req.wr_rd==1;req.burst_size==2;})
				tempQ.push_back(req);
			end
			repeat(5)begin
				temp=tempQ.pop_front();
				`uvm_do_with(req,{req.burst_type==temp.burst_type;req.wr_rd==0;req.addr==temp.addr;req.burst_size==temp.burst_size;req.burst_len==temp.burst_len;req.id==temp.id;})
			end
		count=5;
	endtask
endclass










