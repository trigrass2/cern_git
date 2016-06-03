------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 1.10
--  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard 
--  /   /         Filename : buffbypassgtx_rx_sync.vhd
-- /___/   /\     
-- \   \  /  \ 
--  \___\/\___\
--
--
-- Module buffbypassgtx_rx_sync
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

entity buffbypassgtx_rx_sync is
port
(
    RXENPMAPHASEALIGN    :   out   std_logic;
    RXPMASETPHASE        :   out   std_logic;
    RXDLYALIGNDISABLE    :   out   std_logic;
    RXDLYALIGNOVERRIDE   :   out   std_logic;
    RXDLYALIGNRESET      :   out   std_logic;
    SYNC_DONE            :   out   std_logic;
    USER_CLK             :   in    std_logic;
    RESET                :   in    std_logic
);


end buffbypassgtx_rx_sync;

architecture RTL of buffbypassgtx_rx_sync is
--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

--*******************************Register Declarations************************

    signal   begin_r                        :   std_logic;
    signal   phase_align_r                  :   std_logic;
    signal   ready_r                        :   std_logic;
    signal   sync_counter_r                 :   unsigned(5 downto 0);
    signal   sync_done_count_r              :   unsigned(5 downto 0);
    signal   align_reset_counter_r          :   unsigned(4 downto 0);
    signal   wait_after_sync_r              :   std_logic;
    signal   wait_before_setphase_counter_r :   unsigned(5 downto 0);
    signal   wait_before_setphase_r         :   std_logic;
    signal   align_reset_r                  :   std_logic;
    
--*******************************Wire Declarations****************************
    
    signal   count_32_setphase_complete_r   :   std_logic;
    signal   count_32_wait_complete_r       :   std_logic;
    signal   count_align_reset_complete_r   :   std_logic;
    signal   next_phase_align_c             :   std_logic;
    signal   next_align_reset_c             :   std_logic;
    signal   next_ready_c                   :   std_logic;
    signal   next_wait_after_sync_c         :   std_logic;
    signal   next_wait_before_setphase_c    :   std_logic;
    signal   sync_32_times_done_r           :   std_logic;
    
    attribute max_fanout:string; 
    attribute max_fanout of ready_r : signal is "2";

begin
--*******************************Main Body of Code****************************

    --________________________________ State machine __________________________    
    -- This state machine manages the phase alingment procedure of the GTX on the
    -- receive side. The module is held in reset till the usrclk source is stable
    -- and RXRESETDONE is asserted. In the case that a MMCM is used to generate 
    -- rxusrclk, the mmcm_locked signal is used to indicate a stable usrclk source.
    -- Once RXRESETDONE and mmcm_locked are asserted, the state machine goes 
    -- into the align_reset_r state where RXDLYALIGNRESET is asserted for 20 cycles. 
    -- After this, it goes into the wait_before_setphase_r state for 32 cycles. 
    -- After asserting RXENPMAPHASEALIGN and waiting 32 cycles, it enters the 
    -- phase_align_r state where RXPMASETPHASE is asserted for 32 clock cycles. 
    -- After the port is deasserted, the state machine goes into a wait state for
    -- 32 cycles. This procedure is repeated 32 times.
    
    -- State registers
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if(RESET='1') then
                begin_r                 <=  '1' after DLY;
                align_reset_r           <=  '0' after DLY;
                wait_before_setphase_r  <=  '0' after DLY;
                phase_align_r           <=  '0' after DLY;
                wait_after_sync_r       <=  '0' after DLY;
                ready_r                 <=  '0' after DLY;
            else
                begin_r                 <=  '0' after DLY;
                align_reset_r           <=  next_align_reset_c after DLY;
                wait_before_setphase_r  <=  next_wait_before_setphase_c after DLY;
                phase_align_r           <=  next_phase_align_c after DLY;
                wait_after_sync_r       <=  next_wait_after_sync_c after DLY;
                ready_r                 <=  next_ready_c after DLY;
            end if;
        end if;
    end process;

    -- Next state logic
    next_align_reset_c          <=  begin_r or
                                    (align_reset_r and  not count_align_reset_complete_r);
                                 
    next_wait_before_setphase_c <=  (align_reset_r and count_align_reset_complete_r) or
                                    (wait_before_setphase_r and not count_32_wait_complete_r);                                
                                        
    next_phase_align_c          <=  (wait_before_setphase_r and count_32_wait_complete_r) or
                                    (phase_align_r and not count_32_setphase_complete_r) or
                                    (wait_after_sync_r and count_32_wait_complete_r and not sync_32_times_done_r);
                                        
    next_wait_after_sync_c      <=  (phase_align_r and count_32_setphase_complete_r) or
                                    (wait_after_sync_r and not count_32_wait_complete_r);

    next_ready_c                <=  (wait_after_sync_r and count_32_wait_complete_r and sync_32_times_done_r) or
                                    ready_r;

    --______ Counter for holding RXDLYALIGNRESET for 20 RXUSRCLK2 cycles ______
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if (align_reset_r='0') then
                align_reset_counter_r <= (others=>'0') after DLY;
            else
                align_reset_counter_r <= align_reset_counter_r + 1 after DLY;
            end if;
        end if ;
    end process;
        
    count_align_reset_complete_r <= align_reset_counter_r(4)
                                    and align_reset_counter_r(2);
                                    
    --_______Counter for waiting 32 clock cycles before RXPMASETPHASE _________
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if ((wait_before_setphase_r='0') and (wait_after_sync_r='0')) then
                wait_before_setphase_counter_r <= (others=>'0') after DLY;
            else
                wait_before_setphase_counter_r <= wait_before_setphase_counter_r + 1 after DLY;
            end if;
        end if;
    end process;

    count_32_wait_complete_r <= wait_before_setphase_counter_r(5);
    
    --_______________ Counter for holding SYNC for SYNC_CYCLES ________________
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if (phase_align_r='0') then
                sync_counter_r <= (others=>'0') after DLY;
            else
                sync_counter_r <= sync_counter_r + 1 after DLY;
            end if;
        end if;
    end process;

    count_32_setphase_complete_r <= sync_counter_r(5);

    --__________ Counter for counting number of times sync is done ____________
    process( USER_CLK )
    begin
        if(USER_CLK'event and USER_CLK = '1') then
            if (RESET='1') then
                sync_done_count_r <= (others=>'0') after DLY;
            elsif((count_32_wait_complete_r ='1') and (phase_align_r = '1')) then
                sync_done_count_r <= sync_done_count_r + 1 after DLY;
            end if;
        end if;
    end process;

    sync_32_times_done_r <= sync_done_count_r(5);

    --_______________ Assign the phase align ports into the GTX _______________

    RXDLYALIGNRESET      <=  align_reset_r;
    RXENPMAPHASEALIGN    <=  (not begin_r) and (not align_reset_r);
    RXPMASETPHASE        <=  phase_align_r;
    RXDLYALIGNDISABLE    <=  '1';
    RXDLYALIGNOVERRIDE   <=  '1';

    --_______________________ Assign the sync_done port _______________________
    
    SYNC_DONE <= ready_r;
    
    
end RTL;
