
interface axi_intf(input reg ACLK, ARESETn);
	bit AWVALID;	
	bit AWREADY;	
	bit [`ID_WIDTH-1:0] AWID;
	bit [`ADDR_WIDTH-1:0] AWADDR;	
	bit [3:0] AWLEN;	
	bit [2:0] AWSIZE;	
	burst_type_en AWBURST;	

	bit ARVALID;	
	bit ARREADY;	
	bit [`ID_WIDTH-1:0] ARID;
	bit [`ADDR_WIDTH-1:0] ARADDR;	
	bit [3:0] ARLEN;	
	bit [2:0] ARSIZE;	
	burst_type_en ARBURST;	

	bit WVALID;	
	bit WREADY;	
	bit WLAST;
	bit [`ID_WIDTH-1:0] WID;
	bit [`DATA_WIDTH-1:0] WDATA;	
	bit [`STRB_WIDTH-1:0] WSTRB;	

	bit RVALID;	
	bit RREADY;	
	bit RLAST;
	bit [`ID_WIDTH-1:0] RID;
	bit [`DATA_WIDTH-1:0] RDATA;	
	resp_type_en RRESP;	

	bit BVALID;	
	bit BREADY;	
	bit [`ID_WIDTH-1:0] BID;
	resp_type_en BRESP;	

	clocking mon_cb @(posedge ACLK);
		default input #0;
		input AWID;
		input ARID;
		input WID;
		input RID;
		input BID;

		input  AWVALID;
		input  ARVALID;
		input  WVALID;
		input  RVALID;
		input  BVALID;

		input AWREADY;
		input ARREADY;
		input WREADY;
		input RREADY;
		input BREADY;

		input AWLEN;
		input ARLEN;
		input AWBURST;
		input ARBURST;
		input AWSIZE;
		input ARSIZE;
		input AWADDR;
		input ARADDR;

		input RDATA;
		input RLAST;
		input WDATA;
		input WSTRB;

		input BRESP;
		input RRESP;

	endclocking
endinterface
