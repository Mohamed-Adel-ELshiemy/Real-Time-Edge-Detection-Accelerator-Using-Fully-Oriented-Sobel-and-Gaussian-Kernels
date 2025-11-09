`timescale 1ns/1ps

module system_top_tb();

reg        i_board_clk;
reg        i_rst;
//camera interface      
wire       o_cam_xclk;
wire       o_cam_rstn;
wire       o_cam_pwdn;
reg        i_cam_pclk; 
reg        i_cam_vsync;
reg        i_cam_href; 
reg  [7:0] i_cam_data; 
// i2c interface
wire       SCL;
wire       SDA;
//system control
reg        i_mode;
reg        inc_sobel;
reg        dec_sobel;
reg        i_sobel;   
reg        i_gaussian;
reg        freeze;
//VGA interface
wire [3:0] o_vga_r  ;
wire [3:0] o_vga_g  ;
wire [3:0] o_vga_b  ;
wire       o_vga_vs ;
wire       o_vga_hs ;
//status
wire        mode_on;     
wire        gaussian_on; 
wire        sobel_on;    
wire        led_threshold;

initial
begin
	i_board_clk = 1'b1;
	i_rst       = 1'b1;
	i_cam_pclk  = 1'b1;
	i_cam_vsync = 1'b0;
	i_cam_href  = 1'b0;
    i_cam_data  = 8'd8;
	i_mode      = 1'b0;
	inc_sobel   = 1'b0;
	dec_sobel   = 1'b0;
	i_sobel     = 1'b0;   
	i_gaussian  = 1'b0;
	freeze      = 1'b0;
	#30
	i_rst       = 1'b0;
	#20
	i_cam_vsync = 1'b1;
	i_cam_href  = 1'b1;
	#20
	i_mode      = 1'b1;
	#20
	inc_sobel   = 1'b1;
	#20
	dec_sobel   = 1'b1;
	#20
	i_sobel     = 1'b1;
	#20
	i_gaussian  = 1'b1;
	#20
	freeze      = 1'b1;
	#100
	$stop;
end

always #10 i_board_clk = ~i_board_clk;

always #20 i_cam_pclk = ~i_cam_pclk;
	
system_top system_top_uut(
							.i_board_clk(i_board_clk),
						    .i_rst(i_rst),      
							.o_cam_xclk(o_cam_xclk),
                            .o_cam_rstn(o_cam_rstn),
                            .o_cam_pwdn(o_cam_pwdn),
                            .i_cam_pclk(i_cam_pclk),
                            .i_cam_vsync(i_cam_vsync),
                            .i_cam_href(i_cam_href), 
                            .i_cam_data(i_cam_data),
                            .SCL(SCL),
                            .SDA(SDA),
                            .i_mode(i_mode),
                            .inc_sobel(inc_sobel),
                            .dec_sobel(dec_sobel),
                            .i_sobel(i_sobel),   
                            .i_gaussian(i_gaussian),
                            .freeze(freeze),
                            .o_vga_r  (o_vga_r),
                            .o_vga_g  (o_vga_g),
                            .o_vga_b  (o_vga_b),
                            .o_vga_vs (o_vga_vs),
                            .o_vga_hs (o_vga_hs),
                             .mode_on(mode_on),     
                             .gaussian_on(gaussian_on), 
                             .sobel_on(sobel_on),    
                             .led_threshold(led_threshold)
						  );	 
						  
endmodule 