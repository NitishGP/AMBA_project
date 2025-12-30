
class apb_seq_lib extends uvm_sequence#(apb_tx);
  `uvm_object_utils(apb_seq_lib)
  `new_object

endclass

class seq_1wr extends apb_seq_lib;
  `uvm_object_utils(seq_1wr)
  `new_object

  task body();
    //       count=0;
    `uvm_do_with(req,{req.PWRITE==1;})
  endtask
endclass

class seq_1rd extends apb_seq_lib;
  `uvm_object_utils(seq_1rd)
  `new_object

  task body();
    count+=1;
    `uvm_do_with(req,{req.PWRITE==0;})
  endtask
endclass

class seq_1wr_1rd extends apb_seq_lib;
  `uvm_object_utils(seq_1wr_1rd)
  `new_object

  task body();
    seq_1wr seq1;
    seq_1rd seq2;
    seq1=seq_1wr::type_id::create("seq1");
    seq2=seq_1rd::type_id::create("seq2");
    `uvm_do(seq1)
    `uvm_do(seq2)
    //             count+=1;

  endtask
endclass

class seq_nwr_nrd extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_nwr_nrd)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object

  task body();
    bit[ADDR_WIDTH-1:0] temp_addr;
    seq_1wr seq1;
    seq_1rd seq2;
    seq1=seq_1wr::type_id::create("seq1");
    seq2=seq_1rd::type_id::create("seq2");
    count+=`COUNT;
    repeat(`COUNT) begin
      `uvm_do(seq1)
      txQ.push_back(seq1.req.PADDR);
    end
    repeat(`COUNT) begin
      temp_addr=txQ.pop_front();
      `uvm_do_with(seq2.req,{seq2.req.PADDR==temp_addr;seq2.req.PWRITE==0;})
    end
    //       $display($time,"  cou-%0d",count);
  endtask
endclass

class seq_jumbled_read extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_jumbled_read)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object

  task body();
    bit[ADDR_WIDTH-1:0] temp_addr;
    seq_1wr seq1;
    seq_1rd seq2;
    seq1=seq_1wr::type_id::create("seq1");
    seq2=seq_1rd::type_id::create("seq2");    
    count+=`COUNT;

    repeat(`COUNT) begin
      `uvm_do(seq1)
      txQ.push_back(seq1.req.PADDR);
    end
    txQ.shuffle();
    repeat(`COUNT) begin
      temp_addr=txQ.pop_front();
      `uvm_do_with(seq2.req,{seq2.req.PADDR==temp_addr;seq2.req.PWRITE==0;})
    end
    //     count+=`COUNT;
  endtask
endclass


class seq_consequtive_wr_rd extends apb_seq_lib;
  `uvm_object_utils(seq_consequtive_wr_rd)
  `new_object

  task body();
    bit[ADDR_WIDTH-1:0] temp_addr;
    seq_1wr seq1;
    seq_1rd seq2;
    seq1=seq_1wr::type_id::create("seq1");
    seq2=seq_1rd::type_id::create("seq2");
    count+=`COUNT;

    repeat(`COUNT) begin
      `uvm_do(seq1)
      temp_addr=seq1.req.PADDR;
      `uvm_do_with(seq2.req,{seq2.req.PADDR==temp_addr;seq2.req.PWRITE==0;})
    end
    //     count+=`COUNT;
  endtask
endclass

class seq_strb_all_1s extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_strb_all_1s)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object
  bit[ADDR_WIDTH-1:0] temp_addr;

  task body();
    seq_1wr seq1;
    seq_1rd seq2;
    seq1=seq_1wr::type_id::create("seq1");
    seq2=seq_1rd::type_id::create("seq2");    
    count+=2**STRB_WIDTH;

    for(int i=0;i<2**STRB_WIDTH;i++) begin
      `uvm_do_with(seq1.req,{seq1.req.PWRITE==1;seq1.req.PSTRB==i;})
      txQ.push_back(seq1.req.PADDR);
    end
    while(txQ.size>0) begin
      temp_addr=txQ.pop_front();
      `uvm_do_with(seq2.req,{seq2.req.PADDR==temp_addr;seq2.req.PWRITE==0;})
    end
  endtask
endclass

class seq_unaligned_addr_txn extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_unaligned_addr_txn)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object

  bit[ADDR_WIDTH-1:0] temp_addr;

  task body();
    count+=`COUNT;
    repeat(`COUNT) begin
      `uvm_create(req)
      req.ALIGNED_ADDR_c.constraint_mode(0);
      `uvm_rand_send_with(req,{req.PWRITE==1;})
      txQ.push_back(req.PADDR);
    end
    repeat(`COUNT) begin
      `uvm_create(req)
      req.ALIGNED_ADDR_c.constraint_mode(0);
      temp_addr=txQ.pop_front();
      `uvm_rand_send_with(req,{req.PADDR==temp_addr;req.PWRITE==0;})
    end
  endtask
endclass

class seq_prot_mismatch extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_prot_mismatch)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object

  //   task body();
  //     seq_nwr_nrd seq1;
  //     seq1=seq_nwr_nrd::type_id::create("seq1");
  // //     start_item();
  // //     `uvm_create(seq1)
  //     //     seq1.req.PROT_c.constraint_mode(0); //fatal error
  // //     `uvm_rand_send(seq1)
  // //     finish_item();
  //   endtask

  bit[ADDR_WIDTH-1:0] temp_addr;

  task body();
    count+=`COUNT;
    repeat(`COUNT) begin
      `uvm_create(req)
      req.VALID_PROT_PADDR_c.constraint_mode(0);
      `uvm_rand_send_with(req,{req.PWRITE==1;})
      txQ.push_back(req.PADDR);
    end
    repeat(`COUNT) begin
      temp_addr=txQ.pop_front();
      `uvm_do_with(req,{req.PADDR==temp_addr;req.PWRITE==0;})
    end
  endtask
endclass

class seq_no_slverr extends apb_seq_lib;
  bit[ADDR_WIDTH-1:0] txQ[$];
  `uvm_object_utils_begin(seq_no_slverr)
  `uvm_field_queue_int(txQ,UVM_ALL_ON)
  `uvm_object_utils_end
  `new_object
  bit[ADDR_WIDTH-1:0] temp_addr;

  task body();
    count+=`COUNT;
    repeat(`COUNT) begin
      `uvm_do_with(req,{req.PWRITE==1;req.PADDR[ADDR_WIDTH-1]==0;})
      txQ.push_back(req.PADDR);
    end
    repeat(`COUNT) begin
      temp_addr=txQ.pop_front();
      `uvm_do_with(req,{req.PADDR==temp_addr;req.PWRITE==0;})
    end
  endtask
endclass

class seq_direct_verif_prot_4_addr extends apb_seq_lib;
  `uvm_object_utils(seq_direct_verif_prot_4_addr)
  `new_object
  bit[ADDR_WIDTH-1:0] temp_addr;

  task body();
    count+=1;
    `uvm_do_with(req,{req.PPROT==4;req.PADDR=='h88;req.PWRITE==1;req.PSTRB=='h9;})
    temp_addr=req.PADDR;
    `uvm_do_with(req,{req.PADDR==temp_addr;req.PWRITE==0;})
  endtask
endclass