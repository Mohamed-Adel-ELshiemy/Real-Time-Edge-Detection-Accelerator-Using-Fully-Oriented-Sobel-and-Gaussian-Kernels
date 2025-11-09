module FIFO #(parameter DW = 8, ADDR = 9, ALMOST_FULL = 2, ALMOST_EMPTY = 2)
(
input  wire                   CLK,
input  wire                   RST,
input  wire                   i_wren,
input  wire                   i_rden,
input  wire [DW-1:0]          i_data,
output reg  [DW-1:0]          o_data,
output reg  [ADDR:0]          o_fill,
output wire                   o_full,
output wire                   o_almostfull,
output wire                   o_empty,
output wire                   o_almostempty
);
localparam FIFO_DEPTH = (1<<ADDR);

reg  [DW-1:0] mem [0:FIFO_DEPTH-1];

reg  [ADDR-1:0] wr_ptr;             
reg  [ADDR-1:0] rd_ptr;

wire  [DW-1:0] rd_data;
assign rd_data = mem[rd_ptr];

always@(posedge CLK) begin
   mem[wr_ptr] <= i_data;
   o_data <= rd_data; //register the output data
end

//Read and Write pointers
always@(posedge CLK) begin
    if(!RST) begin
      wr_ptr <= 0;
	  rd_ptr <= 0;
    end
    else begin
     wr_ptr <= (i_wren) ? wr_ptr + 1 : wr_ptr;
     rd_ptr <= (i_rden) ? rd_ptr + 1 : rd_ptr;
    end
 end
    
//Status and fill level
always@(posedge CLK) begin
   if(!RST) begin
      o_fill <= 0;
    end
    else if (i_rden && !i_wren) begin
      o_fill <= o_fill - 1;
    end
    else if (!i_rden && i_wren) begin
      o_fill <= o_fill + 1;
    end
 end

assign o_full        = (o_fill == FIFO_DEPTH);
assign o_almostfull  = (o_fill == FIFO_DEPTH-ALMOST_FULL);
assign o_empty       = (o_fill == 0);
assign o_almostempty = (o_fill <= ALMOST_EMPTY);
    
endmodule 
