## Generated SDC file "M:/svn_repositories/GBT_project/svn_work/trunk/example_designs/altera_sv/amc40/sdc/amc40_gbt_ref_design.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Full Version"

## DATE    "Thu Mar 27 13:32:54 2014"

##
## DEVICE  "5SGXEA7N2F45C3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************

create_clock -period 240MHz [get_ports {REF_CLOCK}]
create_clock -period 100MHz [get_ports {SYS_CLK_100MHz}]

create_clock -name {altera_reserved_tck} -period 33.333 -waveform { 0.000 16.666 } [get_ports {altera_reserved_tck}]

#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {REF_CLOCK}]        -rise_to [get_clocks {REF_CLOCK}] 0.080  
set_clock_uncertainty -rise_from [get_clocks {REF_CLOCK}]        -fall_to [get_clocks {REF_CLOCK}] 0.080  
set_clock_uncertainty -fall_from [get_clocks {REF_CLOCK}]        -rise_to [get_clocks {REF_CLOCK}] 0.080  
set_clock_uncertainty -fall_from [get_clocks {REF_CLOCK}]        -fall_to [get_clocks {REF_CLOCK}] 0.080 

set_clock_uncertainty -rise_from [get_clocks {SYS_CLK_100MHz}]        -rise_to [get_clocks {SYS_CLK_100MHz}] 0.080  
set_clock_uncertainty -rise_from [get_clocks {SYS_CLK_100MHz}]        -fall_to [get_clocks {SYS_CLK_100MHz}] 0.080  
set_clock_uncertainty -fall_from [get_clocks {SYS_CLK_100MHz}]        -rise_to [get_clocks {SYS_CLK_100MHz}] 0.080  
set_clock_uncertainty -fall_from [get_clocks {SYS_CLK_100MHz}]        -fall_to [get_clocks {SYS_CLK_100MHz}] 0.080 

#**************************************************************
# Set Input Delay
#**************************************************************

#**************************************************************
# Set Output Delay
#**************************************************************

#**************************************************************
# Set Clock Groups
#**************************************************************

#set_clock_groups -asynchronous -group [get_clocks {SYS_CLK_40MHz}] 
set_clock_groups -asynchronous -group [get_clocks {REF_CLOCK}] 
set_clock_groups -asynchronous -group [get_clocks {SYS_CLK_100MHz}] 
set_clock_groups -asynchronous -group [get_clocks {*frameclk_pll_inst*outclk_0}]
set_clock_groups -asynchronous -group [get_clocks {*rxFrmClkPhAlgnr*outclk0}]
set_clock_groups -asynchronous -group [get_clocks {*rx_pma_clk}]
set_clock_groups -asynchronous -group [get_clocks {*tx_pma_clk}]

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -to [get_ports {altera_reserved_tdo}]

set_false_path -to [get_registers {*alt_xcvr_resync*sync_r[0]}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]

set_false_path -from [get_ports {altera_reserved_tdi}]
set_false_path -from [get_ports {altera_reserved_tms}]
set_false_path -from [get_ports {altera_reserved_ntrst}]

set_false_path -from *signaltap*
set_false_path -to *signaltap*

set_false_path -from *tx_clkout -to *frameclk_pll_inst*outclk_0
set_false_path -from *frameclk_pll_inst*outclk_0 -to *tx_clkout
set_false_path -from *rx_clkout -to *frameclk_pll_inst*outclk_0
set_false_path -from *frameclk_pll_inst*outclk_0 -to *rx_clkout
 
set_false_path -from *tx_clkout -to *rxFrmClkPhAlgnr*outclk0
set_false_path -from *rxFrmClkPhAlgnr*outclk0 -to *tx_clkout
set_false_path -from *rx_clkout -to *rxFrmClkPhAlgnr*outclk0
set_false_path -from *rxFrmClkPhAlgnr*outclk0 -to *rx_clkout

set_false_path -to [get_ports {SMA_CLK_OUT}]

#set_false_path -from [get_pins {frameclk_pll_inst|iopll_0|outclk0}] -to [get_pins {gbtExmplDsgn|gbtBank|\mgt_param_package_src_gen:mgt|\mgtLatOpt_gen:mgtLatOpt|\gxLatOpt_x6_gen:gxLatOpt_x6|xcvr_native_a10_0|g_xcvr_native_insts[0]|tx_clkout}]
#**************************************************************
# Set Multicycle Path
#**************************************************************

#set_multicycle_path -hold -end -from [get_clocks {fabricPll|alt_sv_fabric_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_keepers {alt_sv_gbt_example_design:gbtExmplDsgn|gbt_bank:gbtBank_2|multi_gigabit_transceivers:mgt|mgt_latopt:\mgtLatOpt_gen:mgtLatOpt|alt_sv_mgt_latopt_txwordclkmon:\txWordClkMon_gen:txWordClkMon|sampledClk_from_txWordClkReg}] 1


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|scrambler|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|txGearbox|*}] 20.000

set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000
set_max_delay -from [get_registers {gbtExmplDsgn_inst|gbtBank|*|rxGearbox|*}] -to [get_registers {gbtExmplDsgn_inst|gbtBank|*|descrambler|*}] 20.000

#**************************************************************
# Set Minimum Delay
#**************************************************************

#**************************************************************
# Set Input Transition
#**************************************************************

#**************************************************************
# Set Max Skew
#**************************************************************
set_max_skew -from *gx_reset_tx:gxResetTx*tx_digitalreset*r_reset -to *pld_pcs_interface* 2.08