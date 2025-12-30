// error solved - 
// scoreboard corrected
// passes every testcase  and most assertion

//error got - fails to show wait transfers , i.e, due to some reason slave doesnot give ready even after enable(can be done another delay signal which is native to slave only)


//DATE   - 6 Aug, 2025
//AUTHOR - Nitish Gobinda Panda
//COMPANY- Scaledge
//PROJECT- APB_SLAVE_RTL/DUT code

module APB_DUT(PCLK,PRESETn,PADDR,PPROT,PSELx,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA,PSLVERR,PWAKEUP,delay_by_slave_module);

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
        ALIGN_ADDR=PADDR-(PADDR%STRB_WIDTH); //aligned addr
        if (PSELx && PENABLE) begin
          n_s = SETUP;
          PREADY = 1;
          if(ALIGN_ADDR[ADDR_WIDTH-1]==1) PSLVERR=1;
          else PSLVERR=0;
          if(PWRITE) begin //write trns
            if(PWDATA[DATA_WIDTH-1 -:8]!=crc(PWDATA, PSTRB)) PSLVERR=1; 
            else PSLVERR=0;//crc mismatch
            //                   $display("%h",PWDATA);
            //                 $display("%h %h %h %b",ALIGN_ADDR, mem[ALIGN_ADDR],PWDATA,PSTRB);
            write_transfer();
          end

          else begin //read transfer i.e, pwrite==0
            if(PSTRB==0) begin
              read_transfer();
              //               $display("%h %h %h %b",ALIGN_ADDR, mem[ALIGN_ADDR],PWDATA,PSTRB);
            end
            else PSLVERR=1;//pstrb should be 0 in read
          end

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

  task write_transfer();
    case(PPROT) //protection
      3'b000:begin //normal-unsecure-data_memory_space
        if(ALIGN_ADDR>=0*(DEPTH/8) && ALIGN_ADDR<1*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
              //               $strobe("%h %h %h %b",ALIGN_ADDR+j, mem[ALIGN_ADDR+j],PWDATA,PSTRB);
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b001:begin //normal-unsecure-instr_memory_space
        if(ALIGN_ADDR>=1*(DEPTH/8) && ALIGN_ADDR<2*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b010:begin //normal-secure-data_memory_space
        if(ALIGN_ADDR>=2*(DEPTH/8) && ALIGN_ADDR<3*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b011:begin //normal-secure-instr_memory_space
        if(ALIGN_ADDR>=3*(DEPTH/8) && ALIGN_ADDR<4*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b100:begin //privilage-unsecure-data_memory_space
        if(ALIGN_ADDR>=4*(DEPTH/8) && ALIGN_ADDR<5*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b101:begin //privilage-unsecure-instr_memory_space
        if(ALIGN_ADDR>=5*(DEPTH/8) && ALIGN_ADDR<6*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b110:begin//privilage-secure-data_memory_space
        if(ALIGN_ADDR>=6*(DEPTH/8) && ALIGN_ADDR<7*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end

      3'b111:begin //privilage-secure-instr_memory_space
        if(ALIGN_ADDR>=7*(DEPTH/8) && ALIGN_ADDR<8*(DEPTH/8)) begin
          for(j=0;j<STRB_WIDTH;j++)begin
            if(PSTRB[j] || j==STRB_WIDTH-1) begin
              mem[ALIGN_ADDR+j]<=PWDATA[8*j+:8];//narrow transfer
            end
          end
        end
        else PSLVERR<=1;
      end
      default : PSLVERR<=1;
    endcase
  endtask


  task read_transfer();
    case(PPROT) //protection
      3'b000:begin //normal-unsecure-data_memory_space
        if(ALIGN_ADDR>=0*(DEPTH/8) && ALIGN_ADDR<1*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
            //             $display("%h %h %h %b",ALIGN_ADDR+k, mem[ALIGN_ADDR+k], PRDATA,PSTRB);
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b001:begin //normal-unsecure-instr_memory_space
        if(ALIGN_ADDR>=1*(DEPTH/8) && ALIGN_ADDR<2*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b010:begin //normal-secure-data_memory_space
        if(ALIGN_ADDR>=2*(DEPTH/8) && ALIGN_ADDR<3*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b011:begin //normal-secure-instr_memory_space
        if(ALIGN_ADDR>=3*(DEPTH/8) && ALIGN_ADDR<4*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b100:begin //privilage-unsecure-data_memory_space
        if(ALIGN_ADDR>=4*(DEPTH/8) && ALIGN_ADDR<5*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b101:begin //privilage-unsecure-instr_memory_space
        if(ALIGN_ADDR>=5*(DEPTH/8) && ALIGN_ADDR<6*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b110:begin//privilage-secure-data_memory_space
        if(ALIGN_ADDR>=6*(DEPTH/8) && ALIGN_ADDR<7*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end

      3'b111:begin //privilage-secure-instr_memory_space
        if(ALIGN_ADDR>=7*(DEPTH/8) && ALIGN_ADDR<8*(DEPTH/8)) begin
          for(k=0;k<DATA_WIDTH/8;k++)begin
            PRDATA[(k+1)*8-1-:8]=mem[ALIGN_ADDR+k];
          end
          PRDATA[DATA_WIDTH-8 +:8]=crc(PRDATA,4'b1111); //put crc while read cycle
        end
        else PSLVERR<=1;
      end
      default : PSLVERR<=1;
    endcase
  endtask
endmodule