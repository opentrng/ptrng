//OpenTRNG's PTRNG base entity

module ptrng #(
  parameter REG_WIDTH = 32,                         //Width for the configuration registers
  parameter RAND_WIDTH = 32                         //Width for the random output
)(
  input clk,                                        //Base clock
  input reset,                                      //Asynchronous reset active to '1'
  input clear,                                      //Synchronous clear active to '1'
  input [REG_WIDTH - 1:0] ring_en,                  //Ring-oscillator enable signal (bit index i enables ROi)
  input freqcount_en,                               //Enable all the frequency counters 
  input [4:0] freqcount_select,                     //Select the RO number for frequency measurement
  input freqcount_start,                            //Pulse '1' to start the frequency measure (for the selected ROs)
  input [REG_WIDTH - 1:0] freqdivider_value,        //Sampling clock divider value (applies on RO0 for ERO and MURO)
  input freqdivider_en,                             //Enable strobing when frequency divider changes
  input [REG_WIDTH - 1:0] alarm_threshold,          //Threshold for triggering the total failure alarm
  input onlinetest_clear,                           //Clear-to-set the online test
  input [REG_WIDTH/2 - 1:0] onlinetest_average,     //Expected average value for online test
  input [REG_WIDTH/2 - 1:0] onlinetest_deviation,   //Maximum deviation to expected value for online test to be valid
  input conditioning,                                //Enable the raw signal conditionner
  input nopacking,                                  //When 'nopacking' is pulled to '1', IRN as written as entire words in FIFO instead of packing only LSB bits

  output freqcount_done,                            //Flag set to '1' when the result is ready (for the selected ROs)
  output freqcount_overflow,                        //Flag set to '1' if an overflow ocurred (for the selected ROs)
  output [REG_WIDTH - 1:0] freqcount_value,         //Frequency estimation output(for the selected ROs)
  output alarm_detected,                            //Total failure alarm, risen to '1' when total failure event is detected
  output onlinetest_valid,                          //Set to '1' when the online test is valid (need to be cleared)   
  output reg [RAND_WIDTH - 1:0] data,               //Random data output
  output reg valid                                  //Random data output valid
);

//RTL description of OpenTRNG's PTRNG

`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/settings.v"
//RRN from entropy source
wire [RAND_WIDTH - 1:0] raw_random_number;
wire raw_random_valid;

//IRN from entropy source
wire [RAND_WIDTH - 1:0] conditioned_number;
wire conditioned_valid;
reg [RAND_WIDTH - 1:0] intermediate_random_number;
reg intermediate_random_valid;


//Packed data bits
wire [RAND_WIDTH - 1:0] packed_data;
wire packed_valid;

//Digital noise source (no signal syncrhonized to rings outside of this block)
digitalnoise #(
  .REG_WIDTH(REG_WIDTH),
  .RAND_WIDTH(RAND_WIDTH)
) i_digitalnoise(
  .clk(clk),
  .reset(reset),
  .clear(clear),
  .ring_en(ring_en),
  .freqcount_en(freqcount_en),
  .freqcount_select(freqcount_select),
  .freqcount_start(freqcount_start),
  .freqcount_done(freqcount_done),
  .freqcount_overflow(freqcount_overflow),
  .freqcount_value(freqcount_value),
  .freqdivider_value(freqdivider_value),
  .freqdivider_en(freqdivider_en),
  .data(raw_random_number),
  .valid(raw_random_valid)
);

//Total failure alarm
alarm #(
  .REG_WIDTH(REG_WIDTH),
  .RAND_WIDTH(RAND_WIDTH)
) alarm(
  .clk(clk),
  .reset(reset),
  .clear(clear),
  .digitizer(DIGITIZER_GEN),
  .raw_random_number(raw_random_number),
  .raw_random_valid(raw_random_valid),
  .threshold(alarm_threshold),
  .detected(alarm_detected)
);


//Online test
onlinetest #(
  .REG_WIDTH(REG_WIDTH),
  .RAND_WIDTH(RAND_WIDTH),
  .DEPTH(64)
) onlinetest(
  .clk(clk),
  .reset(reset),
  .clear(clear || onlinetest_clear),
  .raw_random_number(raw_random_number),
  .raw_random_valid(raw_random_valid),
  .average(onlinetest_average),
  .deviation(onlinetest_deviation),
  .valid(onlinetest_valid)
);


//Conditioning refers to algorithmic post-processing
conditioner #(
  .RAND_WIDTH(RAND_WIDTH)
) conditioner (
  .clk(clk),
  .reset(reset),
  .clear(clear),
  .enable(conditioning),
  .raw_random_number(raw_random_number),
  .raw_random_valid(raw_random_valid),
  .conditioned_number(conditioned_number),
  .conditioned_valid(conditioned_valid)
);

//Data to bypass the conditioner if disabled
always @(posedge clk) begin
  if (conditioning) begin
    intermediate_random_number <= conditioned_number;
  end else begin
    intermediate_random_number <= raw_random_number;
  end
end


//Valid signal to bypass the conditioner if disabled
always @(posedge clk or posedge reset) begin
  if (reset) begin
    intermediate_random_valid <= 1'b0;
  end else begin
    if (clear) begin
      intermediate_random_valid <= 1'b0;
    end else begin
      if (conditioning) begin
        intermediate_random_valid <= conditioned_valid;
      end else begin
        intermediate_random_valid <= raw_random_valid;
      end
    end
  end
end

//LSB packing into words
bitpacker #(
  .W(REG_WIDTH)
) bitpacker(
  .clk(clk),
  .reset(reset),
  .clear(clear || nopacking),
  .data_in(intermediate_random_number[0]),
  .valid_in(intermediate_random_valid),
  .data_out(packed_data),
  .valid_out(packed_valid)
);

//Data output selection
always @(posedge clk) begin
  if (nopacking) begin
    data <= intermediate_random_number;
  end else begin
    data <= packed_data;
  end  
end


//Valid output selection
always @(posedge clk or posedge reset) begin
  if(reset) begin
    valid <= 1'b0;
  end else begin
    if (clear) begin
      valid <= 1'b0;
    end else begin
      if (nopacking) begin
        valid <= intermediate_random_valid;
      end else begin
        valid <= packed_valid;
      end
    end
  end
end


  
endmodule
