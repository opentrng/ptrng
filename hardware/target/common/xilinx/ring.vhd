library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

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
		-- Enable the monitoring signal
		mon_en: in std_logic;
		-- Output signal for monitoring
		mon_osc: out std_logic
	);
end entity;

-- RTL implementation of the RO for Xilinx FPGAs.
architecture xilinx of ring is

	signal net: std_logic_vector (N downto 0);
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of net: signal is "true";

begin

	-- Loopback NAND for inverting the signal and enable the ring
	lut_nand: LUT2
	generic map (
		INIT => "0111"
	)
	port map (
		I0 => net(N),
		I1 => enable,
		O => net(0)
	);

	-- Generate all elements (buffers)
	element: for I in 0 to N-1 generate
		lut_buffer: LUT1
		generic map (
			INIT => "10"
		)
		port map (
			I0 => net(I),
			O => net(I+1)
		);
	end generate;

	-- Output a net of the RO
	osc <= net(N);

	-- Dedicated inverter to monitor the signal without modifying its load
	lut_and: LUT2
	generic map (
			INIT => "1000"
		)
	port map (
		I0 => net(0),
		I1 => mon_en,
		O => mon_osc

	);

end architecture;
