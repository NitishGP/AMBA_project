
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
		run_test("");
	end

	task reset();
	endtask
endmodule
