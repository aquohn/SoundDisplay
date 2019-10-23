`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2019 14:47:23
// Design Name: 
// Module Name: clk_voice
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

//TODO: integrate reset?
//TODO: parametrise and use for loop?

module Clk_Gen(
    input clk100m,
    output reg clk6p25m,
    output reg clk20k,
    output reg clk20
    );
    
    reg [3:0] cnt6p25m;
    reg [11:0] cnt20k;
    reg [21:0] cnt20;
    
    initial begin
        cnt6p25m = 4'd0;
        clk6p25m = 1'b0;
        cnt20k = 12'd0; 
        clk20k = 1'b0; 
        cnt20 = 22'd0;
        clk20 = 1'b0;
    end
    
    parameter CNT_6P25_TOGGLE = 7;
    parameter CNT_20K_TOGGLE = 2499;
    parameter CNT_20_TOGGLE = 2499999;
    
    always @(posedge clk100m) begin

        // use blocking assignments for clock divider

        cnt6p25m <= cnt6p25m + 1;
        cnt20k <= cnt20k + 1;
        cnt20 <= cnt20 + 1;

        if (cnt6p25m == CNT_6P25_TOGGLE) begin
            cnt6p25m <= 4'd0;
            clk6p25m = ~clk6p25m;
        end

        if (cnt20k == CNT_20K_TOGGLE) begin
            cnt20k <= 12'd0;
            clk20k = ~clk20k;
        end

        if (cnt20 == CNT_20_TOGGLE) begin
            cnt20 <= 22'd0;
            clk20 = ~clk20;
        end
    end
endmodule
