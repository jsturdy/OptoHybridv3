----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Clocking
-- 2017/07/21 -- Initial port to version 3 electronics
-- 2017/07/22 -- Additional MMCM added to monitor and dejitter the eport clock
-- 2017/08/09 -- 200MHz iodelay refclk added to primary MMCM
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.types_pkg.all;
use work.param_pkg.all;
use work.ipbus_pkg.all;
use work.registers.all;

entity clocking is
port(

    -- fixed phase 320 MHz e-port clocks
    -- gbt_eclk_p  : in std_logic_vector (1 downto 0);
    -- gbt_eclk_n  : in std_logic_vector (1 downto 0);

    -- programmable frequency/phase deskew clocks
    gbt_dclk_p : in std_logic_vector(1 downto 0);
    gbt_dclk_n : in std_logic_vector(1 downto 0);

    -- eport 40/320 serdes clocks
    gbt_rx_clk_div_o : out std_logic;
    gbt_rx_clk_o     : out std_logic;

    gbt_tx_clk_div_o : out std_logic;
    gbt_tx_clk_o     : out std_logic;

    -- logic clocks
    clk_1x_o        : out std_logic;
    clk_2x_o        : out std_logic;
    clk_4x_o        : out std_logic;
    clk_4x_90_o     : out std_logic;

    delay_refclk_o  : out std_logic;

    cluster_clk_o   : out std_logic;

    -- mmcm locked status monitors
    dskw_mmcm_locked_o   : out std_logic;
    eprt_mmcm_locked_o   : out std_logic;

    mmcms_locked_o   : out std_logic;

    -- ipbus

    ipb_mosi_i : in  ipb_wbus;
    ipb_miso_o : out ipb_rbus;

    ipb_reset_i : in std_logic


);
end clocking;


architecture Behavioral of clocking is

    signal gbt_dclk     : std_logic_vector (1 downto 0);

    signal mmcm_locked : std_logic_vector(1 downto 0);

    signal clock : std_logic;

    ------ Register signals begin (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_OH_CLOCKING_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_OH_CLOCKING_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_OH_CLOCKING_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_OH_CLOCKING_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_OH_CLOCKING_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_OH_CLOCKING_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_OH_CLOCKING_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_OH_CLOCKING_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_OH_CLOCKING_NUM_REGS - 1 downto 0) := (others => '0');
    -- Connect counter signal declarations
    signal cnt_eprt_mmcm_unlocked : std_logic_vector (7 downto 0) := (others => '0');
    signal cnt_dskw_mmcm_unlocked : std_logic_vector (7 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    clk_1x_o <= clock;

    --------- MMCMs ---------

    clk_gen0 : entity work.clk_gen
    port map(

        clk40_i_p   => gbt_dclk_p(0),
        clk40_i_n   => gbt_dclk_n(0),

        clk40_o     => clock,
        clk80_o     => clk_2x_o,
        clk160_o    => clk_4x_o,
        clk160_90_o => clk_4x_90_o,
        clk200_o    => delay_refclk_o,
        clk20_135_o => cluster_clk_o,

        locked_o    => mmcm_locked(0)
    );

    clk_gen1 : entity work.eprt_clk_gen
    port map(

        clk40_i_p     => gbt_dclk_p(1),
        clk40_i_n     => gbt_dclk_n(1),

        gbt_rxclk_div => gbt_rx_clk_div_o,
        gbt_rxclk     => gbt_rx_clk_o,

        gbt_txclk_div => gbt_tx_clk_div_o,
        gbt_txclk     => gbt_tx_clk_o,

        locked_o      => mmcm_locked(1)
    );

    mmcms_locked_o     <= mmcm_locked(0) and mmcm_locked(1);

    -- fanout
    process (clock) begin
    if (rising_edge(clock)) then
        dskw_mmcm_locked_o <= mmcm_locked(0);
        eprt_mmcm_locked_o <= mmcm_locked(1);
    end if;
    end process;

    --===============================================================================================
    -- (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_OH_CLOCKING_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_OH_CLOCKING_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_OH_CLOCKING_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => clock,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => clock,
           regs_read_arr_i        => regs_read_arr,
           regs_write_arr_o       => regs_write_arr,
           read_pulse_arr_o       => regs_read_pulse_arr,
           write_pulse_arr_o      => regs_write_pulse_arr,
           regs_read_ready_arr_i  => regs_read_ready_arr,
           regs_write_done_arr_i  => regs_write_done_arr,
           individual_addrs_arr_i => regs_addresses,
           regs_defaults_arr_i    => regs_defaults,
           writable_regs_i        => regs_writable_arr
      );

    -- Addresses
    regs_addresses(0)(REG_OH_CLOCKING_ADDRESS_MSB downto REG_OH_CLOCKING_ADDRESS_LSB) <= x"0000";
    regs_addresses(1)(REG_OH_CLOCKING_ADDRESS_MSB downto REG_OH_CLOCKING_ADDRESS_LSB) <= x"0002";

    -- Connect read signals
    regs_read_arr(0)(REG_OH_CLOCKING_CLOCKING_LOGIC_MMCM_LOCKED_BIT) <= mmcm_locked(0);
    regs_read_arr(0)(REG_OH_CLOCKING_CLOCKING_GBT_MMCM_UNLOCKED_CNT_MSB downto REG_OH_CLOCKING_CLOCKING_GBT_MMCM_UNLOCKED_CNT_LSB) <= cnt_eprt_mmcm_unlocked;
    regs_read_arr(0)(REG_OH_CLOCKING_CLOCKING_LOGIC_MMCM_UNLOCKED_CNT_MSB downto REG_OH_CLOCKING_CLOCKING_LOGIC_MMCM_UNLOCKED_CNT_LSB) <= cnt_dskw_mmcm_unlocked;
    regs_read_arr(1)(REG_OH_CLOCKING_CLOCKING_GBT_MMCM_LOCKED_BIT) <= mmcm_locked(1);

    -- Connect write signals

    -- Connect write pulse signals

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect counter instances

    COUNTER_OH_CLOCKING_CLOCKING_GBT_MMCM_UNLOCKED_CNT : entity work.counter
    generic map (g_WIDTH => 8)
    port map (
        ref_clk_i => clock,
        snap_i    => '1',
        reset_i   => ipb_reset_i,
        en_i      => (not mmcm_locked(1)),
        data_o    => cnt_eprt_mmcm_unlocked
    );


    COUNTER_OH_CLOCKING_CLOCKING_LOGIC_MMCM_UNLOCKED_CNT : entity work.counter
    generic map (g_WIDTH => 8)
    port map (
        ref_clk_i => clock,
        snap_i    => '1',
        reset_i   => ipb_reset_i,
        en_i      => (not mmcm_locked(0)),
        data_o    => cnt_dskw_mmcm_unlocked
    );

    -- Connect read ready signals

    -- Defaults

    -- Define writable regs

    --==== Registers end ============================================================================

end Behavioral;
