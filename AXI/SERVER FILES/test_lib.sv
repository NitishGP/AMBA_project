class axi_base_test extends uvm_test;
	`uvm_component_utils(axi_base_test)
	`NEW_COMP
	axi_env env;
	uvm_factory factory=uvm_factory::get();

	function void build();
		env=axi_env::type_id::create("env",this);

		uvm_config_db#(int)::set(this,"*","WR_COUNT",5);
		uvm_config_db#(int)::set(this,"*","RD_COUNT",5);

		//	uvm_config_db#(uvm_object_wrapper)::set(this,"env.m_agent.sqr.run_phase","default_sequence",axi_seq_1_wr_rd_incr::get_type());
		//uvm_config_db#(uvm_object_wrapper)::set(this,"env.m_agent.sqr.run_phase","default_sequence",axi_seq_1wr_incr::get_type());
	endfunction

	function void end_of_elaboration();
		uvm_top.print_topology;
	endfunction

		function void report();		
				$display("match==%d\nmismatch==%d",match,mismatch);
			if(mismatch==0 ) $display("Testcase Passed");
			else $display("Testcase Failed");
		endfunction
endclass


class axi_test_seq_1_wr_rd_incr extends axi_base_test;
	`uvm_component_utils(axi_test_seq_1_wr_rd_incr)
	`NEW_COMP
	axi_seq_1_wr_rd_incr seq;
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		seq=axi_seq_1_wr_rd_incr::type_id::create("seq");
		phase.raise_objection(this);
		seq.start(env.m_agent.sqr);
		phase.phase_done.set_drain_time(this,100);
		phase.drop_objection(this);
	endtask
endclass

class axi_test_seq_5_wr_rd_incr extends axi_base_test;
	`uvm_component_utils(axi_test_seq_5_wr_rd_incr)
	`NEW_COMP
	axi_seq_5_wr_rd_incr seq;

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		seq=axi_seq_5_wr_rd_incr::type_id::create("seq");
		phase.raise_objection(this);
		seq.start(env.m_agent.sqr);
		phase.phase_done.set_drain_time(this,100);
		phase.drop_objection(this);
	endtask
endclass

class axi_test_seq_5_wr_rd_wrap extends axi_base_test;
	`uvm_component_utils(axi_test_seq_5_wr_rd_wrap)
	`NEW_COMP
	axi_seq_5_wr_rd_wrap seq;

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		seq=axi_seq_5_wr_rd_wrap::type_id::create("seq");
		phase.raise_objection(this);
		seq.start(env.m_agent.sqr);
		phase.phase_done.set_drain_time(this,100);
		phase.drop_objection(this);
	endtask
endclass

class axi_test_seq_5_wr_rd_fixed extends axi_base_test;
	`uvm_component_utils(axi_test_seq_5_wr_rd_fixed)
	`NEW_COMP
	axi_seq_5_wr_rd_fixed seq;

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		seq=axi_seq_5_wr_rd_fixed::type_id::create("seq");
		phase.raise_objection(this);
		seq.start(env.m_agent.sqr);
		phase.phase_done.set_drain_time(this,100);
		phase.drop_objection(this);
	endtask
endclass

class axi_overlap_test extends axi_base_test;
	`uvm_component_utils(axi_overlap_test)
	`NEW_COMP
	axi_overlap_seq seq;

	function void build();
		super.build();
		factory.set_type_override_by_name("axi_drv","axi_overlap_drv");
	endfunction
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		seq=axi_overlap_seq::type_id::create("seq");
		phase.raise_objection(this);
		seq.start(env.m_agent.sqr);
		phase.phase_done.set_drain_time(this,500);
		phase.drop_objection(this);
	endtask
endclass
