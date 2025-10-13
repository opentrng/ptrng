module adc (
  input  [ 6:0] daddr_in,         // Address bus for the dynamic reconfiguration port
	input         den_in,           // Enable Signal for the dynamic reconfiguration port
	input  [15:0] di_in,            // Input data bus for the dynamic reconfiguration port
	input         dwe_in,           // Write Enable for the dynamic reconfiguration port
	output [15:0] do_out,           // Output data bus for dynamic reconfiguration port
	output        drdy_out,         // Data ready signal for the dynamic reconfiguration port
	input         dclk_in,          // Clock input for the dynamic reconfiguration port
	input         reset_in,         // Reset signal for the System Monitor control logic
	output        busy_out,         // ADC Busy signal
	output [ 4:0] channel_out,      // Channel Selection Outputs
	output        eoc_out,          // End of Conversion Signal
	output        eos_out,          // End of Sequence Signal
	output        alarm_out,        // OR'ed output of all the Alarms
	input         vp_in,            // Dedicated Analog Input Pair
	input         vn_in
);
endmodule
