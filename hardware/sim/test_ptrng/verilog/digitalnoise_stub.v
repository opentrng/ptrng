module digitalnoise #(
  parameter REG_WIDTH = 32,
  parameter RAND_WIDTH = 32
)(
  input clk,
  input reset,
  input clear,
  input [REG_WIDTH-1:0] ring_en,
  input freqcount_en,
  input [4:0] freqcount_select,
  input freqcount_start,
  input [REG_WIDTH-1:0] freqdivider_value,
  input freqdivider_en,

  output freqcount_done,
  output freqcount_overflow,
  output [REG_WIDTH-1:0] freqcount_value,
  output [RAND_WIDTH-1:0] data,
  output valid
);
endmodule
