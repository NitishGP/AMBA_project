`define NEW_COMP\
function new(string name="",uvm_component parent=null);\
	super.new(name,parent);\
endfunction

`define NEW_OBJ\
function new(string name="");\
	super.new(name);\
endfunction

`define DATA_WIDTH 32
`define ID_WIDTH 4
//parameter depth=$clog2(`DEPTH);
`define ADDR_WIDTH 8  
//parameter strbw=`DATA_WIDTH/8
`define STRB_WIDTH 4 


typedef enum bit {SLAVE,MASTER} SL_MS_en;

typedef enum bit[1:0] {OKAY,EXOKAY,SLVERR,DECERR} resp_type_en; 

typedef enum bit[1:0] {FIXED,INCR,WRAP,RSVD_BURST} burst_type_en; 

typedef enum bit[1:0] {OVERLAP,OUT_OF_ORDER,INTERLEAVE,NORMAL} txn_type_en; 

int count,match,mismatch;
