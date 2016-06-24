--////////////////////////////////////////////////////////////////////////////////
--//   ____  ____ 
--//  /   /\/   / 
--// /___/  \  /    Vendor: Xilinx 
--// \   \   \/     Version : 2.5
--//  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--//  /   /         Filename : xlx_k7v7_gtx_rx_manual_phase_align.vhd
--// /___/   /\     
--// \   \  /  \ 
--//  \___\/\___\ 
--//
--//
--  Description :     This module performs RX Buffer Phase Alignment in Manual Mode.
--                     
--
--
-- Module xlx_k7v7_gtx_rx_manual_phase_align
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
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



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xlx_k7v7_gtx_RX_MANUAL_PHASE_ALIGN is
  Generic( NUMBER_OF_LANES          : integer range 1 to 32:= 4;  -- Number of lanes that are controlled using this FSM.
           MASTER_LANE_ID           : integer range 0 to 31:= 0   -- Number of the lane which is considered the master in manual phase-alignment
         );     

    Port ( STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                                  --or reference-clock present at startup.
           RESET_PHALIGNMENT        : in  STD_LOGIC;
           RUN_PHALIGNMENT          : in  STD_LOGIC;
           PHASE_ALIGNMENT_DONE     : out STD_LOGIC := '0';       -- Manual phase-alignment performed sucessfully    
           RXDLYSRESET              : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0');
           RXDLYSRESETDONE          : in  STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0);
           RXPHALIGN                : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0');
           RXPHALIGNDONE            : in  STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0);
           RXDLYEN                  : out STD_LOGIC_VECTOR(NUMBER_OF_LANES-1 downto 0) := (others=> '0')
           );
end xlx_k7v7_gtx_RX_MANUAL_PHASE_ALIGN;

architecture RTL of xlx_k7v7_gtx_RX_MANUAL_PHASE_ALIGN is

  component xlx_k7v7_gtx_sync_block
   generic (
     INITIALISE : bit_vector(1 downto 0) := "00"
   );
   port  (
             clk           : in  std_logic;
             data_in       : in  std_logic;
             data_out      : out std_logic
          );
   end component;

  constant VCC_VEC  : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '1');
  constant GND_VEC  : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');

  type rx_phase_align_manual_fsm is(
    INIT, WAIT_DLYRST_DONE, M_PHALIGN, M_DLYEN,
    S_PHALIGN, M_DLYEN2, PHALIGN_DONE
    );
  signal rx_phalign_manual_state  : rx_phase_align_manual_fsm := INIT;
  signal rxphaligndone_prev       : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal rxphaligndone_ris_edge   : std_logic_vector(NUMBER_OF_LANES-1 downto 0);

  signal rxdlysresetdone_store    : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal rxphaligndone_store      : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal rxdone_clear             : std_logic := '0';

  signal rxphaligndone_sync       : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');
  signal rxdlysresetdone_sync     : std_logic_vector(NUMBER_OF_LANES-1 downto 0) :=(others => '0');


begin

 cdc: for i in 0 to NUMBER_OF_LANES-1 generate
 sync_RXPHALIGNDONE : xlx_k7v7_gtx_sync_block
  port map
         (
            clk             =>  STABLE_CLOCK,
            data_in         =>  RXPHALIGNDONE(i),
            data_out        =>  rxphaligndone_sync(i) 
         );

  sync_RXDLYSRESETDONE : xlx_k7v7_gtx_sync_block
  port map
         (
            clk             =>  STABLE_CLOCK,
            data_in         =>  RXDLYSRESETDONE(i),
            data_out        =>  rxdlysresetdone_sync(i) 
         );

   end generate;



  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      rxphaligndone_prev    <= rxphaligndone_sync;  
    end if;
  end process;
  
  edge_detect: for i in 0 to NUMBER_OF_LANES-1 generate
    rxphaligndone_ris_edge(i) <= '1' when (rxphaligndone_prev(i) = '0') and (rxphaligndone_sync(i) = '1') else '0';            
  end generate;

  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      if rxdone_clear = '1' then
        rxdlysresetdone_store <= (others=>'0');
        rxphaligndone_store  <= (others=>'0');
      else
        for i in 0 to NUMBER_OF_LANES-1 loop
          if rxdlysresetdone_sync(i) = '1' then
            rxdlysresetdone_store(i) <= '1';
          end if;
          if rxphaligndone_ris_edge(i) = '1' then
             rxphaligndone_store(i)  <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process;




  process(STABLE_CLOCK)
  begin
    if rising_edge(STABLE_CLOCK) then
      if RESET_PHALIGNMENT = '1' then
        PHASE_ALIGNMENT_DONE    <= '0';
        rx_phalign_manual_state <= INIT;
        rxdone_clear            <= '1';
      else
        case rx_phalign_manual_state is
          when INIT => 
            PHASE_ALIGNMENT_DONE <= '0';
            rxdone_clear         <= '1';
            
            if RUN_PHALIGNMENT = '1' then
              --Assert RXDLYSRESET for all lanes. 
              rxdone_clear            <= '0';
              RXDLYSRESET             <= (others => '1');
              rx_phalign_manual_state <= WAIT_DLYRST_DONE;
            end if;
            
          when WAIT_DLYRST_DONE =>
            for i in 0 to NUMBER_OF_LANES - 1 loop
              --if RXDLYSRESETDONE(i) = '1' then
              if rxdlysresetdone_store(i) = '1' then
                --Hold RXDLYSRESET High until RXDLYSRESETDONE of the 
                --respective lane is asserted.
                --Deassert RXDLYSRESET for the lane in which the 
                --RXDLYSRESETDONE is asserted.
                RXDLYSRESET(i) <= '0';
              end if;
            end loop;
            if rxdlysresetdone_store = VCC_VEC then
              rx_phalign_manual_state   <= M_PHALIGN;
            end if;
          
          when M_PHALIGN => 
            --When RXDLYSRESET of all lanes are deasserted, assert 
            --RXPHALIGN for the master lane.
            RXPHALIGN(MASTER_LANE_ID) <= '1';
            if rxphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Hold this signal High until a rising edge on RXPHALIGNDONE 
              --of the master lane is detected, then deassert RXPHALIGN for 
              --the master lane.
              RXPHALIGN(MASTER_LANE_ID) <= '0';
              rx_phalign_manual_state   <= M_DLYEN;
            end if;
          
          when M_DLYEN => 
            --Assert RXDLYEN for the master lane. This causes RXPHALIGNDONE 
            --to be deasserted.
            RXDLYEN(MASTER_LANE_ID) <= '1';
            if rxphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Hold RXDLYEN for the master lane High until a rising edge on
              --RXPHALIGNDONE of the master lane is detected, then deassert 
              --RXDLYEN for the master lane.
              RXDLYEN(MASTER_LANE_ID)   <= '0';
              rx_phalign_manual_state   <= S_PHALIGN;        
            end if;
          
          when S_PHALIGN =>
            --Assert RXPHALIGN for all slave lane(s). Hold this signal High until
            --a rising edge on RXPHALIGNDONE of the respective slave lane is detected.
            RXPHALIGN                 <= (others=>'1');--\Assert only the PHINIT-signal of
            RXPHALIGN(MASTER_LANE_ID) <= '0';          --/the slaves.
            for i in 0 to NUMBER_OF_LANES - 1 loop
              if rxphaligndone_store(i) = '1' then
                --When a rising edge on the respective lane is detected, RXPHALIGN
                --of that lane is deasserted.
                RXPHALIGN(i) <= '0';
              end if;
            end loop;
           --The reason for checking of the occurance of at least one rising edge
            --is to avoid the potential direct move where RXPHALIGNDONE might not 
            --be going low fast enough. 
            --if rxphaligndone_store = VCC_VEC and rxphaligndone_ris_edge /= GND_VEC then
            if rxphaligndone_store = VCC_VEC then
              rx_phalign_manual_state   <= M_DLYEN2;
            end if;
          
          when M_DLYEN2 =>
            --When RXPHALIGN for all slave lane(s) are deasserted, assert RXDLYEN 
            --for the master lane. This causes RXPHALIGNDONE of the master lane 
            --to be deasserted.
            RXDLYEN(MASTER_LANE_ID) <= '1';
            if rxphaligndone_ris_edge(MASTER_LANE_ID) = '1' then
              --Wait until RXPHALIGNDONE of the master lane reasserts. Phase and 
              --delay alignment for the multilane interface is complete.
              rx_phalign_manual_state   <= PHALIGN_DONE;        
            end if;
          
          when PHALIGN_DONE =>
            --Continue to hold RXDLYEN for the master lane High to adjust RXUSRCLK 
            --to compensate for temperature and voltage variations.
            RXDLYEN(MASTER_LANE_ID) <= '1';
            PHASE_ALIGNMENT_DONE    <= '1';

          when OTHERS =>
            rx_phalign_manual_state <= INIT;
         
        end case;
      end if;
    end if;
  end process;  

end RTL;
