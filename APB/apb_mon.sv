
class apb_mon extends uvm_monitor;
  `uvm_component_utils(apb_mon)
  `new_component
  virtual apb_intf vif;
  uvm_analysis_port#(apb_tx) ap_port;
  apb_tx tx;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif);
    ap_port=new("ap_port",this);
  endfunction

  task run_phase(uvm_phase phase);
    int c;
    super.run_phase(phase);
    `uvm_info("mon_run_phase","inside mon_run_phase",UVM_MEDIUM)
    wait(vif.PRESETn);
    forever begin
      @(vif.mon_cb)
      if(vif.mon_cb.PSELx && vif.mon_cb.PENABLE && vif.mon_cb.PREADY)begin
        tx=apb_tx::type_id::create("mon_tx");
        //       $display($time," monitor iterations %0d",++c);
        tx.PWRITE               =vif.mon_cb.PWRITE;
        if(vif.PWRITE) tx.PWDATA=vif.mon_cb.PWDATA;
        else tx.PRDATA          =vif.mon_cb.PRDATA;
        tx.PSTRB                =vif.mon_cb.PSTRB;
        tx.PPROT                =vif.mon_cb.PPROT;
        tx.PADDR                =vif.mon_cb.PADDR;
        tx.PSLVERR              =vif.mon_cb.PSLVERR;
        //       tx.print();
        ap_port.write(tx);
      end
    end
  endtask
endclass
