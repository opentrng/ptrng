library ieee;
use ieee.std_logic_1164.all;

-- Ring-oscillator entity composed of N inverters. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ring is
	generic (
		-- Number of inverters in the ring (NAND excluded)
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

-- ASIC RTL implementation of the RO.
architecture rtl of ring is

	signal net: std_logic_vector (N downto 0) := (others => '0');
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of net: signal is "true";

begin

	-- NAND for enabling the ring and inverting the signal
	net(0) <= enable nand net(N);

	-- Generate all inverters
	element: for I in 0 to N-1 generate
		net(I+1) <= not net(I);
	end generate;

	-- Output a net of the RO
	osc <= net(0);

	-- Dedicated inverter to monitor the signal without modifying its load
	mon <= not net(0);

end architecture;
