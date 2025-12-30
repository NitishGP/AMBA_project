

// Corrected state machine - mealy overlapping type

//DATE   - 6 Aug, 2025
//AUTHOR - Nitish Gobinda Panda
//COMPANY- Scaledge
//PROJECT- APB_SLAVE_RTL/DUT code


module APB_DUT(PCLK,PRESETn,PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA,PSLVERR,PWAKEUP);

  parameter DATA_WIDTH=8;
  parameter ADDR_WIDTH=8;
  parameter STRB_WIDTH=(DATA_WIDTH/8);
  parameter DEPTH=2**ADDR_WIDTH;

  input PCLK, PRESETn, PSELx, PENABLE, PWRITE,PWAKEUP;
  input [ADDR_WIDTH-1:0] PADDR;
  input [2:0] PPROT;
  input [DATA_WIDTH-1:0] PWDATA;
  input [STRB_WIDTH-1:0] PSTRB;
  output reg PREADY, PSLVERR;
  output reg [DATA_WIDTH-1:0] PRDATA;

  reg [7:0] mem [DEPTH-1:0];
  reg [ADDR_WIDTH-1:0] ALIGN_ADDR;

  localparam IDLE=3'b001;
  localparam SETUP=3'b010;
  localparam ACCESS=3'b100;

  reg [2:0] n_s,p_s;

  integer i,j,k,l,m;
  
  

  // State transition logic
  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      p_s <= IDLE; // Reset to initial state
    else
      p_s <= n_s;
  end

  // Next p_s and output logic
  always @(*) begin
    case (p_s)
      IDLE: begin
        if (PSELx) begin
          n_s = SETUP;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end else begin
          n_s = IDLE;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
      end
      SETUP: begin
        if (PSELx && PENABLE) begin
          n_s = ACCESS;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end 
        else if (PSELx && !PENABLE) begin
          n_s = SETUP;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end else begin
          n_s = IDLE;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
      end
      ACCESS: begin
        if (PSELx && PENABLE) begin
          n_s = SETUP;
          PREADY = 1; // Output is 1 when "101" is detected
          PSLVERR= 1;
          PRDATA=1;
        end else if (PSELx && !PENABLE) begin
          n_s = ACCESS;
          PREADY = 0; // Output is 1 when "101" is detected
          PSLVERR= 0;
          PRDATA=0;
        end else begin
          n_s = IDLE;
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
      end
      default: begin
        n_s = IDLE;
        PREADY = 0;
        PSLVERR= 0;
        PRDATA=0;
      end
    endcase
  end
endmodule