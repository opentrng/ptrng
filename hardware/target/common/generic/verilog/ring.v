//Ring-oscillator entity composed of N elements. Takes an enable signal as input. Outputs a period oscillating signal

 module ring #(
  parameter N = 2     //Number of elements in the ring(including the NAND)
 )(
  input enable,       //Enable the signal (active '1')
  output osc,         //Clock output signal
  input mon_en,       //Enable the monitoring signal
  output mon          //Output signal for monitoring 
 );

//RTL implementation of the RO
wire [N-1:0] net;

//Loopback NAND for inverting the signal and enable the ring  
assign net[0] = !(net[N-1] & enable); 
genvar I;
//Generate all inverters
generate
  for (I = 1; I <= N - 1; I = I + 1 ) begin : inv
     assign net[I] = net[I-1];
  end
endgenerate

//Output a net of the RO
assign osc = net[0];

//Monitoring output
assign mon = mon_en ? osc : 1'b0;

endmodule