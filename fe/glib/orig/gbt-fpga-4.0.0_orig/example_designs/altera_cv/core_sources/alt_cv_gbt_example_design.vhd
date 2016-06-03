--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           Altera Cyclone V - GBT Bank example design                                         
--                                                                                                 
-- Language:              VHDL'93                                                                  
--                                                                                                   
-- Target Device:         Altera Cyclone V                                                        
-- Tool version:          Quartus II 14.0                                                               
--                                                                                                   
-- Version:               3.5                                                                      
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        07/04/2013   3.0       M. Barros Marin   First .vhd module definition
--
--                        05/10/2014   3.5       M. Barros Marin   - Minor modifications
--                                                                 - Updated to Quartus II 14.0
--
-- Additional Comments:   Note!! Only ONE GBT Bank with ONE link can be used in this example design. 
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
library alt_cv_gt_reconfctrl_x1;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity alt_cv_gbt_example_design is 
	generic (
		GBT_BANK_ID											: integer := 0;
		NUM_LINKS											: integer := 1;
		TX_OPTIMIZATION									: integer range 0 to 1 := STANDARD;
		RX_OPTIMIZATION									: integer range 0 to 1 := STANDARD;
		TX_ENCODING											: integer range 0 to 1 := GBT_FRAME;
		RX_ENCODING											: integer range 0 to 1 := GBT_FRAME;
		
		-- Extended configuration --
		DATA_GENERATOR_ENABLE							: integer range 0 to 1 := 1;
		DATA_CHECKER_ENABLE								: integer range 0 to 1 := 1;
		MATCH_FLAG_ENABLE									: integer range 0 to 1 := 1
	);
   port ( 

		--==============--
		-- Clocks       --
		--==============--
		FRAMECLK_40MHZ												: in  std_logic;
		XCVRCLK_120MHZ												: in  std_logic;
				
		TX_FRAMECLK_O												: out std_logic_vector(1 to NUM_LINKS);
		RX_FRAMECLK_O												: out std_logic_vector(1 to NUM_LINKS);
		TX_WORDCLK_O												: out std_logic_vector(1 to NUM_LINKS);
		RX_WORDCLK_O												: out std_logic_vector(1 to NUM_LINKS);
		
		--==============--
		-- Reset        --
		--==============--
		GBTBANK_GENERAL_RESET_I									: in  std_logic;
		GBTBANK_MANUAL_RESET_TX_I								: in  std_logic;
		GBTBANK_MANUAL_RESET_RX_I								: in  std_logic;
		
		--==============--
		-- Serial lanes --
		--==============--
		GBTBANK_MGT_RX												: in  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_MGT_TX												: out std_logic_vector(1 to NUM_LINKS);
		
		--==============--
		-- Data			 --
		--==============--		
		GBTBANK_GBT_DATA_I										: in  gbtframe_A(1 to NUM_LINKS);
		GBTBANK_WB_DATA_I											: in  wbframe_A(1 to NUM_LINKS);
		GBTBANK_GBT_DATA_O										: out gbtframe_A(1 to NUM_LINKS);
		GBTBANK_WB_DATA_O											: out wbframe_A(1 to NUM_LINKS);
		
		--==============--
		-- Reconf.		 --
		--==============--
		GBTBANK_RECONF_AVMM_RST									: in  std_logic;
		GBTBANK_RECONF_AVMM_CLK									: in  std_logic;
		GBTBANK_RECONF_AVMM_ADDR								: in  std_logic_vector(6 downto 0);
		GBTBANK_RECONF_AVMM_READ								: in  std_logic;
		GBTBANK_RECONF_AVMM_WRITE								: in  std_logic;
		GBTBANK_RECONF_AVMM_WRITEDATA							: in  std_logic_vector(31 downto 0);
		GBTBANK_RECONF_AVMM_READDATA							: out std_logic_vector(31 downto 0);
		GBTBANK_RECONF_AVMM_WAITREQUEST						: out std_logic;
			
		--==============--
		-- TX ctrl	    --
		--==============--
		GBTBANK_TX_ISDATA_SEL_I									: in  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_TEST_PATTERN_SEL_I								: in  std_logic_vector(1 downto 0);
		
		--==============--
		-- RX ctrl      --
		--==============--
		GBTBANK_RESET_GBTRXREADY_LOST_FLAG_I       		: in  std_logic_vector(1 to NUM_LINKS);             
		GBTBANK_RESET_DATA_ERRORSEEN_FLAG_I         		: in  std_logic_vector(1 to NUM_LINKS);
			
		
		--==============--
		-- TX Status    --
		--==============--
		GBTBANK_GBTRX_READY_O									: out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_LINK_TX_READY_O								 	: out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_LINK_RX_READY_O								 	: out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_LINK_READY_O										: out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_TX_MATCHFLAG_O									: out std_logic;
			
		--==============--
		-- RX Status    --
		--==============--
		GBTBANK_RX_ISDATA_SEL_O									: out  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_GBTRXREADY_LOST_FLAG_O         			: out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_RXDATA_ERRORSEEN_FLAG_O                 : out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O    : out std_logic_vector(1 to NUM_LINKS);
		GBTBANK_RX_MATCHFLAG_O									: out std_logic_vector(1 to NUM_LINKS);
		
		--==============--
		-- XCVR ctrl    --
		--==============--
		GBTBANK_LOOPBACK_I										: in  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_TX_POL												: in  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_RX_POL												: in  std_logic_vector(1 to NUM_LINKS);
		GBTBANK_TXWORDCLKMON_EN									: in  std_logic     
     
   );
end alt_cv_gbt_example_design;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of alt_cv_gbt_example_design is 
   
   --================================ Signal Declarations ================================--   
   -- GBT Bank 1:
   --------------
   
   signal to_gbtBank_clks                                 : gbtBankClks_i_R;                          
   signal from_gbtBank_clks                               : gbtBankClks_o_R;
   --------------------------------------------------------        
   signal to_gbtBank_gbtTx                                : gbtTx_i_R_A(1 to NUM_LINKS); 
   signal from_gbtBank_gbtTx                              : gbtTx_o_R_A(1 to NUM_LINKS); 
   --------------------------------------------------------        
   signal to_gbtBank_mgt                                  : mgt_i_R;
   signal from_gbtBank_mgt                                : mgt_o_R; 
   --------------------------------------------------------        
   signal to_gbtBank_gbtRx                                : gbtRx_i_R_A(1 to NUM_LINKS); 
   signal from_gbtBank_gbtRx                              : gbtRx_o_R_A(1 to NUM_LINKS);
   
  
	-- Resets:
	-----------
	signal mgtTxReset_from_gbtBank_gbtBankRst				  : std_logic_vector(1 to NUM_LINKS);
	signal mgtRxReset_from_gbtBank_gbtBankRst				  : std_logic_vector(1 to NUM_LINKS);
	signal gbtTxReset_from_gbtBank_gbtBankRst				  : std_logic_vector(1 to NUM_LINKS);
	signal gbtRxReset_from_gbtBank_gbtBankRst				  : std_logic_vector(1 to NUM_LINKS);
			
	-- TX Data generator:
	---------------------
	signal gbtBank_txEncodingSel									: std_logic_vector(1 downto 0);
	signal txData_from_gbtBank_pattGen							: std_logic_vector(83 downto 0);
	signal txExtraDataWidebus_from_gbtBank_pattGen			: std_logic_vector(31 downto 0);
	
	signal txData_to_gbtBank										: gbtframe_A(1 to NUM_LINKS);
	signal gbtData_from_gbtInput									: gbtframe_A(1 to NUM_LINKS);
	signal txExtraDataWidebus_to_gbtBank						: wbframe_extra_A(1 to NUM_LINKS);
	
	-- RX Data checker:
	-------------------
	signal gbtBank_rxEncodingSel									: std_logic_vector(1 downto 0);
	
	-- RX frameclk aligner:
	-----------------------
	signal phaseAlignDone_from_gbtBank_rxFrmClkPhAlgnr		: std_logic_vector(1 to NUM_LINKS);
	signal pllLocked_from_gbtBank_rxFrmClkPhAlgnr			: std_logic_vector(1 to NUM_LINKS);
	signal gbtBank_rxFrameClkReady_staticMux					: std_logic_vector(1 to NUM_LINKS);
	signal rxFrameClk_from_gbtBank_rxFrmClkPhAlgnr			: std_logic_vector(1 to NUM_LINKS);
	
	signal latOptGbtBank_rx											: std_logic_vector(1 to NUM_LINKS);
	signal rxWordClkReady											: std_logic_vector(1 to NUM_LINKS);
	signal header_flag												: std_logic_vector(1 to NUM_LINKS);
   
   
   --=====================================================================================--    

--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--
   
   --==================================== User Logic =====================================--

      --##############################################################################--
    --##################################################################################--
   --##################################              #####################################--
   --##################################  GBT Bank    #####################################--
   --##################################              #####################################--
    --##################################################################################--
      --##############################################################################--  
		
	--============--
	-- Clocks     --
	--============--																				  
	
	gbtBank_Clk_gen: for i in 1 to NUM_LINKS generate
	
		rxFrameClk_from_gbtBank_rxFrmClkPhAlgnr(i) <= FRAMECLK_40MHZ;
		pllLocked_from_gbtBank_rxFrmClkPhAlgnr(i)  <= '1';
		phaseAlignDone_from_gbtBank_rxFrmClkPhAlgnr(i) <= '1';
		
		latOptGbtBank_rx(i)							<= from_gbtBank_gbtRx(i).latOptGbtBank_rx;
		rxWordClkReady(i)								<= from_gbtBank_mgt.mgtLink(i).rxWordClkReady;
		header_flag(i)									<= from_gbtBank_gbtRx(i).header_flag;
		
		RX_FRAMECLK_O(i)								<= rxFrameClk_from_gbtBank_rxFrmClkPhAlgnr(i);
		TX_FRAMECLK_O(i)								<= FRAMECLK_40MHZ;
		
		TX_WORDCLK_O(i)								<= from_gbtBank_clks.mgt_clks.tx_wordclk(i);
		RX_WORDCLK_O(i)								<= from_gbtBank_clks.mgt_clks.rx_wordclk(i);
		
		to_gbtBank_clks.tx_frameClk(i)			<= FRAMECLK_40MHZ;
		to_gbtBank_clks.rx_frameClk(i)			<= rxFrameClk_from_gbtBank_rxFrmClkPhAlgnr(i);
		
		
		gbtBank_rxFrameClkReady_staticMux(i)   <= pllLocked_from_gbtBank_rxFrmClkPhAlgnr(i);
		
	end generate;
	
	to_gbtBank_clks.mgt_clks.mgtRefClk 			<= XCVRCLK_120MHZ;
	to_gbtBank_clks.mgt_clks.txFrameClk			<= FRAMECLK_40MHZ;
	
	--============--
	-- Resets     --
	--============--
	gbtBank_rst_gen: for i in 1 to NUM_LINKS generate
	
		gbtBank_gbtBankRst: entity work.gbt_bank_reset    
			generic map (
				RX_INIT_FIRST                                     => false,
				INITIAL_DELAY                                     => 1 * 40e6,   -- Comment: * 1s  
				TIME_N                                            => 1 * 40e6,   --          * 1s
				GAP_DELAY                                         => 1 * 40e6)   --          * 1s
			port map (     
				CLK_I                                             => FRAMECLK_40MHZ,                                               
				--------------------------------------------------
				GENERAL_RESET_I                                   => GBTBANK_GENERAL_RESET_I,                                                                 
				MANUAL_RESET_TX_I                                 => GBTBANK_MANUAL_RESET_TX_I,
				MANUAL_RESET_RX_I                                 => GBTBANK_MANUAL_RESET_RX_I,
				--------------------------------------------------         
				MGT_TX_RESET_O                                    => mgtTxReset_from_gbtBank_gbtBankRst(i),                              
				MGT_RX_RESET_O                                    => mgtRxReset_from_gbtBank_gbtBankRst(i),                             
				GBT_TX_RESET_O                                    => gbtTxReset_from_gbtBank_gbtBankRst(i),                                      
				GBT_RX_RESET_O                                    => gbtRxReset_from_gbtBank_gbtBankRst(i),                              
				--------------------------------------------------          
				BUSY_O                                            => open,                                                                         
				DONE_O                                            => open                                                                          
			); 
			
	end generate;
	
	--========================--
	-- Data pattern generator --
	--========================--
	dataGenEn_gen: if DATA_GENERATOR_ENABLE = ENABLED generate
	
		gbtBank_txEncodingSel                                  <= "01" when TX_ENCODING = WIDE_BUS  else 
																					  "00";     -- Comment: GBT_FRAME

		gbtBank2_pattGen: entity work.gbt_pattern_generator
			port map (                                                        
				RESET_I                                        => mgtRxReset_from_gbtBank_gbtBankRst(1),   
				TX_FRAMECLK_I                                  => FRAMECLK_40MHZ,
				-----------------------------------------------     
				TX_ENCODING_SEL_I                              => gbtBank_txEncodingSel,
				TEST_PATTERN_SEL_I                             => GBTBANK_TEST_PATTERN_SEL_I,
				STATIC_PATTERN_SCEC_I                          => "00",
				STATIC_PATTERN_DATA_I                          => x"000BABEAC1DACDCFFFFF",
				STATIC_PATTERN_EXTRADATA_WIDEBUS_I             => x"BEEFCAFE",
				-----------------------------------------------
				TX_DATA_O                                      => txData_from_gbtBank_pattGen,
				TX_EXTRA_DATA_WIDEBUS_O                        => txExtraDataWidebus_from_gbtBank_pattGen
			);
			
		dataGenEn_output_gen: for i in 1 to NUM_LINKS generate		
			gbtData_from_gbtInput(i) 			<= GBTBANK_GBT_DATA_I(i) when GBTBANK_TEST_PATTERN_SEL_I = "11" else
															txData_from_gbtBank_pattGen;
			
			txData_to_gbtBank(i)					<= gbtData_from_gbtInput(i) when TX_ENCODING = GBT_FRAME else
															GBTBANK_WB_DATA_I(i)(115 downto 32);
															
			txExtraDataWidebus_to_gbtBank(i) <= GBTBANK_WB_DATA_I(i)(31 downto 0) when GBTBANK_TEST_PATTERN_SEL_I = "11" else
															txExtraDataWidebus_from_gbtBank_pattGen;
		end generate;
		
	end generate;
	
	dataGenDs_gen: if DATA_GENERATOR_ENABLE = DISABLED generate
		
		dataGenDs_output_gen: for i in 1 to NUM_LINKS generate
			txData_to_gbtBank(i) 				<= GBTBANK_GBT_DATA_I(i) when TX_ENCODING = GBT_FRAME else
															GBTBANK_WB_DATA_I(i)(115 downto 32);
															
			txExtraDataWidebus_to_gbtBank(i) <= GBTBANK_WB_DATA_I(i)(31 downto 0);
		end generate;
		
	end generate;
	
	--==========================--
	-- Data pattern checker		 --
	--==========================--
	dataCheckEn_gen: if DATA_CHECKER_ENABLE = ENABLED generate
	
		gbtBank_rxEncodingSel                                <= "01" when TX_ENCODING = WIDE_BUS  else 
																				  "00";     -- Comment: GBT_FRAME
		
		gbtBank_patCheckEnabled_gen: for i in 1 to NUM_LINKS generate
			gbtBank_pattCheck: entity work.gbt_pattern_checker
				port map (
					RESET_I                                        => gbtRxReset_from_gbtBank_gbtBankRst(i),         
					RX_FRAMECLK_I                                  => rxFrameClk_from_gbtBank_rxFrmClkPhAlgnr(i), 
					-----------------------------------------------           
					RX_DATA_I                                      => from_gbtBank_gbtRx(i).data,        
					RX_EXTRA_DATA_WIDEBUS_I                        => from_gbtBank_gbtRx(i).extraData_widebus,
					-----------------------------------------------           
					GBT_RX_READY_I                                 => from_gbtBank_gbtRx(i).ready,
					RX_ENCODING_SEL_I                              => gbtBank_rxEncodingSel,
					TEST_PATTERN_SEL_I                             => GBTBANK_TEST_PATTERN_SEL_I,   
					STATIC_PATTERN_SCEC_I                          => "00",
					STATIC_PATTERN_DATA_I                          => x"000BABEAC1DACDCFFFFF",        
					STATIC_PATTERN_EXTRADATA_WIDEBUS_I             => x"BEEFCAFE",  
					RESET_GBTRXREADY_LOST_FLAG_I                   => GBTBANK_RESET_GBTRXREADY_LOST_FLAG_I(i),               
					RESET_DATA_ERRORSEEN_FLAG_I                    => GBTBANK_RESET_DATA_ERRORSEEN_FLAG_I(i),  
					-----------------------------------------------           
					GBTRXREADY_LOST_FLAG_O                         => GBTBANK_GBTRXREADY_LOST_FLAG_O(i), 
					RXDATA_ERRORSEEN_FLAG_O                        => GBTBANK_RXDATA_ERRORSEEN_FLAG_O(i),
					RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O           => GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O(i)
				);
		end generate;
		
	end generate;
	
	dataCheckDs_gen: if DATA_CHECKER_ENABLE = DISABLED generate
		GBTBANK_GBTRXREADY_LOST_FLAG_O						<= (others => '0');
		GBTBANK_RXDATA_ERRORSEEN_FLAG_O						<= (others => '0');
		GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O		<= (others => '0');
	end generate;
	
	--============--
	-- GBT Tx     --
	--============--
	
	gbtBank_gbtTx_gen: for i in 1 to NUM_LINKS generate
		to_gbtBank_gbtTx(i).reset					<= gbtTxReset_from_gbtBank_gbtBankRst(i);
		to_gbtBank_gbtTx(i).isDataSel	      	<= GBTBANK_TX_ISDATA_SEL_I(i);
		to_gbtBank_gbtTx(i).data              	<= txData_to_gbtBank(i);
		to_gbtBank_gbtTx(i).extraData_wideBus 	<= txExtraDataWidebus_to_gbtBank(i);
	end generate;
		
	--============--
	-- GBT Rx     --
	--============--
	
	gbtBank_gbtRx_gen: for i in 1 to NUM_LINKS generate
		to_gbtBank_gbtRx(i).reset					<= gbtRxReset_from_gbtBank_gbtBankRst(i);  
		to_gbtBank_gbtRx(i).rxFrameClkReady   	<= gbtBank_rxFrameClkReady_staticMux(i);
		GBTBANK_GBTRX_READY_O(i)					<= from_gbtBank_gbtRx(i).ready;
		
		GBTBANK_GBT_DATA_O(i)						<= from_gbtBank_gbtRx(i).data;
		
		GBTBANK_WB_DATA_O(i)(115 downto 32)		<= from_gbtBank_gbtRx(i).data;
		GBTBANK_WB_DATA_O(i)(31  downto 0)		<= from_gbtBank_gbtRx(i).extraData_widebus;
	end generate;
	
	--=============--
	-- Transceiver --
	--=============--
	to_gbtBank_mgt.mgtCommon.reconf_reset				<= GBTBANK_RECONF_AVMM_RST;
	to_gbtBank_mgt.mgtCommon.reconf_clk					<= GBTBANK_RECONF_AVMM_CLK;
	to_gbtBank_mgt.mgtCommon.reconf_avmm_addr			<= GBTBANK_RECONF_AVMM_ADDR;
	to_gbtBank_mgt.mgtCommon.reconf_avmm_read			<= GBTBANK_RECONF_AVMM_READ;
	to_gbtBank_mgt.mgtCommon.reconf_avmm_write		<= GBTBANK_RECONF_AVMM_WRITE;
	to_gbtBank_mgt.mgtCommon.reconf_avmm_writedata	<= GBTBANK_RECONF_AVMM_WRITEDATA;
	GBTBANK_RECONF_AVMM_READDATA							<= from_gbtBank_mgt.mgtCommon.reconf_avmm_readdata;
	GBTBANK_RECONF_AVMM_WAITREQUEST						<= from_gbtBank_mgt.mgtCommon.reconf_avmm_waitrequest;
	
	to_gbtBank_mgt.mgtCommon.txWrdClkMon_enable    	<= GBTBANK_TXWORDCLKMON_EN;
		
	gbtBank_mgt_gen: for i in 1 to NUM_LINKS generate
		to_gbtBank_mgt.mgtLink(i).tx_reset					<= mgtTxReset_from_gbtBank_gbtBankRst(i);
		to_gbtBank_mgt.mgtLink(i).rx_reset					<= mgtRxReset_from_gbtBank_gbtBankRst(i);
		to_gbtBank_mgt.mgtLink(i).rxSerialData				<= GBTBANK_MGT_RX(i);
		to_gbtBank_mgt.mgtLink(i).loopBack					<= GBTBANK_LOOPBACK_I(i);
		to_gbtBank_mgt.mgtLink(i).tx_polarity				<= GBTBANK_TX_POL(i);
		to_gbtBank_mgt.mgtLink(i).rx_polarity				<= GBTBANK_RX_POL(i);
		to_gbtBank_mgt.mgtLink(i).rxBitSlip_enable		<= '1';
		to_gbtBank_mgt.mgtLink(i).rxBitSlip_ctrl			<= '0';
		to_gbtBank_mgt.mgtLink(i).rxBitSlip_nbr			<= (others => '0');
		to_gbtBank_mgt.mgtLink(i).rxBitSlip_run			<= '0';
		to_gbtBank_mgt.mgtLink(i).rxBitSlip_oddRstEn		<= '0';
	
	
		GBTBANK_MGT_TX(i)										<= from_gbtBank_mgt.mgtLink(i).txSerialData;
		GBTBANK_LINK_READY_O(i)								<= from_gbtBank_mgt.mgtLink(i).ready;
		GBTBANK_LINK_TX_READY_O(i)							<= from_gbtBank_mgt.mgtLink(i).tx_ready;
		GBTBANK_LINK_RX_READY_O(i)							<= from_gbtBank_mgt.mgtLink(i).rx_ready;
	
	end generate;
   --============--
   -- GBT Bank 1 --
   --============--
   
   -- Comment: Note!! This example design instantiates two GBT Banks:
   --
   --          - GBT Bank 1: One GBT Link (Standard GBT TX and Standard GBT RX).
   --
   
   gbtBank: entity work.gbt_bank
      generic map (
         GBT_BANK_ID                                  => GBT_BANK_ID,
			NUM_LINKS												=> NUM_LINKS,
			TX_OPTIMIZATION										=> TX_OPTIMIZATION,
			RX_OPTIMIZATION										=> RX_OPTIMIZATION,
			TX_ENCODING												=> TX_ENCODING,
			RX_ENCODING												=> RX_ENCODING)
      port map (                       
         CLKS_I                                            => to_gbtBank_clks,                                  
         CLKS_O                                            => from_gbtBank_clks,               
         --------------------------------------------------               
         GBT_TX_I                                          => to_gbtBank_gbtTx,             
         GBT_TX_O                                          => from_gbtBank_gbtTx,         
         --------------------------------------------------               
         MGT_I                                             => to_gbtBank_mgt,              
         MGT_O                                             => from_gbtBank_mgt,              
         --------------------------------------------------               
         GBT_RX_I                                          => to_gbtBank_gbtRx,              
         GBT_RX_O                                          => from_gbtBank_gbtRx         
      ); 
   

   --============--
   -- Match flag --
   --============--	
	matchFlag_gen: if MATCH_FLAG_ENABLE = ENABLED generate
	
		gbtBank_txFlag: entity work.gbt_pattern_matchflag
			PORT MAP (
				RESET_I                                           => gbtTxReset_from_gbtBank_gbtBankRst(1),
				CLK_I                                             => FRAMECLK_40MHZ,
				DATA_I                                            => txData_from_gbtBank_pattGen,
				MATCHFLAG_O                                       => GBTBANK_TX_MATCHFLAG_O
			);
		
		gbtBank_rxFlag_gen: for i in 1 to NUM_LINKS generate
			gbtBank_rxFlag: entity work.gbt_pattern_matchflag
				PORT MAP (
					RESET_I                                           => gbtRxReset_from_gbtBank_gbtBankRst(i),
					CLK_I                                             => FRAMECLK_40MHZ,
					DATA_I                                            => from_gbtBank_gbtRx(i).data,
					MATCHFLAG_O                                       => GBTBANK_RX_MATCHFLAG_O(i)
				);
		end generate;
	
	end generate;
		
	matchFlagDisabled_gen: if MATCH_FLAG_ENABLE = DISABLED generate
	
		GBTBANK_TX_MATCHFLAG_O <= '0';
		GBTBANK_RX_MATCHFLAG_O <= (others => '0');
		
	end generate;
	
   --=====================================================================================--   
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--