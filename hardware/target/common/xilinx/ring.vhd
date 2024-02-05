library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

-- Ring-oscillator entity composed of LEN elements. Takes an enable signal as input. Ouputs a periodic oscillating signal.
entity ring is
	generic (
		-- Element LUT1 table of truth ("01" for inverters, "10" for identity)
		INIT: bit_vector (1 downto 0) := "01";
		-- Number of elements in the ring (NAND excluded)
		LEN: natural
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

-- Xilinx specific implementation of the RO.
architecture xilinx of ring is

	signal net: std_logic_vector (LEN downto 0) := (others => '0');
	attribute DONT_TOUCH: string;
	attribute DONT_TOUCH of net: signal is "true";
	attribute ALLOW_COMBINATORIAL_LOOPS: string;
	attribute ALLOW_COMBINATORIAL_LOOPS of net: signal is "true";

begin

	-- NAND for enabling the ring and inverting the signal
	enabler_inverter: LUT2
	generic map (
		INIT => "0111"
	)
	port map (
		I0 => net(LEN),
		I1 => enable,
		O => net(0)
	);

	-- Generate all elements (buffers or inverters)
	element: for I in 0 to LEN-1 generate
		inverter: LUT1
		generic map (
			INIT => INIT
		)
		port map (
			I0 => net(I),
			O => net(I+1)
		);
	end generate;

	-- Output a net of the RO
	osc <= net(0);

	-- Dedicated inverter to monitor the signal without modifying its load
	monitor: LUT1
	generic map (
		INIT => "01"
	)
	port map (
		I0 => net(0),
		O => mon
	);

end architecture;
