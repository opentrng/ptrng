//Bloc responsable for online tests, which basically consists in calculating the moving cummulative sum of RRNs and comparing this cumsum to the average value +/- the drift.

module onlinetest#(
  parameter REG_WIDTH = 32,                     //Width for the configuration registers
  parameter RAND_WIDTH = 32,                    //Width for the RRN input
  parameter DEPTH = 128                          //Deepth for the cumulative sum
)(
  input clk,                                    //Base clock
  input reset,                                  //Asynchronous reset active to '1'
  input clear,                                  //Synchronous clear active to '1'
  input [RAND_WIDTH - 1:0] raw_random_number,   //Raw Random Number input data (RRN)
  input raw_random_valid,                       //RRN data input validation
  input [REG_WIDTH/2 - 1:0] average,            //Average accepted value
  input [REG_WIDTH/2 - 1:0] deviation,          //Maximum deviation between accepted value and calculated value
  
  output reg valid                              //Set to '1' when the total failure event is detected
);

//RTL implementation of the online test

parameter MARGIN = 8;


wire [RAND_WIDTH - 1:0] fifo_in;
wire [RAND_WIDTH - 1:0] fifo_out;
wire fifo_write_en;
wire fifo_read_en;
wire fifo_almost_empty;
wire fifo_almost_full;

reg [REG_WIDTH + RAND_WIDTH - 1:0] cumsum_value;
reg cumsum_valid;

//Build the cumsum of all last RRNs
always @(posedge clk or posedge reset) begin
  if (reset) begin
    cumsum_value <= {REG_WIDTH + RAND_WIDTH{1'b0}}; //FACTOR_WIDTH
    cumsum_valid <= 1'b0;
  end else begin
    if (clear) begin
      cumsum_value <= {REG_WIDTH + RAND_WIDTH{1'b0}};
      cumsum_valid <= 1'b0; 
    end else begin
      if (raw_random_valid) begin
        if (fifo_read_en) begin
          cumsum_value <= (cumsum_value + fifo_in) - fifo_out;
          cumsum_valid <= 1'b1;
        end else begin
          cumsum_value <= cumsum_value + fifo_in;
        end
      end
    end
  end
end

//Write each incoming RRN into RRN to be substracted from accumulator

assign fifo_write_en = raw_random_valid;
assign fifo_in = raw_random_number;
assign fifo_read_en = (fifo_almost_full == 1'b1) ? raw_random_valid : 1'b0;

//Averaging FIFO
fifo #(
  .SIZE(DEPTH + MARGIN),
  .ALMOST_EMPTY_SIZE(MARGIN),
  .ALMOST_FULL_SIZE(DEPTH),
  .DATA_WIDTH(RAND_WIDTH)
)averaging_fifo(
  .clk(clk),
  .reset(reset),
  .clear(clear),
  .data_in(fifo_in),
  .wr(fifo_write_en),
  .data_out(fifo_out),
  .rd(fifo_read_en),
  .almost_empty(fifo_almost_empty),
  .almost_full(fifo_almost_full)
);

wire [REG_WIDTH/2 - 1:0] average_min = average - deviation;
wire [REG_WIDTH/2 - 1:0] average_max = average + deviation;
//Compare the cumsum to threshold for validation
always @(posedge clk or posedge reset) begin
  if(reset) begin
    valid <= 1'b1;
  end else begin
    if(clear) begin
      valid <= 1'b1;
    end else begin
      if(cumsum_valid) begin
        if((cumsum_value < average_min) || (cumsum_value > average_max)) begin
          valid <= 1'b0;      
        end
      end
    end 
  end
end


endmodule
