//This entity defines the Coherent Sampling Ring Oscillator entropy source, where the first ring oscillator RO0 is used to sample R01, resulting in the generation of a beat signal. A counter, incremented by RO0, measures the period of the beat signal. The COSO's random output bit is derived from the counter least significant bit (LSB). Additionally, the raw counter value is accessible on output port. Both of thses signals are synchronized with the output clock 'clk'.

module coso #(
  parameter DATA_WIDTH = 16 //32
)(
  input ro0,                            //Sampling ring-oscillator input
  input ro1,                            //Sampled ring-oscillator input

  output clk,                           //Clock output (aka the beat signal)
  output lsb,                           //Bit data output (LSB of the counter)
  output [DATA_WIDTH - 1:0] data,       //Raw value of the counter
  output valid                          //Valid signal for 'data' and 'lsb'
);

//This architecture implements the RTL version of COSO measuring full period of beat signal with counter reset on beat signal rising edges.

reg beat_d0;
reg beat_d1;
parameter [DATA_WIDTH-1:0] MAX = {DATA_WIDTH{1'b1}}; 
reg [DATA_WIDTH-1:0] counter;
reg [DATA_WIDTH-1:0] value;

//Sample RO1 with RO0 to create the beat signal
always @(posedge ro0) begin
  beat_d0 <= ro1;
  beat_d1 <= beat_d0;  
end

//Count the full period of the beat in steps of RO0
always @(posedge ro0) begin
  if (beat_d0 == 1'b1 && beat_d1 == 1'b0) begin
    counter <= {DATA_WIDTH{1'b0}};
  end else if (counter < MAX) begin
    counter <= counter + 1'b1;
  end
end

//Resample the value of the counter
always @(posedge ro0) begin
  if(beat_d0 == 1'b1 && beat_d1 == 1'b0) begin
    value <= counter;
  end  
end

//Output LSB and raw signals synchronized to the beat
assign clk   = beat_d0;
assign lsb   = value[0];
assign data  = value;
assign valid = 1'b1;
  
endmodule
