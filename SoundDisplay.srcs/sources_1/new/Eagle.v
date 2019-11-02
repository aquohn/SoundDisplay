`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2019 06:10:43
// Design Name: 
// Module Name: Eagle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Eagle(
    input mic_clk,
    input oled_clk,
    input clk100m,
    input clk20,
    input frame_begin,
    input fft_out_rdy,
    input [9:0] freq_addr,
    input [23:0] freq_mag,
    input fft_done,
    input [15:0] sw, //set zoom level
    input [12:0] pixel_index,
    input btnU_signal,
    input btnR_signal,
    input btnL_signal,
    input btnD_signal,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    
    
    
endmodule
