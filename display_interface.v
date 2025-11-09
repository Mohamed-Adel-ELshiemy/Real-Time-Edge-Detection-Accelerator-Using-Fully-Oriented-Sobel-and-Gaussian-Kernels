module display_interface 
     (
         input  wire        i_p_clk	  ,
         input  wire        i_rstn    ,
         input  wire        i_mode    ,
         // frame buffer interface
	     input  wire [11:0] i_rdata   ,
         output reg  [18:0] o_raddr   ,
		 // vga out
	     output reg  [3:0] vga_out_r  , 
	     output reg  [3:0] vga_out_g  , 
	     output reg  [3:0] vga_out_b  , 
	     output wire       vga_out_vs , 
	     output wire       vga_out_hs   
    );
// =============================================================
//              Parameters, Registers, and Wires
// =============================================================
reg  [18:0] nxt_raddr;

wire        vsync, hsync, active;

wire [9:0]  counterX, counterY;


reg  [1:0]  STATE, NEXT_STATE;

localparam  STATE_INITIAL = 0,
            STATE_DELAY   = 1,
            STATE_IDLE    = 3,
            STATE_ACTIVE  = 2;
// =============================================================
//                    Implementation:
// =============================================================
initial 
     begin
         STATE = STATE_INITIAL;
     end
// assign rgb based on mode; rgb or greyscale
always@* 
     begin
        if(i_mode) 
		     begin
								vga_out_r=i_rdata[7:4];                //////////////////////////////////////////
								vga_out_g=i_rdata[7:4];                //////////////////////////////////////////
								vga_out_b=i_rdata[7:4];                //////////////////////////////////////////
             end                                                  //////////////////////////////////////////
        else                                                      //////////////////////////////////////////
		     begin                                                //////////////////////////////////////////
								vga_out_r=i_rdata[11:8];          //////////////////////////////////////////
								vga_out_g=i_rdata[7:4];           //////////////////////////////////////////
								vga_out_b=i_rdata[3:0];           //////////////////////////////////////////
             end
    end
// next state combo logic
always@*
  	 begin
        nxt_raddr  = o_raddr;
        NEXT_STATE = STATE;
        case(STATE)
            // wait 2 frames for camera configuration on reset/startup
            STATE_INITIAL: begin
                NEXT_STATE = ((counterX == 640) && (counterY == 480)) ? STATE_DELAY:STATE_INITIAL;
            end

            STATE_DELAY: begin
                NEXT_STATE = ((counterX == 640) && (counterY == 480)) ? STATE_ACTIVE:STATE_DELAY;
            end

            STATE_IDLE: begin
                if((counterX == 799)&&((counterY==524)||(counterY<480))) begin
                    nxt_raddr  = o_raddr + 1;
                    NEXT_STATE = STATE_ACTIVE;
                end
                else if(counterY > 479) begin
                    nxt_raddr = 0;
                end
            end
            // normal operation: begin reading from frame buffer at start of frame
            STATE_ACTIVE: begin
                if(active && (counterX < 639)) begin
                    nxt_raddr = (o_raddr == 307199) ? 0:o_raddr+1;
                end
                else begin
                    NEXT_STATE = STATE_IDLE;
                end
            end
        endcase
    end
// registered logic
always@(posedge i_p_clk) 
     begin
        if(!i_rstn) 
		     begin
                o_raddr <= 0;
                STATE <= STATE_DELAY;
             end
        else
		     begin
                 o_raddr <= nxt_raddr;
                 STATE   <= NEXT_STATE;
             end
     end


    vtc #(
    .COUNTER_WIDTH(10)
    )
    vtc_i (
    .i_clk         (i_p_clk  ), // pixel clock
    .i_rstn        (i_rstn   ), 

    // timing signals
    .o_vsync       (vga_out_vs),
    .o_hsync       (vga_out_hs),
    .o_active      (active    ),
								
    // counter passthrough      
    .o_counterX    (counterX ),
    .o_counterY    (counterY ) 
    );



endmodule

