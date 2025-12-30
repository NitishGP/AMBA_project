
class apb_sbd extends uvm_scoreboard;
  `uvm_component_utils(apb_sbd)
  `new_component
  uvm_analysis_imp#(apb_tx,apb_sbd) sbd_export;
  apb_tx tx,tx2;
  int actual_op, expected_op;

  bit [DATA_WIDTH-1:0] ref_mem[DEPTH-1:0];
  //    bit [DATA_WIDTH-1:0] ref_mem[bit[ADDR_WIDTH-1:0]];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sbd_export=new("sbd_export",this);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      drv2sbd.get(tx2);
      tx2.PADDR=tx2.PADDR-(tx2.PADDR%STRB_WIDTH); //aligned addr
      if(tx2.PWRITE==WRITE) begin
        if(tx2.PADDR inside {[tx2.PPROT*(DEPTH/8):((tx2.PPROT+1)*(DEPTH/8))-1]})begin
          store();
        end
      end
    end
  endtask

  task store();
    byte crc_byte=0;

    if(tx2==null) return;

    tx2.PSTRB[STRB_WIDTH-1]=1'b0;// dont store crc received

    //     $display($time, " store- %b %h",tx.PSTRB,tx.PWDATA);
    foreach(tx2.PSTRB[i]) begin
      if (tx2.PSTRB[i]) ref_mem[tx2.PADDR][8*(i+1)-1 -:8]=tx2.PWDATA[8*(i+1)-1 -:8];//get valid bits in data received
      if(i!=STRB_WIDTH-1) crc_byte=crc_byte^ref_mem[tx2.PADDR][8*(i+1)-1 -:8];//calculate crc on valid bits
    end
    ref_mem[tx2.PADDR][DATA_WIDTH-1 -:8]=crc_byte;

    `uvm_info("REF_MODEL DEBUG",$sformatf("ref_model--%h--%h",tx2.PADDR,ref_mem[tx2.PADDR]),UVM_DEBUG)    
  endtask

  function void write(apb_tx t);
    $cast(tx,t);
    tx.PADDR=tx.PADDR-(tx.PADDR%STRB_WIDTH); //aligned addr
    if(tx.PWRITE==READ) begin
      expected_op  =ref_mem[tx.PADDR];
      actual_op=tx.PRDATA;

      if(actual_op==expected_op) match++;
      else begin
      uvm_report_warning("CHECKER DEBUG",$sformatf("checker--act-%h--exp-%h time-%t",actual_op,expected_op,$time),UVM_LOW);    
        mismatch++;
      end
    end
  endfunction
endclass
