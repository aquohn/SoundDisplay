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

module clk_oled(
    input clk100m,
    output reg clk6p25m,
    output reg clk12p5m
    );
    
    reg [11:0] cnt;
    
    initial begin
        cnt = 4'd0;
        clk6p25m = 1'b0;
        clk12p5m = 1'b0; 
    end
    
    parameter CNT_6P25_TOGGLE = 4'd7;
    parameter CNT_12P5_TOGGLE = 4'd3;
    
    always @(posedge clk100m) begin
        if (cnt == CNT_6P25_TOGGLE) begin
            cnt <= 4'd0;
            clk6p25m <= ~clk6p25m;
            clk12p5m <= ~clk12p5m;    
        end else if (cnt == CNT_12P5_TOGGLE) begin
            clk12p5m <= ~clk12p5m;
            cnt <= cnt + 1;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule