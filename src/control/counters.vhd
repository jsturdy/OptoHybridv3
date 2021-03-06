----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Counters
-- T. Lenzi, A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module implements all counters in the OH and the wishbone interface to
--   read them out
----------------------------------------------------------------------------------
-- 2017/07/24 -- Initial port to version 3 electronics
-- 2017/07/25 -- Clear synthesis warnings from module
-- 2017/08/10 -- Add reset fanout tree
-- 2017/08/14 -- Add global reset and SNAP machine
-- 2017/08/14 -- Reset counters on resync
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.types_pkg.all;
use work.ipbus_pkg.all;
use work.registers.all;

entity counters is
generic(
    N_COUNTERS          : integer := 48;
    N_TIMERS            : integer := 24
);
port(

    clock               : in std_logic;
    reset_i             : in std_logic;

    -- Wishbone slave
    wb_slv_req_i        : in  ipb_wbus;
    wb_slv_res_o        : out ipb_rbus;

    -- Wishbone request
    wb_m_req_i          : in wb_req_array_t ((WB_MASTERS - 1) downto 0);
    wb_m_res_i          : in wb_res_array_t ((WB_MASTERS - 1) downto 0);
    wb_s_req_i          : in wb_req_array_t ((WB_SLAVES  - 1) downto 0);
    wb_s_res_i          : in wb_res_array_t ((WB_SLAVES  - 1) downto 0);

    -- GBT
    gbt_link_error_i    : in std_logic;

    -- MMCM
    mmcms_locked_i        : in std_logic;
    eprt_mmcm_locked_i    : in std_logic;
    dskw_mmcm_locked_i    : in std_logic;

    -- TTC
    ttc_l1a          : in std_logic;
    ttc_bc0          : in std_logic;
    ttc_resync       : in std_logic;
    ttc_bx0_sync_err : in std_logic;

    -- SEM
    sem_correction_i    : in std_logic

);
end counters;

architecture Behavioral of counters is

    constant N          : integer := N_COUNTERS+N_TIMERS;

    -- Signals from the Wishbone Hub
    signal wb_stb       : std_logic_vector((N - 1) downto 0);
    signal wb_we        : std_logic;
    signal wb_addr      : std_logic_vector(WB_ADDR_SIZE-1 downto 0);
    signal wb_data      : std_logic_vector(31 downto 0);

    -- Signals for the registers
    signal reg_ack      : std_logic_vector((N - 1) downto 0);
    signal reg_err      : std_logic_vector((N - 1) downto 0);
    signal cnt_data     : std32_array_t   ((N - 1) downto 0);

    signal snap_data    : std32_array_t   ((N - 1) downto 0);

    -- Sbits
    signal ors          : std_logic_vector (23 downto 0);

    signal cnt_en       : std_logic_vector ((N-1) downto 0);

    signal snap_en      : std_logic;

    signal reset_all    : std_logic;

    signal reset_en     : std_logic_vector ((N-1) downto 0);

    signal wb_sump      : std_logic;

    signal reset        : std_logic;

    constant snap_id    : integer := 0;
    constant reset_id   : integer := 1;
    constant resync_id  : integer := 15;

    ------ Register signals begin (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_FPGA.COUNTERS_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    process (clock) begin
        if (rising_edge(clock)) then
            reset <= reset_i;
        end if;
    end process;

    --===============================--
    --== Wishbone request splitter ==--
    --===============================--

    wb_splitter_inst : entity work.wb_splitter
    generic map(
        SIZE        => N,
        OFFSET      => 0
    )
    port map(
        ref_clk_i   => clock,
        reset_i     => reset,
        wb_req_i    => wb_slv_req_i,
        wb_res_o    => wb_slv_res_o,
        stb_o       => wb_stb,
        we_o        => wb_we,
        addr_o      => wb_addr,
        data_o      => wb_data,
        ack_i       => reg_ack,
        err_i       => reg_err,
        data_i      => snap_data
    );

    --========================--
    --== Automatic response ==--
    --========================--

    ack_err_loop : for I in 0 to (N - 1) generate
    begin
        reg_ack(I) <= wb_stb(I);
        reg_err(I) <= '0';
    end generate;

    --==========--
    --== SNAP ==--
    --==========--

    -- accumulator enables
    process(clock)
    begin
        if (rising_edge(clock)) then
            if (snap_en = '1') then
                snap_data <= cnt_data;
            end if;
        end if;
    end process;

    --==============--
    --== Counters ==--
    --==============--

    counter_loop : for I in 0 to (N_COUNTERS-1) generate
    begin

        u_counter_loop : entity work.counter
        port map (
            ref_clk_i => clock,
            snap_i    => '1',
            reset_i   => reset_en(I), -- reset counter by writing to the register
            en_i      => cnt_en  (I),
            data_o    => cnt_data(I)
        );

        process(clock)
        begin
            if (rising_edge(clock)) then

                -- don't reset the resync counter on resync
                if (I = reset_id ) then
                    reset_en (I) <= (wb_stb  (I) and wb_we);
                elsif (I = resync_id) then
                    reset_en (I) <= (wb_stb  (I) and wb_we) or reset_all;
                else
                    reset_en (I) <= (wb_stb  (I) and wb_we) or reset_all or ttc_resync;
                end if;

        end if;
        end process;

    end generate;

    -- time from the OR of s-bits to the L1A for each VFAT
    -- counters 21 to 44

    timer_loop : for I in 0 to (N_TIMERS-1) generate
    begin

        process(clock)
        begin
            if (rising_edge(clock)) then
            reset_en (N_COUNTERS+I) <= wb_stb  (N_COUNTERS+I) and wb_we;;
        end if;
        end process;

        u_timer_loop : entity work.timer
        port map(
            ref_clk_i => clock,
            reset_i   => reset_en(N_COUNTERS+I),
            start_i   => active_vfats_i(I),
            stop_i    => ttc_l1a,
            data_o    => cnt_data(N_COUNTERS + I)
        );

    end generate;

    -- (this section is generated by <optohybrid_top>/tools/generate_registers.py -- do not edit)
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_FPGA.COUNTERS_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_FPGA.COUNTERS_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_FPGA.COUNTERS_ADDRESS_LSB,
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
    regs_addresses(0)(REG_FPGA.COUNTERS_ADDRESS_MSB downto REG_FPGA.COUNTERS_ADDRESS_LSB) <= x"0000";
    regs_addresses(1)(REG_FPGA.COUNTERS_ADDRESS_MSB downto REG_FPGA.COUNTERS_ADDRESS_LSB) <= x"0001";

    -- Connect read signals
    regs_read_arr(1)(REG_FPGA_COUNTERS_CNT_SNAP_CNT_MSB downto REG_FPGA_COUNTERS_CNT_SNAP_CNT_LSB) <= snap_data(REG_FPGA_COUNTERS_CNT_SNAP_CNT_ADDR);

    -- Connect write signals

    -- Connect write pulse signals
    snap_en <= regs_write_pulse_arr(0);
    reset_all <= regs_write_pulse_arr(1);

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect read ready signals

    -- Defaults

    -- Define writable regs

    --==== Registers end ============================================================================

end Behavioral;
