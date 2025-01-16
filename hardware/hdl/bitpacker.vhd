library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

-- Pack bits into words of 2^N bits
entity bitpacker is
	generic (
		-- Defines size of the packing (output width 2^N bits)
		W: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Synchronous clear active to '1'
		clear: in std_logic;
		-- Input bits
		data_in: in std_logic;
		-- Validate the bit input
		valid_in: in std_logic;
		-- Word output
		data_out: out std_logic_vector (W-1 downto 0);
		-- Validate the word output
		valid_out: out std_logic
	);
end entity;

-- RTL implementation of the bit packer
architecture rtl of bitpacker is

	constant N: positive := positive(ceil(log2(real(W))));
	signal pipe: std_logic;
	signal shift_reg: std_logic_vector (W-1 downto 0);
	signal counter: std_logic_vector (N-1 downto 0);

begin

	-- Count the size of words
	process (clk, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
			pipe <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
				pipe <= '0';
			else
				if valid_in = '1' then
					counter <= counter + 1;
					pipe <= '1';
				end if;
			end if;
		end if;
	end process;

	-- Shift register for input bits
	process (clk, reset)
	begin
		if reset = '1' then
			shift_reg <= (others => '0');
		elsif rising_edge(clk) then
			if clear = '1' then
				shift_reg <= (others => '0');
			else
				if valid_in = '1' then
					shift_reg <= data_in & shift_reg(W-1 downto 1);
				end if;
			end if;
		end if;
	end process;
	
	-- Validate the word to output depending on counter value
	process (clk, reset)
	begin
		if reset = '1' then
			valid_out <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
				data_out <= (others => '0');
				valid_out <= '0';
			else
				if counter = 0 then
					if pipe = '1' then
						valid_out <= valid_in;
						data_out <= shift_reg;
					end if;
				else
					valid_out <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;
