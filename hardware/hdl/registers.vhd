


-- Created with Corsair v1.0.4
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
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

    -- GLOBAL.RESET
    csr_global_reset_out : out std_logic;

    -- RING.ENABLE
    csr_ring_enable_out : out std_logic_vector(31 downto 0);

    -- FREQCOUNT.EN
    csr_freqcount_en_out : out std_logic;
    -- FREQCOUNT.START
    csr_freqcount_start_out : out std_logic;
    -- FREQCOUNT.DONE
    csr_freqcount_done_in : in std_logic;
    -- FREQCOUNT.SELECT
    csr_freqcount_select_out : out std_logic_vector(4 downto 0);
    -- FREQCOUNT.RESULT
    csr_freqcount_result_in : in std_logic_vector(23 downto 0);

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

architecture rtl of registers is

signal csr_id_rdata : std_logic_vector(31 downto 0);
signal csr_id_ren : std_logic;
signal csr_id_ren_ff : std_logic;
signal csr_id_uid_ff : std_logic_vector(15 downto 0);
signal csr_id_rev_ff : std_logic_vector(15 downto 0);

signal csr_global_rdata : std_logic_vector(31 downto 0);
signal csr_global_wen : std_logic;
signal csr_global_reset_ff : std_logic;

signal csr_ring_rdata : std_logic_vector(31 downto 0);
signal csr_ring_wen : std_logic;
signal csr_ring_ren : std_logic;
signal csr_ring_ren_ff : std_logic;
signal csr_ring_enable_ff : std_logic_vector(31 downto 0);

signal csr_freqcount_rdata : std_logic_vector(31 downto 0);
signal csr_freqcount_wen : std_logic;
signal csr_freqcount_ren : std_logic;
signal csr_freqcount_ren_ff : std_logic;
signal csr_freqcount_en_ff : std_logic;
signal csr_freqcount_start_ff : std_logic;
signal csr_freqcount_done_ff : std_logic;
signal csr_freqcount_select_ff : std_logic_vector(4 downto 0);
signal csr_freqcount_result_ff : std_logic_vector(23 downto 0);

signal rdata_ff : std_logic_vector(31 downto 0);
signal rvalid_ff : std_logic;
begin

--------------------------------------------------------------------------------
-- CSR:
-- [0x0] - ID - Entropy source identification register for UID and revision number.
--------------------------------------------------------------------------------


csr_id_ren <= ren when (raddr = std_logic_vector(to_unsigned(0, ADDR_W))) else '0'; -- 0x0
process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_id_ren_ff <= '0'; -- 0x0
else
        csr_id_ren_ff <= csr_id_ren;
end if;
end if;
end process;

-----------------------
-- Bit field:
-- ID(15 downto 0) - UID - Unique ID for OpenTRNG entropy source
-- access: ro, hardware: f
-----------------------

csr_id_rdata(15 downto 0) <= csr_id_uid_ff;


process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_id_uid_ff <= "1100111010100011"; -- 0xcea3
else
        
            csr_id_uid_ff <= csr_id_uid_ff;
end if;
end if;
end process;



-----------------------
-- Bit field:
-- ID(31 downto 16) - REV - Revision number
-- access: ro, hardware: f
-----------------------

csr_id_rdata(31 downto 16) <= csr_id_rev_ff;


process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_id_rev_ff <= "0000000000000001"; -- 0x1
else
        
            csr_id_rev_ff <= csr_id_rev_ff;
end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x4] - GLOBAL - Global control register for the entropy source
--------------------------------------------------------------------------------
csr_global_rdata(31 downto 1) <= (others => '0');

csr_global_wen <= wen when (waddr = std_logic_vector(to_unsigned(4, ADDR_W))) else '0'; -- 0x4

-----------------------
-- Bit field:
-- GLOBAL(0) - RESET - Synchronous reset active to `'1'`
-- access: wosc, hardware: o
-----------------------

csr_global_rdata(0) <= '0';

csr_global_reset_out <= csr_global_reset_ff;

process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_global_reset_ff <= '0'; -- 0x0
else
        if (csr_global_wen = '1') then
            if (wstrb(0) = '1') then
                csr_global_reset_ff <= wdata(0);
            end if;
        else
            csr_global_reset_ff <= '0';
        end if;
end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0x8] - RING - Ring-oscillator enable register (enable bits are active at `'1'`).
--------------------------------------------------------------------------------

csr_ring_wen <= wen when (waddr = std_logic_vector(to_unsigned(8, ADDR_W))) else '0'; -- 0x8

csr_ring_ren <= ren when (raddr = std_logic_vector(to_unsigned(8, ADDR_W))) else '0'; -- 0x8
process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_ring_ren_ff <= '0'; -- 0x0
else
        csr_ring_ren_ff <= csr_ring_ren;
end if;
end if;
end process;

-----------------------
-- Bit field:
-- RING(31 downto 0) - ENABLE - The bit at index _i_ in the bitfield enables the RO number _i_
-- access: rw, hardware: o
-----------------------

csr_ring_rdata(31 downto 0) <= csr_ring_enable_ff;

csr_ring_enable_out <= csr_ring_enable_ff;

process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_ring_enable_ff <= "00000000000000000000000000000000"; -- 0x0
else
        if (csr_ring_wen = '1') then
            if (wstrb(0) = '1') then
                csr_ring_enable_ff(7 downto 0) <= wdata(7 downto 0);
            end if;
            if (wstrb(1) = '1') then
                csr_ring_enable_ff(15 downto 8) <= wdata(15 downto 8);
            end if;
            if (wstrb(2) = '1') then
                csr_ring_enable_ff(23 downto 16) <= wdata(23 downto 16);
            end if;
            if (wstrb(3) = '1') then
                csr_ring_enable_ff(31 downto 24) <= wdata(31 downto 24);
            end if;
        else
            csr_ring_enable_ff <= csr_ring_enable_ff;
        end if;
end if;
end if;
end process;



--------------------------------------------------------------------------------
-- CSR:
-- [0xc] - FREQCOUNT - Frequency counter control register.
--------------------------------------------------------------------------------

csr_freqcount_wen <= wen when (waddr = std_logic_vector(to_unsigned(12, ADDR_W))) else '0'; -- 0xc

csr_freqcount_ren <= ren when (raddr = std_logic_vector(to_unsigned(12, ADDR_W))) else '0'; -- 0xc
process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_ren_ff <= '0'; -- 0x0
else
        csr_freqcount_ren_ff <= csr_freqcount_ren;
end if;
end if;
end process;

-----------------------
-- Bit field:
-- FREQCOUNT(0) - EN - Enable the frequency counter (active at `'1'`)
-- access: rw, hardware: o
-----------------------

csr_freqcount_rdata(0) <= csr_freqcount_en_ff;

csr_freqcount_en_out <= csr_freqcount_en_ff;

process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_en_ff <= '0'; -- 0x0
else
        if (csr_freqcount_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqcount_en_ff <= wdata(0);
            end if;
        else
            csr_freqcount_en_ff <= csr_freqcount_en_ff;
        end if;
end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCOUNT(1) - START - Write `'1'` to start the frequency counter measure
-- access: wosc, hardware: o
-----------------------

csr_freqcount_rdata(1) <= '0';

csr_freqcount_start_out <= csr_freqcount_start_ff;

process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_start_ff <= '0'; -- 0x0
else
        if (csr_freqcount_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqcount_start_ff <= wdata(1);
            end if;
        else
            csr_freqcount_start_ff <= '0';
        end if;
end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCOUNT(2) - DONE - This field is set to `'1'` when the measure is done and ready to be read
-- access: ro, hardware: i
-----------------------

csr_freqcount_rdata(2) <= csr_freqcount_done_ff;


process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_done_ff <= '0'; -- 0x0
else
            csr_freqcount_done_ff <= csr_freqcount_done_in;
end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCOUNT(7 downto 3) - SELECT - Select the index of the ring-oscillator for frequency measurement
-- access: rw, hardware: o
-----------------------

csr_freqcount_rdata(7 downto 3) <= csr_freqcount_select_ff;

csr_freqcount_select_out <= csr_freqcount_select_ff;

process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_select_ff <= "00000"; -- 0x0
else
        if (csr_freqcount_wen = '1') then
            if (wstrb(0) = '1') then
                csr_freqcount_select_ff(4 downto 0) <= wdata(7 downto 3);
            end if;
        else
            csr_freqcount_select_ff <= csr_freqcount_select_ff;
        end if;
end if;
end if;
end process;



-----------------------
-- Bit field:
-- FREQCOUNT(31 downto 8) - RESULT - Measured value (unit in cycles of the system clock)
-- access: ro, hardware: i
-----------------------

csr_freqcount_rdata(31 downto 8) <= csr_freqcount_result_ff;


process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    csr_freqcount_result_ff <= "000000000000000000000000"; -- 0x0
else
            csr_freqcount_result_ff <= csr_freqcount_result_in;
end if;
end if;
end process;



--------------------------------------------------------------------------------
-- Write ready
--------------------------------------------------------------------------------
wready <= '1';

--------------------------------------------------------------------------------
-- Read address decoder
--------------------------------------------------------------------------------
process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
else
    if (ren = '1') then
        if raddr = std_logic_vector(to_unsigned(0, ADDR_W)) then -- 0x0
            rdata_ff <= csr_id_rdata;
        elsif raddr = std_logic_vector(to_unsigned(4, ADDR_W)) then -- 0x4
            rdata_ff <= csr_global_rdata;
        elsif raddr = std_logic_vector(to_unsigned(8, ADDR_W)) then -- 0x8
            rdata_ff <= csr_ring_rdata;
        elsif raddr = std_logic_vector(to_unsigned(12, ADDR_W)) then -- 0xc
            rdata_ff <= csr_freqcount_rdata;
        else 
            rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
        end if;
    else
        rdata_ff <= "10111010101011011011111011101111"; -- 0xbaadbeef
    end if;
end if;
end if;
end process;

rdata <= rdata_ff;

--------------------------------------------------------------------------------
-- Read data valid
--------------------------------------------------------------------------------
process (clk) begin
if rising_edge(clk) then
if (rst = '1') then
    rvalid_ff <= '0'; -- 0x0
else
    if ((ren = '1') and (rvalid = '1')) then
        rvalid_ff <= '0';
    elsif (ren = '1') then
        rvalid_ff <= '1';
    end if;
end if;
end if;
end process;


rvalid <= rvalid_ff;

end architecture;