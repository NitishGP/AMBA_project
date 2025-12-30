
  parameter DATA_WIDTH=32;
  parameter ADDR_WIDTH=8;
  parameter STRB_WIDTH=(DATA_WIDTH/8);
  parameter DEPTH=2**ADDR_WIDTH;

`define COUNT 8

`define new_component\
			function new(string name="",uvm_component parent=null);\
				super.new(name,parent);\
			endfunction


`define new_object\
			function new(string name="");\
				super.new(name);\
			endfunction

typedef enum bit {READ=0,WRITE} wr_rd_en;

int match,mismatch,count;

mailbox #(apb_tx) drv2sbd=new();