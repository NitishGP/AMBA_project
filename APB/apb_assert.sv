
module apb_assert(PCLK,PRESETn,PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA,PSLVERR,PWAKEUP,delay_by_slave_module, State );
  parameter DATA_WIDTH=8;
  parameter ADDR_WIDTH=8;
  parameter STRB_WIDTH=(DATA_WIDTH/8);
  parameter DEPTH=2**ADDR_WIDTH;

  localparam IDLE=3'b001;
  localparam SETUP=3'b010;
  localparam ACCESS=3'b100;

  input logic [2:0] State;
  input PCLK, PRESETn, PSELx, PENABLE, PWRITE,PWAKEUP,delay_by_slave_module;
  input logic [ADDR_WIDTH-1:0] PADDR;
  input logic [2:0] PPROT;
  input logic [DATA_WIDTH-1:0] PWDATA;
  input logic [STRB_WIDTH-1:0] PSTRB;
  input logic PREADY, PSLVERR;
  input logic [DATA_WIDTH-1:0] PRDATA;


  //During an Access phase, when PENABLE is HIGH, PREADY is asserted by the Completer at the rising edge of PCLK  
  property handshake();
    @(posedge PCLK) disable iff(!PRESETn) (PENABLE && PSELx) && State==ACCESS |-> ##[0:3] $rose(PREADY);
  endproperty
  HANDSHAKE : assert property(handshake);

    
  // The interface only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock.
  property access_after_enable();
    @(posedge PCLK) disable iff(!PRESETn) State==SETUP && PENABLE && PSELx |=> State==ACCESS;
  endproperty
  ACCESS_AFTER_ENABLE  : assert property(access_after_enable);


  //PADDR[31] being set asserts PLSVERR signal.
  MSB_SLVERR : assert property(@(posedge PCLK) disable iff(!PRESETn) PENABLE && PREADY && PSELx && PADDR[ADDR_WIDTH-1]==1'b1 |-> PSLVERR);


  // the interface moves into the SETUP state, where the appropriate select signal, PSELx, is asserted                                     
  PSELxASSERT : assert property(@(posedge PCLK) disable iff(!PRESETn) $past(State)==IDLE  && State==SETUP |-> PSELx == 1);


  //The select signal, PSEL, is asserted, which means that PADDR, PWRITE and PWDATA must be valid. 
  INPUT_SIGNAL_VALIDITY_ASSERT : assert property(
    @(posedge PCLK) disable iff(!PRESETn) 
    State==SETUP |-> !(($isunknown(PWDATA))&& ($isunknown(PADDR)) && ($isunknown(PWRITE)))
  );


  //The enable signal, PENABLE, is asserted in the ACCESS state.
  PENABLE_ASSERT : assert property(@(posedge PCLK) disable iff(!PRESETn) State==ACCESS && PREADY|-> PENABLE == 1);


    // The following signals must not change in the transition between SETUP and ACCESS and between cycles in the ACCESS state: ->PADDR ->PPROT ->PWRITE ->PWDATA, (only for write transactions) ->PSTRB ->PAUSER ->PWUSER
  SETUP_ACCESS_TRN_SIGNAL_STABILITY : assert property(
    @(posedge PCLK) disable iff(!PRESETn) 
    State==ACCESS && $past(State)==SETUP && PSELx==1|-> $stable(PWDATA) && $stable(PADDR) && $stable(PPROT) && $stable(PWRITE) && $stable(PSTRB)
  );


  // If PREADY is held LOW by the Completer, then the interface remains in the ACCESS state.
  ACCESS2ACCESS_ASSERT : assert property(@(posedge PCLK) disable iff(!PRESETn) State==ACCESS && PENABLE && PSELx && !PREADY |=> State==ACCESS);
    
    
  // PSLVERR is only considered valid during the last cycle of an APB transfer, when PSEL, PENABLE, and PREADY are all HIGH
    VALID_PSLVERR : assert property(@(posedge PCLK) disable iff(!PRESETn) PSLVERR -> State==ACCESS && PENABLE && PSELx && PREADY);

  //The following signals must be valid when PSEL, PENABLE, and PREADY are asserted:-> PRDATA, read only-> PSLVERR
  OUTPUT_SIGNAL_VALIDITY_ASSERT : assert property(
    @(posedge PCLK) disable iff(!PRESETn)
    PSELx && PENABLE && PREADY && PWRITE==READ |->  !($isunknown(PRDATA) && $isunknown(PSLVERR))
  );
    
endmodule