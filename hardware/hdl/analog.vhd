library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library opentrng;

-- Read analog temperature and voltage from an ADC (many FPGA have internal sensors).
entity analog is
	port (
		-- Reference clock
		clk: in std_logic;
		-- Asynchronous reset
		reset: in std_logic;
		-- Enable continuous measurements
		enable: in std_logic;
		-- Temperature output
		temperature: out std_logic_vector (11 downto 0);
		-- Voltage output
		voltage: out std_logic_vector (11 downto 0)
	);
end entity;

-- RTL architecture for reading temperature and voltage from ADC.
architecture rtl of analog is

	signal den: std_logic;
	signal drdy: std_logic;
	signal channel: std_logic_vector (4 downto 0);
	signal eoc: std_logic;
	signal do: std_logic_vector (15 downto 0);

begin

	-- State machine to manage the measurement operation
	process (clk, reset)
	begin
		if reset = '1' then
			den <= '0';
			temperature <= (others => '0');
			voltage <= (others => '0');
		elsif rising_edge(clk) then
			if enable = '1' then
				den <= eoc;
				if drdy = '1' then
					if channel = 0 then
						temperature <= do(15 downto 4);
					elsif channel = 1 then
						voltage <= do(15 downto 4);
					end if;
				end if;
			else
				den <= '0';
				temperature <= (others => '0');
				voltage <= (others => '0');
			end if;
		end if;
	end process;

	-- Instantiate the ADC for temperature and voltage measurements
	adc: entity opentrng.adc
	port map (
		dclk_in => clk,
		reset_in => reset,
		den_in => den,
		daddr_in => "00" & channel,
		di_in => (others => '0'),
		dwe_in => '0',
		drdy_out => drdy,
		channel_out => channel,
		eoc_out => eoc,
		do_out => do,
		vp_in => '1',
		vn_in => '0'
	);

end architecture;
