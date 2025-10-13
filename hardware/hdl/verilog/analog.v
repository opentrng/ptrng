//Read analog temperature and voltage from an ADC (many FPGA have internal sensors).

module analog (
  input clk,                       //Reference clock
  input reset,                     //Asynchronous reset
  input enable,                    //Enable continuous measurements

  output reg [11:0] temperature,       //Temperature output
  output reg [11:0] voltage            //Voltage output
);

//RTL architecture for reading temperature and voltage from ADC

reg den;
wire drdy;
wire [4:0] channel;
wire eoc;
wire [15:0] do_;


//State machine to manage the measurement operation
always @(posedge clk or posedge reset) begin
  if (reset) begin
    den <= 1'b0;
    temperature <= 12'h000;
    voltage <= 12'h000;
  end else begin
    if(enable) begin
      den <= eoc;
      if (drdy) begin
        if (!channel) begin
          temperature <= do_[15:4];          
        end else if(channel == 1'b1) voltage <= do_[15:4];
        
        end
    end else begin
      den <= 1'b0;
      temperature <= 12'h000;
      voltage <= 12'h000;
    end
  end
end

adc i_adc(
  .dclk_in(clk),
  .reset_in(reset),
  .den_in(den),
  .daddr_in({2'b00, channel}),
  .di_in({16{1'b0}}),
  .dwe_in(1'b0),
  .drdy_out(drdy),
  .channel_out(channel),
  .eoc_out(eoc),
  .do_out(do_),
  .vp_in(1'b1),
  .vn_in(1'b0)
);
  
endmodule
