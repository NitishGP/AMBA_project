
class axi_sbd extends uvm_scoreboard;
	`uvm_component_utils(axi_sbd)
	`NEW_COMP
	`uvm_analysis_imp_decl(_master_mon)
	`uvm_analysis_imp_decl(_slave_mon)
	uvm_analysis_imp_master_mon#(axi_tx,axi_sbd) sbd_master_imp;
	uvm_analysis_imp_slave_mon#(axi_tx,axi_sbd) sbd_slave_imp;
	axi_tx txm[int],txs[int],txM[int],txS[int];
	axi_tx txmQ[int][$];


		function void build();
			sbd_master_imp=new("sbd_master_imp",this);
			sbd_slave_imp=new("sbd_slave_imp",this);
		endfunction
	
		function void write_master_mon(axi_tx t);
			txmQ[t.id].push_back(t);
		endfunction
	
		function void write_slave_mon(axi_tx t);
			fork
				match_slave_master_tx(t);
			join_none
		endfunction
	
		task match_slave_master_tx(axi_tx tx);
		bit[`DATA_WIDTH-1:0]temp;
		wait(txmQ[tx.id].size>0);
				txM[tx.id]=txmQ[tx.id].pop_front();
	
				$displayh("%0d txM=%p\ntxS=%p",$time,txM[tx.id].dataQ,tx.dataQ);
				foreach(txM[tx.id].dataQ[i]) begin
							$display("strb:%b",txM[tx.id].wstrb[i]);
					foreach(txM[tx.id].wstrb[i][j])begin
						if(txM[tx.id].wstrb[i][j]==1)begin
							temp={temp,txM[tx.id].dataQ[i][((8*(j+1))-1)-:8]};
						end
					end
					if(temp==tx.dataQ[i]) match++;
					else begin
						$displayh("check mismtach::%h %h %p",temp,tx.dataQ[i],tx.dataQ);
						mismatch++;
					end
					temp='b0;
				end
		endtask
	
	endclass
