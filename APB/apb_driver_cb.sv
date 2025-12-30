
class apb_driver_cb extends uvm_callback;
  `uvm_object_utils(apb_driver_cb)
  `new_object
  
  virtual task pre_drive_tx(ref apb_tx t);
  endtask
  
  virtual task post_drive_tx();
  endtask
  
  virtual task data_corrupt(ref apb_tx t);
  endtask
endclass

class apb_driver_cb1 extends apb_driver_cb;
  `uvm_object_utils(apb_driver_cb1)
  `new_object
  
  virtual task pre_drive_tx(ref apb_tx t);
    $display("PRE_DRV_TASK callback called");
    t.PWDATA[DATA_WIDTH-1 -:8]=0;
  endtask
  virtual task post_drive_tx();
    $display("POST_DRV_TASK callback called");
  endtask
  
  virtual task data_corrupt(ref apb_tx t);
    $display("POST_DRV_TASK callback called");
  endtask
endclass

class apb_driver_cb2 extends apb_driver_cb;
  `uvm_object_utils(apb_driver_cb2)
  `new_object
  
  virtual task pre_drive_tx(ref apb_tx t);
    $display("PRE_DRV_TASK callback called");
  endtask
  virtual task post_drive_tx();
    $display("POST_DRV_TASK callback called");
  endtask
  
  virtual task data_corrupt(ref apb_tx t);
    $display("POST_DRV_TASK callback called");
    t.PWDATA[7:0]=$random;
  endtask
endclass