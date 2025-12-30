
class apb_test_lib extends uvm_test;
  `uvm_component_utils(apb_test_lib)
  apb_env env;

  `new_component

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("test_build_phase","inside test_build",UVM_MEDIUM)
    env=apb_env::type_id::create("env",this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("test_elaboration_phase","inside test_elaboration_phase",UVM_MEDIUM)
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("test_run_phase","inside test_run_phase",UVM_MEDIUM)
  endtask


  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if(!mismatch && match ==count ) $display("TESTCASE PASSED\nCount:%0d\nMatch:%0d\nMismatch:%0d",count,match,mismatch);
    else $display("TESTCASE FAILED\nCount:%0d\nMatch:%0d\nMismatch:%0d",count,match,mismatch);
  endfunction
endclass

class test_1wr extends apb_test_lib;
  `uvm_component_utils(test_1wr)
  `new_component
  seq_1wr seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_1wr::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_1wr_1rd extends apb_test_lib;
  `uvm_component_utils(test_1wr_1rd)
  `new_component
  seq_1wr_1rd seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_1wr_1rd::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask


endclass

class test_nwr_nrd extends apb_test_lib;
  `uvm_component_utils(test_nwr_nrd)
  `new_component
  seq_nwr_nrd seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_nwr_nrd::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_unaligned_addr_txn extends apb_test_lib;
  `uvm_component_utils(test_unaligned_addr_txn)
  `new_component
  seq_unaligned_addr_txn  seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_unaligned_addr_txn::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_consequtive_wr_rd extends apb_test_lib;
  `uvm_component_utils(test_consequtive_wr_rd)
  `new_component
  seq_consequtive_wr_rd seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_consequtive_wr_rd::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_strb_all_1s extends apb_test_lib;
  `uvm_component_utils(test_strb_all_1s)
  `new_component
  seq_strb_all_1s seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_strb_all_1s::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_prot_mismatch extends apb_test_lib;
  `uvm_component_utils(test_prot_mismatch)
  `new_component
  seq_prot_mismatch seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_prot_mismatch::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,20);
  endtask
endclass

class test_no_slverr extends apb_test_lib;
  `uvm_component_utils(test_no_slverr)
  `new_component
  seq_no_slverr seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_no_slverr::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_crc_mismatch_callback extends apb_test_lib;
  `uvm_component_utils(test_crc_mismatch_callback)
  `new_component
  seq_no_slverr seq;
  apb_drv         d;
  apb_driver_cb1 cb;


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d =env.agent.drv;
    cb=apb_driver_cb1::type_id::create("cb");
    uvm_callbacks#(apb_drv, apb_driver_cb)::add(d,cb);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_no_slverr::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_data_corruption_callback extends apb_test_lib;//should fail
  `uvm_component_utils(test_data_corruption_callback)
  `new_component
  seq_no_slverr seq;
  apb_drv         d;
  apb_driver_cb2 cb;


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d =env.agent.drv;
    cb=apb_driver_cb2::type_id::create("cb");
    uvm_callbacks#(apb_drv, apb_driver_cb)::add(d,cb);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_no_slverr::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_direct_verif_prot_4_addr  extends apb_test_lib;
  `uvm_component_utils(test_direct_verif_prot_4_addr)
  `new_component
  seq_direct_verif_prot_4_addr seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_direct_verif_prot_4_addr::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_jumbled_read  extends apb_test_lib;
  `uvm_component_utils(test_jumbled_read)
  `new_component
  seq_jumbled_read seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_jumbled_read::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_wait_trans_by_override  extends apb_test_lib;
  `uvm_component_utils(test_wait_trans_by_override)
  `new_component
  seq_nwr_nrd seq;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_drv::type_id::set_type_override(apb_delay_drv::get_type());
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=seq_nwr_nrd::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass

class test_top_all_feature extends apb_test_lib;
  `uvm_component_utils(test_top_all_feature)
  `new_component
  top_all_feature seq;

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=top_all_feature::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.t_sqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask
endclass