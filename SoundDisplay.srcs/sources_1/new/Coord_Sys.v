`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2019 14:37:43
// Design Name: 
// Module Name: Coord_Sys
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


module Coord_Sys(
    input [12:0] pixel_index,
    input [6:0] x,
    input [5:0] y
    );
    
    parameter OLED_HEIGHT = 64;
    parameter OLED_WIDTH = 96;
    
    assign x = pixel_index % OLED_WIDTH;
    assign y = pixel_index / OLED_HEIGHT;
    
endmodule
