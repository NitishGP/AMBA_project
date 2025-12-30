module top;

  bit clk,rst;
  apb_intf pif(clk,rst);

  always #5 clk=~clk;

  APB_DUT #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut(
    .PCLK   (pif.PCLK),
    .PRESETn(pif.PRESETn),
    .PADDR  (pif.PADDR),
    .PPROT  (pif.PPROT),
    .PSELx  (pif.PSELx),
    .PSTRB  (pif.PSTRB),
    .PSLVERR(pif.PSLVERR),
    .PWAKEUP(pif.PWAKEUP),
    .PWRITE (pif.PWRITE),
    .PWDATA (pif.PWDATA),
    .PENABLE(pif.PENABLE),
    .PREADY (pif.PREADY),
    .PRDATA (pif.PRDATA),
    .delay_by_slave_module(pif.delay_by_slave_module));

  bind APB_DUT apb_assert #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut_assert(
    pif.PCLK,
    pif.PRESETn,
    pif.PADDR,
    pif.PPROT,
    pif.PSELx,
    pif.PENABLE,
    pif.PWRITE,
    pif.PWDATA,
    pif.PSTRB,
    pif.PREADY,
    pif.PRDATA,
    pif.PSLVERR,
    pif.PWAKEUP,
    pif.delay_by_slave_module,
    p_s); //for state transition assertion

  initial begin
    uvm_config_db#(virtual apb_intf)::set(uvm_root::get(),"*","vif",pif);
  end

  initial begin
    clk=0;
    rst=0;
    reset();
    @(posedge clk);
    rst=1;
  end

  initial begin
    run_test("apb_test_lib");
  end

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

  task reset();
    pif.PENABLE<=0;
    pif.PWRITE <=wr_rd_en'(0);
    pif.PWDATA <=0;
    pif.PADDR  <=0;
    pif.PSELx  <=0;
    pif.PSTRB  <=0;
    pif.PWAKEUP<=0;
  endtask
endmodule
