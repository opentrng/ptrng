library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

-- LUT based NAND implementation for Xilinx
entity nand is
	port (
		-- First input signal
		i0: in std_logic;
		-- Second input signal
		i1: in std_logic;
		-- Output signal equal to not(i0 and i1)
		o: out std_logic
	);
end entity;

-- Architecture for the LUT NAND gate
architecture lut of nand is
begin

	-- LUT2 instantation with NAND table of truth
	lut_nand: LUT2
	generic map (
		INIT => "0111"
	)
	port map (
		I0 => i0,
		I1 => i1,
		O => o
	);

end architecture;
