----------------------------------------------------------------------------------
-- Company:        IIHE - ULB
-- Engineer:       Thomas Lenzi (thomas.lenzi@cern.ch)
-- 
-- Create Date:    13:46:42 08/05/2015 
-- Design Name:    OptoHybrid v2
-- Module Name:    vfat2_latency_scan - Behavioral 
-- Project Name:   OptoHybrid v2
-- Target Devices: xc6vlx130t-1ff1156
-- Tool versions:  ISE  P.20131013
-- Description: 
--
-- Wishbone slave that handles the Latency Scan based on the Tracking data
--
-- Register map:
-- 0 : start the scan for a given VFAT2
-- 1 : minimum latency (8 bits)
-- 2 : maximum latency (8 bits)
-- 3 : latency step (8 bits)
-- 4 : number of events  (24 bits)
-- 5 : read out the results (32 bits = 8 bits of latency value & 24 bits of number of events hit)
-- 6 : local reset
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_pkg.all;

entity vfat2_latency_scan is
port(
    -- System reference clock
    ref_clk_i       : in std_logic;
    -- System reset
    reset_i         : in std_logic;
    -- Request from the system
    wb_slv_req_i    : in wb_req_t;
    -- Response to the system
    wb_slv_res_o    : out wb_res_t;
    -- Request to the I2C slave
    wb_mst_req_o    : out wb_req_t;
    -- Response from the I2C slave
    wb_mst_res_i    : in wb_res_t;
    -- Tracking data of the VFAT2s in the sector
    vfat2_tk_data_i : in tk_data_array_t(3 downto 0);
    -- Is the scan running 
    scan_running_o  : out std_logic
);
end vfat2_latency_scan;

architecture Behavioral of vfat2_latency_scan is

    -- Local reset
    signal local_reset  : std_logic;
    
    -- Signals from the Wishbone Splitter
    signal wb_stb       : std_logic_vector(6 downto 0);
    signal wb_we        : std_logic;
    signal wb_addr      : std_logic_vector(31 downto 0);
    signal wb_data      : std_logic_vector(31 downto 0);
    
    -- Signals for the registers
    signal reg_ack      : std_logic_vector(6 downto 0);
    signal reg_err      : std_logic_vector(6 downto 0);
    signal reg_data     : std32_array_t(6 downto 0);
    
    -- Signals to the FIFO
    signal fifo_rst     : std_logic;
    signal fifo_we      : std_logic;
    signal fifo_din     : std_logic_vector(31 downto 0);

begin

    --===============================--
    --== Wishbone request splitter ==--
    --===============================--

    wb_splitter_inst : entity work.wb_splitter
    generic map(
        SIZE        => 7
    )
    port map(
        wb_clk_i    => ref_clk_i,
        reset_i     => local_reset,
        wb_req_i    => wb_slv_req_i,
        wb_res_o    => wb_slv_res_o,
        stb_o       => wb_stb,
        we_o        => wb_we,
        addr_o      => wb_addr,
        data_o      => wb_data,
        ack_i       => reg_ack,
        err_i       => reg_err,
        data_i      => reg_data
    );
    
    --==========================--
    --== Latency scan routine ==--
    --==========================--
    
    -- 0 : start the scan for a given VFAT2

    vfat2_latency_scan_req_inst : entity work.vfat2_latency_scan_req
    port map(
        ref_clk_i       => ref_clk_i,
        reset_i         => local_reset,
        req_stb_i       => wb_stb(0),
        req_vfat2_i     => wb_addr(12 downto 8),
        req_min_lat_i   => reg_data(1)(7 downto 0),
        req_max_lat_i   => reg_data(2)(7 downto 0),
        req_lat_step_i  => reg_data(3)(7 downto 0),
        req_events_i    => reg_data(4)(23 downto 0),
        wb_mst_req_o    => wb_mst_req_o,
        wb_mst_res_i    => wb_mst_res_i,
        vfat2_tk_data_i => vfat2_tk_data_i,
        fifo_rst_o      => fifo_rst,
        fifo_we_o       => fifo_we,
        fifo_din_o      => fifo_din,
        scan_running_o  => scan_running_o
    );
    
    -- Connect signals for automatic response
    reg_ack(0) <= wb_stb(0);
    reg_err(0) <= '0';
    reg_data(0) <= (others => '0');
    
    --===============--
    --== Registers ==--
    --===============--
   
    -- 1 : minimum latency (8 bits)
    -- 2 : maximum latency (8 bits)
    -- 3 : latency step (8 bits)
    -- 4 : number of events  (24 bits)   
   
    registers_inst : entity work.registers
    generic map(
        SIZE        => 4
    )
    port map(
        ref_clk_i   => ref_clk_i,
        reset_i     => local_reset,
        stb_i       => wb_stb(4 downto 1),
        we_i        => wb_we,
        data_i      => wb_data,
        ack_o       => reg_ack(4 downto 1),
        err_o       => reg_err(4 downto 1),
        data_o      => reg_data(4 downto 1)
    );
    
    --=======================--
    --== FIFO with results ==--
    --=======================--
    
    -- 5 : read out the results (32 bits = 8 bits of latency value & 24 bits of number of events hit)

    fifo256x32_inst : entity work.fifo256x32
    port map(
        clk         => ref_clk_i,
        rst         => (local_reset or fifo_rst),
        wr_en       => fifo_we,
        din         => fifo_din,
        rd_en       => wb_stb(5),
        valid       => reg_ack(5),
        dout        => reg_dout(5),
        underflow   => reg_err(5),
        full        => open,
        empty       => open
    );
    
    --=================--
    --== Local reset ==--
    --=================--

    local_reset <= reset_i or wb_stb(6);
    
    -- Connect signals for automatic response
    reg_ack(6) <= wb_stb(6);
    reg_err(6) <= '0';
    reg_data(6) <= (others => '0');
    
end Behavioral;