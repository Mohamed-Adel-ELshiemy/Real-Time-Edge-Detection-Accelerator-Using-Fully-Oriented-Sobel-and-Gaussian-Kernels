module sobel #(parameter DW = 8)(
input   wire            CLK,
input   wire            RST,
input   wire            i_valid,
input   wire   [9*DW:0] i_data,
input   wire   [25:0]   i_threshold,
output  reg    [DW-1:0] o_data,
output  reg             o_valid
);

integer i;
localparam KW = 8;

//3x3 Filter Kernel
reg [KW-1:0] kernelX [8:0];
reg [KW-1:0] kernelY [8:0];

//stage 1 --> Multiply
reg [15:0] multDataX_reg [8:0];
reg [15:0] multDataY_reg [8:0];
reg mult_valid_reg;
reg [15:0] multDataX [8:0];
reg [15:0] multDataY [8:0];
reg mult_valid;

//stage 2 --> Accumlate
reg [15:0] sumDataX, sumDataY;
reg [15:0] sumDataX_reg, sumDataY_reg;
reg sum_valid;

//stage 3 --> Convolution
wire [25:0] convolved_data;
reg  [25:0] dataX, dataY;
reg         convolved_valid;

//Kernel Definition
initial begin
  kernelX[0] =  1;
  kernelX[1] =  0;
  kernelX[2] = -1;
  kernelX[3] =  2;
  kernelX[4] =  0;
  kernelX[5] = -2;
  kernelX[6] =  1;
  kernelX[7] =  0;
  kernelX[8] = -1;

  kernelY[0] =  1;
  kernelY[1] =  2;
  kernelY[2] =  1;
  kernelY[3] =  0;
  kernelY[4] =  0;
  kernelY[5] =  0;
  kernelY[6] = -1;
  kernelY[7] = -2;
  kernelY[8] = -1;
    end
    
//stage 1 apply the filter on the image
always @(posedge CLK or negedge RST) begin
  if (!RST) begin
    mult_valid <= 1'b0;
    for (i=0; i<9; i=i+1) begin
      multDataX[i] <= 0;
      multDataY[i] <= 0;
     end
    end
   else begin
     mult_valid <= i_valid;
     for (i=0; i<9; i=i+1)
     begin
      multDataX[i] <= $signed(kernelX[i])*$signed({1'b0,i_data[i*DW+:DW]});
      multDataY[i] <= $signed(kernelY[i])*$signed({1'b0,i_data[i*DW+:DW]});
     end
   end
 end
 
always @(posedge CLK or negedge RST) begin
  if (!RST) begin
    mult_valid_reg <= 1'b0;
    for (i=0; i<9; i=i+1) begin
      multDataX_reg[i] <= 0;
      multDataY_reg[i] <= 0;
     end
   end
    else begin
      mult_valid_reg <= 1'b1;
      for (i=0; i<9; i=i+1) begin
      multDataX_reg[i] <= multDataX[i];
      multDataY_reg[i] <= multDataX[i];
    end
    end
end 

//stage 2
//sum all the data from previous stage
always @(*) begin
  sumDataX = 0;
  sumDataY = 0;
  for (i=0; i<9; i=i+1)
  begin
    sumDataX = $signed(sumDataX) + $signed(multDataX_reg[i]);
    sumDataY = $signed(sumDataY) + $signed(multDataY_reg[i]);
  end
end

always @(posedge CLK or negedge RST) begin
  if (!RST) begin
    sumDataX_reg <= 0;
    sumDataY_reg <= 0;
    sum_valid    <= 0;
   end
  else begin
    sumDataX_reg <= sumDataX;
    sumDataY_reg <= sumDataY;
    sum_valid    <= mult_valid_reg;
  end
end

//stage 3
//square X and Y results from stage 2
always @(posedge CLK or negedge RST) begin
  if (!RST) begin
    dataX           <= 0;
    dataY           <= 0;
    convolved_valid <= 0;
  end
  else begin
    dataX           <= $signed(sumDataX_reg)*$signed(sumDataX_reg);
    dataY           <= $signed(sumDataY_reg)*$signed(sumDataY_reg);
    convolved_valid <= sum_valid;
   end
end

assign convolved_data = dataX + dataY;

//Use Thresholding instead of square root
always @(posedge CLK or negedge RST) begin
  if (~RST) begin
    o_valid <= 0;
    o_data  <= 0;
   end
  else begin
    o_valid <= convolved_valid;
    o_data  <= (convolved_data > i_threshold) ? {(DW){1'b1}} : 8'h0;
  end
end

endmodule
    