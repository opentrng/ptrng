library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Pack bits into words of 2^N bits
entity bitpacker is
	generic (
		-- Defines size of the packing (default to 2^5 = 32bits)
		N: natural := 5
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Input bits
		data_in: in std_logic;
		-- Validate the bit input
		valid_in: in std_logic;
		-- Word output
		data_out: out std_logic_vector ((2**N)-1 downto 0);
		-- Validate the word output
		valid_out: out std_logic
	);
end entity;

-- RTL implementation of the bit packer
architecture rtl of bitpacker is

	signal pipe: std_logic;
	signal shift_reg: std_logic_vector ((2**N)-1 downto 0);
	signal counter: std_logic_vector (N-1 downto 0);

begin

	-- Count the size of words
	process (clk, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
			pipe <= '0';
		elsif rising_edge(clk) then
			if valid_in = '1' then
				counter <= counter + 1;
				pipe <= '1';
			end if;
		end if;
	end process;

	-- Shift register for input bits
	process (clk, reset)
	begin
		if reset = '1' then
			shift_reg <= (others => '0');
		elsif rising_edge(clk) then
			if valid_in = '1' then
				shift_reg <= data_in & shift_reg((2**N)-1 downto 1);
			end if;
		end if;
	end process;
	
	-- Validate the word to output depending on counter value
	process (clk, reset)
	begin
		if reset = '1' then
			valid_out <= '0';
		elsif rising_edge(clk) then
			if counter = 0 then
				if pipe = '1' then
					valid_out <= valid_in;
					data_out <= shift_reg;
				end if;
			else
				valid_out <= '0';
			end if;
		end if;
	end process;

end architecture;
