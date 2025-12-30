
class apb_env extends uvm_env;

  `uvm_component_utils(apb_env)

  `new_component

  apb_agent agent;
  apb_sbd sbd;

  top_sqr t_sqr;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env_build_phase","inside env_build",UVM_MEDIUM)
    agent=apb_agent::type_id::create("agent",this);
    sbd=apb_sbd::type_id::create("sbd",this);
    t_sqr=top_sqr::type_id::create("t_sqr",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env_connect_phase","inside env_connect_phase",UVM_MEDIUM)
    agent.mon.ap_port.connect(sbd.sbd_export);

    t_sqr.sqr_inst=agent.sqr;
  endfunction

endclass
