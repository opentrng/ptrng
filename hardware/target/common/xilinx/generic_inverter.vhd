library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

-- LUT based inverter implementation for Xilinx to introduce a delay in the signal
entity generic_inverter is
	port (
		-- Input signal to invert
		i: in std_logic;
		-- Inverted output signal with a delay
		o: out std_logic
	);
end entity;

-- Architecture for the LUT inverter gate
architecture lut of generic_inverter is
begin

	-- LUT1 instantation with inverter table of truth
	lut_inverter: LUT1
	generic map (
		INIT => "01"
	)
	port map (
		I0 => i,
		O => o
	);

end architecture;
