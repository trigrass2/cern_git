// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Mon Apr 18 09:40:36 2016
// Host        : pcphese57 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/GBT-FPGA/trunk/example_designs/xilinx_k7v7/core_sources/tx_pll/vivado/xlx_k7v7_tx_pll_stub.v
// Design      : xlx_k7v7_tx_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xlx_k7v7_tx_pll(clk_in1, clk_out1, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1,reset,locked" */;
  input clk_in1;
  output clk_out1;
  input reset;
  output locked;
endmodule
