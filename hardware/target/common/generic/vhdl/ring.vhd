library ieee;
use ieee.std_logic_1164.all;

-- Ring-oscillator entity composed of N elements. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ring is
	generic (
		-- Number of elements in the ring (including the NAND)
		N: natural
	);
	port (
		-- Enable signal (active '1')
		enable: in std_logic;
		-- Clock output signal
		osc: out std_logic;
		-- Enable the monitoring signal
		mon_en: in std_logic;
		-- Output signal for monitoring
		mon: out std_logic
	);
end entity;

-- RTL implementation of the RO.
architecture rtl of ring is

	signal net: std_logic_vector (N-1 downto 0);

begin

	-- Loopback NAND for inverting the signal and enable the ring
	net(0) <= net(N-1) nand enable;

	-- Generate all inverters
	inv: for I in 1 to N-1 generate
		net(I) <= net(I-1);
	end generate;

	-- Output a net of the RO
	osc <= net(0);
	
	-- Monitoring output
	mon <= osc when mon_en = '1' else '0';

end architecture;
