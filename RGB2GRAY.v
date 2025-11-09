module RGB2GRAY(
input   wire          CLK,
input   wire          RST,
input   wire          i_valid,
output  reg           o_valid,
input   wire  [11:0]  i_data,
output  reg   [11:0]   o_data
);
 
wire [7:0] red;
wire [7:0] green;
wire [7:0] blue;

//Convert incoming RGB444 data to grayscale   
assign red   = (i_data[11:8] << 4); //wire [7:0] red     = {i_data[11:8], 4'b0};
assign green = (i_data[7:4]  << 4); //wire [7:0] green   = {i_data[7:4], 4'b0};
assign blue  = (i_data[3:0]  << 4); //wire [7:0] blue    = {i_data[3:0], 4'b0};




always @(posedge CLK) begin
  if (!RST) begin
    {o_data, o_valid}  <= 2'b0;
   end
  else begin
        
         {o_data, o_valid}  <= 2'b0;
        
            if(i_valid) begin
			        o_data <= (red >> 2)+(red >> 5)+(red >> 6)+(green >> 1)+(green >> 4)+( green >> 5)+(blue >> 3);
			  //o_data <= (r+g+b)/3;
              o_valid <= 1;
			  end
			end
    /*
    Grayscale Algorithm:
     -luminosity method

    o_data = 0.299R + 0.587G + 0.114B
    
    o_data = [ (R>>2) + (R>>5) + (R>>6) ] + [ (G>>1) + (G>>4) + (G>>5)] + [ (B>>3) ]
    o_data = [  0.25R +  0.03R +  0.01R ] + [  0.5G  + 0.06G  + 0.03G ] + [ 0.12B  ]
    o_data = [0.29R] + [0.59G] + [0.12B]
    
    */
    
end

/*function [7:0] grayscaler;
  input [7:0] pixel;
    begin
   r = {pixel[7:5],5'b0};
   g = {2'b0, pixel[4:2],3'b0};
   b = {6'b0, pixel[1:0]};
   grayscaler = (r>>2)+(r>>5)+(r>>6)+(g>>1)+(g>>4)+(g>>5)+(b>>3);
end
endfunction
*/
  /*
    p0_g    <= grayscaler(p0);
    p1_g    <= grayscaler(p1);
    p2_g    <= grayscaler(p2);
    p3_g    <= grayscaler(p3);
    p4_g    <= grayscaler(p4);
    p5_g    <= grayscaler(p5);
    p6_g    <= grayscaler(p6);
    p7_g    <= grayscaler(p7);
    p8_g    <= grayscaler(p8);
    */
endmodule



