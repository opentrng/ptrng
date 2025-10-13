//This algorithm post processing block (conditioner) implements the extended Von Neummann encoding. Basic VN encoder handles bit input. Here RRN can be vectors, the truth table for this extended VN encoder is the following: (i,j) => i(k,k) => skip


module conditioner #(
  parameter RAND_WIDTH = 32                          //Width for the RRN input and output
) (
  input clk,                                         //Base clock
  input reset,                                       //Synchronous reset active to '1'
  input clear,                                       //Synchronous clear active to '1'
  input enable,                                      //Enable the conditioner at '1'
  input [RAND_WIDTH - 1: 0] raw_random_number,       //Raw Random Number input data (RRN)
  input raw_random_valid,                            //RRN data input validation
    
  output reg [RAND_WIDTH - 1: 0] conditioned_number,     //Conditioned random number output data (also known as IRN)
  output reg conditioned_valid                           //Conditioned data output validation
);

//RTL implementation of the Von Neumann extended encoder
reg [RAND_WIDTH - 1: 0] previous;
reg evenodd;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    previous <= {RAND_WIDTH{1'b0}};
    evenodd <= 1'b0;
    conditioned_valid <= 1'b0;
    conditioned_number <= {RAND_WIDTH{1'b0}};
  end else begin 
    if (clear) begin
      previous <= {RAND_WIDTH{1'b0}};
      evenodd <= 1'b0;
      conditioned_valid <= 1'b0;
      conditioned_number <= {RAND_WIDTH{1'b0}}; 
    end
    else if (enable) begin
      if (raw_random_valid) begin 
        previous <= raw_random_number;
        evenodd <=  ~evenodd;
        if (raw_random_number != previous && evenodd) begin
            conditioned_number <= previous;
            conditioned_valid  <= 1'b1;
        end else begin
            conditioned_valid <= 1'b0;                 
            end
      end else begin
            conditioned_valid <= 1'b0;
      end
    end else begin
        conditioned_valid <= 1'b0;
    end 
  end   
end

  
endmodule
