`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 22:11:18
// Design Name: 
// Module Name: CLK_10Hz
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


module CLK_10Hz(
    input clk_in,
    output reg clk_out
    );
    
    reg [9:0] cnt;
    
    initial begin
        cnt = 10'd0;
        clk_out = 1'b0; 
    end
    
    parameter CNT_TOGGLE = 10'd999;
    
    always @(posedge clk_in) begin
        if (cnt == CNT_TOGGLE) begin
            cnt <= 10'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule