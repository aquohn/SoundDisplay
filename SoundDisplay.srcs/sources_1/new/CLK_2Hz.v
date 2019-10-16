`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 21:57:28
// Design Name: 
// Module Name: CLK_2Hz
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

module CLK_2Hz(
    input clk_in,
    output reg clk_out
    );
    
    reg [12:0] cnt;
    
    initial begin
        cnt = 13'd0;
        clk_out = 1'b0; 
    end
    
    parameter CNT_TOGGLE = 13'd4999;
    
    always @(posedge clk_in) begin
        if (cnt == CNT_TOGGLE) begin
            cnt <= 13'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule
