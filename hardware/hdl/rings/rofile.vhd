library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This entity is for simulation purpose only. It simulates a ring oscillator output signal by reading successive period durations in a text file located at given PATH. The file can be generated with the RO emulator.
entity rofile is
	generic (
		-- Path of text file containing the clock periods for each cycle
		PATH: string
	);
	port (
		-- The oscillator runs when enabled = '1'
		enable: in std_logic;
		-- Output of the ring oscillator
		osc: out std_logic
	);
end entity;

-- This architecture is available for simulation only.
architecture sim of rofile is

	file fin: text;
	signal ring: std_logic := '0';

begin

	stimulus: process
		variable inline: line;
		variable period: integer;
	begin
		file_open(fin, PATH,  read_mode);
		while not endfile(fin) and enable = '1' loop
			readline(fin, inline);
			read(inline, period);
			wait for period * 1fs;
			if enable = '1' then
				ring <= not ring;
			else
				ring <= '0';
			end if;
		end loop;
		file_close(fin);
		report "RO " & PATH & " STIMULUS DONE!";
		wait;
	end process;

	osc <= ring;

end architecture;
