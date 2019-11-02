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
    input oled_clk,
    input clk100m,
    input clk20,
    input frame_begin,
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
    
    parameter UP = 0;
    parameter DOWN = 1;
    parameter LEFT = 2;
    parameter RIGHT = 3;
    
    parameter RED_ISMAX = 0;
    parameter GREEN_ISMAX = 1;
    parameter BLUE_ISMAX = 2;

    wire bird_clk;        
    reg [2:0] bird_cnt = 2'b00;
    
    Clk_Gen bird_clk_gen();
    
endmodule
