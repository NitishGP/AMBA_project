module top;

	reg clk,rst;
	axi_intf pif(clk,rst);

	always #5 clk=~clk;

	initial begin
		clk=0;
		rst=1;
		reset();
		repeat(2)@(posedge clk);
		rst=0;
		
	end
	initial begin
		uvm_config_db#(virtual axi_intf)::set(uvm_root::get(),"*","vif",pif);	
	end
	initial begin
	//		run_test("axi_overlap_test");
			run_test("axi_test_seq_5_wr_rd_wrap");
	end

	task reset();
	endtask
endmodule
