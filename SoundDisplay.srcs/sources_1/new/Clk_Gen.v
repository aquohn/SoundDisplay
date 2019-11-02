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
    input [31:0] toggle,
    output reg clk_out = 1'b0
    );
    
    reg [31:0] cnt = 32'b0;
    
    always @(posedge clk100m) begin

        // use blocking assignments for clock divider

        cnt <= cnt + 1;

        if (cnt >= toggle) begin
            cnt <= 32'd0;
            clk_out = ~clk_out;
        end
    end
endmodule
