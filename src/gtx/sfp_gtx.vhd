-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 1.12
--  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard
--  /   /         Filename : sfp_gtx.vhd
-- /___/   /\     
-- \   \  /  \ 
--  \___\/\___\
--
--
-- Module SFP_GTX (a GTX Wrapper)
-- Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
-- 
-- 
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


--***************************** Entity Declaration ****************************

entity sfp_gtx is
generic
(
    -- Simulation attributes
    WRAPPER_SIM_GTXRESET_SPEEDUP    : integer   := 0 -- Set to 1 to speed up sim reset
);
port
(
    
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX0  (X0Y0)
    
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GTX0_RXCHARISK_OUT                      : out  std_logic_vector(1 downto 0);
    GTX0_RXDISPERR_OUT                      : out  std_logic_vector(1 downto 0);
    GTX0_RXNOTINTABLE_OUT                   : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GTX0_RXBYTEISALIGNED_OUT                : out  std_logic;
    GTX0_RXCOMMADET_OUT                     : out  std_logic;
    GTX0_RXENMCOMMAALIGN_IN                 : in   std_logic;
    GTX0_RXENPCOMMAALIGN_IN                 : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GTX0_RXDATA_OUT                         : out  std_logic_vector(15 downto 0);
    GTX0_RXRECCLK_OUT                       : out  std_logic;
    GTX0_RXUSRCLK2_IN                       : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GTX0_RXN_IN                             : in   std_logic;
    GTX0_RXP_IN                             : in   std_logic;
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GTX0_GTXRXRESET_IN                      : in   std_logic;
    GTX0_MGTREFCLKRX_IN                     : in   std_logic;
    GTX0_PLLRXRESET_IN                      : in   std_logic;
    GTX0_RXPLLLKDET_OUT                     : out  std_logic;
    GTX0_RXRESETDONE_OUT                    : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GTX0_TXCHARISK_IN                       : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GTX0_TXDATA_IN                          : in   std_logic_vector(15 downto 0);
    GTX0_TXOUTCLK_OUT                       : out  std_logic;
    GTX0_TXUSRCLK2_IN                       : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GTX0_TXN_OUT                            : out  std_logic;
    GTX0_TXP_OUT                            : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GTX0_GTXTXRESET_IN                      : in   std_logic;
    GTX0_TXRESETDONE_OUT                    : out  std_logic;

    
    
    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX1  (X0Y1)
    
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GTX1_RXCHARISK_OUT                      : out  std_logic_vector(1 downto 0);
    GTX1_RXDISPERR_OUT                      : out  std_logic_vector(1 downto 0);
    GTX1_RXNOTINTABLE_OUT                   : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GTX1_RXBYTEISALIGNED_OUT                : out  std_logic;
    GTX1_RXCOMMADET_OUT                     : out  std_logic;
    GTX1_RXENMCOMMAALIGN_IN                 : in   std_logic;
    GTX1_RXENPCOMMAALIGN_IN                 : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GTX1_RXDATA_OUT                         : out  std_logic_vector(15 downto 0);
    GTX1_RXRECCLK_OUT                       : out  std_logic;
    GTX1_RXUSRCLK2_IN                       : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GTX1_RXN_IN                             : in   std_logic;
    GTX1_RXP_IN                             : in   std_logic;
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GTX1_GTXRXRESET_IN                      : in   std_logic;
    GTX1_MGTREFCLKRX_IN                     : in   std_logic;
    GTX1_PLLRXRESET_IN                      : in   std_logic;
    GTX1_RXPLLLKDET_OUT                     : out  std_logic;
    GTX1_RXRESETDONE_OUT                    : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GTX1_TXCHARISK_IN                       : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GTX1_TXDATA_IN                          : in   std_logic_vector(15 downto 0);
    GTX1_TXOUTCLK_OUT                       : out  std_logic;
    GTX1_TXUSRCLK2_IN                       : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GTX1_TXN_OUT                            : out  std_logic;
    GTX1_TXP_OUT                            : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GTX1_GTXTXRESET_IN                      : in   std_logic;
    GTX1_TXRESETDONE_OUT                    : out  std_logic

    
);


end sfp_gtx;
    
architecture RTL of sfp_gtx is

    attribute CORE_GENERATION_INFO : string;
    attribute CORE_GENERATION_INFO of RTL : architecture is "sfp_gtx,v6_gtxwizard_v1_12,{protocol_file=Start_from_scratch}";

--***************************** Signal Declarations *****************************

    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;


  
    signal  gtx0_share_rxpll_i           :   std_logic_vector(1 downto 0);
    signal  gtx0_mgtrefclkrx_i           :   std_logic_vector(1 downto 0);
  
    signal  gtx1_share_rxpll_i           :   std_logic_vector(1 downto 0);
    signal  gtx1_mgtrefclkrx_i           :   std_logic_vector(1 downto 0);
   
--*************************** Component Declarations **************************
component sfp_gtx_gtx
generic
(
    -- Simulation attributes
    GTX_SIM_GTXRESET_SPEEDUP    : integer    := 0;
    
    -- Share RX PLL parameter
    GTX_TX_CLK_SOURCE           : string     := "TXPLL";
    -- Save power parameter
    GTX_POWER_SAVE              : bit_vector := "0000000000"
);
port 
(   
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISK_OUT                           : out  std_logic_vector(1 downto 0);
    RXDISPERR_OUT                           : out  std_logic_vector(1 downto 0);
    RXNOTINTABLE_OUT                        : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    RXBYTEISALIGNED_OUT                     : out  std_logic;
    RXCOMMADET_OUT                          : out  std_logic;
    RXENMCOMMAALIGN_IN                      : in   std_logic;
    RXENPCOMMAALIGN_IN                      : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA_OUT                              : out  std_logic_vector(15 downto 0);
    RXRECCLK_OUT                            : out  std_logic;
    RXUSRCLK2_IN                            : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    RXN_IN                                  : in   std_logic;
    RXP_IN                                  : in   std_logic;
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GTXRXRESET_IN                           : in   std_logic;
    MGTREFCLKRX_IN                          : in   std_logic_vector(1 downto 0);
    PLLRXRESET_IN                           : in   std_logic;
    RXPLLLKDET_OUT                          : out  std_logic;
    RXRESETDONE_OUT                         : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK_IN                            : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA_IN                               : in   std_logic_vector(15 downto 0);
    TXOUTCLK_OUT                            : out  std_logic;
    TXUSRCLK2_IN                            : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    TXN_OUT                                 : out  std_logic;
    TXP_OUT                                 : out  std_logic;
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GTXTXRESET_IN                           : in   std_logic;
    MGTREFCLKTX_IN                          : in   std_logic_vector(1 downto 0);
    PLLTXRESET_IN                           : in   std_logic;
    TXPLLLKDET_OUT                          : out  std_logic;
    TXRESETDONE_OUT                         : out  std_logic


);
end component;


--********************************* Main Body of Code**************************

begin                       

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';
                     

   
    gtx0_mgtrefclkrx_i <= (tied_to_ground_i & GTX0_MGTREFCLKRX_IN);
    gtx1_mgtrefclkrx_i <= (tied_to_ground_i & GTX1_MGTREFCLKRX_IN);

 
    --------------------------- GTX Instances  -------------------------------   


    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX0  (X0Y0)

    gtx0_sfp_gtx_i : sfp_gtx_gtx
    generic map
    (
        -- Simulation attributes
        GTX_SIM_GTXRESET_SPEEDUP    => WRAPPER_SIM_GTXRESET_SPEEDUP,
        
        -- Share RX PLL parameter
        GTX_TX_CLK_SOURCE           => "RXPLL",
        -- Save power parameter
        GTX_POWER_SAVE              => "0000110100"
    )
    port map
    (
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISK_OUT                   =>      GTX0_RXCHARISK_OUT,
        RXDISPERR_OUT                   =>      GTX0_RXDISPERR_OUT,
        RXNOTINTABLE_OUT                =>      GTX0_RXNOTINTABLE_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED_OUT             =>      GTX0_RXBYTEISALIGNED_OUT,
        RXCOMMADET_OUT                  =>      GTX0_RXCOMMADET_OUT,
        RXENMCOMMAALIGN_IN              =>      GTX0_RXENMCOMMAALIGN_IN,
        RXENPCOMMAALIGN_IN              =>      GTX0_RXENPCOMMAALIGN_IN,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA_OUT                      =>      GTX0_RXDATA_OUT,
        RXRECCLK_OUT                    =>      GTX0_RXRECCLK_OUT,
        RXUSRCLK2_IN                    =>      GTX0_RXUSRCLK2_IN,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXN_IN                          =>      GTX0_RXN_IN,
        RXP_IN                          =>      GTX0_RXP_IN,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        GTXRXRESET_IN                   =>      GTX0_GTXRXRESET_IN,
        MGTREFCLKRX_IN                  =>      gtx0_mgtrefclkrx_i,
        PLLRXRESET_IN                   =>      GTX0_PLLRXRESET_IN,
        RXPLLLKDET_OUT                  =>      GTX0_RXPLLLKDET_OUT,
        RXRESETDONE_OUT                 =>      GTX0_RXRESETDONE_OUT,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXCHARISK_IN                    =>      GTX0_TXCHARISK_IN,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA_IN                       =>      GTX0_TXDATA_IN,
        TXOUTCLK_OUT                    =>      GTX0_TXOUTCLK_OUT,
        TXUSRCLK2_IN                    =>      GTX0_TXUSRCLK2_IN,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        TXN_OUT                         =>      GTX0_TXN_OUT,
        TXP_OUT                         =>      GTX0_TXP_OUT,
        ----------------------- Transmit Ports - TX PLL Ports ----------------------
        GTXTXRESET_IN                   =>      GTX0_GTXTXRESET_IN,
        MGTREFCLKTX_IN                  =>      gtx0_mgtrefclkrx_i,
        PLLTXRESET_IN                   =>      tied_to_ground_i,
        TXPLLLKDET_OUT                  =>      open,
        TXRESETDONE_OUT                 =>      GTX0_TXRESETDONE_OUT

    );



    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX1  (X0Y1)

    gtx1_sfp_gtx_i : sfp_gtx_gtx
    generic map
    (
        -- Simulation attributes
        GTX_SIM_GTXRESET_SPEEDUP    => WRAPPER_SIM_GTXRESET_SPEEDUP,
        
        -- Share RX PLL parameter
        GTX_TX_CLK_SOURCE           => "RXPLL",
        -- Save power parameter
        GTX_POWER_SAVE              => "0000110100"
    )
    port map
    (
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISK_OUT                   =>      GTX1_RXCHARISK_OUT,
        RXDISPERR_OUT                   =>      GTX1_RXDISPERR_OUT,
        RXNOTINTABLE_OUT                =>      GTX1_RXNOTINTABLE_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED_OUT             =>      GTX1_RXBYTEISALIGNED_OUT,
        RXCOMMADET_OUT                  =>      GTX1_RXCOMMADET_OUT,
        RXENMCOMMAALIGN_IN              =>      GTX1_RXENMCOMMAALIGN_IN,
        RXENPCOMMAALIGN_IN              =>      GTX1_RXENPCOMMAALIGN_IN,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA_OUT                      =>      GTX1_RXDATA_OUT,
        RXRECCLK_OUT                    =>      GTX1_RXRECCLK_OUT,
        RXUSRCLK2_IN                    =>      GTX1_RXUSRCLK2_IN,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXN_IN                          =>      GTX1_RXN_IN,
        RXP_IN                          =>      GTX1_RXP_IN,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        GTXRXRESET_IN                   =>      GTX1_GTXRXRESET_IN,
        MGTREFCLKRX_IN                  =>      gtx1_mgtrefclkrx_i,
        PLLRXRESET_IN                   =>      GTX1_PLLRXRESET_IN,
        RXPLLLKDET_OUT                  =>      GTX1_RXPLLLKDET_OUT,
        RXRESETDONE_OUT                 =>      GTX1_RXRESETDONE_OUT,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXCHARISK_IN                    =>      GTX1_TXCHARISK_IN,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA_IN                       =>      GTX1_TXDATA_IN,
        TXOUTCLK_OUT                    =>      GTX1_TXOUTCLK_OUT,
        TXUSRCLK2_IN                    =>      GTX1_TXUSRCLK2_IN,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        TXN_OUT                         =>      GTX1_TXN_OUT,
        TXP_OUT                         =>      GTX1_TXP_OUT,
        ----------------------- Transmit Ports - TX PLL Ports ----------------------
        GTXTXRESET_IN                   =>      GTX1_GTXTXRESET_IN,
        MGTREFCLKTX_IN                  =>      gtx1_mgtrefclkrx_i,
        PLLTXRESET_IN                   =>      tied_to_ground_i,
        TXPLLLKDET_OUT                  =>      open,
        TXRESETDONE_OUT                 =>      GTX1_TXRESETDONE_OUT

    );

  
  
    

     
end RTL;
