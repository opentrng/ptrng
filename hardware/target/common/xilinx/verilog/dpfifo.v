// Show ahead Dual port FIFO for Xilinx series 7. Show ahead means that first data is always available on the output port, read fetches next.

module dpfifo #(
  parameter DATA_WIDTH = 32           //With of data ports
) (
  input reset,                        //Asynchronous reset            
  input wr_clk,                       //Write clock
  input [DATA_WIDTH-1:0] wr_data,     //Input data, sync to 'wr_clk'
  input wr_en,                        //Write enable
  input rd_clk,                       //Read clock
  output [DATA_WIDTH-1:0] rd_data,    //Ouput data, sync to 'rd_clk'
  input  rd_en,                       //Read enable
  output empty,                       //Empty flag
  output full,                        //Full flag
  output almost_empty,                //Almost empty flag
  output almost_full                  //Almost full flag
);

// FIFO_DUALCLOCK_MACRO: Dual-Clock First-In, First-Out (FIFO) RAM Buffer
//                       7 Series
// Xilinx HDL Language Template, version 2021.2

/////////////////////////////////////////////////////////////////
// DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
// ===========|===========|============|=======================//
//   37-72    |  "36Kb"   |     512    |         9-bit         //
//   19-36    |  "36Kb"   |    1024    |        10-bit         //
//   19-36    |  "18Kb"   |     512    |         9-bit         //
//   10-18    |  "36Kb"   |    2048    |        11-bit         //
//   10-18    |  "18Kb"   |    1024    |        10-bit         //
//    5-9     |  "36Kb"   |    4096    |        12-bit         //
//    5-9     |  "18Kb"   |    2048    |        11-bit         //
//    1-4     |  "36Kb"   |    8192    |        13-bit         //
//    1-4     |  "18Kb"   |    4096    |        12-bit         //
/////////////////////////////////////////////////////////////////


FIFO_DUALCLOCK_MACRO #(
  .ALMOST_EMPTY_OFFSET(13'h0008),   //Sets the almost empty threshold
  .ALMOST_FULL_OFFSET(13'h0008),    //Sets almost full threshold
  .DATA_WIDTH(DATA_WIDTH),        //Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
  .DEVICE("7SERIES"),             //Target Device: "VIRTEX5", "VIRTEX6", "7SERIES"
  .FIFO_SIZE("36Kb"),             //Target BRAM, "18Kb" or "36Kb"
  .FIRST_WORD_FALL_THROUGH(1'b1)  //Sets the FIFO FWFT to TRUE or FALSE
) FIFO_DUALCLOCK_MACRO_inst (
  .ALMOSTEMPTY(almost_empty),     //1-bit output almost empty
  .ALMOSTFULL(almost_full),       //1-bit output almost full
  .DO(rd_data),                   //Output data, width defined by DATA_WIDTH parameter
  .EMPTY(empty),                  //1-bit output empty
  .FULL(full),                    //1-bit output full
  //.RDCOUNT(RDCOUNT),            //Output read count, width determined by FIFO depth
  //.RDERR(RDERR),                //1-bit output read error
  //.WRCOUNT(WRCOUNT),            //Output write count, width determined by FIFO depth
  //.WRERR(WRERR),                //1-bit output write error
  .DI(wr_data),                   // Input data, width defined by DATA_WIDTH parameter
  .RDCLK(rd_clk),                 //1-bit input read clock
  .RDEN(rd_en),                   //1-bit input read enable
  .RST(reset),                    //1-bit input reset
  .WRCLK(wr_clk),                 //1-bit input write clock
  .WREN(wr_en)                    //1-bit input write enable
);

//End of FIFO_DUALCLOCK_MACRO_inst instantiation

endmodule

