
interface apb_intf(input bit PCLK,PRESETn);
  logic [ADDR_WIDTH-1:0] PADDR ;  
  logic                  PSELx ; 
  wr_rd_en                  PWRITE; 
  logic [DATA_WIDTH-1:0] PWDATA; 
  logic                  PENABLE;
  logic                  PREADY; 
  logic [DATA_WIDTH-1:0] PRDATA; 
  logic                  PSLVERR;
  logic [STRB_WIDTH-1:0] PSTRB;
  logic                  PWAKEUP;
  logic [2:0]            PPROT;
  logic                  delay_by_slave_module;

  clocking drv_cb@(posedge PCLK);
    default  input #1 output #0; 
    output	PADDR;
    output	PSELx;
    output	PWDATA;
    output	PWRITE;
    output	PENABLE;
    output	PSTRB;
    output	PPROT;
    output  PWAKEUP;
    output  delay_by_slave_module;

    input   PREADY;
    input   PRDATA;
    input   PSLVERR;
  endclocking


  clocking mon_cb@(posedge PCLK);
    default  input #1; 
    input	PADDR;
    input	PSELx;
    input	PWDATA;
    input	PWRITE;
    input	PENABLE;
    input   PREADY;
    input   PRDATA;
    input   PSLVERR;
    input	PSTRB;
    input	PPROT;
    input   PWAKEUP;
    input   delay_by_slave_module;
  endclocking

endinterface
