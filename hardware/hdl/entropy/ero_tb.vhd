library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Test bench entity for ERO.
entity ero_tb is
end entity;

-- Implementation of the testbench for simulation.
architecture sim of ero_tb is

	signal ro1: std_logic := '0';
	signal ro2: std_logic := '0';

	signal ero_clk: std_logic;
	signal ero_data: std_logic;

	file fout: text;

begin

	-- ERO is the design under test
	dut: entity work.ero
	port map (
		ro1 => ro1,
		ro2 => ro2,
		div => std_logic_vector(to_unsigned(1000, 32)),
		clk => ero_clk,
		data => ero_data
	);

	-- Simulation of RO1 with data generated by the RO emulator
	rofile1: entity work.rofile
	generic map (
		PATH => "../../emulator/ro1.txt"
	)
	port map (
		enable => '1',
		osc => ro1
	);

	-- Simulation of RO2 with data generated by the RO emulator
	rofile2: entity work.rofile
	generic map (
		PATH => "../../emulator/ro2.txt"
	)
	port map (
		enable => '1',
		osc => ro2
	);

	-- Write each ERO random bit to the output file 'ero.txt'
	file_open(fout, "ero.txt",  write_mode);
	output: process (ero_clk)
		variable outline: line;
	begin
		if rising_edge(ero_clk) then
			write(outline, ero_data);
			writeline(fout, outline);
		end if;
	end process;

end architecture;
