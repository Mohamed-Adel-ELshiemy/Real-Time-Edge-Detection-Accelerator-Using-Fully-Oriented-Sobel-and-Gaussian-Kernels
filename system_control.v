`define MODE_PASSTHROUGH 0

module system_control 
(
input   wire         i_sysclk,
input   wire         RST,
input   wire         i_mode,  //button for mode select(board button)
input   wire         sof,
input   wire         i_gaussian,
input   wire         i_sobel, //sobel switch enable on board
input   wire         inc_sobel,
input   wire         dec_sobel, //control vaulue of threshold

output  reg          cam_start,
output  reg          o_mode,
output  reg          pipe_flush,
output  reg          gaussian_enable,
output  reg          sobel_enable,
output  reg [25:0]   sobel_threshold,     
output  reg          threshold_region
);

wire db_mode;
reg  inc_sobel_1, inc_sobel_2;
reg  dec_sobel_1, dec_sobel_2;
wire db_posedge;
wire db_inc_sobel, db_dec_sobel;
wire inc_sobel_posedge, dec_sobel_posedge;


debounce #(.D_count(500_000)) inc_debounce (
.i_clk         (i_sysclk),
.i_input       (inc_sobel),
.o_debounce    (db_inc_sobel)  
);

debounce #(.D_count(500_000)) dec_debounce (
.i_clk         (i_sysclk),
.i_input       (dec_sobel),
.o_debounce    (db_dec_sobel)  
);

debounce #(.D_count(500_000)) mode_debounce (
.i_clk         (i_sysclk),
.i_input       (i_mode),
.o_debounce    (db_mode)  
);

reg STATE;
localparam CAMERA = 0,
           ACTIVE = 1;

always@(posedge i_sysclk or negedge RST) begin
    if(~RST) begin
      cam_start <= 0;
      STATE     <= 0;
     end
    else begin
       case(STATE)
           CAMERA : begin
                    cam_start <= 1; //cam_start is like a single pulse that initiate the capture 
                    STATE     <= 1;
                    end
           ACTIVE : begin
                    cam_start <= 0;
                    STATE     <= 1;
                    end
        endcase
      end
end

//Detecting one button press
//toggle mode upon detecting a change is state
initial o_mode = 0;
reg button1, button2;
always @(posedge i_sysclk or negedge RST) begin
   if (~RST) begin
      button1 <= 0;
      button2 <= 0;
    end
    else begin
      {button1, button2} <= {db_mode, button1};
    end
end
assign db_posedge = (button1 && ~button2); //detect the button press

always @(posedge i_sysclk or negedge RST) begin
   if (~RST) begin
     o_mode <= `MODE_PASSTHROUGH;
   end
   else begin
     if (db_posedge) begin
       o_mode <= ~o_mode; //toggle the mode
     end
   end
 end
 
//gaussian filter enable
always@(posedge i_sysclk) begin
    if(o_mode == `MODE_PASSTHROUGH)
		gaussian_enable <= 0;
    else begin
		gaussian_enable <= (i_gaussian);
	end
end

//sobel enable
always @(posedge i_sysclk) begin
  if (o_mode == `MODE_PASSTHROUGH) begin
    sobel_enable  <= 0;
  end
  else begin
     sobel_enable <= i_sobel;
   end
end

reg gaussian_1, gaussian_2;
wire delta_gaussian;
always@(posedge i_sysclk) begin
	if(!RST) begin
		{gaussian_1, gaussian_2} <= 2'b0;
	end
	else begin
		{gaussian_1, gaussian_2} <= {i_gaussian, gaussian_1};
	end
end

assign delta_gaussian = (gaussian_1 != gaussian_2);

 
reg sobel_1, sobel_2;
wire delta_sobel;
always @(posedge i_sysclk or negedge RST) begin
   if (~RST) begin
     {sobel_1, sobel_2} <= 2'b0;
   end
   else begin 
     {sobel_1, sobel_2} <= {i_sobel, sobel_1};
   end
end
assign delta_sobel = (sobel_1 != sobel_2);
 

//Control for Sobel Threhold
always @(posedge i_sysclk or negedge RST) begin
   if(~RST) begin
     {inc_sobel_1, inc_sobel_2} <= 2'b0;
   end
   else begin
     {inc_sobel_1, inc_sobel_2} <= {db_inc_sobel, inc_sobel_1};
   end
end
assign inc_sobel_posedge = (inc_sobel_1 && ~inc_sobel_2);
 
 
always @(posedge i_sysclk or negedge RST) begin
   if(~RST) begin
     {dec_sobel_1, dec_sobel_2} <= 2'b0;
   end
   else begin
     {dec_sobel_1, dec_sobel_2} <= {db_dec_sobel, dec_sobel_1};
   end
end
assign dec_sobel_posedge = (dec_sobel_1 && ~dec_sobel_2);

//set threshold boundary 
always @(posedge i_sysclk or negedge RST) begin
   if(~RST) begin
     sobel_threshold <= 25;
   end
   else begin
     if (inc_sobel_posedge) begin
       if (sobel_threshold < 100) begin
         sobel_threshold  <= sobel_threshold + 1;
         threshold_region <= 0;
       end
       else begin
          sobel_threshold  <= sobel_threshold;
          threshold_region <= 1;
        end
      end
    else if (dec_sobel_posedge) begin
      if (sobel_threshold > 0) begin
        sobel_threshold  <= sobel_threshold - 1;
        threshold_region <= 0;
       end
       else begin
        sobel_threshold  <= sobel_threshold;
        threshold_region <= 1;
       end
     end
   end
end
            
//if filter is applied we flush (hold flush until the start of new frame)
reg FLUSH_STATE;
localparam IDLE     = 0,
           F_ACTIVE = 1;
always @(posedge i_sysclk or negedge RST) begin
   if(~RST) begin
     pipe_flush  <= 0;
     FLUSH_STATE <= IDLE;
   end
   else begin 
     if (o_mode != `MODE_PASSTHROUGH) begin
       case (FLUSH_STATE)
           IDLE : begin
                  pipe_flush  <= 0;
                  FLUSH_STATE <= (delta_gaussian || delta_sobel)? F_ACTIVE:IDLE;
                  end
         ACTIVE : begin
                  pipe_flush  <= 1;
                  FLUSH_STATE <= (sof)?IDLE:F_ACTIVE;
                  end
                endcase
            end
          else begin
            pipe_flush <= 0;
          end
        end
end

endmodule               