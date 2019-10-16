`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 22:09:11
// Design Name: 
// Module Name: CLK_5Hz
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


module CLK_5Hz(
    input clk_in,
    output reg clk_out
    );
    
    reg [10:0] cnt;
    
    initial begin
        cnt = 11'd0;
        clk_out = 1'b0; 
    end
    
    parameter CNT_TOGGLE = 11'd1999;
    
    always @(posedge clk_in) begin
        if (cnt == CNT_TOGGLE) begin
            cnt <= 11'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule