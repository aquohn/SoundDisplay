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

module clk_voice(
    input clk_in,
    output reg clk_out
    );
    
    reg [11:0] cnt;
    
    initial begin
        cnt = 12'd0;
        clk_out = 1'b0; 
    end
    
    parameter CNT_TOGGLE = 12'd2499;
    
    always @(posedge clk_in) begin
        if (cnt == CNT_TOGGLE) begin
            cnt <= 12'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule
