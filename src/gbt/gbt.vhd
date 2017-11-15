----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- GBT
-- A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module implements all functionality required for communicating with GBTx
----------------------------------------------------------------------------------
-- 2017/07/24 -- Initial. Wrapper around GBT components to simplify top-level
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;
use work.registers.all;

entity gbt is
generic(
    DEBUG : boolean := FALSE
);
port(

    reset_i : in std_logic;

    clock_i : in std_logic; -- 40 MHz logic clock

    gbt_rx_clk_div_i : in std_logic; -- 40 MHz phase shiftable frame clock from GBT
    gbt_rx_clk_i     : in std_logic; -- 320 MHz phase shiftable frame clock from GBT

    gbt_tx_clk_div_i : in std_logic; -- 40 MHz phase shiftable frame clock from GBT
    gbt_tx_clk_i     : in std_logic; -- 320 MHz phase shiftable frame clock from GBT

    elink_i_p : in  std_logic_vector (1 downto 0);
    elink_i_n : in  std_logic_vector (1 downto 0);

    elink_o_p : out std_logic_vector (1 downto 0);
    elink_o_n : out std_logic_vector (1 downto 0);

    gbt_link_error_o : out std_logic;

    l1a_o         : out std_logic;
    bc0_o         : out std_logic;
    resync_o      : out std_logic;
    reset_vfats_o : out std_logic;

    cnt_snap : in std_logic;

    -- GBTx

    gbt_rxready_i : in std_logic;
    gbt_rxvalid_i : in std_logic;
    gbt_txready_i : in std_logic;

    -- wishbone master
    ipb_mosi_o : out ipb_wbus;
    ipb_miso_i : in  ipb_rbus;

    -- wishbone slave
    ipb_mosi_i : in  ipb_wbus;
    ipb_miso_o : out ipb_rbus;
    ipb_reset_i : in std_logic
);

end gbt;

architecture Behavioral of gbt is

    signal gbt_tx_data  : std_logic_vector(15 downto 0) := (others => '0');
    signal gbt_rx_data   : std_logic_vector(15 downto 0) := (others => '0');

    signal gbt_tx_bitslip : std_logic_vector(2 downto 0) := (others => '0');

    signal reset     : std_logic;

    -- wishbone master
    signal ipb_mosi : ipb_wbus;
    signal ipb_miso : ipb_rbus;

    ------ Register signals begin (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_OH_GBT_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_OH_GBT_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_OH_GBT_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_OH_GBT_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_OH_GBT_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_OH_GBT_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_OH_GBT_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_OH_GBT_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_OH_GBT_NUM_REGS - 1 downto 0) := (others => '0');
    -- Connect counter signal declarations
    signal cnt_ipb_response : std_logic_vector (23 downto 0) := (others => '0');
    signal cnt_ipb_request : std_logic_vector (23 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    -- wishbone master
    ipb_mosi_o <= ipb_mosi;
    ipb_miso   <= ipb_miso_i;

    -- fanout reset tree

    process (clock_i) begin
        if (rising_edge(clock_i)) then
            reset <= reset_i;
        end if;
    end process;

    --=========--
    --== GBT ==--
    --=========--

    -- at 320 MHz performs ser-des on incoming
    gbt_serdes_inst : entity work.gbt_serdes
    port map(
        -- reset
       reset_i          => reset,

       -- input clocks

       gbt_rx_clk_div_i => gbt_rx_clk_div_i , -- 40 MHz phase shiftable frame clock from GBT
       gbt_rx_clk_i     => gbt_rx_clk_i     , -- 320 MHz phase shiftable frame clock from GBT

       gbt_tx_clk_div_i => gbt_tx_clk_div_i , -- 40 MHz phase shiftable frame clock from GBT
       gbt_tx_clk_i     => gbt_tx_clk_i     , -- 320 MHz phase shiftable frame clock from GBT

       clock            => clock_i,     -- 40 MHz logic clock

       -- serial data
       elink_o_p      => elink_o_p,  -- output e-links
       elink_o_n      => elink_o_n,  -- output e-links

       elink_i_p       => elink_i_p,   -- input e-links
       elink_i_n       => elink_i_n,   -- input e-links

       -- gbt tx bitslip

       gbt_tx_bitslip => gbt_tx_bitslip,


       -- parallel data
       data_o           => gbt_rx_data,           -- Parallel data out
       data_i           => gbt_tx_data           -- Parallel data in
    );

    -- decodes GBT frames to build packets

    gbt_link_inst : entity work.gbt_link
    port map(

        -- reset
        reset_i         => reset,

        -- clock inputs
        clock           => clock_i, -- 40 MHz ttc fabric clock

        -- parallel data
        data_i          => gbt_rx_data,
        data_o          => gbt_tx_data,

        -- wishbone master
        ipb_mosi_o    => ipb_mosi,
        ipb_miso_i    => ipb_miso,

        -- decoded TTC
        reset_vfats_o   => reset_vfats_o,
        resync_o        => resync_o,
        l1a_o           => l1a_o,
        bc0_o           => bc0_o,

        -- outputs
        error_o         => gbt_link_error_o

    );

    --===============================================================================================
    -- (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_OH_GBT_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_OH_GBT_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_OH_GBT_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => clock_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => clock_i,
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
    regs_addresses(0)(REG_OH_GBT_ADDRESS_MSB downto REG_OH_GBT_ADDRESS_LSB) <= "000";
    regs_addresses(1)(REG_OH_GBT_ADDRESS_MSB downto REG_OH_GBT_ADDRESS_LSB) <= "010";
    regs_addresses(2)(REG_OH_GBT_ADDRESS_MSB downto REG_OH_GBT_ADDRESS_LSB) <= "100";

    -- Connect read signals
    regs_read_arr(0)(REG_OH_GBT_TX_BITSLIP_MSB downto REG_OH_GBT_TX_BITSLIP_LSB) <= gbt_tx_bitslip;
    regs_read_arr(0)(REG_OH_GBT_TX_CNT_RESPONSE_SENT_MSB downto REG_OH_GBT_TX_CNT_RESPONSE_SENT_LSB) <= cnt_ipb_response;
    regs_read_arr(1)(REG_OH_GBT_RX_RX_READY_BIT) <= gbt_rxready_i;
    regs_read_arr(1)(REG_OH_GBT_RX_RX_VALID_BIT) <= gbt_rxvalid_i;
    regs_read_arr(1)(REG_OH_GBT_RX_CNT_REQUEST_RECEIVED_MSB downto REG_OH_GBT_RX_CNT_REQUEST_RECEIVED_LSB) <= cnt_ipb_request;
    regs_read_arr(2)(REG_OH_GBT_TX_TX_READY_BIT) <= gbt_txready_i;

    -- Connect write signals
    gbt_tx_bitslip <= regs_write_arr(0)(REG_OH_GBT_TX_BITSLIP_MSB downto REG_OH_GBT_TX_BITSLIP_LSB);

    -- Connect write pulse signals

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect counter instances

    COUNTER_OH_GBT_TX_CNT_RESPONSE_SENT : entity work.counter
    generic map (g_WIDTH => 24)
    port map (
        ref_clk_i => clock_i,
        snap_i    => cnt_snap,
        reset_i   => ipb_reset_i,
        en_i      => ipb_miso.ipb_ack,
        data_o    => cnt_ipb_response
    );


    COUNTER_OH_GBT_RX_CNT_REQUEST_RECEIVED : entity work.counter
    generic map (g_WIDTH => 24)
    port map (
        ref_clk_i => clock_i,
        snap_i    => cnt_snap,
        reset_i   => ipb_reset_i,
        en_i      => ipb_mosi.ipb_strobe,
        data_o    => cnt_ipb_request
    );

    -- Connect read ready signals

    -- Defaults
    regs_defaults(0)(REG_OH_GBT_TX_BITSLIP_MSB downto REG_OH_GBT_TX_BITSLIP_LSB) <= REG_OH_GBT_TX_BITSLIP_DEFAULT;

    -- Define writable regs
    regs_writable_arr(0) <= '1';

    --==== Registers end ============================================================================
end Behavioral;
