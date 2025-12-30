class apb_tx extends uvm_sequence_item;
  `new_object


  rand logic [ADDR_WIDTH-1:0] PADDR;  
  rand wr_rd_en               PWRITE; 
  rand logic [DATA_WIDTH-1:0] PWDATA; 
  logic [DATA_WIDTH-1:0] PRDATA; 
  rand logic [STRB_WIDTH-1:0] PSTRB;
  rand logic [2:0]            PPROT;
  rand logic                  PSLVERR;
  rand bit flag;

  `uvm_object_utils_begin(apb_tx)
  `uvm_field_int(PRDATA,UVM_ALL_ON);
  `uvm_field_int(PPROT,UVM_ALL_ON);
  `uvm_field_int(PADDR,UVM_ALL_ON);
  `uvm_field_int(PWDATA,UVM_ALL_ON);
  `uvm_field_int(PSTRB,UVM_ALL_ON);
  `uvm_field_int(PSLVERR,UVM_ALL_ON);
  `uvm_field_enum(wr_rd_en,PWRITE,UVM_ALL_ON);
  `uvm_object_utils_end

  function int crc(bit[DATA_WIDTH-1:0] a, bit[STRB_WIDTH-1:0]strb);
    for(int l=0;l<STRB_WIDTH;l=l+1)begin  // considers strb bits during crc calculation
      if(strb[l]==0) a[8*(l+1)-1 -:8]=8'h00;
    end
    a[$bits(a)-8 +:8]=0;
    for(int i=0;i<$bits(a)-8;i=i+8)begin
      a[$bits(a)-8 +:8]=a[$bits(a)-8 +:8]^a[i+:8];
    end
    return a;
  endfunction

  function void post_randomize();
    PWDATA=crc(PWDATA,PSTRB);   
  endfunction

  constraint VALID_PROT_PADDR_c{
    PADDR inside {[PPROT*(DEPTH/8):((PPROT+1)*(DEPTH/8))-1]};
  }
  
  constraint ALIGNED_ADDR_c{
  	PADDR%4==0;
  }

  constraint PSLVERR_c{ //increases the chances of valid transaction
    flag dist {1:=7, 0:=3}; 
    (flag) -> (PADDR[ADDR_WIDTH-1]==0);
  }

  constraint PDATA_c{
    if(PWRITE==READ) {
      PSTRB==0;
      PWDATA==0;
    }   
  }

endclass
