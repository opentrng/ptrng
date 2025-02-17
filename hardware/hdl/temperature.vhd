library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Read the temperature from an ADC (many FPGA have a die temperature sensor into ADCs).
entity temperature is
	port (
		-- Reference clock
		clk: in std_logic;
		-- Asynchronous reset
		reset: in std_logic;
		-- Synchronous clear active to '1'
		clear: in std_logic;
		-- Global enable for the entity
		enable: in std_logic;
		-- Pulse '1' to start the temperature measure
		start: in std_logic;
		-- Flag set to '1' when the result is ready
		done: out std_logic;
		-- Temperature output
		result: out std_logic_vector (15 downto 0)
	);
end entity;

-- RTL architecture for reading the temperature.
architecture rtl of temperature is

	signal measure: std_logic;
	signal ready: std_logic;
	signal data: std_logic_vector (15 downto 0);

begin

	-- State machine to manage the measurement operation
	process (clk, reset)
	begin
		if reset = '1' then
			measure <= '0';
			done <= '0';
		elsif rising_edge(clk) then
			if clear = '0' and enable = '1' then
				if start = '1' then
					measure <= '1';
					done <= '0';
				else
					if ready = '1' then
						measure <= '0';
						result <= X"0" & data(15 downto 4);
						done <= '1';
					end if;
				end if;
			else
				result <= (others => '0');
				measure <= '0';
				done <= '0';
			end if;
		end if;
	end process;

	-- Instanciate the temperature ADC
	adc: entity work.adc
	port map (
		daddr_in => (others => '0'),
		den_in => measure,
		di_in => (others => '0'),
		dwe_in => '0',
		do_out => data,
		drdy_out => ready,
		dclk_in => clk,
		reset_in => reset,
		vp_in => '1',
		vn_in => '0'
	);

end architecture;
