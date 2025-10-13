//The MURO wrapper converts the std_logic_vector input ports for R01-R0t to an entity with t=5 inputs (RO0-R05)

module murowrapper #(
  parameter REG_WIDTH = 32,             
  parameter t = 5                      
)(
  input reset,                          
  input ro0,
  input ro1,
  input ro2,
  input ro3,
  input ro4,
  input ro5,                           
  input [REG_WIDTH - 1:0] divider,      
  input changed,                        
  output clk,                           
  output data                        
);

//This architecture implements the RTL version of MURO's wrapper

reg [t-1:0] rox;

assign rox = {ro5,ro4,ro3,ro2,ro1};

//Divide RO0 clock by the divider factor

muro #(
  .REG_WIDTH(REG_WIDTH),
  .t(t)
)i_muro(
  .reset(reset),
  .ro0(ro0),
  .rox(rox),
  .divider(divider),
  .changed(changed),
  .clk(clk),
  .data(data)
);
endmodule
