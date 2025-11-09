/*
 *  Filters glitchy inputs by ignoring state changes
 *  that occur within less than DELAY clock ticks 
 *
 *  Registers state change, debounced output, after 
 *  DELAY number of clock ticks of an unchanged input
 *  
 *  NOTE:
 *  DELAY = (Debounce Time [s]) * (i_clk [Hz])
 *  100MHZ
 *  applies 20 ms debounce to input
 */
 

module debounce 
(
input  wire i_clk,
input  wire i_input,
output reg  o_debounce
);

// debounce period in clock periods
parameter D_count = 2_000_000; //delay = 20ms * 100MHZ

reg [21:0] counter;
reg in_1, in_2;

initial begin
  in_1       = 0;
  in_2       = 0;
  counter    = 0;
  o_debounce = 0;
end

always @(posedge i_clk) begin
  in_1  <= i_input;
  in_2  <= in_1;
end

always @(posedge i_clk) begin
  if (in_2 != o_debounce && counter < D_count) begin
    counter <= counter + 1;
  end
  else if (counter == D_count) begin
    o_debounce <= in_2;
    counter    <= 0;
  end
  else begin
    counter <= 0;
  end
end

endmodule
   