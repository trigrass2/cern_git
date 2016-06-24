--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (EP-ESE-BE)                                                         
-- Engineer:              Julian Mendez (julian.mendez@cern.ch)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           Altera GX development kit - GBT Bank example design                                        
--                                                                                                 
-- Language:              VHDL'93                                                                  
--                                                                                                   
-- Target Device:         Altera GX development kit (Altera Arria 10)                                                       
-- Tool version:          Quartus II 13.1                                                                
--                                                                                                   
-- Version:               3.0                                                                      
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        15/04/2016   3.0       J. Mendez         First .vhd module definition           
--
-- Additional Comments:   Note!! This example design instantiates one GBt Banks:
--
--                               - GBT Bank 1: One GBT Link (Standard GBT TX and Standard GBT RX)     
--                                                                                              
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity pcie40_gbt_example_design is   
   port (   
      
      --===============--
      -- General reset --
      --===============--  
      SYS_RESET_N                                             : in  std_logic; 
    
      --===============--
      -- Clocks scheme --
      --===============--
      REF_CLOCK                                            	  : in  std_logic;   -- Comment:  (LHC PLL 240MHz)
      SYS_CLK_100MHz														  : in  std_logic;
	   --SMA_CLK_OUT															  : out std_logic;
		
      --==============--
      -- Serial lanes --
      --==============--
      
      -- GBT Bank 1:
      --------------
		
      MPO_TX                                                  : out std_logic;
      MPO_RX                                           		  : in  std_logic
   );
end pcie40_gbt_example_design;



--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of pcie40_gbt_example_design is
   
   --================================ Signal Declarations ================================--	
   --=====================================================================================-- 
	
	--============--
	-- 40MHz PLL  --
	--============--
	signal SYS_CLK_40MHz							:	std_logic;
	signal frameclk_locked						: std_logic;	
	signal phaseShift_to_txpll 				: std_logic := '0';
	signal phaseShiftDone_from_txpll			: std_logic;
	
	--==============--
	-- XCVR Control --
	--==============--
	signal rx_pol									: std_logic := '1';
	signal tx_pol									: std_logic := '1';
	signal loopback								: std_logic := '1';
	
	--=====================--
	-- Measurements        --
	--=====================--
	signal tx_matchflag							: std_logic;
	signal rx_matchflag							: std_logic;
	
	signal rxframeclk_from_gbtExmplDsgn		: std_logic;
	signal txframeclk_from_gbtExmplDsgn		: std_logic;
	signal rxwordclk_from_gbtExmplDsgn		: std_logic;
	signal txwordclk_from_gbtExmplDsgn		: std_logic;
	
	signal latdelay								: std_logic_vector(31 downto 0);
	
	--============--
	-- GBT Status --
	--============--
	signal gbtData_from_gbtExmplDsgn			: std_logic_vector(83 downto 0);
	signal WBData_from_gbtExmplDsgn			: std_logic_vector(115 downto 0);
	signal gbtTxReady_from_gbtExamplDsgn	: std_logic;
	signal XCVRTXReady_from_gbtExamplDsgn 	: std_logic;
	signal XCVRRXReady_from_gbtExamplDsgn 	: std_logic;
	signal XCVRReady_from_gbtExamplDsgn 	: std_logic;
	signal gbtRxReady_from_gbtExamplDsgn	: std_logic;
	signal bitslip_from_gbtExamplDsgn		: std_logic_vector(5 downto 0);
	signal gbtRxLostFlag_from_gbtExmplDsgn	: std_logic;
	signal gbtDataErrSeen_from_gbtExmplDsgn: std_logic;
	signal WBDataErrSeen_from_gbtExmplDsgn	: std_logic;
	
	--==========--
	-- GBT Ctrl --
	--==========--
	signal reset_from_issp						: std_logic;
	signal resetTx_from_issp					: std_logic;
	signal resetRx_from_issp					: std_logic;
	signal reset_from_jtag						: std_logic;
	
	signal reset_dataerrorseenflag			: std_logic;
	signal reset_gbtRxReadylostflag			: std_logic;
	
	signal gbtData_from_issp					: std_logic_vector(83 downto 0);
	signal WBData_from_issp						: std_logic_vector(115 downto 0);
	signal testPattern_from_issp				: std_logic_vector(1 downto 0);
	signal txIsDataSel_from_issp				: std_logic;
	signal rxIsDataSel_from_issp				: std_logic;
	
	--============--
	-- Components --
	--============--	
	component frameclk_pll is
		port (
			cntsel           : in  std_logic_vector(4 downto 0) := (others => 'X'); -- cntsel
			locked           : out std_logic;                                       -- export
			num_phase_shifts : in  std_logic_vector(2 downto 0) := (others => 'X'); -- num_phase_shifts
			outclk_0         : out std_logic;                                       -- clk
			phase_done       : out std_logic;                                       -- phase_done
			phase_en         : in  std_logic                    := 'X';             -- phase_en
			refclk           : in  std_logic                    := 'X';             -- clk
			rst              : in  std_logic                    := 'X';             -- reset
			scanclk          : in  std_logic                    := 'X';             -- scanclk
			updn             : in  std_logic                    := 'X'              -- updn
		);
	end component frameclk_pll;
	
	component latoptimized_measurements is
		port (
			clk_clk         : in  std_logic                     := 'X';             -- clk
			delay_io_export : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			reset_reset_n   : in  std_logic                     := 'X';             -- reset_n
			reset_io_export : out std_logic                                         -- export
		);
	end component latoptimized_measurements;
	
	component ax_issp is
		port (
			probe  : in  std_logic_vector(14 downto 0) := (others => 'X'); -- probe
			source : out std_logic_vector(8 downto 0)                     -- source
		);
	end component ax_issp;
	
	component ax_data_issp is
		port (
			probe  : in  std_logic_vector(200 downto 0) := (others => 'X'); -- probe
			source : out std_logic_vector(202 downto 0)                     -- source
		);
	end component ax_data_issp;
	
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--
   
   --==================================== User Logic =====================================--


       --#############################################################################--
     --#################################################################################--
   --#############################                           #############################--
   --#############################  GBT Bank example design  #############################--
   --#############################                           #############################--
     --#################################################################################--
       --#############################################################################--
   
	--==================--
	-- TX Frameclk PLL  --
	--==================--
	
	-- In order to emulate a real environement, the 40MHz is created from the 
	-- Reference clock to control the phase relation between both clocks.
	--
	-- In a real system, the 40MHz and 240MHz come from an external PLL with
	-- a constant phase relation.
	
   frameclk_pll_inst: frameclk_pll
		port map(
			locked   			=> frameclk_locked,
			outclk_0 			=> SYS_CLK_40MHz,
			refclk   			=> REF_CLOCK,
			rst      			=> not(SYS_RESET_N),
			
			cntsel           	=> "00000",
			num_phase_shifts 	=> "001",
			phase_done       	=> phaseShiftDone_from_txpll,
			scanclk          	=> REF_CLOCK,
			phase_en         	=> '0', --phaseShift_to_txpll,
			updn             	=> '1'
		);

   --=====================================--
   -- Arria 10 - GBT Bank example design  --
   --=====================================--	
	gbtExmplDsgn_inst: entity work.alt_ax_gbt_example_design
		generic map(
			NUM_LINKS												=> 1,
			TX_OPTIMIZATION										=> LATENCY_OPTIMIZED,
			RX_OPTIMIZATION										=> LATENCY_OPTIMIZED,
			TX_ENCODING												=> GBT_FRAME,
			RX_ENCODING												=> GBT_FRAME
		)
      port map (

		--==============--
		-- Clocks       --
		--==============--
		FRAMECLK_40MHZ												=> SYS_CLK_40MHz,
		XCVRCLK														=> REF_CLOCK,
		
		RX_FRAMECLK_O(1)											=> rxframeclk_from_gbtExmplDsgn,
		TX_FRAMECLK_O(1)											=> txframeclk_from_gbtExmplDsgn,
		RX_WORDCLK_O(1)											=> rxwordclk_from_gbtExmplDsgn,
		TX_WORDCLK_O(1)											=> txwordclk_from_gbtExmplDsgn,
		
		--==============--
		-- Reset        --
		--==============--
		GBTBANK_GENERAL_RESET_I									=> not(frameclk_locked) or reset_from_jtag or reset_from_issp,
		GBTBANK_MANUAL_RESET_TX_I								=> resetTx_from_issp,
		GBTBANK_MANUAL_RESET_RX_I								=> resetRx_from_issp,
		
		--==============--
		-- Serial lanes --
		--==============--
		GBTBANK_MGT_RX(1)											=> MPO_RX,
		GBTBANK_MGT_TX(1)											=> MPO_TX,
		
		--==============--
		-- Data			 --
		--==============--		
		GBTBANK_GBT_DATA_I(1)									=> gbtData_from_issp,
		GBTBANK_WB_DATA_I(1)										=> WBData_from_issp,
		
		GBTBANK_GBT_DATA_O(1)									=> gbtData_from_gbtExmplDsgn,
		GBTBANK_WB_DATA_O(1)										=> WBData_from_gbtExmplDsgn,
		
		--==============--
		-- Reconf.		 --
		--==============--
		GBTBANK_RECONF_AVMM_RST									=> '0',
		GBTBANK_RECONF_AVMM_CLK									=> SYS_CLK_100MHz,
		GBTBANK_RECONF_AVMM_ADDR								=> (others => '0'),
		GBTBANK_RECONF_AVMM_READ								=> '0',
		GBTBANK_RECONF_AVMM_WRITE								=> '0',
		GBTBANK_RECONF_AVMM_WRITEDATA							=> (others => '0'),
		GBTBANK_RECONF_AVMM_READDATA							=> open,
		GBTBANK_RECONF_AVMM_WAITREQUEST						=> open,
		
		--==============--
		-- TX ctrl	    --
		--==============--
		GBTBANK_TX_ISDATA_SEL_I(1)								=> txIsDataSel_from_issp,
		GBTBANK_TEST_PATTERN_SEL_I								=> testPattern_from_issp,
		
		--==============--
		-- RX ctrl      --
		--==============--
		GBTBANK_RESET_GBTRXREADY_LOST_FLAG_I(1)     		=> reset_gbtRxReadylostflag,
		GBTBANK_RESET_DATA_ERRORSEEN_FLAG_I(1)      		=> reset_dataerrorseenflag,
		
		--==============--
		-- TX Status    --
		--==============--
		GBTBANK_GBTTX_READY_O(1)								=> gbtTxReady_from_gbtExamplDsgn,
		GBTBANK_LINK_TX_READY_O(1)								=> XCVRTXReady_from_gbtExamplDsgn,
		GBTBANK_LINK_READY_O(1)									=> XCVRReady_from_gbtExamplDsgn,
		GBTBANK_TX_MATCHFLAG_O									=> tx_matchflag,
		
		--==============--
		-- RX Status    --
		--==============--
		GBTBANK_GBTRX_READY_O(1)								=> gbtRxReady_from_gbtExamplDsgn,
		GBTBANK_LINK_RX_READY_O(1)								=> XCVRRXReady_from_gbtExamplDsgn,
		GBTBANK_LINK1_BITSLIP_O           					=> bitslip_from_gbtExamplDsgn,
		GBTBANK_GBTRXREADY_LOST_FLAG_O(1)               => gbtRxLostFlag_from_gbtExmplDsgn,
		GBTBANK_RXDATA_ERRORSEEN_FLAG_O(1)              => gbtDataErrSeen_from_gbtExmplDsgn,
		GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O(1) => WBDataErrSeen_from_gbtExmplDsgn,
		GBTBANK_RX_MATCHFLAG_O(1)								=> rx_matchflag,
		GBTBANK_RX_ISDATA_SEL_O(1)								=> rxIsDataSel_from_issp,
		
		--==============--
		-- XCVR ctrl    --
		--==============--
		GBTBANK_LOOPBACK_I(1)					=> loopback,
		
		GBTBANK_TX_POL(1)							=> tx_pol,
		GBTBANK_RX_POL(1)							=> rx_pol
   );
	
	
	--=====================================--
	-- clocks measurements                 --
	--=====================================--
	
		-- Ref clock
		measure_refclk_inst : entity work.measure_refclk
			GENERIC MAP(
				CYC_MEASURE_CLK_IN_1_SEC	=> X"05F5E100"
			)
			port MAP(
				RefClock				=> REF_CLOCK,
				Measure_Clk			=> SYS_CLK_100MHz,
				reset					=> not(frameclk_locked),
				RefClock_Measure	=> open
			);
	
		-- TX Frameclk
		measure_txframeclk_inst : entity work.measure_refclk
			GENERIC MAP(
				CYC_MEASURE_CLK_IN_1_SEC	=> X"05F5E100"
			)
			port MAP(
				RefClock				=> txframeclk_from_gbtExmplDsgn,
				Measure_Clk			=> SYS_CLK_100MHz,
				reset					=> not(frameclk_locked),
				RefClock_Measure	=> open
			);
		
		-- Rx Frameclock
		measure_rxframeclk_inst : entity work.measure_refclk
			GENERIC MAP(
				CYC_MEASURE_CLK_IN_1_SEC	=> X"05F5E100"
			)
			port MAP(
				RefClock				=> rxframeclk_from_gbtExmplDsgn,
				Measure_Clk			=> SYS_CLK_100MHz,
				reset					=> not(frameclk_locked),
				RefClock_Measure	=> open
			);
		
		-- TX Wordclk
		measure_txwordclk_inst : entity work.measure_refclk
			GENERIC MAP(
				CYC_MEASURE_CLK_IN_1_SEC	=> X"05F5E100"
			)
			port MAP(
				RefClock				=> txwordclk_from_gbtExmplDsgn,
				Measure_Clk			=> SYS_CLK_100MHz,
				reset					=> not(frameclk_locked),
				RefClock_Measure	=> open
			);
		
		-- RX Wordclk
		measure_rxwordclk_inst : entity work.measure_refclk
			GENERIC MAP(
				CYC_MEASURE_CLK_IN_1_SEC	=> X"05F5E100"
			)
			port MAP(
				RefClock				=> rxwordclk_from_gbtExmplDsgn,
				Measure_Clk			=> SYS_CLK_100MHz,
				reset					=> not(frameclk_locked),
				RefClock_Measure	=> open
			);
			
	
	--============--
	-- Debug issp --
	--============--	
	gbtBank1_inSysSrcAndPrb: ax_issp
      port map (
         PROBE(0)                                             => gbtTxReady_from_gbtExamplDsgn,
			PROBE(1)															  => gbtRxReady_from_gbtExamplDsgn,			
			PROBE(2)															  => XCVRTXReady_from_gbtExamplDsgn,
			PROBE(3)															  => XCVRRXReady_from_gbtExamplDsgn,
			PROBE(4)															  => XCVRReady_from_gbtExamplDsgn,			
			PROBE(10 downto 5)											  => bitslip_from_gbtExamplDsgn,			
			PROBE(11)														  => gbtRxLostFlag_from_gbtExmplDsgn,
			PROBE(12)														  => gbtDataErrSeen_from_gbtExmplDsgn,			
			PROBE(13)														  => WBDataErrSeen_from_gbtExmplDsgn,
			PROBE(14)														  => phaseShiftDone_from_txpll,
			
         SOURCE(0)                                            => loopback,
         SOURCE(1)                                            => rx_pol,
         SOURCE(2)                                            => tx_pol,
         SOURCE(3)                                            => reset_dataerrorseenflag,
         SOURCE(4)                                            => reset_gbtRxReadylostflag,
         SOURCE(5)                                            => reset_from_issp,
         SOURCE(6)                                            => resetTx_from_issp,
         SOURCE(7)                                            => resetRx_from_issp,
			SOURCE(8)														  => phaseShift_to_txpll
      );
		
	gbtBank1_Data_inSysSrcAndPrb: ax_data_issp
      port map (
         SOURCE(83 downto 0)                                  => gbtData_from_issp,
			SOURCE(199 downto 84)										  => WBData_from_issp,
			SOURCE(201 downto 200)										  => testPattern_from_issp,
			SOURCE(202)														  => txIsDataSel_from_issp,
			
         PROBE(83 downto 0)                                   => gbtData_from_gbtExmplDsgn,
			PROBE(199 downto 84)										  	  => WBData_from_gbtExmplDsgn,
			PROBE(200)														  => rxIsDataSel_from_issp
      );
		
	--======================--
	-- Latency measurements --
	--======================--
	
		-- The script latency_meas.tcl, located into the example_designs/altera_a10/tcl folder can be
		-- used to carry out automatic measurement of the latency.
		-- It performs multiple resets of the gbt IP and measure the latency between tx_matchflag and
		-- rx_matchflag. To use it, the test pattern shall be "01".
		
		latencymeas_inst: entity work.pattern_matchflag_delaymeas   
			port map(   
				RESET_I               => reset_from_jtag,
				CLK_I                 => REF_CLOCK,
				TX_MATCHFLAG_I        => tx_matchflag,
				RX_MATCHFLAG_I        => rx_matchflag,
				DELAY_O				    => latdelay
			);
		
		latoptimized_ctrl_inst: latoptimized_measurements
			port map (
				clk_clk         => SYS_CLK_100MHz,    -- clk
				delay_io_export => latdelay,          -- export
				reset_reset_n   => SYS_RESET_N,       -- reset_n
				reset_io_export => reset_from_jtag    -- export
			);
		
	--SMA_CLK_OUT <= tx_matchflag or rx_matchflag;
   --=====================================================================================--   
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--