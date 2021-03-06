----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- System Monitor
-- T. Lenzi, A. Peck
----------------------------------------------------------------------------------
-- 2017/08/08 -- Remove auxillary inputs, add alarms
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;
use work.registers.all;

entity adc is
port(

    clock_i       : in std_logic;
    reset_i         : in std_logic;

    -- IPbus
    ipb_reset_i       : in  std_logic;
    ipb_clk_i         : in  std_logic;
    ipb_mosi_i        : in  ipb_wbus;
    ipb_miso_o        : out ipb_rbus;

    -- Analog input
    adc_vp         : in  std_logic;
    adc_vn         : in  std_logic;

    cnt_snap : in std_logic

);
end adc;

architecture Behavioral of adc is
    --====================--
    --== System Monitor ==--
    --====================--

    signal daddr      : std_logic_vector  (6 downto 0);
    signal data_in    : std_logic_vector (15 downto 0);
    signal data_out   : std_logic_vector (15 downto 0);
    signal den        : std_logic;
    signal data_ready : std_logic;
    signal reset      : std_logic;
    signal write_en   : std_logic;

    signal overtemp     : std_logic;
    signal vccaux_alarm : std_logic;
    signal vccint_alarm : std_logic;

    ------ Register signals begin (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_ADC_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_ADC_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_ADC_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_ADC_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_ADC_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_ADC_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_ADC_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_ADC_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_ADC_NUM_REGS - 1 downto 0) := (others => '0');
    -- Connect counter signal declarations
    signal cnt_overtemp : std_logic_vector (7 downto 0) := (others => '0');
    signal cnt_vccaux_alarm : std_logic_vector (7 downto 0) := (others => '0');
    signal cnt_vccint_alarm : std_logic_vector (7 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    xadc_inst : entity work.xadc
    port map(
        daddr_in         => daddr,
        dclk_in          => clock_i,
        den_in           => den,
        di_in            => data_in,
        dwe_in           => write_en,
        reset_in         => reset_i,
        busy_out         => open,
        channel_out      => open,
        do_out           => data_out,
        drdy_out         => data_ready,
        eoc_out          => open,
        eos_out          => open,
        vp_in            => adc_vp,
        vn_in            => adc_vn,
        ot_out           => overtemp,
        vccaux_alarm_out => vccaux_alarm,
        vccint_alarm_out => vccint_alarm
    );

    --===============================================================================================
    -- (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_ADC_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_ADC_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_ADC_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
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
    regs_addresses(0)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"0";
    regs_addresses(1)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"1";
    regs_addresses(2)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"2";
    regs_addresses(3)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"3";
    regs_addresses(4)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"4";
    regs_addresses(5)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"5";
    regs_addresses(6)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"6";
    regs_addresses(7)(REG_ADC_ADDRESS_MSB downto REG_ADC_ADDRESS_LSB) <= x"7";

    -- Connect read signals
    regs_read_arr(0)(REG_ADC_CTRL_OVERTEMP_BIT) <= overtemp;
    regs_read_arr(0)(REG_ADC_CTRL_VCCAUX_ALARM_BIT) <= vccaux_alarm;
    regs_read_arr(0)(REG_ADC_CTRL_VCCINT_ALARM_BIT) <= vccint_alarm;
    regs_read_arr(1)(REG_ADC_CTRL_ADR_IN_MSB downto REG_ADC_CTRL_ADR_IN_LSB) <= daddr;
    regs_read_arr(2)(REG_ADC_CTRL_DATA_IN_MSB downto REG_ADC_CTRL_DATA_IN_LSB) <= data_in;
    regs_read_arr(3)(REG_ADC_CTRL_DATA_OUT_MSB downto REG_ADC_CTRL_DATA_OUT_LSB) <= data_out;
    regs_read_arr(6)(REG_ADC_CTRL_ENABLE_BIT) <= den;
    regs_read_arr(7)(REG_ADC_CTRL_CNT_OVERTEMP_MSB downto REG_ADC_CTRL_CNT_OVERTEMP_LSB) <= cnt_overtemp;
    regs_read_arr(7)(REG_ADC_CTRL_CNT_VCCAUX_ALARM_MSB downto REG_ADC_CTRL_CNT_VCCAUX_ALARM_LSB) <= cnt_vccaux_alarm;
    regs_read_arr(7)(REG_ADC_CTRL_CNT_VCCINT_ALARM_MSB downto REG_ADC_CTRL_CNT_VCCINT_ALARM_LSB) <= cnt_vccint_alarm;

    -- Connect write signals
    daddr <= regs_write_arr(1)(REG_ADC_CTRL_ADR_IN_MSB downto REG_ADC_CTRL_ADR_IN_LSB);
    data_in <= regs_write_arr(2)(REG_ADC_CTRL_DATA_IN_MSB downto REG_ADC_CTRL_DATA_IN_LSB);
    den <= regs_write_arr(6)(REG_ADC_CTRL_ENABLE_BIT);

    -- Connect write pulse signals
    reset <= regs_write_pulse_arr(4);
    write_en <= regs_write_pulse_arr(5);

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect counter instances

    COUNTER_ADC_CTRL_CNT_OVERTEMP : entity work.counter_snap
    generic map (
        g_COUNTER_WIDTH  => 8
    )
    port map (
        ref_clk_i => clock_i,
        reset_i   => ipb_reset_i,
        en_i      => overtemp,
        snap_i    => cnt_snap,
        count_o   => cnt_overtemp
    );


    COUNTER_ADC_CTRL_CNT_VCCAUX_ALARM : entity work.counter_snap
    generic map (
        g_COUNTER_WIDTH  => 8
    )
    port map (
        ref_clk_i => clock_i,
        reset_i   => ipb_reset_i,
        en_i      => vccaux_alarm,
        snap_i    => cnt_snap,
        count_o   => cnt_vccaux_alarm
    );


    COUNTER_ADC_CTRL_CNT_VCCINT_ALARM : entity work.counter_snap
    generic map (
        g_COUNTER_WIDTH  => 8
    )
    port map (
        ref_clk_i => clock_i,
        reset_i   => ipb_reset_i,
        en_i      => vccint_alarm,
        snap_i    => cnt_snap,
        count_o   => cnt_vccint_alarm
    );


    -- Connect rate instances

    -- Connect read ready signals
    regs_read_ready_arr(3) <= data_ready;

    -- Defaults
    regs_defaults(1)(REG_ADC_CTRL_ADR_IN_MSB downto REG_ADC_CTRL_ADR_IN_LSB) <= REG_ADC_CTRL_ADR_IN_DEFAULT;
    regs_defaults(2)(REG_ADC_CTRL_DATA_IN_MSB downto REG_ADC_CTRL_DATA_IN_LSB) <= REG_ADC_CTRL_DATA_IN_DEFAULT;
    regs_defaults(6)(REG_ADC_CTRL_ENABLE_BIT) <= REG_ADC_CTRL_ENABLE_DEFAULT;

    -- Define writable regs
    regs_writable_arr(1) <= '1';
    regs_writable_arr(2) <= '1';
    regs_writable_arr(6) <= '1';

    --==== Registers end ============================================================================

end Behavioral;
