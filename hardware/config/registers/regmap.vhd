


-- Created with Corsair v1.0.4
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regmap is
generic(
    ADDR_W : integer := 16;
    DATA_W : integer := 32;
    STRB_W : integer := 4
);
port(
    clk    : in std_logic;
    rst    : in std_logic;
    -- ID.UID
    -- ID.REV

    -- CONTROL.RESET
    csr_control_reset_out : out std_logic;
    -- CONTROL.CONDITIONING
    csr_control_conditioning_out : out std_logic;

    -- RING.EN
    csr_ring_en_out : out std_logic_vector(31 downto 0);

    -- FREQCTRL.EN
    csr_freqctrl_en_out : out std_logic;
    -- FREQCTRL.START
    csr_freqctrl_start_out : out std_logic;
    -- FREQCTRL.DONE
    csr_freqctrl_done_in : in std_logic;
    -- FREQCTRL.SELECT
    csr_freqctrl_select_out : out std_logic_vector(4 downto 0);
    -- FREQCTRL.OVERFLOW
    csr_freqctrl_overflow_in : in std_logic;

    -- FREQVALUE.VALUE
    csr_freqvalue_value_in : in std_logic_vector(31 downto 0);

    -- FREQDIVIDER.VALUE
    csr_freqdivider_value_waccess : out std_logic;
    csr_freqdivider_value_out : out std_logic_vector(31 downto 0);

    -- MONITORING.ALARM
    csr_monitoring_alarm_in : in std_logic;
    -- MONITORING.VALID
    csr_monitoring_valid_in : in std_logic;
    -- MONITORING.CLEAR
    csr_monitoring_clear_out : out std_logic;

    -- ALARM.THRESHOLD
    csr_alarm_threshold_out : out std_logic_vector(31 downto 0);

    -- ONLINETEST.AVERAGE
    csr_onlinetest_average_out : out std_logic_vector(15 downto 0);
    -- ONLINETEST.DEVIATION
    csr_onlinetest_deviation_out : out std_logic_vector(15 downto 0);

    -- FIFOCTRL.CLEAR
    csr_fifoctrl_clear_out : out std_logic;
    -- FIFOCTRL.NOPACKING
    csr_fifoctrl_nopacking_out : out std_logic;
    -- FIFOCTRL.EMPTY
    csr_fifoctrl_empty_in : in std_logic;
    -- FIFOCTRL.FULL
    csr_fifoctrl_full_in : in std_logic;
    -- FIFOCTRL.ALMOSTEMPTY
    csr_fifoctrl_almostempty_in : in std_logic;
    -- FIFOCTRL.ALMOSTFULL
    csr_fifoctrl_almostfull_in : in std_logic;
    -- FIFOCTRL.RDBURSTAVAILABLE
    csr_fifoctrl_rdburstavailable_in : in std_logic;
    -- FIFOCTRL.BURSTSIZE
    csr_fifoctrl_burstsize_in : in std_logic_vector(15 downto 0);

    -- FIFODATA.DATA
    csr_fifodata_data_rvalid : in std_logic;
    csr_fifodata_data_ren : out std_logic;
    csr_fifodata_data_in : in std_logic_vector(31 downto 0);

    -- Local Bus
    waddr  : in  std_logic_vector(ADDR_W-1 downto 0);
    wdata  : in  std_logic_vector(DATA_W-1 downto 0);
    wen    : in  std_logic;
    wstrb  : in  std_logic_vector(STRB_W-1 downto 0);
    wready : out std_logic;
    raddr  : in  std_logic_vector(ADDR_W-1 downto 0);
    ren    : in  std_logic;
    rdata  : out std_logic_vector(DATA_W-1 downto 0);
    rvalid : out std_logic
);
end entity;

architecture rtl of regmap is

signal csr_id_rdata : std_logic_vector(31 downto 0);
signal csr_id_ren : std_logic;
signal csr_id_ren_ff : std_logic;
signal csr_id_uid_ff : std_logic_vector(15 downto 0);
signal csr_id_rev_ff : std_logic_vector(15 downto 0);

signal csr_control_rdata : std_logic_vector(31 downto 0);
signal csr_control_wen : std_logic;
signal csr_control_ren : std_logic;
signal csr_control_ren_ff : std_logic;
signal csr_control_reset_ff : std_logic;
signal csr_control_conditioning_ff : std_logic;

signal csr_ring_rdata : std_logic_vector(31 downto 0);
signal csr_ring_wen : std_logic;
signal csr_ring_ren : std_logic;
signal csr_ring_ren_ff : std_logic;
signal csr_ring_en_ff : std_logic_vector(31 downto 0);

signal csr_freqctrl_rdata : std_logic_vector(31 downto 0);
signal csr_freqctrl_wen : std_logic;
signal csr_freqctrl_ren : std_logic;
signal csr_freqctrl_ren_ff : std_logic;
signal csr_freqctrl_en_ff : std_logic;
signal csr_freqctrl_start_ff : std_logic;
signal csr_freqctrl_done_ff : std_logic;
signal csr_freqctrl_select_ff : std_logic_vector(4 downto 0);
signal csr_freqctrl_overflow_ff : std_logic;

signal csr_freqvalue_rdata : std_logic_vector(31 downto 0);
signal csr_freqvalue_ren : std_logic;
signal csr_freqvalue_ren_ff : std_logic;
signal csr_freqvalue_value_ff : std_logic_vector(31 downto 0);

signal csr_freqdivider_rdata : std_logic_vector(31 downto 0);
signal csr_freqdivider_wen : std_logic;
signal csr_freqdivider_ren : std_logic;
signal csr_freqdivider_ren_ff : std_logic;
signal csr_freqdivider_value_ff : std_logic_vector(31 downto 0);

signal csr_monitoring_rdata : std_logic_vector(31 downto 0);
signal csr_monitoring_wen : std_logic;
signal csr_monitoring_ren : std_logic;
signal csr_monitoring_ren_ff : std_logic;
signal csr_monitoring_alarm_ff : std_logic;
signal csr_monitoring_valid_ff : std_logic;
signal csr_monitoring_clear_ff : std_logic;

signal csr_alarm_rdata : std_logic_vector(31 downto 0);
signal csr_alarm_wen : std_logic;
signal csr_alarm_ren : std_logic;
signal csr_alarm_ren_ff : std_logic;
signal csr_alarm_threshold_ff : std_logic_vector(31 downto 0);

signal csr_onlinetest_rdata : std_logic_vector(31 downto 0);
signal csr_onlinetest_wen : std_logic;
signal csr_onlinetest_ren : std_logic;
signal csr_onlinetest_ren_ff : std_logic;
signal csr_onlinetest_average_ff : std_logic_vector(15 downto 0);
signal csr_onlinetest_deviation_ff : std_logic_vector(15 downto 0);

signal csr_fifoctrl_rdata : std_logic_vector(31 downto 0);
signal csr_fifoctrl_wen : std_logic;
signal csr_fifoctrl_ren : std_logic;
signal csr_fifoctrl_ren_ff : std_logic;
signal csr_fifoctrl_clear_ff : std_logic;
signal csr_fifoctrl_nopacking_ff : std_logic;
signal csr_fifoctrl_empty_ff : std_logic;
signal csr_fifoctrl_full_ff : std_logic;
signal csr_fifoctrl_almostempty_ff : std_logic;
signal csr_fifoctrl_almostfull_ff : std_logic;
signal csr_fifoctrl_rdburstavailable_ff : std_logic;
signal csr_fifoctrl_burstsize_ff : std_logic_vector(15 downto 0);

signal csr_fifodata_rdata : std_logic_vector(31 downto 0);
signal csr_fifodata_ren : std_logic;
signal csr_fifodata_ren_ff : std_logic;
signal csr_fifodata_data_ff : std_logic_vector(31 downto 0);
signal csr_fifodata_data_rvalid_ff : std_logic;

signal rvalid_drv : std_logic;
signal rdata_ff : std_logic_vector(31 downto 0);
signal rvalid_ff : std_logic;
begin

--------------------------------------------------------------------------------
-- CSR:
-- [0x0] - ID - OpenTRNG's PTRNG identification register for UID and revision number.
--------------------------------------------------------------------------------


csr_id_ren <= ren when (raddr = std_logic_vector(to_unsigned(0, ADDR_W))) else '0'; -- 0x0
process (clk, rst) begin
if (rst = '1') then
    csr_id_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_id_ren_ff <= csr_id_ren;
end if;
end process;

-----------------------
-- Bit field:
-- ID(15 downto 0) - UID - Unique ID for OpenTRNG's PTRNG
-- access: ro, hardware: f
-----------------------

csr_id_rdata(15 downto 0) <= csr_id_uid_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_id_uid_ff <= "1100111010100011"; -- 0xcea3
elsif rising_edge(clk) then
        
            csr_id_uid_ff <= csr_id_uid_ff;
end if;
end process;



-----------------------
-- Bit field:
-- ID(31 downto 16) - REV - Revision number
-- access: ro, hardware: f
-----------------------

csr_id_rdata(31 downto 16) <= csr_id_rev_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_id_rev_ff <= "0000000000000001"; -- 0x1
elsif rising_edge(clk) then
        
            csr_id_rev_ff <= csr_id_rev_ff;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x4] - CONTROL - Global control register for the OpenTRNG's PTRNG
--------------------------------------------------------------------------------
csr_control_rdata(31 downto 2) <= (others => '0');

csr_control_wen <= wen when (waddr = std_logic_vector(to_unsigned(4, ADDR_W))) else '0'; -- 0x4

csr_control_ren <= ren when (raddr = std_logic_vector(to_unsigned(4, ADDR_W))) else '0'; -- 0x4
process (clk, rst) begin
if (rst = '1') then
    csr_control_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_control_ren_ff <= csr_control_ren;
end if;
end process;

-----------------------
-- Bit field:
-- CONTROL(0) - RESET - Synchronous reset active to '1'
-- access: wosc, hardware: o
-----------------------

csr_control_rdata(0) <= '0';

csr_control_reset_out <= csr_control_reset_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_control_reset_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_control_wen = '1') then
            if (wstrb(0) = '1') then
                csr_control_reset_ff <= wdata(0);
            end if;
        else
            csr_control_reset_ff <= '0';
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- CONTROL(1) - CONDITIONING - Enable or disable the algorithmic post processing to convert RRN to IRN active to '1', bypass at '0'
-- access: rw, hardware: o
-----------------------

csr_control_rdata(1) <= csr_control_conditioning_ff;

csr_control_conditioning_out <= csr_control_conditioning_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_control_conditioning_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_control_wen = '1') then
            if (wstrb(0) = '1') then
                csr_control_conditioning_ff <= wdata(1);
            end if;
        else
            csr_control_conditioning_ff <= csr_control_conditioning_ff;
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x8] - RING - Ring-oscillator enable register (enable bits are active at '1')
--------------------------------------------------------------------------------

csr_ring_wen <= wen when (waddr = std_logic_vector(to_unsigned(8, ADDR_W))) else '0'; -- 0x8

csr_ring_ren <= ren when (raddr = std_logic_vector(to_unsigned(8, ADDR_W))) else '0'; -- 0x8
process (clk, rst) begin
if (rst = '1') then
    csr_ring_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_ring_ren_ff <= csr_ring_ren;
end if;
end process;

-----------------------
-- Bit field:
-- RING(31 downto 0) - EN - The bit at index _i_ in the bitfield enables the RO number _i_
-- access: rw, hardware: o
-----------------------

csr_ring_rdata(31 downto 0) <= csr_ring_en_ff;

csr_ring_en_out <= csr_ring_en_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_ring_en_ff <= "00000000000000000000000000000000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_ring_wen = '1') then
            if (wstrb(0) = '1') then
                csr_ring_en_ff(7 downto 0) <= wdata(7 downto 0);
            end if;
            if (wstrb(1) = '1') then
                csr_ring_en_ff(15 downto 8) <= wdata(15 downto 8);
            end if;
            if (wstrb(2) = '1') then
                csr_ring_en_ff(23 downto 16) <= wdata(23 downto 16);
            end if;
            if (wstrb(3) = '1') then
                csr_ring_en_ff(31 downto 24) <= wdata(31 downto 24);
            end if;
        else
            csr_ring_en_ff <= csr_ring_en_ff;
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0xc] - FREQCTRL - Frequency counter control register
--------------------------------------------------------------------------------
csr_freqctrl_rdata(30 downto 8) <= (others => '0');

csr_freqctrl_wen <= wen when (waddr = std_logic_vector(to_unsigned(12, ADDR_W))) else '0'; -- 0xc

csr_freqctrl_ren <= ren when (raddr = std_logic_vector(to_unsigned(12, ADDR_W))) else '0'; -- 0xc
process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_freqctrl_ren_ff <= csr_freqctrl_ren;
end if;
end process;

-----------------------
-- Bit field:
-- FREQCTRL(0) - EN - Enable the frequency counter (active at '1')
-- access: rw, hardware: o
-----------------------

csr_freqctrl_rdata(0) <= csr_freqctrl_en_ff;

csr_freqctrl_en_out <= csr_freqctrl_en_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_en_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_freqctrl_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqctrl_en_ff <= wdata(0);
            end if;
        else
            csr_freqctrl_en_ff <= csr_freqctrl_en_ff;
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCTRL(1) - START - Write '1' to start the frequency counter measure
-- access: wosc, hardware: o
-----------------------

csr_freqctrl_rdata(1) <= '0';

csr_freqctrl_start_out <= csr_freqctrl_start_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_start_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_freqctrl_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqctrl_start_ff <= wdata(1);
            end if;
        else
            csr_freqctrl_start_ff <= '0';
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCTRL(2) - DONE - This field is set to '1' when the measure is done and ready to be read
-- access: ro, hardware: i
-----------------------

csr_freqctrl_rdata(2) <= csr_freqctrl_done_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_done_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_freqctrl_done_ff <= csr_freqctrl_done_in;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCTRL(7 downto 3) - SELECT - Select the index of the ring-oscillator for frequency measurement
-- access: rw, hardware: o
-----------------------

csr_freqctrl_rdata(7 downto 3) <= csr_freqctrl_select_ff;

csr_freqctrl_select_out <= csr_freqctrl_select_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_select_ff <= "00000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_freqctrl_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqctrl_select_ff(4 downto 0) <= wdata(7 downto 3);
            end if;
        else
            csr_freqctrl_select_ff <= csr_freqctrl_select_ff;
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCTRL(31) - OVERFLOW - Flag set to '1' if an overflow occurred during measurement
-- access: ro, hardware: i
-----------------------

csr_freqctrl_rdata(31) <= csr_freqctrl_overflow_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_freqctrl_overflow_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_freqctrl_overflow_ff <= csr_freqctrl_overflow_in;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x10] - FREQVALUE - Frequency counter register for reading the measured value
--------------------------------------------------------------------------------


csr_freqvalue_ren <= ren when (raddr = std_logic_vector(to_unsigned(16, ADDR_W))) else '0'; -- 0x10
process (clk, rst) begin
if (rst = '1') then
    csr_freqvalue_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_freqvalue_ren_ff <= csr_freqvalue_ren;
end if;
end process;

-----------------------
-- Bit field:
-- FREQVALUE(31 downto 0) - VALUE - Measured value (unit in cycles of the system clock)
-- access: ro, hardware: i
-----------------------

csr_freqvalue_rdata(31 downto 0) <= csr_freqvalue_value_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_freqvalue_value_ff <= "00000000000000000000000000000000"; -- 0x0
elsif rising_edge(clk) then
            csr_freqvalue_value_ff <= csr_freqvalue_value_in;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x14] - FREQDIVIDER - Clock divider register, applies on oscillator RO0
--------------------------------------------------------------------------------

csr_freqdivider_wen <= wen when (waddr = std_logic_vector(to_unsigned(20, ADDR_W))) else '0'; -- 0x14

csr_freqdivider_ren <= ren when (raddr = std_logic_vector(to_unsigned(20, ADDR_W))) else '0'; -- 0x14
process (clk, rst) begin
if (rst = '1') then
    csr_freqdivider_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_freqdivider_ren_ff <= csr_freqdivider_ren;
end if;
end process;

-----------------------
-- Bit field:
-- FREQDIVIDER(31 downto 0) - VALUE - Clock divider value (1 means no division, 2 division by two, ...)
-- access: rw, hardware: oa
-----------------------
csr_freqdivider_value_waccess <= wready and csr_freqdivider_wen;

csr_freqdivider_rdata(31 downto 0) <= csr_freqdivider_value_ff;

csr_freqdivider_value_out <= csr_freqdivider_value_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_freqdivider_value_ff <= "00000000000000000000000000000000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_freqdivider_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqdivider_value_ff(7 downto 0) <= wdata(7 downto 0);
            end if;
            if (wstrb(1) = '1') then
                csr_freqdivider_value_ff(15 downto 8) <= wdata(15 downto 8);
            end if;
            if (wstrb(2) = '1') then
                csr_freqdivider_value_ff(23 downto 16) <= wdata(23 downto 16);
            end if;
            if (wstrb(3) = '1') then
                csr_freqdivider_value_ff(31 downto 24) <= wdata(31 downto 24);
            end if;
        else
            csr_freqdivider_value_ff <= csr_freqdivider_value_ff;
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x18] - MONITORING - Register for monitoring the total failure alarm and the online tests
--------------------------------------------------------------------------------
csr_monitoring_rdata(31 downto 3) <= (others => '0');

csr_monitoring_wen <= wen when (waddr = std_logic_vector(to_unsigned(24, ADDR_W))) else '0'; -- 0x18

csr_monitoring_ren <= ren when (raddr = std_logic_vector(to_unsigned(24, ADDR_W))) else '0'; -- 0x18
process (clk, rst) begin
if (rst = '1') then
    csr_monitoring_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_monitoring_ren_ff <= csr_monitoring_ren;
end if;
end process;

-----------------------
-- Bit field:
-- MONITORING(0) - ALARM - This signal is triggered to '1' in the event of a total failure alarm, the alarm is cleared on PTRNG reset only
-- access: roc, hardware: i
-----------------------

csr_monitoring_rdata(0) <= csr_monitoring_alarm_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_monitoring_alarm_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_monitoring_ren = '1' and csr_monitoring_ren_ff = '0') then
            csr_monitoring_alarm_ff <= '0';
            csr_monitoring_alarm_ff <= csr_monitoring_alarm_in;
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- MONITORING(1) - VALID - This signal is set to '1' when the online test is valid, when it falls to '0' (invalid) it must be manually cleared
-- access: ro, hardware: i
-----------------------

csr_monitoring_rdata(1) <= csr_monitoring_valid_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_monitoring_valid_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_monitoring_valid_ff <= csr_monitoring_valid_in;
end if;
end process;



-----------------------
-- Bit field:
-- MONITORING(2) - CLEAR - This signal clears the online test to set the 'valid' signal back to '1'
-- access: wosc, hardware: o
-----------------------

csr_monitoring_rdata(2) <= '0';

csr_monitoring_clear_out <= csr_monitoring_clear_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_monitoring_clear_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_monitoring_wen = '1') then
            if (wstrb(0) = '1') then
                csr_monitoring_clear_ff <= wdata(2);
            end if;
        else
            csr_monitoring_clear_ff <= '0';
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x1c] - ALARM - Register for configuring the total failure alarm
--------------------------------------------------------------------------------

csr_alarm_wen <= wen when (waddr = std_logic_vector(to_unsigned(28, ADDR_W))) else '0'; -- 0x1c

csr_alarm_ren <= ren when (raddr = std_logic_vector(to_unsigned(28, ADDR_W))) else '0'; -- 0x1c
process (clk, rst) begin
if (rst = '1') then
    csr_alarm_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_alarm_ren_ff <= csr_alarm_ren;
end if;
end process;

-----------------------
-- Bit field:
-- ALARM(31 downto 0) - THRESHOLD - Threshold value for triggering the total failure alarm. The threshold is compared to a counter and the alarm is triggered when the counter becomes greater or equal than the threshold. The counting method depends on the digitizer type (ERO, MURO, COSO...)
-- access: rw, hardware: o
-----------------------

csr_alarm_rdata(31 downto 0) <= csr_alarm_threshold_ff;

csr_alarm_threshold_out <= csr_alarm_threshold_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_alarm_threshold_ff <= "00000000000000000000000000000000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_alarm_wen = '1') then
            if (wstrb(0) = '1') then
                csr_alarm_threshold_ff(7 downto 0) <= wdata(7 downto 0);
            end if;
            if (wstrb(1) = '1') then
                csr_alarm_threshold_ff(15 downto 8) <= wdata(15 downto 8);
            end if;
            if (wstrb(2) = '1') then
                csr_alarm_threshold_ff(23 downto 16) <= wdata(23 downto 16);
            end if;
            if (wstrb(3) = '1') then
                csr_alarm_threshold_ff(31 downto 24) <= wdata(31 downto 24);
            end if;
        else
            csr_alarm_threshold_ff <= csr_alarm_threshold_ff;
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x20] - ONLINETEST - Register for configuring the online test
--------------------------------------------------------------------------------

csr_onlinetest_wen <= wen when (waddr = std_logic_vector(to_unsigned(32, ADDR_W))) else '0'; -- 0x20

csr_onlinetest_ren <= ren when (raddr = std_logic_vector(to_unsigned(32, ADDR_W))) else '0'; -- 0x20
process (clk, rst) begin
if (rst = '1') then
    csr_onlinetest_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_onlinetest_ren_ff <= csr_onlinetest_ren;
end if;
end process;

-----------------------
-- Bit field:
-- ONLINETEST(15 downto 0) - AVERAGE - Average expected value for the online test internal value
-- access: rw, hardware: o
-----------------------

csr_onlinetest_rdata(15 downto 0) <= csr_onlinetest_average_ff;

csr_onlinetest_average_out <= csr_onlinetest_average_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_onlinetest_average_ff <= "0000000000000000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_onlinetest_wen = '1') then
            if (wstrb(0) = '1') then
                csr_onlinetest_average_ff(7 downto 0) <= wdata(7 downto 0);
            end if;
            if (wstrb(1) = '1') then
                csr_onlinetest_average_ff(15 downto 8) <= wdata(15 downto 8);
            end if;
        else
            csr_onlinetest_average_ff <= csr_onlinetest_average_ff;
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- ONLINETEST(31 downto 16) - DEVIATION - Maximum difference between the average expected value and the current internal value for the online test
-- access: rw, hardware: o
-----------------------

csr_onlinetest_rdata(31 downto 16) <= csr_onlinetest_deviation_ff;

csr_onlinetest_deviation_out <= csr_onlinetest_deviation_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_onlinetest_deviation_ff <= "0000000000000000"; -- 0x0
elsif rising_edge(clk) then
        if (csr_onlinetest_wen = '1') then
            if (wstrb(2) = '1') then
                csr_onlinetest_deviation_ff(7 downto 0) <= wdata(23 downto 16);
            end if;
            if (wstrb(3) = '1') then
                csr_onlinetest_deviation_ff(15 downto 8) <= wdata(31 downto 24);
            end if;
        else
            csr_onlinetest_deviation_ff <= csr_onlinetest_deviation_ff;
        end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x24] - FIFOCTRL - Control register for the FIFO, into read the PTRNG random data output
--------------------------------------------------------------------------------
csr_fifoctrl_rdata(31 downto 23) <= (others => '0');

csr_fifoctrl_wen <= wen when (waddr = std_logic_vector(to_unsigned(36, ADDR_W))) else '0'; -- 0x24

csr_fifoctrl_ren <= ren when (raddr = std_logic_vector(to_unsigned(36, ADDR_W))) else '0'; -- 0x24
process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_fifoctrl_ren_ff <= csr_fifoctrl_ren;
end if;
end process;

-----------------------
-- Bit field:
-- FIFOCTRL(0) - CLEAR - Clear the FIFO
-- access: wosc, hardware: o
-----------------------

csr_fifoctrl_rdata(0) <= '0';

csr_fifoctrl_clear_out <= csr_fifoctrl_clear_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_clear_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_fifoctrl_wen = '1') then
            if (wstrb(0) = '1') then
                csr_fifoctrl_clear_ff <= wdata(0);
            end if;
        else
            csr_fifoctrl_clear_ff <= '0';
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(1) - NOPACKING - When packing is disabled IRN as written as 32-bit words in the FIFO instead of packing their LSB into 32-bit words
-- access: rw, hardware: o
-----------------------

csr_fifoctrl_rdata(1) <= csr_fifoctrl_nopacking_ff;

csr_fifoctrl_nopacking_out <= csr_fifoctrl_nopacking_ff;

process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_nopacking_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        if (csr_fifoctrl_wen = '1') then
            if (wstrb(0) = '1') then
                csr_fifoctrl_nopacking_ff <= wdata(1);
            end if;
        else
            csr_fifoctrl_nopacking_ff <= csr_fifoctrl_nopacking_ff;
        end if;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(2) - EMPTY - Empty flag
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(2) <= csr_fifoctrl_empty_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_empty_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_empty_ff <= csr_fifoctrl_empty_in;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(3) - FULL - Full flag
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(3) <= csr_fifoctrl_full_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_full_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_full_ff <= csr_fifoctrl_full_in;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(4) - ALMOSTEMPTY - Almost empty flag
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(4) <= csr_fifoctrl_almostempty_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_almostempty_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_almostempty_ff <= csr_fifoctrl_almostempty_in;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(5) - ALMOSTFULL - Almost full flag
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(5) <= csr_fifoctrl_almostfull_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_almostfull_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_almostfull_ff <= csr_fifoctrl_almostfull_in;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(6) - RDBURSTAVAILABLE - Valid to '1' when a burst is available for read (see BURSTSIZE)
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(6) <= csr_fifoctrl_rdburstavailable_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_rdburstavailable_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_rdburstavailable_ff <= csr_fifoctrl_rdburstavailable_in;
end if;
end process;



-----------------------
-- Bit field:
-- FIFOCTRL(22 downto 7) - BURSTSIZE - Size of a burst (in count of 32bit words)
-- access: ro, hardware: i
-----------------------

csr_fifoctrl_rdata(22 downto 7) <= csr_fifoctrl_burstsize_ff;


process (clk, rst) begin
if (rst = '1') then
    csr_fifoctrl_burstsize_ff <= "0000000000000000"; -- 0x0
elsif rising_edge(clk) then
            csr_fifoctrl_burstsize_ff <= csr_fifoctrl_burstsize_in;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x28] - FIFODATA - Data register for the FIFO to read the PTRNG random data output
--------------------------------------------------------------------------------


csr_fifodata_ren <= ren when (raddr = std_logic_vector(to_unsigned(40, ADDR_W))) else '0'; -- 0x28
process (clk, rst) begin
if (rst = '1') then
    csr_fifodata_ren_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_fifodata_ren_ff <= csr_fifodata_ren;
end if;
end process;

-----------------------
-- Bit field:
-- FIFODATA(31 downto 0) - DATA - 32 bits word from the PTRNG
-- access: ro, hardware: q
-----------------------

csr_fifodata_rdata(31 downto 0) <= csr_fifodata_data_in;

csr_fifodata_data_ren <= csr_fifodata_ren and (not csr_fifodata_ren_ff);

process (clk, rst) begin
if (rst = '1') then
    csr_fifodata_data_ff <= "00000000000000000000000000000000"; -- 0x0
elsif rising_edge(clk) then
        
            csr_fifodata_data_ff <= csr_fifodata_data_ff;
end if;
end process;


process (clk, rst) begin
if (rst = '1') then
    csr_fifodata_data_rvalid_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
        csr_fifodata_data_rvalid_ff <= csr_fifodata_data_rvalid;
end if;
end process;


--------------------------------------------------------------------------------
-- Write ready
--------------------------------------------------------------------------------
wready <= '1';

--------------------------------------------------------------------------------
-- Read address decoder
--------------------------------------------------------------------------------
process (clk, rst) begin
if (rst = '1') then
    rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
elsif rising_edge(clk) then
    if (ren = '1') then
        if raddr = std_logic_vector(to_unsigned(0, ADDR_W)) then -- 0x0
            rdata_ff <= csr_id_rdata;
        elsif raddr = std_logic_vector(to_unsigned(4, ADDR_W)) then -- 0x4
            rdata_ff <= csr_control_rdata;
        elsif raddr = std_logic_vector(to_unsigned(8, ADDR_W)) then -- 0x8
            rdata_ff <= csr_ring_rdata;
        elsif raddr = std_logic_vector(to_unsigned(12, ADDR_W)) then -- 0xc
            rdata_ff <= csr_freqctrl_rdata;
        elsif raddr = std_logic_vector(to_unsigned(16, ADDR_W)) then -- 0x10
            rdata_ff <= csr_freqvalue_rdata;
        elsif raddr = std_logic_vector(to_unsigned(20, ADDR_W)) then -- 0x14
            rdata_ff <= csr_freqdivider_rdata;
        elsif raddr = std_logic_vector(to_unsigned(24, ADDR_W)) then -- 0x18
            rdata_ff <= csr_monitoring_rdata;
        elsif raddr = std_logic_vector(to_unsigned(28, ADDR_W)) then -- 0x1c
            rdata_ff <= csr_alarm_rdata;
        elsif raddr = std_logic_vector(to_unsigned(32, ADDR_W)) then -- 0x20
            rdata_ff <= csr_onlinetest_rdata;
        elsif raddr = std_logic_vector(to_unsigned(36, ADDR_W)) then -- 0x24
            rdata_ff <= csr_fifoctrl_rdata;
        elsif raddr = std_logic_vector(to_unsigned(40, ADDR_W)) then -- 0x28
            rdata_ff <= csr_fifodata_rdata;
        else 
            rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
        end if;
    else
        rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
    end if;
end if;
end process;

rdata <= rdata_ff;

--------------------------------------------------------------------------------
-- Read data valid
--------------------------------------------------------------------------------
process (clk, rst) begin
if (rst = '1') then
    rvalid_ff <= '0'; -- 0x0
elsif rising_edge(clk) then
    if ((ren = '1') and (rvalid = '1')) then
        rvalid_ff <= '0';
    elsif (ren = '1') then
        rvalid_ff <= '1';
    end if;
end if;
end process;


rvalid_drv <=
    csr_fifodata_data_rvalid_ff when (csr_fifodata_ren_ff = '1') else
    rvalid_ff;

rvalid <= rvalid_drv;

end architecture;