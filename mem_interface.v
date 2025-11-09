module mem_interface #(parameter DATA_WIDTH = 12, BRAM_DEPTH = 307200)
(
input   wire                  CLK,
input   wire                  RST,
input   wire                  i_flush,
input   wire [DATA_WIDTH-1:0] i_rdata,
input   wire                  i_almostempty,
output  reg                   o_rd,
input  wire                   i_rclk,
input  wire [18:0]            i_raddr,
output wire [DATA_WIDTH-1:0]  o_rdata    
);

reg         WR_STATE, NEXT_WR_STATE;
localparam  WR_STATE_IDLE   = 0,
            WR_STATE_ACTIVE = 1;
            
reg                           nxt_rd;
reg  [$clog2(BRAM_DEPTH)-1:0] nxt_mem_waddr, mem_waddr;
reg                           nxt_mem_wr, mem_wr;

always @(posedge CLK or negedge RST) begin
  if (~RST || i_flush) begin
     o_rd      <= 0;
     mem_wr    <= 0;
     mem_waddr <= 0;
     WR_STATE    <= WR_STATE_IDLE;
     end
     else begin
       o_rd      <= nxt_rd;
       mem_wr    <= nxt_mem_wr;
       mem_waddr <= nxt_mem_waddr;
       WR_STATE  <= NEXT_WR_STATE;
     end
  end

//Memory Write FSM
always @(*) begin
   nxt_rd           = 0;
   nxt_mem_wr       = 0;
   nxt_mem_waddr    = mem_waddr;
   NEXT_WR_STATE    = WR_STATE;
   case (WR_STATE)
     WR_STATE_IDLE : begin
                     if (!i_almostempty) begin
                       nxt_rd        = 1;
                       nxt_mem_wr    = 1;
                       NEXT_WR_STATE   = WR_STATE_ACTIVE;
                      end
                      end 
    WR_STATE_ACTIVE : begin
                      nxt_rd        = (!i_almostempty);
                      nxt_mem_wr    = (!i_almostempty);
                      nxt_mem_waddr = (mem_waddr == 307199) ? 0:mem_waddr+1;
                      if(i_almostempty) begin
                        NEXT_WR_STATE = WR_STATE_IDLE;
                      end
                      end
        endcase
    end

mem_bram #(.BRAM_DEPTH(BRAM_DEPTH)) mem_bram_i (
.wr_clk     (CLK       ),
.wr_port_en (1'b1      ),  
.wr_addr    (mem_waddr ), // write address
.wr_data    (i_rdata   ), // write data
.i_wr       (mem_wr    ), // write enable
.rd_clk     (i_rclk    ),
.rd_port_en  (1'b1      ),
.rd_addr    (i_raddr   ), // read address
.o_rdata    (o_rdata   )  // read data
);
 
endmodule