module sobel_top (
input	wire        CLK,
input   wire        RST,
input   wire        i_enable,   //enable the filter
input   wire        i_flush,
input   wire [23:0] i_threshold,
input   wire [11:0] i_data,   
input   wire        i_almostempty, 
output  reg         o_rd,    
input   wire        i_obuf_rd,
output  wire [11:0] o_obuf_data,
output  wire [4:0]  o_obuf_fill,
output  wire        o_obuf_full,
output  wire        o_obuf_almostfull,
output  wire        o_obuf_empty,
output  wire        o_obuf_almostempty
);
wire [71:0] sobel_din;
wire        valid;
wire        req;
wire [7:0]  sobel_dout;
wire        sobel_valid;

reg         nxt_rd;
reg         nxt_din_valid, din_valid;
reg  [9:0]  nxt_rdCounter, rdCounter;

reg  [11:0] obuf_wdata;
reg         obuf_wr;

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

//passthrough logic 
always @ (*) begin
  if (i_enable) begin
    obuf_wdata = {sobel_dout, 4'b0};
	obuf_wr    = sobel_valid;
	end
   else begin
    obuf_wdata = i_data;
    obuf_wr    = din_valid;
   end
end   


//FSM next state logic 
always @(*) begin
  nxt_rd        = 0;
  nxt_din_valid = 0;
  ns            = cs;
  case (cs)
    IDLE : begin
	       case (i_enable)
		     0 : begin
			     if (!i_almostempty) begin
				   nxt_rd        = 1;
				   nxt_din_valid = 1;
				   ns            = ACTIVE;
				   end
				   end
			  1 : begin
			      if (!i_almostempty && req) begin
				   nxt_rd        = 1;
				   nxt_din_valid = 1;
				   ns            = ACTIVE;
				   end
				   end
			endcase
			end
	ACTIVE :begin
	        case (i_enable)
			  0 : begin
                  nxt_rd        = (!i_almostempty);
                  nxt_din_valid = (!i_almostempty);
				  ns            = (i_almostempty) ? IDLE : ACTIVE;
				  end
		      1 : begin
				  nxt_rd        = (!i_almostempty && req);
				  nxt_din_valid = (!i_almostempty && req);
				  ns            = (i_almostempty || !req) ? IDLE : ACTIVE;
				  end
			endcase
			end
		endcase
end
   

FIFO #(.DW(12), .ADDR(10), .ALMOST_FULL(2), .ALMOST_EMPTY(1)) U0_fifo(
.CLK(CLK),
.RST(RST),
.i_wren(obuf_wr),
.i_data(obuf_wdata),
.i_rden(i_obuf_rd),
.o_data(o_obuf_data),
.o_fill(o_obuf_fill),
.o_full(o_obuf_full),
.o_almostfull(o_obuf_almostfull),
.o_empty(o_obuf_empty),
.o_almostempty(o_obuf_almostempty)
);

sobel U0_sobel(
.CLK(CLK),
.RST(RST),
.i_valid(valid),
.i_threshold(i_threshold),
.i_data(sobel_din),
.o_data(sobel_dout),
.o_valid(sobel_valid)
);

Pixel_Control #(.LINE_LENGTH(640), .LINE_NUM (480), .DATA_WIDTH (8)) U0_Sobel_Control(
.CLK(CLK),
.RST(RST&&(~i_flush)),
.i_data(i_data[11:4]),
.i_valid(din_valid),
.o_req(req),
.o_data(sobel_din),
.o_valid(valid)
);

endmodule