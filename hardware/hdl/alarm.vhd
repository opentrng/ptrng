library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

-- Total failure alarm on RRN. The total failure detection method depends on the digitizer type, the detection it triggered when the internal counter is greater or equal than the input threshold parameter.
entity alarm is
	generic (
		-- Width for the configuration registers
		REG_WIDTH: natural;
		-- Width for the RRN input
		RAND_WIDTH: natural
	);
	port (
		-- Base clock
		clk: in std_logic;
		-- Asynchronous reset active to '1'
		reset: in std_logic;
		-- Digitizer type (see constants package)
		digitizer: in natural;
		-- Raw Random Number input data (RRN)
		raw_random_number: in std_logic_vector (RAND_WIDTH-1 downto 0);
		-- RRN data input validation
		raw_random_valid: in std_logic;
		-- Threshold value to trigger the failure
		threshold: in std_logic_vector (REG_WIDTH/2-1 downto 0);
		-- Set to '1' when the total failure event is detected
		detected: out std_logic
	);
end entity;

-- RTL implementation of the total failure alarm
architecture rtl of alarm is

	signal counter: std_logic_vector (REG_WIDTH/2-1 downto 0) := (others => '0');
	signal value: std_logic_vector (RAND_WIDTH-1 downto 0) := (others => '0');

begin

	-- Count the given metric (depending on digitizer type)
	process (clk, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
		elsif rising_edge(clk) then

			-- In test mode increase the counter each RRN
			if digitizer = TEST then
				if raw_random_valid = '1' then
					counter <= counter + 1;
				end if;

			-- For ERO/MURO count for long runs of same value
			elsif digitizer = ERO or digitizer = MURO then
				if raw_random_valid = '1' then
					if raw_random_number = value then
						counter <= counter + 1;
					else
						counter <= (others => '0');
						value <= raw_random_number;
					end if;
				end if;

			-- For COSO reset the counter each time there is a valid RRN
			elsif digitizer = COSO then
				if raw_random_valid = '1' then
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if;

			-- If no valid digitizer is set the counter highest value to trig the event
			else
				counter <= (others => '1');
			end if;
		end if;
	end process;

	-- Trig the failure detected event when counter GT threshold
	process (clk, reset)
	begin
		if reset = '1' then
			detected <= '0';
		elsif rising_edge(clk) then
			if counter >= threshold then
				detected <= '1';
			end if;
		end if;
	end process;

end architecture;
