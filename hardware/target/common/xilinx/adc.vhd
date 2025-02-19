library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

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
end;

architecture xilinx of adc is

	signal FLOAT_VCCAUX_ALARM : std_logic;
	signal FLOAT_VCCINT_ALARM : std_logic;
	signal FLOAT_USER_TEMP_ALARM : std_logic;
	signal FLOAT_VBRAM_ALARM : std_logic;
	signal FLOAT_MUXADDR : std_logic_vector (4 downto 0);
	signal aux_channel_p : std_logic_vector (15 downto 0);
	signal aux_channel_n : std_logic_vector (15 downto 0);
	signal alm_int : std_logic_vector (7 downto 0);

begin

	alarm_out <= alm_int(7);

	aux_channel_p(0) <= '0';
	aux_channel_n(0) <= '0';

	aux_channel_p(1) <= '0';
	aux_channel_n(1) <= '0';

	aux_channel_p(2) <= '0';
	aux_channel_n(2) <= '0';

	aux_channel_p(3) <= '0';
	aux_channel_n(3) <= '0';

	aux_channel_p(4) <= '0';
	aux_channel_n(4) <= '0';

	aux_channel_p(5) <= '0';
	aux_channel_n(5) <= '0';

	aux_channel_p(6) <= '0';
	aux_channel_n(6) <= '0';

	aux_channel_p(7) <= '0';
	aux_channel_n(7) <= '0';

	aux_channel_p(8) <= '0';
	aux_channel_n(8) <= '0';

	aux_channel_p(9) <= '0';
	aux_channel_n(9) <= '0';

	aux_channel_p(10) <= '0';
	aux_channel_n(10) <= '0';

	aux_channel_p(11) <= '0';
	aux_channel_n(11) <= '0';

	aux_channel_p(12) <= '0';
	aux_channel_n(12) <= '0';

	aux_channel_p(13) <= '0';
	aux_channel_n(13) <= '0';

	aux_channel_p(14) <= '0';
	aux_channel_n(14) <= '0';

	aux_channel_p(15) <= '0';
	aux_channel_n(15) <= '0';

	U0 : XADC
	generic map(
		INIT_40 => X"0000", -- config reg 0
		INIT_41 => X"01AF", -- config reg 1
		INIT_42 => X"0400", -- config reg 2
		INIT_48 => X"0300", -- Sequencer channel selection
		INIT_49 => X"0000", -- Sequencer channel selection
		INIT_4A => X"0000", -- Sequencer Average selection
		INIT_4B => X"0000", -- Sequencer Average selection
		INIT_4C => X"0000", -- Sequencer Bipolar selection
		INIT_4D => X"0000", -- Sequencer Bipolar selection
		INIT_4E => X"0000", -- Sequencer Acq time selection
		INIT_4F => X"0000", -- Sequencer Acq time selection
		INIT_50 => X"B5ED", -- Temp alarm trigger
		INIT_51 => X"57E4", -- Vccint upper alarm limit
		INIT_52 => X"A147", -- Vccaux upper alarm limit
		INIT_53 => X"CA33",  -- Temp alarm OT upper
		INIT_54 => X"A93A", -- Temp alarm reset
		INIT_55 => X"52C6", -- Vccint lower alarm limit
		INIT_56 => X"9555", -- Vccaux lower alarm limit
		INIT_57 => X"AE4E",  -- Temp alarm OT reset
		INIT_58 => X"5999",  -- Vccbram upper alarm limit
		INIT_5C => X"5111",  -- Vccbram lower alarm limit
		SIM_DEVICE => "7SERIES"
	)

	port map (
		CONVST              => '0',
		CONVSTCLK           => '0',
		DADDR(6 downto 0)   => daddr_in(6 downto 0),
		DCLK                => dclk_in,
		DEN                 => den_in,
		DI(15 downto 0)     => di_in(15 downto 0),
		DWE                 => dwe_in,
		RESET               => reset_in,
		VAUXN(15 downto 0)  => aux_channel_n(15 downto 0),
		VAUXP(15 downto 0)  => aux_channel_p(15 downto 0),
		ALM                 => alm_int,
		BUSY                => busy_out,
		CHANNEL(4 downto 0) => channel_out(4 downto 0),
		DO(15 downto 0)     => do_out(15 downto 0),
		DRDY                => drdy_out,
		EOC                 => eoc_out,
		EOS                 => eos_out,
		JTAGBUSY            => open,
		JTAGLOCKED          => open,
		JTAGMODIFIED        => open,
		OT                  => open,
		MUXADDR             => FLOAT_MUXADDR,
		VN                  => vn_in,
		VP                  => vp_in
	);

end;

