library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

-- LUT based buffer implementation for Xilinx to introduce a delay in the signal
entity generic_buffer is
	port (
		-- Input signal
		i: in std_logic;
		-- Output signal with a delay
		o: out std_logic
	);
end entity;

-- Architecture for the LUT buffer gate
architecture lut of generic_buffer is
begin

	-- LUT1 instantation with identity table of truth
	lut_delay: LUT1
	generic map (
		INIT => "10"
	)
	port map (
		I0 => i,
		O => o
	);

end architecture;
