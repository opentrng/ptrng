//Top for testing the PTRNG by writing configuration registers and reading data into a FIFO through an UART.

module top #(
  parameter CLK_REF = 100_000_000, //Frequency(Hz) of the oscillator (clk)
  parameter FIFO_SIZE = 512*64,   //Size of the FIFO to store generated number before read to from UART
  parameter BURST_SIZE = 512      //Size of the data frame sent to the PC through the UART (FIFO size must be at least 2x bigger)
)(
  input clk,                      //Oscillator input
  input hw_reset,                 //Asynchronous hardware reset active to '1'
  input uart_txd,                 //UART signal from PC
  output uart_rxd                 //UART signal to PC
);


//RTL implementation of the FPGA test top

//Constants
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 16;

//UART interface
wire [7:0] tx_data;
wire tx_req;
wire tx_busy;
wire [7:0] rx_data;
wire rx_data_valid;
wire rx_brk;
wire rx_err;

//Command processor
wire [DATA_WIDTH - 1:0] rd_data;
wire [DATA_WIDTH - 1:0] wr_data;
wire [ADDR_WIDTH - 1:0] address;
wire read_req;
wire write_req;

//Register map
wire ptrng_reset;
wire analog_en;
wire [11:0] analog_temperature;
wire [11:0] analog_voltage;
wire [DATA_WIDTH - 1:0] ring_en;
wire freqcount_en;
wire freqcount_start;
wire freqcount_done;
wire freqcount_overflow;
wire [4:0] freqcount_select;
wire [DATA_WIDTH - 1:0] freqcount_value;
wire [DATA_WIDTH - 1:0] freqdivider_value;
wire freqdivider_en;
wire [DATA_WIDTH - 1:0] alarm_threshold;
wire alarm_detected;
wire onlinetest_clear;
wire onlinetest_valid;
wire [15:0] onlinetest_average;
wire [15:0] onlinetest_deviation;
wire conditioning;
wire nopacking;
wire [15:0] burst_size_16bits = BURST_SIZE;

//PTRNG
wire [DATA_WIDTH - 1:0] ptrng_data;
wire ptrng_valid;


//FIFO
wire fifo_clear;
wire fifo_empty;
wire fifo_full;
wire fifo_almost_empty;
wire fifo_almost_full;
wire fifo_read_en;
wire [DATA_WIDTH - 1:0] fifo_data_read;

//UART
fluart #(
  .CLK_FREQ(CLK_REF),
  .SER_FREQ(115_200),
  .BRK_LEN(10)
) i_fluart(
  .clk(clk),
  .reset(hw_reset),
  .txd(uart_rxd),
  .rxd(uart_txd),
  .tx_data(tx_data),
  .tx_req(tx_req),
  .tx_brk(1'b0),
  .tx_busy(tx_busy),
  .rx_data(rx_data),
  .rx_data_valid(rx_data_valid),
  .rx_brk(rx_brk),
  .rx_err(rx_err)
);

//Command processor 
cmd_proc #(
  .ADDR_SIZE(ADDR_WIDTH),
  .DATA_SIZE(DATA_WIDTH)
) i_cmd_proc(
  .clk(clk),
  .reset(rx_brk || rx_err),    //hw_reset or rx_brk or rx_err
  .rx_data(rx_data),
  .rx_data_valid(rx_data_valid),
  .tx_data(tx_data),
  .tx_req(tx_req),
  .tx_busy(tx_busy),
  .address(address),
  .rd_data(rd_data),
  .wr_data(wr_data),
  .read_req(read_req),
  .write_req(write_req)
);

//Register map
regmap i_regmap(
  .clk(clk),
  .rst(hw_reset),

  //Local bus
  .waddr(address),
  .wdata(wr_data),
  .wen(write_req),
  .wstrb(4'b1111),

  //wready
  .raddr(address),
  .ren(read_req),
  .rdata(rd_data),

  //Registers for the user
  .csr_control_reset_out(ptrng_reset),
	.csr_control_conditioning_out(conditioning),
	.csr_analog_temperature_in(analog_temperature),
	.csr_analog_voltage_in(analog_voltage),
	.csr_analog_en_out(analog_en),
	.csr_ring_en_out(ring_en),
	.csr_freqctrl_en_out(freqcount_en),
	.csr_freqctrl_start_out(freqcount_start),
	.csr_freqctrl_done_in(freqcount_done),
	.csr_freqctrl_select_out(freqcount_select),
	.csr_freqctrl_overflow_in(freqcount_overflow),
	.csr_freqvalue_value_in(freqcount_value),
	.csr_freqdivider_value_out(freqdivider_value),
	.csr_freqdivider_value_waccess(freqdivider_en),
	.csr_alarm_threshold_out(alarm_threshold),
	.csr_monitoring_alarm_in(alarm_detected),
	.csr_monitoring_clear_out(onlinetest_clear),
	.csr_monitoring_valid_in(onlinetest_valid),
	.csr_onlinetest_average_out(onlinetest_average),
	.csr_onlinetest_deviation_out(onlinetest_deviation),
	.csr_fifoctrl_clear_out(fifo_clear),
	.csr_fifoctrl_nopacking_out(nopacking),
	.csr_fifoctrl_empty_in(fifo_empty),
	.csr_fifoctrl_full_in(fifo_full),
	.csr_fifoctrl_almostempty_in(fifo_almost_empty),
	.csr_fifoctrl_almostfull_in(fifo_almost_full),
	.csr_fifoctrl_rdburstavailable_in(~fifo_almost_empty), 
	.csr_fifoctrl_burstsize_in (burst_size_16bits), //vhdl: std_logic_vector(to_unsigned(BURST_SIZE,16))
	.csr_fifodata_data_rvalid (1'b1), //Useless since rvalid is not used
	.csr_fifodata_data_ren(fifo_read_en),
	.csr_fifodata_data_in(fifo_data_read)
);

//Internal temperature and voltage sensor
analog i_analog(
  .clk(clk),
  .reset(hw_reset),
  .enable(analog_en),
  .temperature(analog_temperature),
  .voltage(analog_voltage)
);

ptrng #(
  .REG_WIDTH(DATA_WIDTH),
  .RAND_WIDTH(DATA_WIDTH)
) i_ptrng(
  .clk(clk),
  .reset(hw_reset),
  .clear(ptrng_reset),
  .ring_en(ring_en),
	.freqcount_en(freqcount_en),
	.freqcount_select(freqcount_select),
	.freqcount_start(freqcount_start),
	.freqcount_done(freqcount_done),
	.freqcount_overflow(freqcount_overflow),
	.freqcount_value(freqcount_value),
	.freqdivider_value(freqdivider_value),
	.freqdivider_en(freqdivider_en),
	.alarm_threshold(alarm_threshold),
	.alarm_detected(alarm_detected),
	.onlinetest_clear(onlinetest_clear),
	.onlinetest_average(onlinetest_average),
	.onlinetest_deviation(onlinetest_deviation),
	.onlinetest_valid(onlinetest_valid),
	.conditioning(conditioning),
	.nopacking(nopacking),
	.data(ptrng_data),
	.valid(ptrng_valid)
);


//FIFO
fifo #(
  .SIZE(FIFO_SIZE),
  .ALMOST_EMPTY_SIZE(BURST_SIZE),
  .ALMOST_FULL_SIZE(FIFO_SIZE - BURST_SIZE),
  .DATA_WIDTH(DATA_WIDTH)
) i_fifo(
  .clk(clk),
  .reset(hw_reset),
  .clear(ptrng_reset || fifo_clear),
  .data_in(ptrng_data),
  .wr(ptrng_valid),
  .data_out(fifo_data_read),
  .rd(fifo_read_en),
  .empty(fifo_empty),
  .full(fifo_full),
  .almost_empty(fifo_almost_empty),
  .almost_full(fifo_almost_full)
);









  
endmodule
