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
endmodule
