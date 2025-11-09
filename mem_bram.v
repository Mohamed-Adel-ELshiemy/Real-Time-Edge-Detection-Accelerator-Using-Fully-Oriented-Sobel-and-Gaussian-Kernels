module mem_bram #(parameter BRAM_WIDTH = 12, BRAM_DEPTH = 16384)
(
input   wire                          wr_clk,
input   wire                          wr_port_en,
input   wire [$clog2(BRAM_DEPTH)-1:0] wr_addr,
input   wire  [BRAM_WIDTH-1:0]        wr_data,
input   wire                          i_wr,

input   wire                          rd_clk,
input   wire                          rd_port_en,
input   wire [$clog2(BRAM_DEPTH)-1:0] rd_addr,
output  reg  [BRAM_WIDTH-1:0]          o_rdata              
);

reg [BRAM_WIDTH-1:0] mem [0:BRAM_DEPTH];

always @ (posedge wr_clk) begin
     if (wr_port_en) begin
	  if (i_wr) begin
	    mem[wr_addr] <= wr_data;
	  end
	 end
end

always @ (posedge rd_clk) begin
    if (rd_port_en) begin
	 o_rdata <= mem[rd_addr];
	 end
end

endmodule

	