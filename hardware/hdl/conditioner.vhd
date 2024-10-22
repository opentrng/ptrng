library ieee;
use ieee.std_logic_1164.all;

-- This algorithm post processing block (conditioner) implements the extended Von Neumann encoding. Basic VN encoder handles bit input. Here RRN can be vectors, the truth table for this extended VN encoder is the following: (i, j)=>i (k, k)=>skip
entity conditioner is
	generic (
		-- Width for the RRN input and output
		RAND_WIDTH: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Enable the conditioner at '1', when '0' this bloc is a simple bypass
		enable: in std_logic;
		-- Raw Random Number input data (RRN)
		raw_random_number: in std_logic_vector (RAND_WIDTH-1 downto 0);
		-- RRN data input validation
		raw_random_valid: in std_logic;
		-- Intermediate Random Number ouput data (IRN)
		intermediate_random_number: out std_logic_vector (RAND_WIDTH-1 downto 0);
		-- IRN data output validation
		intermediate_random_valid: out std_logic
	);
end entity;

-- RTL implementation of the Von Neumann extended encoder
architecture rtl of conditioner is

	signal previous: std_logic_vector (RAND_WIDTH-1 downto 0);

begin

	-- Compare current RRN to previous one
	accumulation: process (clk, reset) is
	begin
		if reset = '1' then
			previous <= (others => '0');
			intermediate_random_valid <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then
				if raw_random_valid = '1' then
					previous <= raw_random_number;
					if raw_random_number /= previous then
						intermediate_random_number <= raw_random_number;
						intermediate_random_valid <= '1';
					else
						intermediate_random_valid <= '0';
					end if;
				else
					intermediate_random_valid <= '0';
				end if;
			else
				intermediate_random_number <= raw_random_number;
				intermediate_random_valid <= raw_random_valid;
			end if;
		end if;
	end process;

end architecture;
