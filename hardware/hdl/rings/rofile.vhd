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

	-- Read period duration in each line of the input file, create the ringo output by inversion of the clock each half period
	stimulus: process
		variable inline: line;
		variable fullperiod: integer;
		variable halfperiod: integer;
	begin
		file_open(fin, PATH,  read_mode);
		while not endfile(fin) loop
			if enable = '1' then
				readline(fin, inline);
				read(inline, fullperiod);
				halfperiod := fullperiod / 2;
				wait for halfperiod * 1fs;
				ring <= not ring;
				wait for (fullperiod-halfperiod) * 1fs;
				ring <= not ring;
			end if;
		end loop;
		file_close(fin);
		report "STIMULUS DONE! " & PATH & " reached end-of-file";
		wait;
	end process;

	-- Take the ringo signal out of the block ;)
	osc <= ring;

end architecture;
