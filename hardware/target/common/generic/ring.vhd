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
		osc: out std_logic
	);
end entity;

-- RTL implementation of the RO.
architecture rtl of ring is

	signal net: std_logic_vector (N downto 0);

begin

	-- Loopback NAND for inverting the signal and enable the ring
	net(0) <= net(N) nand enable;

	-- Generate all inverters
	inv: for I in 0 to N-1 generate
		net(I+1) <= net(I);
	end generate;

	-- Output a net of the RO
	osc <= net(0);

end architecture;
