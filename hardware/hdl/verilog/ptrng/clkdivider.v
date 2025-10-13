//This entity is a simple linear clock divider. The 'factor' input can be in another clock domain than 'original' clock but must be stable when 'changed' is low.
module clkdivider #(
  parameter FACTOR_WIDTH = 32               //Maximum division factor width (32 bits)
)(
  input reset,                              //Asynchronous reset
  input original,                           //Input clock to be divided
  input [FACTOR_WIDTH - 1:0] divider,       //Division factor(1:no division, 2:division by 2,...) 
  input changed,                            //Enable 
  output divided                            //Divided output clock   
); 

reg [FACTOR_WIDTH-1:0] counter;
reg pulse;
wire rst_count;

assign rst_count = reset || changed;

always @(posedge original or posedge rst_count) begin   //Create the pulse when counter is equal to 1
  if(rst_count) begin
    counter <= {FACTOR_WIDTH{1'b0}};
    pulse   <= 1'b0;
  end else begin 
    if(divider == 2) begin
      counter[0] <= ~(counter[0]);
      pulse <= counter[0];
    end else if(counter < divider - 1) begin
      counter <= counter + 1;
      if (counter == 32'b1) begin 
          pulse <= 1'b1;
      end else begin
          pulse <= 1'b0;
      end
    end else begin
      counter <= {FACTOR_WIDTH{1'b0}};
      pulse <= 1'b0;    
    end
  end
end


//Select the rehaped clock if the divided is a least 2, else the original signal 
assign divided = (divider == 32'd0) ? 1'b0 : 
                 (divider == 32'd1) ? original : pulse;

endmodule
