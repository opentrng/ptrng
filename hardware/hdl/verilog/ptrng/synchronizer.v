//Vector clock domain crossing. Resynchronize a vector from source clock to destination clock with an dual port FIFO.

module synchronizer #(
  parameter DATA_WIDTH = 32
)(
  input reset,                            //Asynchronous reset
  input clk_from,                         //Cross from this clock
  input [DATA_WIDTH - 1:0] data_in,       //Input data, sync to 'clk_from'
  input data_in_en,                       //Valid signal for 'data_in'
  input clk_to,                           //Cross to this clock
  input clear,                            //Synchronous clear active to '1' (sync to 'clk_to')

  output [DATA_WIDTH - 1:0] data_out,     //Output data, syn to 'clk_to'
  output data_out_en                      //Valid signal for 'data_out'
);


//RTL implementation of the resynchronizer for a vector

wire almost_empty;
wire empty;
reg read_en;

// //Dual port FIFO
 dpfifo #(
    .DATA_WIDTH(DATA_WIDTH)
 ) i_dpfifo(
    .reset(reset|clear),
    .wr_clk(clk_from),
    .wr_data(data_in),
    .wr_en(data_in_en),
    .rd_clk(clk_to),
    .rd_data(data_out),
    .rd_en(read_en),
    .empty(empty),
    .almost_empty(almost_empty)
 );

//TODO generate a synchronizer error when FIFO is full

//Read the FIFO if there is any available data
always @(posedge clk_to or posedge reset) begin
  if (reset) begin
    read_en <= 1'b0;
  end else begin
    if (clear) begin
      read_en <= 1'b0;
    end else begin
      if (!empty && !almost_empty) begin
        read_en <= 1'b1;
      end else begin
        read_en <= 1'b0;
      end
    end
  end
end

assign data_out_en = read_en;


endmodule
