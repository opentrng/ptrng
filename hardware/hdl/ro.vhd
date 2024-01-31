library ieee;
use ieee.std_logic_1164.all;

-- Ring-oscillator entity composed of LEN elements. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ro is
	generic (
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

-- RTL implementation of the RO.
architecture rtl of ro is

	signal ring: std_logic_vector (LEN downto 0) := (others => '0');
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of ring: signal is "true";
	attribute ALLOW_COMBINATORIAL_LOOPS: string;
	attribute ALLOW_COMBINATORIAL_LOOPS of ring: signal is "true";

begin

	-- NAND for inverting the signal and enable the ring
	ring_inverse_and_enable: entity work.nand
	port map (
		i0 => ring(LEN),
		i1 => enable,
		o => ring(0)
	);

	-- Generate all elements (buffers or inverters)
	generate_ring: for I in 0 to LEN-1 generate
		delay: entity work.buffer
		port map (
			i0 => ring(I),
			o => ring(I+1)
		);
	end generate;

	-- Output a net of the RO
	osc <= ring(0);

end architecture;
