//DATE   - 12 Aug, 2025
//AUTHOR - Nitish Gobinda Panda
//COMPANY- Scaledge
//PROJECT- APB_SLAVE_RTL/DUT code

//!!!!!!!!!!!!!!!   NOTE   !!!!!!!!!!!!!!
//delay_by_slave_module isa signal given by another connected module to our design.
//it can be modelled by another agent but here i have used same agent for this (to save time)


module APB_DUT(PCLK,PRESETn,PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA,PSLVERR,PWAKEUP, delay_by_slave_module);

  parameter DATA_WIDTH=8;
  parameter ADDR_WIDTH=8;
  parameter STRB_WIDTH=(DATA_WIDTH/8);
  parameter DEPTH=2**ADDR_WIDTH;

  input PCLK, PRESETn, PSELx, PENABLE, PWRITE,PWAKEUP,delay_by_slave_module;
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

  function reg[7:0] crc(input reg[DATA_WIDTH-1:0] a, input reg[STRB_WIDTH-1:0]strb);
    begin
      for(l=0;l<STRB_WIDTH;l=l+1)begin  // considers strb bits during crc calculation
        if(strb[l]==0) a[8*(l+1)-1 -:8]=8'h00;
      end
      a[DATA_WIDTH-8 +:8]=0;
      for(m=0;m<DATA_WIDTH-8;m=m+8)begin //calculates crc
        a[DATA_WIDTH-8 +:8]=a[DATA_WIDTH-8 +:8]^a[m+:8];
      end
      crc=a[DATA_WIDTH-8 +:8];
    end
  endfunction

  // State transition logic
  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      p_s <= IDLE; // Reset to initial state
      PREADY <= 0;
      PSLVERR<= 0;
      PRDATA <=0;
      for(i=0;i<DEPTH;i++) mem[i]<=0;

    end else begin
      p_s <= n_s;
    end
  end

  // Next p_s and output logic
  always @(*) begin
    case (p_s)
      IDLE: begin
        if (PSELx) begin  //indicate initiation of a possibility of transfer
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
        if(PSELx && PENABLE) begin
          n_s = ACCESS; //section-3.1.1 The interface only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock.
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
        else if(PSELx && !PENABLE) begin
          n_s = SETUP; 
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
        else begin
          n_s = IDLE; 
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
      end
      ACCESS: begin
        //section-2.1.1 a Completer might use the unaligned address, aligned address, or signal an error response.
        ALIGN_ADDR=PADDR-(PADDR%STRB_WIDTH); //unaligned to aligned addr
        if(PSELx && PENABLE)begin
          if(delay_by_slave_module) begin // enables wait states intranscations
            PREADY = 1;
          end else begin
            PREADY=0;
          end
        end

        if (PSELx && PENABLE && PREADY) begin
          //wait states
          n_s=SETUP; //Section - 4.1 the bus moves directly to the SETUP state if another transfer follows.
          if((ALIGN_ADDR[ADDR_WIDTH-1]==1) || (PWDATA[DATA_WIDTH-1 -:8]!=crc(PWDATA, PSTRB))) PSLVERR=1; 
          else PSLVERR=0;//crc mismatch
          if(PWRITE) begin //write trns
            if(ALIGN_ADDR>=PPROT*(DEPTH/8) && ALIGN_ADDR<(PPROT+1)*(DEPTH/8)) begin //asserts if valid pprot for address to be accessed
              for(j=0;j<STRB_WIDTH;j++)begin
                if(PSTRB[j] || j==STRB_WIDTH-1) begin
                  mem[ALIGN_ADDR+j]=PWDATA[8*j+:8];//narrow transfer
                end
              end
            end
            else PSLVERR=1;

          end

          else begin //read transfer i.e, pwrite==0
            if(PSTRB==0) begin
              if(ALIGN_ADDR>=PPROT*(DEPTH/8) && ALIGN_ADDR<(PPROT+1)*(DEPTH/8)) begin//asserts if valid pprot for address to be accesses

                for(k=0;k<DATA_WIDTH/8;k++)begin
                  PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
                  // $display("%h %h %h %b",ALIGN_ADDR+k, mem[ALIGN_ADDR+k], PRDATA,PSTRB);
                end
                PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
              end
              else PSLVERR=1;  

            end
            else PSLVERR=1;//pstrb should be 0 in read
          end

        end else if (PSELx && PENABLE && !PREADY) begin
          n_s = ACCESS;//Section-4.1 If PREADY is held LOW by the Completer, then the interface remains in the ACCESS state.
          PREADY = 0; 
          PSLVERR= 0;
          PRDATA=0;
        end else begin
          n_s = IDLE;//Section - 4.1 - the bus returns to the IDLE state if no more transfers(enable&&ready&&sel==1==transfer) are required
          PREADY = 0;
          PSLVERR= 0;
          PRDATA=0;
        end
      end
      default: begin
        n_s = IDLE;//Section-4.1 default state of APB interface
        PREADY = 0;
        PSLVERR= 0;
        PRDATA=0;
      end
    endcase
  end
endmodule

