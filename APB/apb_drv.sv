
class apb_drv extends uvm_driver #(apb_tx);
  `uvm_component_utils(apb_drv)
  `new_component
  virtual apb_intf vif;
  apb_tx tx_c;
  int repetitions;
  `uvm_register_cb(apb_drv, apb_driver_cb)//register callback


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("drv_build_phase","inside drv_build_phase",UVM_MEDIUM)
    if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif)) begin
      `uvm_error("DRV_BUILD_PHASE","VIRTUAL INTERFACE RETIEVAL FAILED IN DRV")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("drv_run_phase","inside drv_run_phase",UVM_MEDIUM)
    wait(vif.PRESETn);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("debug drv","inside run_drv before drive_tx",UVM_DEBUG)
      `uvm_do_callbacks(apb_drv, apb_driver_cb, pre_drive_tx(req))
      tx_c= new req;
      drv2sbd.put(tx_c);
      drive_tx(req);
      //      $display($time," rep-%0d cou-%0d",repetitions,count);

      `uvm_do_callbacks(apb_drv, apb_driver_cb, post_drive_tx())

      seq_item_port.item_done();

    end
  endtask

  virtual task drive_tx(apb_tx tx);
    `uvm_info("debug drive_tx","inside drive_tx before clk",UVM_DEBUG)

    repetitions++;//keeps count of no of drives
	
    @(vif.drv_cb);
    `uvm_do_callbacks(apb_drv, apb_driver_cb, data_corrupt(req))
    vif.drv_cb.PENABLE<=1;
    vif.drv_cb.PWAKEUP<=1;
    vif.drv_cb.PSELx  <=1;
    vif.drv_cb.delay_by_slave_module<=1;

    vif.drv_cb.PWRITE <=tx.PWRITE;
    vif.drv_cb.PADDR  <=tx.PADDR;
    vif.drv_cb.PPROT  <=tx.PPROT;
    vif.drv_cb.PSTRB  <=tx.PSTRB;
    if(tx.PWRITE) vif.drv_cb.PWDATA<=tx.PWDATA;
    else vif.drv_cb.PWDATA<=0;
    `uvm_info("debug drive_tx","inside drive_tx after clk",UVM_DEBUG)

    while (!vif.drv_cb.PREADY) @(vif.drv_cb);
    `uvm_info("debug drive_tx","inside drive_tx after wait",UVM_DEBUG)
    @(vif.drv_cb);

    if(repetitions==2*count) begin
      @(vif.drv_cb);
      vif.drv_cb.PSELx  <=0; //brings state to idle after all transfers
      @(vif.drv_cb);
    end

  endtask

endclass

class apb_delay_drv extends apb_drv;
  `uvm_component_utils(apb_delay_drv)
  `new_component
  `uvm_set_super_type(apb_delay_drv,apb_drv)

  virtual task drive_tx(apb_tx tx);


    `uvm_info("debug drive_tx","inside drive_tx before clk",UVM_DEBUG)
    @(vif.drv_cb);
    vif.drv_cb.PWAKEUP<=1;
    vif.drv_cb.PSELx  <=1;
    vif.drv_cb.PENABLE<=0;

    vif.drv_cb.PWRITE <=tx.PWRITE;
    vif.drv_cb.PADDR  <=tx.PADDR;
    vif.drv_cb.PPROT  <=tx.PPROT;
    vif.drv_cb.PSTRB  <=tx.PSTRB;
    `uvm_do_callbacks(apb_drv, apb_driver_cb, data_corrupt(req))
    if(tx.PWRITE) vif.drv_cb.PWDATA<=tx.PWDATA;
    else vif.drv_cb.PWDATA<=0;
    `uvm_info("debug drive_tx","inside drive_tx after clk",UVM_DEBUG)

    @(vif.drv_cb);//SETUP
    vif.drv_cb.PENABLE<=1;

    repeat($urandom_range(0,3))@(vif.drv_cb);//introduces wait before recieving ready
    vif.drv_cb.delay_by_slave_module<=1;


    //     while (!vif.drv_cb.PREADY) @(vif.drv_cb);
    `uvm_info("debug drive_tx","inside drive_tx after wait",UVM_DEBUG)
    wait(vif.drv_cb.PREADY);
//     @(vif.drv_cb);
    vif.drv_cb.PENABLE<=0;
    vif.drv_cb.PSELx<=0;
    vif.drv_cb.delay_by_slave_module<=0;
    vif.drv_cb.PWRITE <=READ;
    vif.drv_cb.PADDR  <=0;
    vif.drv_cb.PPROT  <=0;
    vif.drv_cb.PSTRB  <=0;
    vif.drv_cb.PWDATA  <=0;
    //     @(vif.drv_cb);//SETUP
    //     @(vif.drv_cb);//ACCESS

  endtask
endclass