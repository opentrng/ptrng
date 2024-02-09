library ieee;
use ieee.std_logic_1164.all;

-- Ring-oscillator entity composed of N elements. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ring is
	generic (
		-- Number of elements in the ring
		N: natural
	);
	port (
		-- Enable signal (active '1')
		enable: in std_logic;
		-- Clock output signal
		osc: out std_logic;
		-- Output signal for monitoring
		mon: out std_logic
	);
end entity;

-- RTL implementation of the RO.
architecture rtl of ring is

	signal net: std_logic_vector (N downto 0) := (others => '0');
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of net: signal is "true";
	attribute ALLOW_COMBINATORIAL_LOOPS: string;
	attribute ALLOW_COMBINATORIAL_LOOPS of net: signal is "true";

begin

	-- Loopback NAND for inverting the signal and enable the ring
	loopback: entity work.generic_nand
	port map (
		i0 => net(N),
		i1 => enable,
		o => net(0)
	);

	-- Generate all elements (buffers or inverters)
	generate_elements: for I in 0 to N-1 generate
		--delay: entity work.generic_buffer
		delay: entity work.generic_inverter
		port map (
			i => net(I),
			o => net(I+1)
		);
	end generate;

	-- Output a net of the RO
	osc <= net(0);

	-- Dedicated inverter to monitor the signal without modifying its load
	monitor: entity work.generic_inverter
	port map (
		i => net(0),
		o => mon
	);

end architecture;
