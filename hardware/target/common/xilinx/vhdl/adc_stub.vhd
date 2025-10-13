library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc is
	port
	(
		daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
		den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
		di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
		dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
		do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
		drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
		dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
		reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
		busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
		channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
		eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
		eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
		alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
		vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
		vn_in           : in  STD_LOGIC
	);
end entity;

architecture xilinx of adc is
begin

end architecture;
