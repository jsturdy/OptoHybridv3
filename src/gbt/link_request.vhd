----------------------------------------------------------------------------------
-- CMS Muon Endcap
-- GEM Collaboration
-- Optohybrid v3 Firmware -- Link Request
-- T. Lenzi, A. Peck
----------------------------------------------------------------------------------
-- Description:
--   This module buffers wishbone requests to and from the OH
----------------------------------------------------------------------------------
-- 2017/08/01 -- Initial working version with thermometer adapted from v2
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.types_pkg.all;

library work;
use work.ipbus_pkg.all;

entity link_request is
port(

    fabric_clock_i  : in std_logic;
    reset_i         : in std_logic;

    ipb_mosi_o    : out ipb_wbus;
    ipb_miso_i    : in  ipb_rbus;

    rx_en_i         : in std_logic;
    rx_data_i       : in std_logic_vector(IPB_REQ_BITS-1 downto 0);

    tx_en_i         : in std_logic;
    tx_valid_o      : out std_logic;
    tx_data_o       : out std_logic_vector(31 downto 0)

);
end link_request;

architecture Behavioral of link_request is

    signal rd_valid : std_logic;
    signal rd_data  : std_logic_vector(IPB_REQ_BITS-1 downto 0);

begin

    --== RX buffer ==--

    fifo_request_rx_inst : entity work.fifo_request_rx
    port map(
        rst     => reset_i,
        clk     => fabric_clock_i,
        wr_en   => rx_en_i,
        din     => rx_data_i,
        rd_en   => '1',
        valid   => rd_valid,
        dout    => rd_data,
        full    => open,
        empty   => open,
        sbiterr => open,
        dbiterr => open
    );

    --== Request processing ==--

    process(fabric_clock_i)
    begin
        if (rising_edge(fabric_clock_i)) then
            if (reset_i = '1') then
                ipb_mosi_o <= (ipb_strobe => '0', ipb_write => '0', ipb_addr => (others => '0'), ipb_wdata => (others => '0'));
            else
                if (rd_valid = '1') then
                    ipb_mosi_o <= (
                                    ipb_strobe => '1',
                                    ipb_write  => rd_data(IPB_REQ_BITS-1),
                                    ipb_addr   => rd_data(47 downto 32),
                                    ipb_wdata  => rd_data(31 downto 0)
                    );
                else
                    ipb_mosi_o.ipb_strobe <= '0';
                end if;
            end if;
        end if;
    end process;

    --== TX buffer ==--

    fifo_request_tx_inst : entity work.fifo_request_tx
    port map(
        rst     => reset_i,
        clk     => fabric_clock_i,
        wr_en   => ipb_miso_i.ipb_ack,
        din     => ipb_miso_i.ipb_rdata,
        rd_en   => tx_en_i,
        valid   => tx_valid_o,
        dout    => tx_data_o,
        full    => open,
        empty   => open,
        sbiterr => open,
        dbiterr => open
    );

end Behavioral;
