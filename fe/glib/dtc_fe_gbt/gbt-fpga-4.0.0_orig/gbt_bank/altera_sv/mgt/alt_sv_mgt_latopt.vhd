--=================================================================================================--
--##################################   Package Information   ######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           Altera Stratix V - Multi Gigabit Transceivers latency-optimized
--                                                                                                 
-- Language:              VHDL'93                                                                 
--                                                                                                   
-- Target Device:         Altera Stratix V                                                      
-- Tool version:          Quartus II 14.0                                                              
--                                                                                                   
-- Revision:              3.6                                                                      
--
-- Description:           
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        27/03/2014   3.0       M. Barros Marin   First .vhd module definition           
--
--                        05/10/2014   3.5       M. Barros Marin   - Minor modification
--                                                                 - Updated to Quartus II 14.0           
--
--                        09/02/2015   3.6       M. Barros Marin   - Modified Tx_WORDCLK monitor
--                                                                 - Modified Rx bitslip control
--                                                                 - Minor modification
--
--
-- Additional Comments:                                                                               
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!                                                                                           !!
-- !! * The different parameters of the GBT Bank are set through:                               !!  
-- !!   (Note!! These parameters are vendor specific)                                           !!                    
-- !!                                                                                           !!
-- !!   - The MGT control ports of the GBT Bank module (these ports are listed in the records   !!
-- !!     of the file "<vendor>_<device>_gbt_bank_package.vhd").                                !! 
-- !!     (e.g. xlx_v6_gbt_bank_package.vhd)                                                    !!
-- !!                                                                                           !!  
-- !!   - By modifying the content of the file "<vendor>_<device>_gbt_bank_user_setup.vhd".     !!
-- !!     (e.g. xlx_v6_gbt_bank_user_setup.vhd)                                                 !! 
-- !!                                                                                           !! 
-- !! * The "<vendor>_<device>_gbt_bank_user_setup.vhd" is the only file of the GBT Bank that   !!
-- !!   may be modified by the user. The rest of the files MUST be used as is.                  !!
-- !!                                                                                           !!  
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                                                                   
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Altera devices library:
library altera; 
library altera_mf;
library lpm;
use altera.altera_primitives_components.all;   
use altera_mf.altera_mf_components.all;
use lpm.lpm_components.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;
use work.gbt_banks_user_setup.all;

-- Libraries for direct instantiation:
library alt_sv_gx_latopt_x1;
library alt_sv_gx_latopt_x2;
library alt_sv_gx_latopt_x3;
library gx_latopt_x4;
library gx_latopt_x5;
library gx_latopt_x6;
		  
library alt_sv_gx_reconfctrl_x1;
library alt_sv_gx_reconfctrl_x2;
library alt_sv_gx_reconfctrl_x3;
library mgt_reconfctrl_x4;
library mgt_reconfctrl_x5;
library mgt_reconfctrl_x6;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity mgt_latopt is
   generic (
      GBT_BANK_ID                               : integer := 1;  
		NUM_LINKS											: integer := 1;
		TX_OPTIMIZATION									: integer range 0 to 1 := STANDARD;
		RX_OPTIMIZATION									: integer range 0 to 1 := STANDARD;
		TX_ENCODING											: integer range 0 to 1 := GBT_FRAME;
		RX_ENCODING											: integer range 0 to 1 := GBT_FRAME
   ); 
   port (      

      --===============--  
      -- Clocks scheme --  
      --===============--  

      MGT_CLKS_I                                   : in  gbtBankMgtClks_i_R;
      MGT_CLKS_O                                   : out gbtBankMgtClks_o_R;        

      --=========--  
      -- MGT I/O --  
      --=========--  

      MGT_I                                        : in  mgt_i_R;
      MGT_O                                        : out mgt_o_R;

      --=============-- 
      -- GBT Control -- 
      --=============-- 
      
		-- Phase monitoring:
		--------------------
		
		PHASE_ALIGNED_I										: in  std_logic;
		PHASE_COMPUTING_DONE_I								: in  std_logic;
		
      GBTTX_MGTTX_RDY_O                            : out std_logic_vector       (1 to NUM_LINKS);
      
      GBTRX_MGTRX_RDY_O                            : out std_logic_vector       (1 to NUM_LINKS);
      GBTRX_RXWORDCLK_READY_O                      : out std_logic_vector       (1 to NUM_LINKS);
      GBTRX_HEADER_LOCKED_I                        : in  std_logic_vector       (1 to NUM_LINKS);
      GBTRX_BITSLIP_NBR_I                          : in  rxBitSlipNbr_mxnbit_A  (1 to NUM_LINKS);      
      
		--========--
		-- Clocks --
		--========--
		TX_WORDCLK_O										: out std_logic_vector      (1 to NUM_LINKS);
      RX_WORDCLK_O										: out std_logic_vector      (1 to NUM_LINKS);
            
      --=======-- 
      -- Words -- 
      --=======-- 
 
      GBTTX_WORD_I                                 : in  word_mxnbit_A          (1 to NUM_LINKS);     
      GBTRX_WORD_O                                 : out word_mxnbit_A          (1 to NUM_LINKS) 
   
   );
end mgt_latopt;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of mgt_latopt is 

   --================================ Signal Declarations ================================--
   
   --======================--
   -- GX reset controllers --
   --======================--  
   
   signal txAnalogReset_from_gxRstCtrl             : std_logic_vector           (1 to NUM_LINKS);
   signal txDigitalReset_from_gxRstCtrl            : std_logic_vector           (1 to NUM_LINKS);
   signal txReady_from_gxRstCtrl                   : std_logic_vector           (1 to NUM_LINKS);
   ------------------------------------------------   
   signal rxAnalogreset_from_gxRstCtrl             : std_logic_vector           (1 to NUM_LINKS);
   signal rxDigitalreset_from_gxRstCtrl            : std_logic_vector           (1 to NUM_LINKS);
   signal rxReady_from_gxRstCtrl                   : std_logic_vector           (1 to NUM_LINKS);

   --=======================--
   -- TX_WORDCLK monitoring --
   --=======================--
	signal resetGxTx_from_txWordMon						: std_logic;
	
   --====================--
   -- RX phase alignment --
   --====================--
   
   signal nbr_to_rxBitSlipControl                  : rxBitSlipNbr_mxnbit_A      (1 to NUM_LINKS);
   signal run_to_rxBitSlipControl                  : std_logic_vector           (1 to NUM_LINKS);
   signal rxBitSlip_from_rxBitSlipControl          : std_logic_vector           (1 to NUM_LINKS);
   signal rxBitSlip_to_gxLatOpt                    : std_logic_vector           (1 to NUM_LINKS);   
   signal resetGxRx_from_rxBitSlipControl          : std_logic_vector           (1 to NUM_LINKS);   
   signal done_from_rxBitSlipControl               : std_logic_vector           (1 to NUM_LINKS);  
   
   --=========--
   -- ATX PLL --
   --=========-- 
	signal reconfToATXPLL									: std_logic_vector			  (69 downto 0);
	signal ATXPLLToReconf									: std_logic_vector			  (45 downto 0);
	signal ATXPLL_clkout										: std_logic;
	signal ATXPLLLocked										: std_logic;
	
   --================================================--
   -- Multi-Gigabit Transceivers (latency-optimized) --
   --================================================--      

   signal rxIsLockedToData_from_gxLatOpt           : std_logic_vector           (1 to NUM_LINKS);   
   signal txCalBusy_from_gxLatOpt                  : std_logic_vector           (1 to NUM_LINKS);
   signal rxCalBusy_from_gxLatOpt                  : std_logic_vector           (1 to NUM_LINKS); 
   
	signal reconfToXCVR										: std_logic_vector			  ((NUM_LINKS*70)-1 downto 0);
	signal XCVRToReconf										: std_logic_vector			  ((NUM_LINKS*46)-1 downto 0);
   
	signal tx_usrclk											: std_logic_vector			  ((NUM_LINKS-1) downto 0);
	signal rx_usrclk											: std_logic_vector			  ((NUM_LINKS-1) downto 0);
	--=====================================================================================--   
   
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--
   
   --==================================== User Logic =====================================-- 
   
   --=============--
   -- Assignments --
   --=============--
   
   commonAssign_gen: for i in 1 to NUM_LINKS generate
   
      MGT_O.mgtLink(i).txCal_busy                  <= txCalBusy_from_gxLatOpt(i);
      MGT_O.mgtLink(i).rxCal_busy                  <= rxCalBusy_from_gxLatOpt(i);
		
      MGT_O.mgtLink(i).tx_ready                    <= txReady_from_gxRstCtrl(i) when TX_OPTIMIZATION = STANDARD else
																		txReady_from_gxRstCtrl(i) and PHASE_ALIGNED_I;
																		
      MGT_O.mgtLink(i).rx_ready                    <= rxReady_from_gxRstCtrl(i);
		
      GBTTX_MGTTX_RDY_O(i)                         <= txReady_from_gxRstCtrl(i);         
      GBTRX_MGTRX_RDY_O(i)                         <= rxReady_from_gxRstCtrl(i);
		
      MGT_O.mgtLink(i).rxIsLocked_toData           <= rxIsLockedToData_from_gxLatOpt(i);		
		
      MGT_O.mgtLink(i).ready                       <= txReady_from_gxRstCtrl(i) and rxReady_from_gxRstCtrl(i) when TX_OPTIMIZATION = STANDARD else
																		txReady_from_gxRstCtrl(i) and rxReady_from_gxRstCtrl(i) and PHASE_ALIGNED_I;
   
   end generate;
   
   --======================--
   -- GX reset controllers --
   --======================--
   
   gxRstCtrl_gen: for i in 1 to NUM_LINKS generate
   
      gxRstCtrl: entity work.alt_sv_mgt_resetctrl       
         port map (
            CLK_I                                  => MGT_CLKS_I.mgtRefClk, 
            ---------------------------------------            
            TX_RESET_I                             => MGT_I.mgtLink(i).tx_reset or resetGxTx_from_txWordMon,    
            RX_RESET_I                             => MGT_I.mgtLink(i).rx_reset or resetGxRx_from_rxBitSlipControl(i),    
            ---------------------------------------             
            TX_ANALOGRESET_O                       => txAnalogReset_from_gxRstCtrl(i),
            TX_DIGITALRESET_O                      => txDigitalReset_from_gxRstCtrl(i),                  
            TX_READY_O                             => txReady_from_gxRstCtrl(i),                         
            PLL_LOCKED_I                           => ATXPLLLocked,                       
            TX_CAL_BUSY_I                          => txCalBusy_from_gxLatOpt(i),                          
            ---------------------------------------             
            RX_ANALOGRESET_O                       => rxAnalogreset_from_gxRstCtrl(i),
            RX_DIGITALRESET_O                      => rxDigitalreset_from_gxRstCtrl(i),                          
            RX_READY_O                             => rxReady_from_gxRstCtrl(i),                         
            RX_IS_LOCKEDTODATA_I                   => rxIsLockedToData_from_gxLatOpt(i),                     
            RX_CAL_BUSY_I                          => rxCalBusy_from_gxLatOpt(i)                                 
         );
   
   end generate;

   --=======================--
   -- TX_WORDCLK monitoring --
   --=======================--
 
   --txWordClkMon_gen: if TX_OPTIMIZATION = LATENCY_OPTIMIZED generate
   --   
   --   -- Comment: * The phase of TX_WORDCLK may be 0deg or 180deg with respect to the phase of the MGT_REFCLK.
   --   --
   --   --          * The module "txWordClkMon" monitors the phase of TX_WORDCLK and if it is not the one chosen by 
   --   --            the user, resets the GX TX until having the correct phase.
	--	
	--	
	--	processingStage: process(MGT_CLKS_I.txFrameClk, MGT_I.mgtCommon.txWrdClkMon_enable)
	--	begin
	--	
	--		if (MGT_I.mgtCommon.txWrdClkMon_enable = '0') then
	--			resetGxTx_from_txWordMon <= '0';
	--			
	--		elsif rising_edge(MGT_CLKS_I.txFrameClk) then
	--	
	--			if (PHASE_ALIGNED_I = '0' and PHASE_COMPUTING_DONE_I = '1') then
	--				resetGxTx_from_txWordMon <= '1';
	--				
	--			else
	--				resetGxTx_from_txWordMon <= '0';
	--				
	--			end if;
	--			
	--		end if;
	--		
	--	end process;
   --  			
   --end generate;

   --txWordClkMon_no_gen: if TX_OPTIMIZATION = STANDARD generate
	--	resetGxTx_from_txWordMon <= '0';		
   --end generate;
    resetGxTx_from_txWordMon <= MGT_I.mgtCommon.rstTxPll;  
   --====================--
   -- RX phase alignment --
   --====================--
   
   -- Comment: Note!! The standard version of the GX does not align the phase of the  
   --                 RX_RECCLK (RX_WORDCLK) with respect to the TX_OUTCLK (TX_WORDCLK).
   
   rxPhaseAlign_numLinks_gen: for i in 1 to NUM_LINKS generate

      rxPhaseAlign_gen: if RX_OPTIMIZATION = LATENCY_OPTIMIZED generate
      
         -- Bitslip control module:
         --------------------------
         
         rxBitSlipControl: entity work.mgt_latopt_bitslipctrl 
            port map (
               RX_RESET_I                          => MGT_I.mgtLink(i).rx_reset,
               RX_WORDCLK_I                        => rx_usrclk(i-1),
               NUMBITSLIPS_I                       => nbr_to_rxBitSlipControl(i),
               ENABLE_I                            => run_to_rxBitSlipControl(i),
               MGT_RX_ODD_RESET_EN_I               => MGT_I.mgtLink(i).rxBitSlip_oddRstEn,
               BITSLIP_O                           => rxBitSlip_from_rxBitSlipControl(i),
               RESET_MGT_RX_O                      => resetGxRx_from_rxBitSlipControl(i),
               RESET_MGT_RX_ITERATIONS_O           => MGT_O.mgtLink(i).rxBitSlip_oddRstNbr,
               DONE_O                              => done_from_rxBitSlipControl(i)
            );
         
         MGT_O.mgtLink(i).rxWordClkReady           <= done_from_rxBitSlipControl(i);
         GBTRX_RXWORDCLK_READY_O(i)                <= done_from_rxBitSlipControl(i);
            
         -- Manual or auto bitslip control selection logic:
         --------------------------------------------------
         
         -- Comment: * MGT_I(i).rxBitSlip_enable must be '1' to enable the GX RX phase alignment.
         --
         --          * Manual control: MGT_I(i).rxBitSlip_ctrl = '1'
         --            Auto control  : MGT_I(i).rxBitSlip_ctrl = '0'
         --
         --          * In manual control, the user provides the number of bitslips (rxBitSlip_nbr)
         --            as well as triggers the GX RX phase alignment (rxBitSlip_run).
         
         rxBitSlip_to_gxLatOpt(i)     <= rxBitSlip_from_rxBitSlipControl(i) when     MGT_I.mgtLink(i).rxBitSlip_enable = '1'
                                       -----------------------------------------------------------------------------
                                       else '0'; 
                                      
         run_to_rxBitSlipControl(i) <= MGT_I.mgtLink(i).rxBitSlip_run       when     MGT_I.mgtLink(i).rxBitSlip_enable = '1' 
                                                                                 and MGT_I.mgtLink(i).rxBitSlip_ctrl   = '1'
                                       -----------------------------------------------------------------------------
                                       else GBTRX_HEADER_LOCKED_I(i)        when     MGT_I.mgtLink(i).rxBitSlip_enable = '1'
                                                                                 and MGT_I.mgtLink(i).rxBitSlip_ctrl   = '0'
                                       -----------------------------------------------------------------------------
                                       else '0';
                           
         nbr_to_rxBitSlipControl(i) <= MGT_I.mgtLink(i).rxBitSlip_nbr       when     MGT_I.mgtLink(i).rxBitSlip_enable = '1'
                                                                                 and MGT_I.mgtLink(i).rxBitSlip_ctrl   = '1'
                                        -----------------------------------------------------------------------------                                
                                        else GBTRX_BITSLIP_NBR_I(i)         when     MGT_I.mgtLink(i).rxBitSlip_enable = '1'
                                                                                 and MGT_I.mgtLink(i).rxBitSlip_ctrl   = '0'
                                        -----------------------------------------------------------------------------                                
                                        else (others => '0');   
      
      end generate;
      
      rxPhaseAlign_no_gen: if RX_OPTIMIZATION = STANDARD generate
      
         -- Bitslip control module:
         --------------------------
        
         MGT_O.mgtLink(i).rxWordClkReady           <= rxReady_from_gxRstCtrl(i);
         GBTRX_RXWORDCLK_READY_O(i)                <= rxReady_from_gxRstCtrl(i);
         resetGxRx_from_rxBitSlipControl				<= (others => '0');
			
         -- Manual or auto bitslip control selection logic:
         --------------------------------------------------
      
         rxBitSlip_to_gxLatOpt(i)                  <= '0';
      
      end generate;
      
   end generate;
   
   --================================================--
   -- ATX PLL													  --
   --================================================-- 
	atx_pll_TXStd: if TX_OPTIMIZATION = STANDARD generate
		atx_pll: entity work.alt_sv_mgt_txpll
			port map (      
				RESET_I             => MGT_I.mgtLink(1).tx_reset, --MGT_I.mgtCommon.ATXPLL_reset,
				
				MGT_REFCLK_I        => MGT_CLKS_I.mgtRefClk,
				FEEDBACK_CLK_I      => '0',
				
				EXTGXTXPLL_CLK_O    => ATXPLL_clkout,
				
				--POWER_DOWN_O        =>
				LOCKED_O            => ATXPLLLocked,
								
				RECONFIG_I          => reconfToATXPLL,
				RECONFIG_O          => ATXPLLToReconf
			);
	end generate;
	
	
	atx_pll_TXLatOpt: if TX_OPTIMIZATION = LATENCY_OPTIMIZED generate
		atx_pll: entity work.alt_sv_mgt_txpll
			port map (      
				RESET_I             => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon, --MGT_I.mgtCommon.ATXPLL_reset,
				
				MGT_REFCLK_I        => MGT_CLKS_I.mgtRefClk,
				FEEDBACK_CLK_I      => tx_usrclk(0),
				
				EXTGXTXPLL_CLK_O    => ATXPLL_clkout,
				
				--POWER_DOWN_O        =>
				LOCKED_O            => ATXPLLLocked,
								
				RECONFIG_I          => reconfToATXPLL,
				RECONFIG_O          => ATXPLLToReconf
			);
	end generate;
	
   --================================================--
   -- Multi-Gigabit Transceivers (latency-optimized) --
   --================================================--  
   
   -- MGT latency-optimized x1:
   ----------------------------
   
   gxLatOpt_x1_gen: if NUM_LINKS = 1 generate
	
      reconfGxLatOpt_x1: entity alt_sv_gx_reconfctrl_x1.alt_sv_gx_reconfctrl_x1
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_0_TO_XCVR                                     => reconfToXCVR,  
         CH0_0_FROM_XCVR                                   => XCVRToReconf,
         
			CH1_1_TO_XCVR                                     => reconfToATXPLL,
         CH1_1_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x1: entity alt_sv_gx_latopt_x1.alt_sv_gx_latopt_x1
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon, 
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1),
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout,               
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity, 
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity, 
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),  
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),          
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);						
			TX_WORDCLK_O(1) <= tx_usrclk(0);			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			
   end generate;
   
   -- MGT latency-optimized x2:
   ----------------------------
   
   gxLatOpt_x2_gen: if NUM_LINKS = 2 generate
	
      reconfGxLatOpt_x2: entity alt_sv_gx_reconfctrl_x2.alt_sv_gx_reconfctrl_x2
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_1_TO_XCVR                                     => reconfToXCVR,  
         CH0_1_FROM_XCVR                                   => XCVRToReconf,
         
			CH2_2_TO_XCVR                                     => reconfToATXPLL,
         CH2_2_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x2: entity alt_sv_gx_latopt_x2.alt_sv_gx_latopt_x2
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon,    
            
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_ANALOGRESET(1)                      => txAnalogReset_from_gxRstCtrl(2), 
				
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(1)                     => txDigitalReset_from_gxRstCtrl(2),
           
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
            RX_ANALOGRESET(1)                      => rxAnalogReset_from_gxRstCtrl(2),
            
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            RX_DIGITALRESET(1)                     => rxDigitalReset_from_gxRstCtrl(2),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout,    
				EXT_PLL_CLK(1)                         => ATXPLL_clkout,  
				
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
            TX_STD_CORECLKIN(1)                    => tx_usrclk(1),	
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_CLKSLIP(1)                          => rxBitSlip_to_gxLatOpt(2),
				
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(1)                   => MGT_O.mgtLink(2).rxIsLocked_toRef,      
            
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
            RX_IS_LOCKEDTODATA(1)                  => rxIsLockedToData_from_gxLatOpt(2),
            
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
            RX_SERIALLPBKEN(1)                     => MGT_I.mgtLink(2).loopBack, 
            
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity,      
            TX_STD_POLINV(1)                       => MGT_I.mgtLink(2).tx_polarity,         
            
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity,      
            RX_STD_POLINV(1)                       => MGT_I.mgtLink(2).rx_polarity,           
            
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),         
            TX_CAL_BUSY(1)                         => txCalBusy_from_gxLatOpt(2),          
            
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),         
            RX_CAL_BUSY(1)                         => rxCalBusy_from_gxLatOpt(2),          
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,                      
            TX_SERIAL_DATA(1)                      => MGT_O.mgtLink(2).txSerialData,                         
            
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,       
            RX_SERIAL_DATA(1)                      => MGT_I.mgtLink(2).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),
            TX_PARALLEL_DATA( 79 downto 40)        => GBTTX_WORD_I(2),
				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1),
            RX_PARALLEL_DATA( 79 downto 40)        => GBTRX_WORD_O(2)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);
			MGT_CLKS_O.tx_wordClk(2) <= tx_usrclk(1);
			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);
			MGT_CLKS_O.rx_wordClk(2) <= rx_usrclk(1);
						
			TX_WORDCLK_O(1) <= tx_usrclk(0);
			TX_WORDCLK_O(2) <= tx_usrclk(1);
			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			RX_WORDCLK_O(2) <= rx_usrclk(1);
			
   end generate;  
   
   -- MGT latency-optimized x3:
   ----------------------------
   
   gxLatOpt_x3_gen: if NUM_LINKS = 3 generate
	
      reconfGxLatOpt_x3: entity alt_sv_gx_reconfctrl_x3.alt_sv_gx_reconfctrl_x3
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_2_TO_XCVR                                     => reconfToXCVR,  
         CH0_2_FROM_XCVR                                   => XCVRToReconf,
         
			CH3_3_TO_XCVR                                     => reconfToATXPLL,
         CH3_3_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x6: entity alt_sv_gx_latopt_x3.alt_sv_gx_latopt_x3
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon,    
            
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_ANALOGRESET(1)                      => txAnalogReset_from_gxRstCtrl(2), 
            TX_ANALOGRESET(2)                      => txAnalogReset_from_gxRstCtrl(3),  
				
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(1)                     => txDigitalReset_from_gxRstCtrl(2), 
            TX_DIGITALRESET(2)                     => txDigitalReset_from_gxRstCtrl(3),
           
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
            RX_ANALOGRESET(1)                      => rxAnalogReset_from_gxRstCtrl(2),
            RX_ANALOGRESET(2)                      => rxAnalogReset_from_gxRstCtrl(3),
            
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            RX_DIGITALRESET(1)                     => rxDigitalReset_from_gxRstCtrl(2),
            RX_DIGITALRESET(2)                     => rxDigitalReset_from_gxRstCtrl(3),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout,    
				EXT_PLL_CLK(1)                         => ATXPLL_clkout,   
				EXT_PLL_CLK(2)                         => ATXPLL_clkout,   
				
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
            TX_STD_CORECLKIN(1)                    => tx_usrclk(1),	
            TX_STD_CORECLKIN(2)                    => tx_usrclk(2),	
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_CLKSLIP(1)                          => rxBitSlip_to_gxLatOpt(2),
            RX_CLKSLIP(2)                          => rxBitSlip_to_gxLatOpt(3),
				
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(1)                   => MGT_O.mgtLink(2).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(2)                   => MGT_O.mgtLink(3).rxIsLocked_toRef,       
            
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
            RX_IS_LOCKEDTODATA(1)                  => rxIsLockedToData_from_gxLatOpt(2),
            RX_IS_LOCKEDTODATA(2)                  => rxIsLockedToData_from_gxLatOpt(3),
            
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
            RX_SERIALLPBKEN(1)                     => MGT_I.mgtLink(2).loopBack, 
            RX_SERIALLPBKEN(2)                     => MGT_I.mgtLink(3).loopBack, 
            
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity,      
            TX_STD_POLINV(1)                       => MGT_I.mgtLink(2).tx_polarity,      
            TX_STD_POLINV(2)                       => MGT_I.mgtLink(3).tx_polarity,         
            
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity,      
            RX_STD_POLINV(1)                       => MGT_I.mgtLink(2).rx_polarity,      
            RX_STD_POLINV(2)                       => MGT_I.mgtLink(3).rx_polarity,           
            
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),         
            TX_CAL_BUSY(1)                         => txCalBusy_from_gxLatOpt(2),         
            TX_CAL_BUSY(2)                         => txCalBusy_from_gxLatOpt(3),          
            
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),         
            RX_CAL_BUSY(1)                         => rxCalBusy_from_gxLatOpt(2),         
            RX_CAL_BUSY(2)                         => rxCalBusy_from_gxLatOpt(3),         
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,                      
            TX_SERIAL_DATA(1)                      => MGT_O.mgtLink(2).txSerialData,                      
            TX_SERIAL_DATA(2)                      => MGT_O.mgtLink(3).txSerialData,                        
            
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,       
            RX_SERIAL_DATA(1)                      => MGT_I.mgtLink(2).rxSerialData,       
            RX_SERIAL_DATA(2)                      => MGT_I.mgtLink(3).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),
            TX_PARALLEL_DATA( 79 downto 40)        => GBTTX_WORD_I(2),
            TX_PARALLEL_DATA(119 downto 80)        => GBTTX_WORD_I(3),
				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1),
            RX_PARALLEL_DATA( 79 downto 40)        => GBTRX_WORD_O(2),
            RX_PARALLEL_DATA(119 downto 80)        => GBTRX_WORD_O(3)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);
			MGT_CLKS_O.tx_wordClk(2) <= tx_usrclk(1);
			MGT_CLKS_O.tx_wordClk(3) <= tx_usrclk(2);
			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);
			MGT_CLKS_O.rx_wordClk(2) <= rx_usrclk(1);
			MGT_CLKS_O.rx_wordClk(3) <= rx_usrclk(2);
						
			TX_WORDCLK_O(1) <= tx_usrclk(0);
			TX_WORDCLK_O(2) <= tx_usrclk(1);
			TX_WORDCLK_O(3) <= tx_usrclk(2);
			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			RX_WORDCLK_O(2) <= rx_usrclk(1);
			RX_WORDCLK_O(3) <= rx_usrclk(2);
			
   end generate;
   
   -- MGT latency-optimized x4:
   ----------------------------
   
   gxLatOpt_x4_gen: if NUM_LINKS = 4 generate
	
      reconfGxLatOpt_x4: entity mgt_reconfctrl_x4.mgt_reconfctrl_x4
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_3_TO_XCVR                                     => reconfToXCVR,  
         CH0_3_FROM_XCVR                                   => XCVRToReconf,
         
			CH4_4_TO_XCVR                                     => reconfToATXPLL,
         CH4_4_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x4: entity gx_latopt_x4.gx_latopt_x4
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon,    
            
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_ANALOGRESET(1)                      => txAnalogReset_from_gxRstCtrl(2), 
            TX_ANALOGRESET(2)                      => txAnalogReset_from_gxRstCtrl(3), 
            TX_ANALOGRESET(3)                      => txAnalogReset_from_gxRstCtrl(4),  
				
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(1)                     => txDigitalReset_from_gxRstCtrl(2), 
            TX_DIGITALRESET(2)                     => txDigitalReset_from_gxRstCtrl(3), 
            TX_DIGITALRESET(3)                     => txDigitalReset_from_gxRstCtrl(4),
           
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
            RX_ANALOGRESET(1)                      => rxAnalogReset_from_gxRstCtrl(2),
            RX_ANALOGRESET(2)                      => rxAnalogReset_from_gxRstCtrl(3),
            RX_ANALOGRESET(3)                      => rxAnalogReset_from_gxRstCtrl(4),
            
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            RX_DIGITALRESET(1)                     => rxDigitalReset_from_gxRstCtrl(2),
            RX_DIGITALRESET(2)                     => rxDigitalReset_from_gxRstCtrl(3),
            RX_DIGITALRESET(3)                     => rxDigitalReset_from_gxRstCtrl(4),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(1)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(2)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(3)                         => ATXPLL_clkout, 
				
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
            TX_STD_CORECLKIN(1)                    => tx_usrclk(1),	
            TX_STD_CORECLKIN(2)                    => tx_usrclk(2),	
            TX_STD_CORECLKIN(3)                    => tx_usrclk(3),	
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_CLKSLIP(1)                          => rxBitSlip_to_gxLatOpt(2),
            RX_CLKSLIP(2)                          => rxBitSlip_to_gxLatOpt(3),
            RX_CLKSLIP(3)                          => rxBitSlip_to_gxLatOpt(4),
				
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(1)                   => MGT_O.mgtLink(2).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(2)                   => MGT_O.mgtLink(3).rxIsLocked_toRef,  
            RX_IS_LOCKEDTOREF(3)                   => MGT_O.mgtLink(4).rxIsLocked_toRef,       
            
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
            RX_IS_LOCKEDTODATA(1)                  => rxIsLockedToData_from_gxLatOpt(2),
            RX_IS_LOCKEDTODATA(2)                  => rxIsLockedToData_from_gxLatOpt(3),
            RX_IS_LOCKEDTODATA(3)                  => rxIsLockedToData_from_gxLatOpt(4),
            
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
            RX_SERIALLPBKEN(1)                     => MGT_I.mgtLink(2).loopBack, 
            RX_SERIALLPBKEN(2)                     => MGT_I.mgtLink(3).loopBack,  
            RX_SERIALLPBKEN(3)                     => MGT_I.mgtLink(4).loopBack,
            
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity,      
            TX_STD_POLINV(1)                       => MGT_I.mgtLink(2).tx_polarity,      
            TX_STD_POLINV(2)                       => MGT_I.mgtLink(3).tx_polarity,       
            TX_STD_POLINV(3)                       => MGT_I.mgtLink(4).tx_polarity,        
            
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity,      
            RX_STD_POLINV(1)                       => MGT_I.mgtLink(2).rx_polarity,      
            RX_STD_POLINV(2)                       => MGT_I.mgtLink(3).rx_polarity,    
            RX_STD_POLINV(3)                       => MGT_I.mgtLink(4).rx_polarity,         
            
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),         
            TX_CAL_BUSY(1)                         => txCalBusy_from_gxLatOpt(2),         
            TX_CAL_BUSY(2)                         => txCalBusy_from_gxLatOpt(3),        
            TX_CAL_BUSY(3)                         => txCalBusy_from_gxLatOpt(4),         
            
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),         
            RX_CAL_BUSY(1)                         => rxCalBusy_from_gxLatOpt(2),         
            RX_CAL_BUSY(2)                         => rxCalBusy_from_gxLatOpt(3),         
            RX_CAL_BUSY(3)                         => rxCalBusy_from_gxLatOpt(4),        
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,                      
            TX_SERIAL_DATA(1)                      => MGT_O.mgtLink(2).txSerialData,                      
            TX_SERIAL_DATA(2)                      => MGT_O.mgtLink(3).txSerialData,                      
            TX_SERIAL_DATA(3)                      => MGT_O.mgtLink(4).txSerialData,                        
            
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,       
            RX_SERIAL_DATA(1)                      => MGT_I.mgtLink(2).rxSerialData,       
            RX_SERIAL_DATA(2)                      => MGT_I.mgtLink(3).rxSerialData,       
            RX_SERIAL_DATA(3)                      => MGT_I.mgtLink(4).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),
            TX_PARALLEL_DATA( 79 downto 40)        => GBTTX_WORD_I(2),
            TX_PARALLEL_DATA(119 downto 80)        => GBTTX_WORD_I(3),
            TX_PARALLEL_DATA(159 downto 120)       => GBTTX_WORD_I(4),
				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1),
            RX_PARALLEL_DATA( 79 downto 40)        => GBTRX_WORD_O(2),
            RX_PARALLEL_DATA(119 downto 80)        => GBTRX_WORD_O(3),
            RX_PARALLEL_DATA(159 downto 120)       => GBTRX_WORD_O(4)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);
			MGT_CLKS_O.tx_wordClk(2) <= tx_usrclk(1);
			MGT_CLKS_O.tx_wordClk(3) <= tx_usrclk(2);
			MGT_CLKS_O.tx_wordClk(4) <= tx_usrclk(3);
			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);
			MGT_CLKS_O.rx_wordClk(2) <= rx_usrclk(1);
			MGT_CLKS_O.rx_wordClk(3) <= rx_usrclk(2);
			MGT_CLKS_O.rx_wordClk(4) <= rx_usrclk(3);
						
			TX_WORDCLK_O(1) <= tx_usrclk(0);
			TX_WORDCLK_O(2) <= tx_usrclk(1);
			TX_WORDCLK_O(3) <= tx_usrclk(2);
			TX_WORDCLK_O(4) <= tx_usrclk(3);
			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			RX_WORDCLK_O(2) <= rx_usrclk(1);
			RX_WORDCLK_O(3) <= rx_usrclk(2);
			RX_WORDCLK_O(4) <= rx_usrclk(3);
			
   end generate;
   
   -- MGT latency-optimized x5:
   ----------------------------
   
   gxLatOpt_x5_gen: if NUM_LINKS = 5 generate
	
      reconfGxLatOpt_x5: entity mgt_reconfctrl_x5.mgt_reconfctrl_x5
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_4_TO_XCVR                                     => reconfToXCVR,  
         CH0_4_FROM_XCVR                                   => XCVRToReconf,
         
			CH5_5_TO_XCVR                                     => reconfToATXPLL,
         CH5_5_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x5: entity gx_latopt_x5.gx_latopt_x5
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon,    
            
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_ANALOGRESET(1)                      => txAnalogReset_from_gxRstCtrl(2), 
            TX_ANALOGRESET(2)                      => txAnalogReset_from_gxRstCtrl(3), 
            TX_ANALOGRESET(3)                      => txAnalogReset_from_gxRstCtrl(4),  
            TX_ANALOGRESET(4)                      => txAnalogReset_from_gxRstCtrl(5), 
				
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(1)                     => txDigitalReset_from_gxRstCtrl(2), 
            TX_DIGITALRESET(2)                     => txDigitalReset_from_gxRstCtrl(3), 
            TX_DIGITALRESET(3)                     => txDigitalReset_from_gxRstCtrl(4), 
            TX_DIGITALRESET(4)                     => txDigitalReset_from_gxRstCtrl(5), 
           
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
            RX_ANALOGRESET(1)                      => rxAnalogReset_from_gxRstCtrl(2),
            RX_ANALOGRESET(2)                      => rxAnalogReset_from_gxRstCtrl(3),
            RX_ANALOGRESET(3)                      => rxAnalogReset_from_gxRstCtrl(4),
            RX_ANALOGRESET(4)                      => rxAnalogReset_from_gxRstCtrl(5),
            
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            RX_DIGITALRESET(1)                     => rxDigitalReset_from_gxRstCtrl(2),
            RX_DIGITALRESET(2)                     => rxDigitalReset_from_gxRstCtrl(3),
            RX_DIGITALRESET(3)                     => rxDigitalReset_from_gxRstCtrl(4),
            RX_DIGITALRESET(4)                     => rxDigitalReset_from_gxRstCtrl(5),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout,
				EXT_PLL_CLK(1)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(2)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(3)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(4)                         => ATXPLL_clkout, 
				
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
            TX_STD_CORECLKIN(1)                    => tx_usrclk(1),	
            TX_STD_CORECLKIN(2)                    => tx_usrclk(2),	
            TX_STD_CORECLKIN(3)                    => tx_usrclk(3),	
            TX_STD_CORECLKIN(4)                    => tx_usrclk(4),	
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_CLKSLIP(1)                          => rxBitSlip_to_gxLatOpt(2),
            RX_CLKSLIP(2)                          => rxBitSlip_to_gxLatOpt(3),
            RX_CLKSLIP(3)                          => rxBitSlip_to_gxLatOpt(4),
            RX_CLKSLIP(4)                          => rxBitSlip_to_gxLatOpt(5),
				
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(1)                   => MGT_O.mgtLink(2).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(2)                   => MGT_O.mgtLink(3).rxIsLocked_toRef,  
            RX_IS_LOCKEDTOREF(3)                   => MGT_O.mgtLink(4).rxIsLocked_toRef,  
            RX_IS_LOCKEDTOREF(4)                   => MGT_O.mgtLink(5).rxIsLocked_toRef,       
            
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
            RX_IS_LOCKEDTODATA(1)                  => rxIsLockedToData_from_gxLatOpt(2),
            RX_IS_LOCKEDTODATA(2)                  => rxIsLockedToData_from_gxLatOpt(3),
            RX_IS_LOCKEDTODATA(3)                  => rxIsLockedToData_from_gxLatOpt(4),
            RX_IS_LOCKEDTODATA(4)                  => rxIsLockedToData_from_gxLatOpt(5),
            
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
            RX_SERIALLPBKEN(1)                     => MGT_I.mgtLink(2).loopBack, 
            RX_SERIALLPBKEN(2)                     => MGT_I.mgtLink(3).loopBack,  
            RX_SERIALLPBKEN(3)                     => MGT_I.mgtLink(4).loopBack,
            RX_SERIALLPBKEN(4)                     => MGT_I.mgtLink(5).loopBack,
            
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity,      
            TX_STD_POLINV(1)                       => MGT_I.mgtLink(2).tx_polarity,      
            TX_STD_POLINV(2)                       => MGT_I.mgtLink(3).tx_polarity,       
            TX_STD_POLINV(3)                       => MGT_I.mgtLink(4).tx_polarity,      
            TX_STD_POLINV(4)                       => MGT_I.mgtLink(5).tx_polarity,        
            
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity,      
            RX_STD_POLINV(1)                       => MGT_I.mgtLink(2).rx_polarity,      
            RX_STD_POLINV(2)                       => MGT_I.mgtLink(3).rx_polarity,    
            RX_STD_POLINV(3)                       => MGT_I.mgtLink(4).rx_polarity,    
            RX_STD_POLINV(4)                       => MGT_I.mgtLink(5).rx_polarity,           
            
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),         
            TX_CAL_BUSY(1)                         => txCalBusy_from_gxLatOpt(2),         
            TX_CAL_BUSY(2)                         => txCalBusy_from_gxLatOpt(3),        
            TX_CAL_BUSY(3)                         => txCalBusy_from_gxLatOpt(4),         
            TX_CAL_BUSY(4)                         => txCalBusy_from_gxLatOpt(5),          
            
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),         
            RX_CAL_BUSY(1)                         => rxCalBusy_from_gxLatOpt(2),         
            RX_CAL_BUSY(2)                         => rxCalBusy_from_gxLatOpt(3),         
            RX_CAL_BUSY(3)                         => rxCalBusy_from_gxLatOpt(4),        
            RX_CAL_BUSY(4)                         => rxCalBusy_from_gxLatOpt(5),       
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,                      
            TX_SERIAL_DATA(1)                      => MGT_O.mgtLink(2).txSerialData,                      
            TX_SERIAL_DATA(2)                      => MGT_O.mgtLink(3).txSerialData,                      
            TX_SERIAL_DATA(3)                      => MGT_O.mgtLink(4).txSerialData,                     
            TX_SERIAL_DATA(4)                      => MGT_O.mgtLink(5).txSerialData,                        
            
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,       
            RX_SERIAL_DATA(1)                      => MGT_I.mgtLink(2).rxSerialData,       
            RX_SERIAL_DATA(2)                      => MGT_I.mgtLink(3).rxSerialData,       
            RX_SERIAL_DATA(3)                      => MGT_I.mgtLink(4).rxSerialData,       
            RX_SERIAL_DATA(4)                      => MGT_I.mgtLink(5).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),
            TX_PARALLEL_DATA( 79 downto 40)        => GBTTX_WORD_I(2),
            TX_PARALLEL_DATA(119 downto 80)        => GBTTX_WORD_I(3),
            TX_PARALLEL_DATA(159 downto 120)       => GBTTX_WORD_I(4),
            TX_PARALLEL_DATA(199 downto 160)       => GBTTX_WORD_I(5),
				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1),
            RX_PARALLEL_DATA( 79 downto 40)        => GBTRX_WORD_O(2),
            RX_PARALLEL_DATA(119 downto 80)        => GBTRX_WORD_O(3),
            RX_PARALLEL_DATA(159 downto 120)       => GBTRX_WORD_O(4),
            RX_PARALLEL_DATA(199 downto 160)       => GBTRX_WORD_O(5)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);
			MGT_CLKS_O.tx_wordClk(2) <= tx_usrclk(1);
			MGT_CLKS_O.tx_wordClk(3) <= tx_usrclk(2);
			MGT_CLKS_O.tx_wordClk(4) <= tx_usrclk(3);
			MGT_CLKS_O.tx_wordClk(5) <= tx_usrclk(4);
			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);
			MGT_CLKS_O.rx_wordClk(2) <= rx_usrclk(1);
			MGT_CLKS_O.rx_wordClk(3) <= rx_usrclk(2);
			MGT_CLKS_O.rx_wordClk(4) <= rx_usrclk(3);
			MGT_CLKS_O.rx_wordClk(5) <= rx_usrclk(4);
						
			TX_WORDCLK_O(1) <= tx_usrclk(0);
			TX_WORDCLK_O(2) <= tx_usrclk(1);
			TX_WORDCLK_O(3) <= tx_usrclk(2);
			TX_WORDCLK_O(4) <= tx_usrclk(3);
			TX_WORDCLK_O(5) <= tx_usrclk(4);
			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			RX_WORDCLK_O(2) <= rx_usrclk(1);
			RX_WORDCLK_O(3) <= rx_usrclk(2);
			RX_WORDCLK_O(4) <= rx_usrclk(3);
			RX_WORDCLK_O(5) <= rx_usrclk(4);
			
   end generate;
   
   -- MGT latency-optimized x6:
   ----------------------------
   
   gxLatOpt_x6_gen: if NUM_LINKS = 6 generate
	
      reconfGxLatOpt_x6: entity mgt_reconfctrl_x6.mgt_reconfctrl_x6
      port map (
         RECONFIG_BUSY                                     => open,     
       
         MGMT_RST_RESET                                    => MGT_I.mgtCommon.reconf_reset,      
			MGMT_CLK_CLK                                      => MGT_I.mgtCommon.reconf_clk, 
			
         RECONFIG_MGMT_ADDRESS                             => MGT_I.mgtCommon.reconf_avmm_addr,    
         RECONFIG_MGMT_READ                                => MGT_I.mgtCommon.reconf_avmm_read,       
         RECONFIG_MGMT_READDATA                            => MGT_O.mgtCommon.reconf_avmm_readdata,      -- Comment: Note!! Left floating.   
         RECONFIG_MGMT_WAITREQUEST                         => MGT_O.mgtCommon.reconf_avmm_waitrequest,   -- Comment: Note!! Left floating.
         RECONFIG_MGMT_WRITE                               => MGT_I.mgtCommon.reconf_avmm_write,      
         RECONFIG_MGMT_WRITEDATA                           => MGT_I.mgtCommon.reconf_avmm_writedata,  
         
			CH0_5_TO_XCVR                                     => reconfToXCVR,  
         CH0_5_FROM_XCVR                                   => XCVRToReconf,
         
			CH6_6_TO_XCVR                                     => reconfToATXPLL,
         CH6_6_FROM_XCVR                                   => ATXPLLToReconf 
      );
		
      gxLatOpt_x6: entity gx_latopt_x6.gx_latopt_x6
         port map (
				-- Reset
				PLL_POWERDOWN(0)                       => MGT_I.mgtLink(1).tx_reset or resetGxTx_from_txWordMon,    
            
				TX_ANALOGRESET(0)                      => txAnalogReset_from_gxRstCtrl(1), 
            TX_ANALOGRESET(1)                      => txAnalogReset_from_gxRstCtrl(2), 
            TX_ANALOGRESET(2)                      => txAnalogReset_from_gxRstCtrl(3), 
            TX_ANALOGRESET(3)                      => txAnalogReset_from_gxRstCtrl(4),  
            TX_ANALOGRESET(4)                      => txAnalogReset_from_gxRstCtrl(5),
            TX_ANALOGRESET(5)                      => txAnalogReset_from_gxRstCtrl(6),  
				
            TX_DIGITALRESET(0)                     => txDigitalReset_from_gxRstCtrl(1), 
            TX_DIGITALRESET(1)                     => txDigitalReset_from_gxRstCtrl(2), 
            TX_DIGITALRESET(2)                     => txDigitalReset_from_gxRstCtrl(3), 
            TX_DIGITALRESET(3)                     => txDigitalReset_from_gxRstCtrl(4), 
            TX_DIGITALRESET(4)                     => txDigitalReset_from_gxRstCtrl(5),  
            TX_DIGITALRESET(5)                     => txDigitalReset_from_gxRstCtrl(6),
           
			   RX_ANALOGRESET(0)                      => rxAnalogReset_from_gxRstCtrl(1),
            RX_ANALOGRESET(1)                      => rxAnalogReset_from_gxRstCtrl(2),
            RX_ANALOGRESET(2)                      => rxAnalogReset_from_gxRstCtrl(3),
            RX_ANALOGRESET(3)                      => rxAnalogReset_from_gxRstCtrl(4),
            RX_ANALOGRESET(4)                      => rxAnalogReset_from_gxRstCtrl(5),
            RX_ANALOGRESET(5)                      => rxAnalogReset_from_gxRstCtrl(6),
            
				RX_DIGITALRESET(0)                     => rxDigitalReset_from_gxRstCtrl(1),
            RX_DIGITALRESET(1)                     => rxDigitalReset_from_gxRstCtrl(2),
            RX_DIGITALRESET(2)                     => rxDigitalReset_from_gxRstCtrl(3),
            RX_DIGITALRESET(3)                     => rxDigitalReset_from_gxRstCtrl(4),
            RX_DIGITALRESET(4)                     => rxDigitalReset_from_gxRstCtrl(5),
            RX_DIGITALRESET(5)                     => rxDigitalReset_from_gxRstCtrl(6),
            
				-- Clocks
				EXT_PLL_CLK(0)                         => ATXPLL_clkout, 
				EXT_PLL_CLK(1)                         => ATXPLL_clkout,  
				EXT_PLL_CLK(2)                         => ATXPLL_clkout,  
				EXT_PLL_CLK(3)                         => ATXPLL_clkout,  
				EXT_PLL_CLK(4)                         => ATXPLL_clkout,  
				EXT_PLL_CLK(5)                         => ATXPLL_clkout,  
				
            RX_CDR_REFCLK(0)                       => MGT_CLKS_I.mgtRefClk, 
				
            TX_STD_CORECLKIN(0)                    => tx_usrclk(0),
            TX_STD_CORECLKIN(1)                    => tx_usrclk(1),	
            TX_STD_CORECLKIN(2)                    => tx_usrclk(2),	
            TX_STD_CORECLKIN(3)                    => tx_usrclk(3),	
            TX_STD_CORECLKIN(4)                    => tx_usrclk(4),	
            TX_STD_CORECLKIN(5)                    => tx_usrclk(5),	
				
            RX_STD_CORECLKIN                       => rx_usrclk, 
				
            TX_STD_CLKOUT                          => tx_usrclk,         
            RX_STD_CLKOUT                          => rx_usrclk,         
            
				-- Configuration
				RX_CLKSLIP(0)                          => rxBitSlip_to_gxLatOpt(1),
            RX_CLKSLIP(1)                          => rxBitSlip_to_gxLatOpt(2),
            RX_CLKSLIP(2)                          => rxBitSlip_to_gxLatOpt(3),
            RX_CLKSLIP(3)                          => rxBitSlip_to_gxLatOpt(4),
            RX_CLKSLIP(4)                          => rxBitSlip_to_gxLatOpt(5),
            RX_CLKSLIP(5)                          => rxBitSlip_to_gxLatOpt(6),
				
            RX_IS_LOCKEDTOREF(0)                   => MGT_O.mgtLink(1).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(1)                   => MGT_O.mgtLink(2).rxIsLocked_toRef,    
            RX_IS_LOCKEDTOREF(2)                   => MGT_O.mgtLink(3).rxIsLocked_toRef,  
            RX_IS_LOCKEDTOREF(3)                   => MGT_O.mgtLink(4).rxIsLocked_toRef,  
            RX_IS_LOCKEDTOREF(4)                   => MGT_O.mgtLink(5).rxIsLocked_toRef, 
            RX_IS_LOCKEDTOREF(5)                   => MGT_O.mgtLink(6).rxIsLocked_toRef,       
            
				RX_IS_LOCKEDTODATA(0)                  => rxIsLockedToData_from_gxLatOpt(1),
            RX_IS_LOCKEDTODATA(1)                  => rxIsLockedToData_from_gxLatOpt(2),
            RX_IS_LOCKEDTODATA(2)                  => rxIsLockedToData_from_gxLatOpt(3),
            RX_IS_LOCKEDTODATA(3)                  => rxIsLockedToData_from_gxLatOpt(4),
            RX_IS_LOCKEDTODATA(4)                  => rxIsLockedToData_from_gxLatOpt(5),
            RX_IS_LOCKEDTODATA(5)                  => rxIsLockedToData_from_gxLatOpt(6),
            
				RX_SERIALLPBKEN(0)                     => MGT_I.mgtLink(1).loopBack, 
            RX_SERIALLPBKEN(1)                     => MGT_I.mgtLink(2).loopBack, 
            RX_SERIALLPBKEN(2)                     => MGT_I.mgtLink(3).loopBack,  
            RX_SERIALLPBKEN(3)                     => MGT_I.mgtLink(4).loopBack,
            RX_SERIALLPBKEN(4)                     => MGT_I.mgtLink(5).loopBack,
            RX_SERIALLPBKEN(5)                     => MGT_I.mgtLink(6).loopBack,
            
				TX_STD_POLINV(0)                       => MGT_I.mgtLink(1).tx_polarity,      
            TX_STD_POLINV(1)                       => MGT_I.mgtLink(2).tx_polarity,      
            TX_STD_POLINV(2)                       => MGT_I.mgtLink(3).tx_polarity,       
            TX_STD_POLINV(3)                       => MGT_I.mgtLink(4).tx_polarity,      
            TX_STD_POLINV(4)                       => MGT_I.mgtLink(5).tx_polarity,      
            TX_STD_POLINV(5)                       => MGT_I.mgtLink(6).tx_polarity,        
            
				RX_STD_POLINV(0)                       => MGT_I.mgtLink(1).rx_polarity,      
            RX_STD_POLINV(1)                       => MGT_I.mgtLink(2).rx_polarity,      
            RX_STD_POLINV(2)                       => MGT_I.mgtLink(3).rx_polarity,    
            RX_STD_POLINV(3)                       => MGT_I.mgtLink(4).rx_polarity,    
            RX_STD_POLINV(4)                       => MGT_I.mgtLink(5).rx_polarity,  
            RX_STD_POLINV(5)                       => MGT_I.mgtLink(6).rx_polarity,          
            
				TX_CAL_BUSY(0)                         => txCalBusy_from_gxLatOpt(1),         
            TX_CAL_BUSY(1)                         => txCalBusy_from_gxLatOpt(2),         
            TX_CAL_BUSY(2)                         => txCalBusy_from_gxLatOpt(3),        
            TX_CAL_BUSY(3)                         => txCalBusy_from_gxLatOpt(4),         
            TX_CAL_BUSY(4)                         => txCalBusy_from_gxLatOpt(5),        
            TX_CAL_BUSY(5)                         => txCalBusy_from_gxLatOpt(6),         
            
				RX_CAL_BUSY(0)                         => rxCalBusy_from_gxLatOpt(1),         
            RX_CAL_BUSY(1)                         => rxCalBusy_from_gxLatOpt(2),         
            RX_CAL_BUSY(2)                         => rxCalBusy_from_gxLatOpt(3),         
            RX_CAL_BUSY(3)                         => rxCalBusy_from_gxLatOpt(4),        
            RX_CAL_BUSY(4)                         => rxCalBusy_from_gxLatOpt(5),          
            RX_CAL_BUSY(5)                         => rxCalBusy_from_gxLatOpt(6),        
            
				-- Reconf
				RECONFIG_TO_XCVR                       => reconfToXCVR,  
            RECONFIG_FROM_XCVR                     => XCVRToReconf, 
            
				-- Data
				
            TX_SERIAL_DATA(0)                      => MGT_O.mgtLink(1).txSerialData,                      
            TX_SERIAL_DATA(1)                      => MGT_O.mgtLink(2).txSerialData,                      
            TX_SERIAL_DATA(2)                      => MGT_O.mgtLink(3).txSerialData,                      
            TX_SERIAL_DATA(3)                      => MGT_O.mgtLink(4).txSerialData,                     
            TX_SERIAL_DATA(4)                      => MGT_O.mgtLink(5).txSerialData,                     
            TX_SERIAL_DATA(5)                      => MGT_O.mgtLink(6).txSerialData,                        
            
				RX_SERIAL_DATA(0)                      => MGT_I.mgtLink(1).rxSerialData,       
            RX_SERIAL_DATA(1)                      => MGT_I.mgtLink(2).rxSerialData,       
            RX_SERIAL_DATA(2)                      => MGT_I.mgtLink(3).rxSerialData,       
            RX_SERIAL_DATA(3)                      => MGT_I.mgtLink(4).rxSerialData,       
            RX_SERIAL_DATA(4)                      => MGT_I.mgtLink(5).rxSerialData,         
            RX_SERIAL_DATA(5)                      => MGT_I.mgtLink(6).rxSerialData,     
            
				TX_PARALLEL_DATA( 39 downto  0)        => GBTTX_WORD_I(1),
            TX_PARALLEL_DATA( 79 downto 40)        => GBTTX_WORD_I(2),
            TX_PARALLEL_DATA(119 downto 80)        => GBTTX_WORD_I(3),
            TX_PARALLEL_DATA(159 downto 120)       => GBTTX_WORD_I(4),
            TX_PARALLEL_DATA(199 downto 160)       => GBTTX_WORD_I(5),
            TX_PARALLEL_DATA(239 downto 200)       => GBTTX_WORD_I(6),
				
            RX_PARALLEL_DATA( 39 downto  0)        => GBTRX_WORD_O(1),
            RX_PARALLEL_DATA( 79 downto 40)        => GBTRX_WORD_O(2),
            RX_PARALLEL_DATA(119 downto 80)        => GBTRX_WORD_O(3),
            RX_PARALLEL_DATA(159 downto 120)       => GBTRX_WORD_O(4),
            RX_PARALLEL_DATA(199 downto 160)       => GBTRX_WORD_O(5),
            RX_PARALLEL_DATA(239 downto 200)       => GBTRX_WORD_O(6)
         );
               
			MGT_CLKS_O.tx_wordClk(1) <= tx_usrclk(0);
			MGT_CLKS_O.tx_wordClk(2) <= tx_usrclk(1);
			MGT_CLKS_O.tx_wordClk(3) <= tx_usrclk(2);
			MGT_CLKS_O.tx_wordClk(4) <= tx_usrclk(3);
			MGT_CLKS_O.tx_wordClk(5) <= tx_usrclk(4);
			MGT_CLKS_O.tx_wordClk(6) <= tx_usrclk(5);
			
			MGT_CLKS_O.rx_wordClk(1) <= rx_usrclk(0);
			MGT_CLKS_O.rx_wordClk(2) <= rx_usrclk(1);
			MGT_CLKS_O.rx_wordClk(3) <= rx_usrclk(2);
			MGT_CLKS_O.rx_wordClk(4) <= rx_usrclk(3);
			MGT_CLKS_O.rx_wordClk(5) <= rx_usrclk(4);
			MGT_CLKS_O.rx_wordClk(6) <= rx_usrclk(5);
						
			TX_WORDCLK_O(1) <= tx_usrclk(0);
			TX_WORDCLK_O(2) <= tx_usrclk(1);
			TX_WORDCLK_O(3) <= tx_usrclk(2);
			TX_WORDCLK_O(4) <= tx_usrclk(3);
			TX_WORDCLK_O(5) <= tx_usrclk(4);
			TX_WORDCLK_O(6) <= tx_usrclk(5);
			
			RX_WORDCLK_O(1) <= rx_usrclk(0);
			RX_WORDCLK_O(2) <= rx_usrclk(1);
			RX_WORDCLK_O(3) <= rx_usrclk(2);
			RX_WORDCLK_O(4) <= rx_usrclk(3);
			RX_WORDCLK_O(5) <= rx_usrclk(4);
			RX_WORDCLK_O(6) <= rx_usrclk(5);
			
   end generate;
      
   --=====================================================================================--   
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--