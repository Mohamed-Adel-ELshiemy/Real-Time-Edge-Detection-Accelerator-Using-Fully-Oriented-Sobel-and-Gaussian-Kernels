
`define MODE_PASSTHROUGH 0

module grayscale_top
(
input   wire         CLK,
input   wire         RST,
input   wire         i_flush,
input   wire         i_mode,  //Grayscale enabler 
input   wire [11:0]  i_data,  
input   wire         i_almostempty,
input   wire         i_rd,    
output  wire [11:0]  o_data,  
output  wire [10:0]  o_fill,
output  wire         o_almostempty,
output  reg          o_rd   
);

reg [11:0] din;
reg        din_valid, nxt_din_valid;

reg        nxt_rd;
reg [9:0]  nxt_rdCounter, rdCounter;

//FIFO output
reg         fifo_wr;
reg  [11:0] fifo_wdata;
wire [11:0] fifo_rdata;
wire        fifo_almostempty;
wire        fifo_almostfull;
wire        fifo_empty;

//grayscaler signals
wire        grayscale_valid;
wire [11:0] grayscale_dout;

reg         cs, ns;
localparam  IDLE   = 0,
            ACTIVE = 1;
            
always @ (posedge CLK or negedge RST) begin
  if (~RST) begin
  o_rd       <= 0;
	din_valid  <= 0;
	rdCounter  <= 0;
	cs         <= IDLE;
	end
  else begin
  o_rd       <= nxt_rd;
	din_valid  <= nxt_din_valid;
	rdCounter  <= nxt_rdCounter;
	cs         <= ns;
	end
end            
                   
//FSM next state logic            
always @(*) begin
  nxt_rd        = 0;
  nxt_din_valid = 0;
  nxt_rdCounter = rdCounter;
  ns            = cs;
  case(cs)
     IDLE: begin
           if(!i_almostempty) begin
           nxt_rd        = 1;
           nxt_din_valid = 1;
           ns            = ACTIVE;
           end
           end
   ACTIVE: begin
           nxt_rd        = (!i_almostempty);
           nxt_din_valid = (!i_almostempty);
           if(i_almostempty) begin
             ns = IDLE;
           end
           end
        endcase
end

//Write to FIFO baed on selected mode
always @(*) begin
  if(i_mode == `MODE_PASSTHROUGH) begin
    fifo_wr    = (!fifo_almostfull) ? din_valid : 0;
    fifo_wdata = i_data;
  end
  else begin
    fifo_wr    = (!fifo_almostfull) ? grayscale_valid : 0;
    fifo_wdata = grayscale_dout;
  end
end

RGB2GRAY U0_gs
(
.CLK(CLK),
.RST(RST),
.i_valid(din_valid),
.i_data(i_data),
.o_data(grayscale_dout),
.o_valid(grayscale_valid)
);

FIFO #(.DW(12), .ADDR(10), .ALMOST_FULL(2), .ALMOST_EMPTY(1)) U1_fifo(
.CLK(CLK),
.RST(RST&&(~i_flush) ),
.i_wren(fifo_wr),
.i_data(fifo_wdata),
.i_rden(i_rd),
.o_data(o_data),
.o_fill(o_fill),
.o_full(),
.o_almostfull(fifo_almostfull),
.o_empty(fifo_empty),
.o_almostempty(o_almostempty)
);

endmodule
  