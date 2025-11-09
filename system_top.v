`default_nettype none /* all your input ports are effectively not fully described, because the compiler does not  
                      know the resolution function for the net */ 
module system_top 
(
input   wire         i_board_clk, //100 MHz board clock
input   wire         i_rst,        //active-high board button

//camera interface
output wire       o_cam_xclk,  // 24MHz clock to camera from DCM
output wire       o_cam_rstn,  // camera active low reset
output wire       o_cam_pwdn,  // camera active high power down 
input  wire       i_cam_pclk,  // camera generated pixel clock
input  wire       i_cam_vsync, // camera vsync
input  wire       i_cam_href,  // camera href
input  wire [7:0] i_cam_data,  // camera 8-bit data in

// i2c interface
inout  wire       SCL,         // bidirectional SCL
inout  wire       SDA,         // bidirectional SDA
 

//system control 
input    wire i_mode,
input    wire inc_sobel,
input    wire dec_sobel,

input    wire i_sobel,   //sobel switch enable on board
input    wire i_gaussian, //gaussian switch enable on board
input    wire freeze,

//VGA interface
output wire [3:0] o_vga_r  , 
output wire [3:0] o_vga_g  , 
output wire [3:0] o_vga_b  , 
output wire       o_vga_vs , 
output wire       o_vga_hs ,

//status
output   wire        mode_on,      //system mode
output   wire        gaussian_on, //gaussian enabled
output   wire        sobel_on,    //sobel enabled
output   wire        led_threshold
);

/* Wires and Registers */

//Debounce 
wire  rst_db;

//clk_wiz
//wire clk_125MHz;
//wire clk_24MHz;
wire clk_25MHz;
//wire clk_processing;
wire i_sysclk;

//System Control
wire        sys_mode;
wire        sobel_enable;
wire        gaussian_enable;
wire        cam_start;
wire        pipe_flush;
wire [25:0] sobel_threshold;
wire        threshold_region; 
 
//Camera Block
wire        i_scl, i_sda;
wire        o_scl, o_sda;
wire        sof;
wire        cam_obuf_rd;
wire [11:0] cam_obuf_rdata;
wire        cam_obuf_almostempty;
wire        cfg_done;

//Grayscale Block
wire         gs_rd;
wire         gs_almostempty;
wire [11:0]  gs_data;
wire [10:0]  gs_fill;

//Gaussian Block
wire         gssn_rd;
wire         gssn_almostempty;
wire         gssn_data;

//Sobel Block
wire         sobel_rd;
wire         sobel_almostempty;
wire [11:0]  sobel_data;

//Display Interface
wire [18:0] frame_raddr;
wire [11:0] frame_rdata;

 assign o_cam_rstn = 1'b1; // sw reset instead
 assign o_cam_pwdn = 1'b0;  
assign mode_on       = sys_mode;
assign gaussian_on   = gaussian_enable;
assign sobel_on      = sobel_enable;
assign led_threshold = threshold_region;

/*                 Reset Signals                 */

//Debounce Reset button
//debounced in camera pclk domain (24MHz)
debounce 
#(.D_count(1))    // 20ms debounce period
db_inst(
.i_clk        (i_cam_pclk),
.i_input      (~i_rst),
.o_debounce   (rst_db)  // 24MHz clock domain debounced reset
);

//Async Reset Synchronizers

//25MHZ
reg sync_rst_25MHZ, sync_rst_1;
always @(posedge clk_25MHz or negedge rst_db) begin
 if (!rst_db) begin
   {sync_rst_25MHZ, sync_rst_1} <= 2'b0;
 end
 else begin
   {sync_rst_25MHZ, sync_rst_1} <= {sync_rst_1, 1'b1};
 end
end

//125MHZ
reg sync_rst_processing, sync_rst_2;
always @(posedge i_sysclk or negedge rst_db) begin
 if (!rst_db) begin
   {sync_rst_processing, sync_rst_2} <= 2'b0;
 end
 else begin
   {sync_rst_processing, sync_rst_2} <= {sync_rst_2, 1'b1};
 end
end


/*                 Instantiation                 */

/*                 Clocking Wizard                 */
clk_wiz_0 dcm_i
   (
    // Clock out ports
    .clk_24MHz(o_cam_xclk),     // output clk_24MHz
    .clk_25MHz(clk_25MHz),     // output clk_25MHz
    .clk_125MHz(i_sysclk),     // output clk_125MHz
    //.clk_processing(clk_processing),     // output clk_PS
    // Status and control signals
    .reset(1'b0 ), // input reset
   // Clock in ports
    .clk_in1(i_board_clk)); 

/*                 System Control                 */

system_control U0_cntrl (
.i_sysclk         (i_sysclk),
.RST              (sync_rst_processing),
.i_mode           (i_mode),
.sof              (sof),
.i_sobel          (i_sobel),
.i_gaussian       (i_gaussian),
.inc_sobel        (inc_sobel),
.dec_sobel        (dec_sobel),

.cam_start        (cam_start),
.o_mode           (sys_mode),
.pipe_flush       (pipe_flush),
.gaussian_enable  (gaussian_enable),
.sobel_enable     (sobel_enable),
.sobel_threshold  (sobel_threshold),
.threshold_region (threshold_region)
);

/*                 Camera Block                 */

assign SCL = (o_scl) ? 1'bz : 1'b0;
    assign SDA = (o_sda) ? 1'bz : 1'b0;
    assign i_scl = SCL;
    assign i_sda = SDA;

    cam_top 
    #(.T_CFG_CLK(8))
    cam_i (
    .i_cfg_clk          (i_sysclk        ),
    .i_rstn             (sync_rst_processing),
    .o_sof              (sof             ),
    
    // OV7670 external inputs    
    .i_cam_pclk         (i_cam_pclk      ),
    .i_cam_vsync        (i_cam_vsync     ),
    .i_cam_href         (i_cam_href      ),
    .i_cam_data         (i_cam_data      ),

    // i2c bidirectional pins
    .i_scl              (i_scl           ),
    .i_sda              (i_sda           ),
    .o_scl              (o_scl           ),
    .o_sda              (o_sda           ),

    // Controls
    .i_cfg_init         (cam_start       ),
    .o_cfg_done         (cfg_done        ),

    // output buffer read interface
    .i_obuf_rclk        (i_sysclk        ),
    .i_obuf_rstn        (sync_rst_processing),
    .i_obuf_rd          (cam_obuf_rd     ),
    .o_obuf_data        (cam_obuf_rdata  ),
    .o_obuf_empty       (),  
    .o_obuf_almostempty (cam_obuf_almostempty ),  
    .o_obuf_fill        ()

    );

//output buffer read interface
/*
.o_almostempty(cam_almosempty),
.i_rd(cam_rd),
.o_data(cam_data)
*/

/*                 Grayscaler                 */
grayscale_top U0_grayscale_top (
.CLK            (i_sysclk),
.RST            (sync_rst_processing),
.i_flush        (pipe_flush||freeze),
.i_mode         (sys_mode),

.o_rd           (cam_obuf_rd),
.i_data         (cam_obuf_rdata),
.i_almostempty  (cam_obuf_almostempty),

.i_rd           (gs_rd),
.o_data         (gs_data),
.o_almostempty  (gs_almostempty),
.o_fill         (gs_fill) 
);

/*                 Gaussian                 */
gaussian_top U0_gaussian_top (
.CLK              (i_sysclk),    ////////////////////////////////////////////////////////////////////////// 125 MHz board clock
.RST             (sync_rst_processing),
.i_enable           (gaussian_enable),
.i_flush            (pipe_flush||freeze),
          
.i_data             (gs_data),
.i_almostempty      (gs_almostempty),
.o_rd               (gs_rd),

.i_obuf_rd          (gssn_rd),
.o_obuf_data        (gssn_data),
.o_obuf_fill        (),
.o_obuf_full        (),
.o_obuf_almostfull  (),
.o_obuf_empty       (),
.o_obuf_almostempty (gssn_almostempty)
);

/*                 Sobel                 */
sobel_top U0_sobel_top (
.CLK                (i_sysclk),
.RST                (sync_rst_processing),
.i_enable           (sobel_enable),
.i_flush            (pipe_flush||freeze),
.i_threshold        (sobel_threshold),

.o_rd               (gssn_rd),
.i_data             (gssn_data),
.i_almostempty      (gssn_almostempty),

.i_obuf_rd          (sobel_rd),
.o_obuf_almostempty (sobel_almostempty),
.o_obuf_data        (sobel_data),
.o_obuf_fill        (),
.o_obuf_full        (),
.o_obuf_almostfull  (),
.o_obuf_empty       ()
);

/*                 Memorey Interface                 */

mem_interface #(.DATA_WIDTH (12), .BRAM_DEPTH (307200))
U0_mem_interface(
.CLK           (i_sysclk),
.RST           (sync_rst_processing),
.i_flush       (pipe_flush||freeze),

.o_rd          (sobel_rd),
.i_rdata       (sobel_data),
.i_almostempty (sobel_almostempty),

.i_rclk        (clk_25MHz),
.i_raddr       (frame_raddr),
.o_rdata       (frame_rdata)
);

/*                 Diaplay Interface                 */

display_interface U0_display(
.i_p_clk        (clk_25MHz      ),            // 25 MHz display clock
.i_rstn        (rst_db /*sync_rst_25MHZ*/        ), 
.i_mode        (sys_mode        ), // mode; color or greyscale
    
// frame buffer read interface
.o_raddr        (frame_raddr  ),
.i_rdata        (frame_rdata  ),

// VGA OUTPUTS   
.vga_out_r      (o_vga_r ), 
.vga_out_g      (o_vga_g ), 
.vga_out_b      (o_vga_b ), 
.vga_out_vs     (o_vga_vs), 
.vga_out_hs     (o_vga_hs)  
);
endmodule