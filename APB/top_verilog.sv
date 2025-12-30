parameter DATA_WIDTH=32;
  parameter ADDR_WIDTH=8;
  parameter STRB_WIDTH=(DATA_WIDTH/8);
  parameter DEPTH=2**ADDR_WIDTH;

module top;
  bit clk,rst,sel,enable,wr_rd;
  bit[2:0]prot;
  bit[DATA_WIDTH-1:0]wdata;
  bit[STRB_WIDTH-1:0] strb;
  bit[ADDR_WIDTH-1:0] addr;
  
  wire[DATA_WIDTH-1:0]rdata;
  wire ready,err;
  
  APB_DUT dut(clk,rst,addr,prot,sel,enable,wr_rd,wdata,strb,ready,rdata,err);
  defparam dut.DATA_WIDTH=DATA_WIDTH;
  defparam dut.ADDR_WIDTH=ADDR_WIDTH;
  
  always #5 clk=~clk;
  
  
  function int crc(int a);
    a[$bits(a)-8 +:8]=0;
    for(int i=0;i<$bits(a)-8;i=i+8)begin
      a[$bits(a)-8 +:8]=a[$bits(a)-8 +:8]^a[i+:8];
    end
    return a;
  endfunction
  
  
 initial begin
   repeat(2)@(posedge clk);
   rst=1;
   
   
   // consequtive write read
//    for(int u=4;u<9;u++)begin
//      write(u);
//      read(u);
//    end
   
   
   
   //write then read
   for(int u=0;u<4;u++)begin
     write(u);
   end
   
//    repeat(2)@(posedge clk);
   
   for(int u=0;u<4;u++)begin
     read(u);
   end
   
   
 end
  
  final begin
    $writememh("any.hex",dut.mem);
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    #200;
    $finish;
  end
  
  
  task write(bit[ADDR_WIDTH-1:0]adr);
    @(posedge clk);
      sel=1;
    enable=1;
    wr_rd=1;
    strb=$urandom;
    prot=0;
    addr=adr;
    wdata=$random;
    wdata=crc(wdata);
    wait(ready);
  endtask
  
  task read( int adr );
    @(posedge clk);
    sel=1;
    enable=1;
    wr_rd=0;
    strb=0;
    prot=0;
    addr=adr;
    wait(ready);
  endtask
endmodul