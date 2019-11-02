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
    input oled_clk,
    input clk100m,
    input clk20,
    input frame_begin,
    input [15:0] sw, //set zoom level
    input [6:0] x,
    input [5:0] y,
    input [4:0] r,
    input [5:0] g,
    input [4:0] b,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    
    reg fft_done_pipe = 1'b0;
   
    reg [4:0] frame_r;
    reg [5:0] frame_g;
    reg [4:0] frame_b;
    
    always @(*) begin
        led = sw;
        oled_data = {frame_r, frame_g, frame_b};
        seg = 7'b1111111;
        an = 4'b1111;
    end

    always @(posedge clk20) begin
        frame_r <= r;
        frame_b <= b;
        frame_g <= g;
    end
    
endmodule
