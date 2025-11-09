//Creates a three-word read memory

module line_buffer #(parameter RL = 640 , DATA_WIDTH = 8)
(
input     wire                     CLK,
input     wire                     RST,
input     wire                     i_wren,
input     wire  [DATA_WIDTH-1:0]   i_data,
input     wire                     i_rden,
output    reg   [3*DATA_WIDTH-1:0] o_data
);

reg [DATA_WIDTH-1:0] line [RL-1:0];
reg [$clog2(RL)-1:0] wr_ptr, rd_ptr; //clog2 is typically used to calculate the minimum width required to address a memory of a given size
//reg [8:0] wr_ptr, rd_ptr;
wire [3*DATA_WIDTH-1:0] read_data;

assign read_data = {line[rd_ptr-1], line[rd_ptr], line[rd_ptr+1]};  //Revise

always @ (posedge CLK) begin
  o_data <= read_data; // 1 cycle read latency for better performance
end


always @ (posedge CLK) begin
  if (i_wren) begin
    line[wr_ptr] <= i_data;
  end
end

always @(posedge CLK or negedge RST) begin
   if(!RST)
     wr_ptr <= 0;
   else begin
     if(i_wren) begin
       wr_ptr <= (wr_ptr == RL - 1) ? 0 : wr_ptr + 1'b1;
   end
   end
end 
       
always @(posedge CLK or negedge RST) begin
    if(!RST)
      rd_ptr <= 0; 
    else begin
      if(i_rden) begin
        rd_ptr <= (rd_ptr == RL - 1) ? 0 : rd_ptr + 1'b1;
    end
    end
end

/*always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    wr_ptr <= 'b0;
    rd_ptr <= 'b0;
   end
  else if (i_wren) begin
   wr_ptr <= (wr_ptr == LINE_LENGTH-1) ? 0 : wr_ptr + 1'b1;
  end
  else if (i_rden) begin
   rd_ptr <= (rd_ptr == LINE_LENGTH-1) ? 0 : rd_ptr + 1'b1;
  end
  else begin
    wr_ptr <= 'b0;
    rd_ptr <= 'b0;
  end
end
*/
endmodule
