
class top_seq_lib extends uvm_sequence;
  `uvm_object_utils(top_seq_lib)
  `new_object
  
  `uvm_declare_p_sequencer(top_sqr)
  
  seq_nwr_nrd                  seq_nwr_nrd_inst;
  seq_1wr_1rd                  seq_1wr_1rd_inst;
  seq_prot_mismatch            seq_prot_mismatch_inst;
  seq_unaligned_addr_txn       seq_unaligned_addr_txn_inst;
  seq_strb_all_1s              seq_strb_all_1s_inst;
  seq_no_slverr                seq_no_slverr_inst;
  seq_jumbled_read             seq_jumbled_read_inst;
  seq_consequtive_wr_rd        seq_consequtive_wr_rd_inst;
  seq_direct_verif_prot_4_addr seq_direct_verif_prot_4_addr_inst;
endclass

class top_all_feature extends top_seq_lib;
  `uvm_object_utils(top_all_feature)
  `new_object
  
  task body();
    `uvm_do_on(seq_1wr_1rd_inst                 ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_nwr_nrd_inst                 ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_prot_mismatch_inst           ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_unaligned_addr_txn_inst      ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_strb_all_1s_inst             ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_no_slverr_inst               ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_jumbled_read_inst            ,p_sequencer.sqr_inst)
    `uvm_do_on(seq_consequtive_wr_rd_inst       ,p_sequencer.sqr_inst)
//     `uvm_do_on(seq_direct_verif_prot_4_addr_inst,p_sequencer.sqr_inst)
  endtask
endclass