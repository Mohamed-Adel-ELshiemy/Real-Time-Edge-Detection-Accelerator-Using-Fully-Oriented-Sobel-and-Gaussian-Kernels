module vtc 
    #(
    // total frame size
    parameter RES_WIDTH     = 800,
    parameter RES_HEIGHT    = 525,
  
    // active area  
    parameter ACTIVE_X      = 640,
    parameter ACTIVE_Y      = 480,

    // hsync pulse width, back porch, front porch
    parameter H_WIDTH   = 96,
    parameter H_BP      = 48,
    parameter H_FP      = 16,

    // vsync pulse width, back porch, front porch
    parameter V_WIDTH   = 2,
    parameter V_BP      = 33,
    parameter V_FP      = 10,

    parameter COUNTER_WIDTH = 10
    )
    (
    input wire i_clk,  
    input wire i_rstn, 

    // display timing
    output wire o_vsync,
    output wire o_hsync,
    output wire o_active,

    
    output wire [COUNTER_WIDTH-1:0] o_counterX,
    output wire [COUNTER_WIDTH-1:0] o_counterY
    );

    

    // horizontal and vertical counters
    reg [COUNTER_WIDTH-1:0] counterX;
    reg [COUNTER_WIDTH-1:0] counterY;


    initial begin
        counterX = 0;
        counterY = 0;
    end

//
// vsync and hsync counters
//
    always@(posedge i_clk) begin
        if(!i_rstn) begin
            counterX <= 0;
        end
        else begin
            counterX <= (counterX == 799) ? 0 : (counterX + 1);
        end
    end

    always@(posedge i_clk) begin
        if(!i_rstn) begin
            counterY <= 0;
        end
        else begin
            if(counterX == 799) begin
                counterY <= (counterY == 524) ? 0 : (counterY + 1);
            end
        end
    end


    assign o_hsync  = ((counterX >= ACTIVE_X + H_FP) && 
                       (counterX <  ACTIVE_X + H_FP + H_WIDTH)); 
 
    assign o_vsync  = ((counterY >= ACTIVE_Y + V_FP) &&
                      (counterY  <  ACTIVE_Y + V_FP + V_WIDTH));

    assign o_active = ((counterX >= 0) && (counterX < ACTIVE_X) &&
                       (counterY >= 0) && (counterY < ACTIVE_Y));

    assign o_counterX = counterX;
    assign o_counterY = counterY;

endmodule // vtc