
class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  `new_component
  apb_cov cov;
  apb_drv drv;
  apb_mon mon;
  apb_sqr sqr;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("agent_build_phase","inside agent_build_p",UVM_MEDIUM)
    sqr=apb_sqr::type_id::create("sqr",this);
    mon=apb_mon::type_id::create("mon",this);
    drv=apb_drv::type_id::create("drv",this);
    cov=apb_cov::type_id::create("cov",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("agent_connect_phase","inside agent_connect_phase",UVM_MEDIUM)
    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.ap_port.connect(cov.analysis_export);
  endfunction
endclass
