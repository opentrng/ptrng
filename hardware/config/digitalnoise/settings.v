`ifndef SETTINGS
`define SETTINGS

`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/constants.v"

//System clock settings
parameter SYSCLK_VCO = 1'b1; //true
parameter SYSCLK_FREQ = 100_000_000;


//Ring-oscillators settings
parameter T = 1;
parameter [((T+1)*32)-1:0] RO_LEN = (20 << 0) | (20 << 32);

//Digitizer settings
parameter DIGITIZER_GEN = COSO;

`endif
