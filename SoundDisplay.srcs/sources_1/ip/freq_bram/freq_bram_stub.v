// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2.2 (win64) Build 2348494 Mon Oct  1 18:25:44 MDT 2018
// Date        : Fri Nov  1 02:18:25 2019
// Host        : QUANTUM running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/aquohn/Documents/EE2026/SoundDisplay/SoundDisplay.srcs/sources_1/ip/freq_bram/freq_bram_stub.v
// Design      : freq_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2.2" *)
module freq_bram(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[9:0],dina[24:0],clkb,enb,addrb[9:0],doutb[24:0]" */;
  input clka;
  input [0:0]wea;
  input [9:0]addra;
  input [24:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [24:0]doutb;
endmodule
