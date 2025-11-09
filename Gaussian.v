module Gaussian (
input   wire            CLK,
input   wire            RST,
input   wire            i_valid,
input   wire   [71:0]   i_data,
input   wire   [25:0]   i_threshold,
output  reg    [7:0]    o_data,
output  reg             o_valid
);

integer i;

//  3x3 kernel
reg  [7:0]  kernel [8:0];

//stage 1 --> Multiply
reg  [10:0] multData_data [8:0];
reg         multData_valid;
reg         multData_reg_valid;
reg  [10:0] multData_data_reg [8:0];

//stage 2 --> Accumlate
reg  [10:0] stage2_accumulator;
reg  [10:0] stage2_data;
reg         stage2_valid;


// KERNEL DEFINITION: 3X3 GAUSSIAN BLUR
initial begin
    kernel[0] = 1;
    kernel[1] = 2;
	kernel[2] = 1;
	kernel[3] = 2;
	kernel[4] = 4;
	kernel[5] = 2;
	kernel[6] = 1;
	kernel[7] = 2;
	kernel[8] = 1;
end

//stage 1 apply the filter on the image
always@(posedge CLK) begin
        if(!RST) begin
           multData_valid <= 0;
           for(i=0; i<9; i=i+1) begin
             multData_data[i] <= 0;
            end
        end
        else begin
           multData_valid <= i_valid;
           for(i=0; i<9; i=i+1) begin
             multData_data[i] <= $signed(kernel[i]) * $signed({1'b0, i_data[i*8+:8]});
            end
        end
end
always@(posedge CLK) begin
        if(!RST) begin
            multData_reg_valid <= 0;
            for(i=0; i<9; i=i+1) begin
                multData_data_reg[i] <= 0;
            end
        end
        else begin
            multData_reg_valid <= multData_valid;
            for(i=0; i<9; i=i+1) begin
                multData_data_reg[i] <= multData_data[i];
            end
        end
end

//stage 2
//sum all the data from previous stage
 always@* begin
        stage2_accumulator = 0;
        for(i=0;  i<9; i=i+1) begin
            stage2_accumulator = $signed(stage2_accumulator) + $signed(multData_data_reg[i]);
        end
end

always@(posedge CLK) begin
        if(!RST) begin
            stage2_valid <= 0;
            stage2_data  <= 0;
        end
        else begin
            stage2_valid <= multData_reg_valid;
            stage2_data  <= stage2_accumulator;
        end
end
////stage 3 --> Divide by 16 and output
always@(posedge CLK) begin
        if(!RST) begin
            o_valid <= 0;
            o_data  <= 0;
        end
        else begin
            o_valid <= stage2_valid;
            o_data  <= stage2_data >> 4; //output is 8 bits
        end
end


endmodule