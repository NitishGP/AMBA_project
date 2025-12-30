
class apb_cov extends uvm_subscriber #(apb_tx);
  `uvm_component_utils(apb_cov)
  apb_tx tx;
  int read_count, write_count;

  covergroup cvg;  
    // Covergroup options  
    option.per_instance       = 1;         
    option.goal               = 100;       
    option.at_least           = 1;         
    option.comment            = "APB Protocol Coverage Group on input signals except enable, ready, psel";  
    option.name               = "APB_Coverage";  
    option.weight             = 1;        

    // Address coverage  
    ADDRESS : coverpoint tx.PADDR {  
      option.goal         = 100;  
      option.at_least     = 2;            
      bins ADDR_CP[8]     = {[0:$]};  
    }  

    // PPROT coverage  
    PROT : coverpoint tx.PPROT {  
      bins PROT_CP[8] = {[0:$]};  
    }  

    // Write/Read operation coverage  
    WR_RD : coverpoint tx.PWRITE {  
      bins WRITE = {wr_rd_en'(1)};  
      bins READ  = {wr_rd_en'(0)};  
      option.goal = 100;  
    }  

    // Write-to-Read and Read-to-Write transition coverage  
    TRN_WR_RD : coverpoint tx.PWRITE {  
      bins PWRITE_0_1 = (READ => WRITE);  
      bins PWRITE_1_0 = (WRITE => READ);  
    }  

    // PSTRB coverage  
    PSTRB : coverpoint tx.PSTRB {  
      bins STRBS[] = {[0:$]};  
    }  

    // PSLVERR coverage  
    PERR : coverpoint tx.PSLVERR {  
      bins ERR    = {1};  
      bins NO_ERR = {0};  
    }  

    // PSLVERR transitions  
    TRN_PSLVERR : coverpoint tx.PSLVERR {  
      bins SLVERR_0_1 = (0 => 1);  //transition coverage
      bins SLVERR_1_0 = (1 => 0);  
      option.goal     = 80;  
      option.at_least     = 2;             

    }  

    // Write Data coverage  
    PWDATA : coverpoint tx.PWDATA {  
      option.auto_bin_max = 8;  
      option.goal         = 100;  
    }  

    //SCENARIO Coverage for generated write transactions
    WRITE_SCENARIO : coverpoint write_count{
      bins write_c = {`COUNT};
      option.goal=100;
      option.comment= "This is scenario coverage for n write and n read cycles";  
      option.weight=3;
    }
    //SCENARIO Coverage for generated read transactions
    READ_SCENARIO : coverpoint read_count{
      bins read_c  = {`COUNT};
      option.goal=100;
      option.comment= "This is scenario coverage for n write and n read cycles";  
      option.weight=3;
    }

    // Cross coverage   
    WR_RDxADDRESS : cross WR_RD, ADDRESS {  
      option.goal = 100;  
    }  
  endgroup

  function new(string name="", uvm_component parent=null);
    super.new(name,parent);
    cvg=new();
  endfunction

  function void write(apb_tx t);
    $cast(tx,t);
    if(tx.PWRITE==WRITE) write_count++;
    else read_count++;
    cvg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("\tCoverage      :%0f",cvg.get_coverage());
    $display("\tADDRESS       :%0f",cvg.ADDRESS.get_coverage());
    $display("\tPROT          :%0f",cvg.PROT.get_coverage());
    $display("\tWR_RD         :%0f",cvg.WR_RD.get_coverage());
    $display("\tTRN_WR_RD     :%0f",cvg.TRN_WR_RD.get_coverage());
    $display("\tPSTRB         :%0f",cvg.PSTRB.get_coverage());
    $display("\tPERR          :%0f",cvg.PERR.get_coverage());
    $display("\tTRN_PSLVERR   :%0f",cvg.TRN_PSLVERR.get_coverage());
    $display("\tPWDATA        :%0f",cvg.PWDATA.get_coverage());
    $display("\tWRITE_SCENARIO:%0f",cvg.WRITE_SCENARIO.get_coverage());
    $display("\tREAD__SCENARIO:%0f",cvg.READ_SCENARIO.get_coverage());
    $display("\tWR_RDxADDRESS :%0f",cvg.WR_RDxADDRESS.get_coverage());
  endfunction
endclass
