`timescale 1ns / 1ps
`include "Constants.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2019 01:15:30
// Design Name: 
// Module Name: Fractal
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


module Fractal(
    input mic_clk,
    input oled_clk,
    input clk100m,
    input [15:0] intensity, //
    input [15:0] sw, //set zoom level
    input [6:0] x,
    input [5:0] y,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
    );
endmodule
