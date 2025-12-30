
class axi_cov extends uvm_subscriber#(axi_tx);
	`uvm_component_utils(axi_cov)
	axi_tx tx;
//	`uvm_analysis_imp_decl(_master_mon)

	covergroup axi_cvg;
		WR_RD:coverpoint tx.wr_rd{
			bins write={1'b1};
			bins  read={1'b0};
		}	
		ID : coverpoint tx.id{
			option.auto_bin_max=4;
		}
		ADDR: coverpoint tx.addr{
			option.auto_bin_max=4;
		}
		BURST_LEN:coverpoint tx.burst_len;
		BURST_TYPE:coverpoint tx.burst_type;
		BURST_SIZE:coverpoint tx.burst_size;

		WR_RDxADDR   : cross WR_RD,ADDR; 
		IDxBURST_LEN : cross ID,BURST_LEN; 
		IDxBURST_SIZE: cross ID,BURST_SIZE; 
		IDxBURST_TYPE: cross ID,BURST_TYPE; 

	endgroup

	function new(string name,uvm_component parent);
		super.new(name,parent);
		axi_cvg=new();
	endfunction
	
	task run();
	endtask

	function void write(axi_tx t);
		$cast(tx,t);
		axi_cvg.sample;
	endfunction

endclass
