library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

-- Ring-oscillator entity composed of LEN elements. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ring is
	generic (
		INVERTERS: boolean := true;
		-- Number of elements in the ring
		LEN: natural
	);
	port (
		-- Enable signal (active '1')
		enable: in std_logic;
		-- Clock output signal
		osc: out std_logic
	);
end entity;

-- Xilinx specific implementation of the RO.
architecture xilinx of ring is

	signal ring: std_logic_vector (LEN downto 0) := (others => '0');
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of ring: signal is "true";
	attribute ALLOW_COMBINATORIAL_LOOPS: string;
	attribute ALLOW_COMBINATORIAL_LOOPS of ring: signal is "true";

begin

	-- NAND for inverting the signal and enable the ring
	lut_nand: LUT2
	generic map (
		INIT => "0111"
	)
	port map (
		I0 => ring(LEN),
		I1 => enable,
		O => ring(0)
	);

	-- Generate all elements (buffers or inverters)
	generate_elements: for I in 0 to LEN-1 generate
		generate_type: if INVERTERS = true generate
			lut_inverter: LUT1
			generic map (
				INIT => "01"
			)
			port map (
				I0 => ring(I),
				O => ring(I+1)
			);
		else generate
			lut_buffer: LUT1
			generic map (
				INIT => "10"
			)
			port map (
				I0 => ring(I),
				O => ring(I+1)
			);
		end generate;
	end generate;

	-- Output a net of the RO
	osc <= ring(0);

end architecture;
