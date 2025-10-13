//The digitizer takes the ring-oscillator signals as input and instanciate the sampling architecture specidied in 'setting.vhd'. It outputs the sampling clock and the sampled data.

`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/constants.v"
`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/settings.v"

module digitizer #(
  parameter REG_WIDTH = 32,                    //Width for the configuration registers
  parameter RAND_WIDTH = 32
)(
  input reset,                                 //Asynchronous reset
  input clear,                                 //Synchronous  clear
  input [T:0] osc,                             //Ring-oscillator inputs
  input [REG_WIDTH - 1:0] freqdivider_value,   //Sampling clock divider value (applies on RO0 for ERO and MURO)
  input freqdivider_en,                        //Enable strobing when frequency divider changes

  output digit_clk,                            //Sampling clock(osc(0))
  output [RAND_WIDTH - 1:0] digit_data,        //Sampled data
  output digit_valid                           //Valid signal for 'digit-data'
);

//RTL implementation of the digitizer

//TEST digitizer is a 32bit counter clocked at osc(0)/freqdivider
generate
if(DIGITIZER_GEN == TEST) begin
  reg [RAND_WIDTH - 1:0] counter;
  wire reset_or_clear = reset || clear;
  clkdivider #(
    .FACTOR_WIDTH(32)
  ) i_clkdivider (
    .reset(reset),
    .original(osc[0]),
    .divider(freqdivider_value),
    .changed(freqdivider_en),
    .divided(digit_clk)
  );

  always @(posedge digit_clk or posedge reset_or_clear) begin
    if (reset_or_clear) begin
      counter <= {RAND_WIDTH{1'b0}};
    end else begin
      counter <= counter + 1;
    end
  end

  assign digit_data = counter;
  assign digit_valid = 1'b1;
end else if(DIGITIZER_GEN == ERO) begin      //Instantiate the ERO
  ero #(
    .REG_WIDTH(REG_WIDTH)
  ) i_ero (
    .reset(reset),
    .ro0(osc[0]),
    .ro1(osc[1]),
    .divider(freqdivider_value),
    .changed(freqdivider_en),
    .clk(digit_clk),
    .data(digit_data[0]),
    .valid(digit_valid)
  );

  assign digit_data[31:1] = {RAND_WIDTH-1{1'b0}};

end else if(DIGITIZER_GEN == MURO) begin     //Instantiate the MURO
  muro #(
    .REG_WIDTH(REG_WIDTH),
    .t(T)
  ) i_muro(
    .reset(reset),
    .ro0(osc[0]),
    .rox(osc[T:1]),
    .divider(freqdivider_value),
    .changed(freqdivider_en),
    .clk(digit_clk),
    .data(digit_data[0]),
    .valid(digit_valid)
  );
  
  assign digit_data[31:1] = {RAND_WIDTH-1{1'b0}};
  
end else if(DIGITIZER_GEN == COSO) begin     //Instantiate the COSO
  coso #(
    .DATA_WIDTH(16)
  ) i_coso(
    .ro0(osc[0]),
    .ro1(osc[1]),
    .clk(digit_clk),
    .data(digit_data[15:0]),
    .valid(digit_valid)
  );
  assign digit_data[RAND_WIDTH-1:16] = {RAND_WIDTH-16{1'b0}};
end else begin                              //Stub for inactive digitizer
  assign digit_clk = 1'b0;
  assign digit_data = {RAND_WIDTH{1'b0}};
  assign digit_valid = 1'b0;
end

endgenerate
  
endmodule
