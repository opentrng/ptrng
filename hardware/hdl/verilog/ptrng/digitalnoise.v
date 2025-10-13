//The digital noise block generates the raw random numbers (RRN). This block contains the ring-oscillators, their sampling architecture and the clock domain crossing to the system clock in order the RRN to be used in the upper design.

//RTL implementation of digital noise
`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/settings.v"

module digitalnoise #(
  parameter REG_WIDTH = 32,
  parameter RAND_WIDTH = 32
)(
  input clk,                                 //Base clock
  input reset,                               //Asynchronous reset active to '1'
  input clear,                               //Synchronous clear active to '1'
  input [REG_WIDTH - 1:0] ring_en,           //Ring-oscillator enable signal (bit index i enables ROi)
  input freqcount_en,                        //Enable the all the frequency counters
  input [4:0] freqcount_select,              //Select the RO number for frequency measurement
  input freqcount_start,                     //Pulse '1' to start the frequency measure (for the selected ROs)
  input [REG_WIDTH - 1:0] freqdivider_value, //Sampling clock divider value (applies on RO0 for ERO and MURO)
  input freqdivider_en,                      //Enable strobing when frequency divider changes

  output freqcount_done,                     //Flag set to '1' when the result is ready (for the selected ROs)
  output freqcount_overflow,                 //Flag set to '1' if an overflow occured (for the selected ROs)
  output [REG_WIDTH - 1:0] freqcount_value,  //Sampling clock divider value (applies on RO0 for ERO and MURO)
  output [REG_WIDTH - 1:0] data,             //Raw Random Number output data (RRN)
  output valid                               //RRN data output valid
);

//Ring oscillators
wire [T:0] osc;
wire [T:0] mon;
reg  [T:0] mon_en;
wire selected_mon;

//Digitizer
wire clk_digit;
wire [RAND_WIDTH-1:0] digit_data;
wire digit_valid;

//CDC
wire cdc_fifo_empty;
wire cdc_fifo_read;
wire [RAND_WIDTH-1:0] cdc_fifo_data;


//Instantiate ring-oscillators from 0 to T with their respective frequency monitor enable
genvar i;
generate
  for (i=0; i<=T; i=i+1) begin
    //Each RO of the bank (or system clock bypass for tests)
    ring #(
      .N(RO_LEN[i*32+:32])
    ) i_ring(
      .enable(ring_en[i]),
      .osc(osc[i]),
      .mon_en(mon_en[i]),
      .mon(mon[i])
    );
    //Enable for the RO monitoring output
    always @(posedge clk or posedge reset) begin
      if(reset) begin
        mon_en[i] <= 1'b0;
      end else begin
        if (freqcount_select == i) begin
          mon_en[i] <= freqcount_en;
        end else begin
          mon_en[i] <= 1'b0;
        end
      end
    end
  end
endgenerate


//One frequency counter for all ROs
freqcounter #(
  .REG_WIDTH(REG_WIDTH),
  .N(10_000_000)
) i_freqcounter(
  .clk(clk),
  .reset(reset),
  .clear(clear),
  .source(selected_mon),
  .enable(freqcount_en),
  .start(freqcount_start),
  .done(freqcount_done),
  .overflow(freqcount_overflow),
  .result(freqcount_value)
);

assign selected_mon = mon[{{(32-5){1'b0}}, freqcount_select}];

//Digitizer
digitizer #(
  .REG_WIDTH(REG_WIDTH),
  .RAND_WIDTH(RAND_WIDTH)
) i_digitizer(
  .reset(reset),
  .clear(clear),
  .osc(osc),
  .freqdivider_value(freqdivider_value),
  .freqdivider_en(freqdivider_en),
  .digit_clk(clk_digit),
  .digit_data(digit_data),
  .digit_valid(digit_valid)
);

//Clock domain crossing from osc(0) to system clock (clk)
synchronizer #(
  .DATA_WIDTH(RAND_WIDTH)
)i_synchronizer(
  .reset(reset),
  .clk_from(clk_digit),
  .data_in(digit_data),
  .data_in_en(digit_valid),
  .clk_to(clk),
  .clear(clear),
  .data_out(data),
  .data_out_en(valid)
);

endmodule
