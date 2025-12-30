`define NEW_COMP\
function new(string name="",uvm_component parent=null);\
	super.new(name,parent);\
endfunction

`define NEW_OBJ\
function new(string name="");\
	super.new(name);\
endfunction

`define WIDTH 8
`define DEPTH 8
`define ADDR_WIDTH $clog2(`DEPTH);

typedef enum bit {SLAVE,MASTER} SL_MS_en;

