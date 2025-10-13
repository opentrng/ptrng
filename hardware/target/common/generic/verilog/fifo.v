//Show ahead FIFO that infers RAM blocks. Flags are updated at the next clock cycle. Show ahead means that first data is available on the output port, read fetches next.

module fifo #(
  parameter SIZE = 512*64,                                  //FIFO size (maximum number of elements)
  parameter ALMOST_EMPTY_SIZE = 0,                        //Threshold for almost size
  parameter ALMOST_FULL_SIZE = SIZE,      //Threshold for almost full   
  parameter DATA_WIDTH = 32                                 //Data path width
)(        
  input clk,                                                //Main clock
  input reset,                                              //Asynchronous reset
  input clear,                                              //Synchronous clear
  input [DATA_WIDTH - 1:0] data_in,                         //Data to be written in the FIFO
  input wr,                                                 //Write signal (enable 'data_in' within the same clock cycle)
  output reg [DATA_WIDTH -1:0] data_out,                        //Show ahead data out (always showing the current data)
  input rd,                                                 //Read signal, ask for a new data that will be available in next cycle
  output empty,                                             //Rise next clock cycle after FIFO became empty
  output full,                                              //Rise next clock cycle after FIFO became full
  output almost_empty,                                      //Rise next clock cycle after FIFO became almost full
  output almost_full                                        //Rise next clock cycle after FIFO became almost full
);

//RTL implementation of the FIFO

//Constants
parameter ADDR_WIDTH = $clog2(SIZE);
parameter [ADDR_WIDTH:0] MAX_SIZE = 2**ADDR_WIDTH; //VHDL: constant MAX_SIZE: std_logic_vector(ADDR_WIDTH dowto 0) := std_logic_vector(to_unsigned(2**ADDR_WIDTH, ADDR_WIDTH +1));

//Data array
reg [DATA_WIDTH - 1:0] ram_block [2**ADDR_WIDTH - 1:0];

wire [31:0] write_address_32;
wire [31:0] read_address_32;

//Read/write control
reg  [ADDR_WIDTH - 1:0] write_address;
reg  [ADDR_WIDTH - 1:0] read_address;
wire [ADDR_WIDTH - 1:0] read_address_plus_1 = read_address + 1;
reg  [ADDR_WIDTH:0] count;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    write_address <= {ADDR_WIDTH{1'b0}};
    read_address <= {ADDR_WIDTH{1'b0}};
    count <= {ADDR_WIDTH+1{1'b0}};
  end else begin
    if (clear) begin
      write_address <= {ADDR_WIDTH{1'b0}};
      read_address <= {ADDR_WIDTH{1'b0}};
      count <= {ADDR_WIDTH{1'b0}};
    end else begin
      if(wr == 1'b1 && rd == 1'b1 && count > 0 && count <= MAX_SIZE) begin
        write_address <= write_address + 1;
        read_address <= read_address + 1;
      end else if(wr == 1'b1 && count < MAX_SIZE) begin
        write_address <= write_address + 1;
        count <= count + 1;
      end else if(rd == 1'b1 && count > 0) begin
        read_address <= read_address + 1;
        count <= count - 1;
      end
    end
  end
end

always @(posedge clk) begin
  if (wr == 1'b1 && rd == 1'b1 && count > 0 && count <= MAX_SIZE) begin
    ram_block[write_address] <= data_in;
  end else if (wr == 1'b1 && count < MAX_SIZE) begin
    ram_block[write_address] <= data_in;
  end
end

always @(posedge clk) begin
  if (rd) begin
    data_out <= ram_block[read_address_plus_1];
  end else begin
    data_out <= ram_block[read_address];
  end
end

assign  empty = (count == 0) ? 1'b1 : 1'b0;
assign almost_empty = (count <= (ALMOST_EMPTY_SIZE)) ? 1'b1 : 1'b0;

assign full = (count >= MAX_SIZE) ? 1'b1 : 1'b0;
assign almost_full = (count >= (ALMOST_FULL_SIZE)) ? 1'b1 : 1'b0;


  
endmodule
