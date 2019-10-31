// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2.2 (win64) Build 2348494 Mon Oct  1 18:25:44 MDT 2018
// Date        : Fri Nov  1 03:06:29 2019
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
module freq_bram(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[24:0],douta[24:0],clkb,enb,web[0:0],addrb[9:0],dinb[24:0],doutb[24:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [24:0]dina;
  output [24:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [9:0]addrb;
  input [24:0]dinb;
  output [24:0]doutb;
endmodule
