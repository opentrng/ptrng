//Pack bits into words of 2^N bits

module bitpacker #(
  parameter W = 32                   //Defines size of the packing (output width 2^N bits)
) (
  input clk,                         //Base clock
  input reset,                       //Asynchronous reset active to '1'
  input clear,                       //Synchronous clear active to '1' 
  input data_in,                     //Input bits
  input valid_in,                    //Validate  the bit input
  output reg [W-1:0] data_out,       //Work output
  output reg valid_out               //Validate the word output
);

//RTL implementation of the bit packer

parameter N = $clog2(W);  //In VHDL: constant N: positive := positive(ceil(log2(real(W))));
reg pipe;
reg [W-1:0] shift_reg;
reg [N-1:0] counter;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    counter <= {N{1'b0}};
    pipe <= 1'b0;
  end else begin
    if (clear) begin
      counter <= {N{1'b0}};
      pipe <= 1'b0;
    end
    else if(valid_in) begin
      counter <= counter + 1'b1;
      pipe <= 1'b1;
    end
  end
end

//Shift register for input bits
always @(posedge clk or posedge reset) begin
  if(reset) begin
    shift_reg <= {W{1'b0}};
  end else begin
    if (clear) begin
      shift_reg <= {W{1'b0}};
    end else if(valid_in) begin
      shift_reg <= {data_in,shift_reg[W-1:1]};
    end
  end
end

//Validate the word to output depending on counter value
always @(posedge clk or posedge reset) begin
  if (reset) begin
    data_out <= {W{1'b0}};
    valid_out <= 1'b0;      
  end else begin
    if (clear) begin
      data_out <= {W{1'b0}};
      valid_out <= 1'b0;
    end else begin
      if(!counter) begin
        if(pipe) begin
          valid_out <= valid_in;
          data_out <= shift_reg;
        end
      end else begin
        valid_out <= 1'b0;
      end      
    end
  end
end

endmodule
