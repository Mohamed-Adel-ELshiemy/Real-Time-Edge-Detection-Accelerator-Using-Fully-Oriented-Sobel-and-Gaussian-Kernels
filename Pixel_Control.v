module Pixel_Control #(parameter DATA_WIDTH = 8, 
LINE_LENGTH = 640, 
LINE_NUM = 480)
(
input     wire                          CLK,
input     wire                          RST,
input     wire  [DATA_WIDTH-1:0]        i_data,
input     wire                          i_valid,
output    reg                           o_req,
output    reg   [9*DATA_WIDTH-1:0]      o_data,
output    reg                           o_valid
);

reg                            req_reg, o_valid_reg;
//Write Logic
reg  [$clog2(LINE_LENGTH):0]   pixelCounter;        //count pixel written in one buffer
reg  [1:0]                     currentWrLineBuffer;//which buffer is being written in

//Read Logic
//count pixel read from one buffer
reg  [$clog2(LINE_LENGTH):0]   rdCounter, rdCounter_reg;

//count Number of lines buffers
reg  [$clog2(LINE_NUM):0]      lineCounter, lineCounter_reg;

//total fill of all levels
reg  [$clog2(3*LINE_LENGTH):0] totalPixelCounter;

//line buffer read enable
reg                            rd_line_buffer, rd_line_buffer_reg;
reg  [1:0]                     currentRdLineBuffer, currentRdLineBuffer_reg;

//Line Buffer signals
reg  [3:0]                     lineBufferDataValid; //line buffer write enables
reg  [3:0]                     lineBufferRdData;    //line buffer read enables
wire [23:0]                    lb0data;
wire [23:0]                    lb1data;
wire [23:0]                    lb2data;
wire [23:0]                    lb3data;
reg  [23:0]                    lb0dataReg;
reg  [23:0]                    lb1dataReg;
reg  [23:0]                    lb2dataReg;
reg  [23:0]                    lb3dataReg;


reg [1:0] cs, ns;

localparam [1:0] IDLE     = 2'b00,
				 LATENCY  = 2'b01,
                 RdBuffer = 2'b11;
 

//keeps track of total number of pixels in the 3 line buffers
always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    totalPixelCounter <= 0;
  end
  else begin
     // write and not reading
    if (i_valid && !rd_line_buffer) begin
      totalPixelCounter <= totalPixelCounter + 1;
    end
    // read and not writing
    else if (!i_valid && rd_line_buffer) begin
      totalPixelCounter <= totalPixelCounter - 1;
    end
    else begin
      totalPixelCounter <= totalPixelCounter;
     end
   end
 end
 
 //read from line buffers only when 3 are full to perform the sobel opreator
always @ (*) begin
	o_valid_reg       	 	= rd_line_buffer;
	rd_line_buffer_reg 		= 0;
	req_reg            		= o_req;
	rdCounter_reg      		= rdCounter;
	lineCounter_reg    		= lineCounter;
	currentRdLineBuffer_reg = currentRdLineBuffer;
	ns						= cs; 
     case (cs)
	 
	   //Start reading from the line buffers only when there are 3 lines of pixel data already written
       IDLE : begin
			  rdCounter_reg = 0;
              if (totalPixelCounter == 3*LINE_LENGTH) begin
                rd_line_buffer_reg = 1'b1;
                req_reg            = 1'b0;
                ns                 = LATENCY;
               end
               else begin
                 rd_line_buffer_reg = 1'b0;
				 req_reg            = 1'b1;
				 ns                 = IDLE;
               end
              end
		
		//2 cycle read latency
	 LATENCY : begin
				rd_line_buffer_reg = 1;
				ns                 = RdBuffer;
				    end
				
		//when a line of data has been read, select the next line buffer to read from
		//and request data
     RdBuffer : begin
				rdCounter_reg = rdCounter + 1;
                 if (rdCounter == LINE_LENGTH-2) begin              
                   rd_line_buffer_reg      = 1'b0;
                   req_reg                 = 1'b1;
				   lineCounter_reg         = (lineCounter == LINE_NUM-1) ? 0 : lineCounter + 1;
				   currentRdLineBuffer_reg = (currentRdLineBuffer == 3) ? 0 : currentRdLineBuffer + 1;
				   ns                      = IDLE;
                  end
                  else begin
				    rd_line_buffer_reg = 1'b1;
                    req_reg            = 1'b0;
                    ns                 = RdBuffer;
                  end
                end
        endcase
end

//we register the data
always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
	  o_valid				<= 0;
	  o_req					<= 0;
	  rd_line_buffer		<= 0;
	  rdCounter				<= 0;
	  lineCounter			<= 0;
	  currentRdLineBuffer	<= 0;
	  cs					<= IDLE;
	  end
	else begin 
	  o_valid				<= o_valid_reg;
      o_req					<= req_reg;
	  rd_line_buffer		<= rd_line_buffer_reg;
	  rdCounter				<= rdCounter_reg;
	  lineCounter			<= lineCounter_reg;
	  currentRdLineBuffer	<= currentRdLineBuffer_reg;
	  cs					<= ns;
	end
end
	  
   


//count line buffer write
always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    pixelCounter <= 'b0;
   end
  else begin
    if (i_valid) begin
    //pixelCounter <= pixelCounter + 1;
    pixelCounter <= ( pixelCounter == LINE_LENGTH-1)?0:pixelCounter+1; 
    end
  end
end

// after writing a full line buffer, start writing in the following line buffer
always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    currentWrLineBuffer <= 0;
  end
  else begin
    if (pixelCounter == LINE_LENGTH-1 && i_valid) begin
      if (currentWrLineBuffer == 3) begin
        currentWrLineBuffer <= 0;
      end
      else begin
        currentWrLineBuffer <= currentWrLineBuffer + 1;
      end
    end
  end
end
    
always @(*) begin
 lineBufferDataValid = 4'h0;
 lineBufferDataValid[currentWrLineBuffer] = i_valid;
end  

//assign data to outputs based on what current line is
always @(*) begin
    lineBufferRdData	= {4{rd_line_buffer}};
	o_data				= 0;
	
  if (lineCounter == 0) begin
	lineBufferRdData[2]	= 0;
	lineBufferRdData[3]	= 0;
	o_data				= {lb0dataReg, lb0dataReg, lb1dataReg};
	end

 else begin
  case (currentRdLineBuffer) 
    0 : begin
		lineBufferRdData[2] = 0;
        o_data = {lb3dataReg,lb0dataReg,lb1dataReg};
        end
    1 : begin
		lineBufferRdData[3] = 0;
        o_data = {lb0dataReg,lb1dataReg,lb2dataReg};
        end
    2 : begin
		lineBufferRdData[0] = 0;
        o_data = {lb1dataReg,lb2dataReg,lb3dataReg};
        end
    3 : begin
		lineBufferRdData[1] = 0;
        o_data = {lb2dataReg,lb3dataReg,lb0dataReg};
        end
    endcase
end
end

//assign different data to outputs based on what current column is
always@(*) begin
    case(rdCounter)
        default: begin
           lb0dataReg = lb0data;
           lb1dataReg = lb1data;
           lb2dataReg = lb2data;
           lb3dataReg = lb3data;
        end

        //catch the beginning of each row
		//we repeat the data [8:15] twice to detect an edge at he corner of the frame
        0: begin
		   lb0dataReg = { {2{lb0data[DATA_WIDTH+:DATA_WIDTH]}}, lb0data[0+:DATA_WIDTH]}; //[DATA_WIDTH+:DATA_WIDTH] = [8:15], [0+:DATA_WIDTH] = [0:7] 
	       lb1dataReg = { {2{lb1data[DATA_WIDTH+:DATA_WIDTH]}}, lb1data[0+:DATA_WIDTH]};
           lb2dataReg = { {2{lb2data[DATA_WIDTH+:DATA_WIDTH]}}, lb2data[0+:DATA_WIDTH]};
		   lb3dataReg = { {2{lb3data[DATA_WIDTH+:DATA_WIDTH]}}, lb3data[0+:DATA_WIDTH]};
            end
           
		   //catch end of each row
    (LINE_LENGTH-1): begin
		   lb0dataReg = { lb0data[(2*DATA_WIDTH)+:DATA_WIDTH], {2{lb0data[DATA_WIDTH+:DATA_WIDTH]}} }; //(2*DATA_WIDTH)+:DATA_WIDTH] = [16:23], [DATA_WIDTH+:DATA_WIDTH] = [8:15]
		   lb1dataReg = { lb1data[(2*DATA_WIDTH)+:DATA_WIDTH], {2{lb1data[DATA_WIDTH+:DATA_WIDTH]}} }; 
           lb2dataReg = { lb2data[(2*DATA_WIDTH)+:DATA_WIDTH], {2{lb2data[DATA_WIDTH+:DATA_WIDTH]}} };
           lb3dataReg = { lb3data[(2*DATA_WIDTH)+:DATA_WIDTH], {2{lb3data[DATA_WIDTH+:DATA_WIDTH]}} };
            end
        endcase
    end




line_buffer U0_lb0 (
.CLK(CLK),
.RST(RST),
.i_data(i_data),
.i_wren(lineBufferDataValid[0]),
.o_data(lb0data),
.i_rden(lineBufferRdData[0])
);

line_buffer U0_lb1 (
.CLK(CLK),
.RST(RST),
.i_data(i_data),
.i_wren(lineBufferDataValid[1]),
.o_data(lb1data),
.i_rden(lineBufferRdData[1])
); 

line_buffer U0_lb2 (
.CLK(CLK),
.RST(RST),
.i_data(i_data),
.i_wren(lineBufferDataValid[2]),
.o_data(lb2data),
.i_rden(lineBufferRdData[2])
); 

line_buffer U0_lb3 (
.CLK(CLK),
.RST(RST),
.i_data(i_data),
.i_wren(lineBufferDataValid[3]),
.o_data(lb3data),
.i_rden(lineBufferRdData[3])
); 


/*always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    rdCounter <= 0;
   end
  else begin
   if (rd_line_buffer) begin
     rdCounter <= ( rdCounter == LINE_LENGTH-1)?0:rdCounter+1;
   end
   end
end

always @ (posedge CLK or negedge RST) begin
  if (!RST) begin
    currentRdLineBuffer <= 0;
  end
  else if (rdCounter == LINE_LENGTH-1 && rd_line_buffer) begin
      if (currentRdLineBuffer == 3) begin
        currentRdLineBuffer <= 0;
      end
      else begin
        currentRdLineBuffer <= currentRdLineBuffer + 1;
      end
    end
  else begin
    currentRdLineBuffer <= currentRdLineBuffer;
  end
end 
*/

/*always @ (*) begin	
  case (currentRdLineBuffer)
    0 : begin
        lineBufferRdData[0] = rd_line_buffer;
        lineBufferRdData[1] = rd_line_buffer;
        lineBufferRdData[2] = rd_line_buffer;
        lineBufferRdData[3] = 1'b0;
        end
    1 : begin
        lineBufferRdData[0] = 1'b0;
        lineBufferRdData[1] = rd_line_buffer;
        lineBufferRdData[2] = rd_line_buffer;
        lineBufferRdData[3] = rd_line_buffer;
        end
    2 : begin
        lineBufferRdData[0] = rd_line_buffer;
        lineBufferRdData[1] = 1'b0;
        lineBufferRdData[2] = rd_line_buffer;
        lineBufferRdData[3] = rd_line_buffer;
        end  
    3 : begin
        lineBufferRdData[0] = rd_line_buffer;
        lineBufferRdData[1] = rd_line_buffer;
        lineBufferRdData[2] = 1'b0;
        lineBufferRdData[3] = rd_line_buffer;
        end        
    endcase
end

*/

endmodule