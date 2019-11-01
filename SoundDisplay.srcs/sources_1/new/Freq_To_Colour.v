`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2019 10:53:01
// Design Name: 
// Module Name: Freq_To_Colour
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


module Freq_To_Colour(
    input clk,
    input we,
    input reset,
    input [9:0] addr,
    input [23:0] freq_mag,
    output reg [31:0] r_sum = 32'b0,
    output reg [32:0] g_sum = 33'b0,
    output reg [31:0] b_sum = 32'b0
    );
    
    parameter RED_LIMIT = 256;
    parameter GREEN_LIMIT = 768;
    
    // add freq values to colour fields
    always @(posedge clk) begin
        if (reset) begin
            r_sum <= 32'b0;
            g_sum <= 33'b0;
            b_sum <= 32'b0;
        end else if (we) begin
            if (addr < RED_LIMIT) begin
                r_sum <= r_sum + freq_mag;
            end else if (addr < GREEN_LIMIT) begin
                g_sum <= g_sum + freq_mag;
            end else begin
                b_sum <= b_sum + freq_mag;
            end
        end
    end
endmodule
