`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 22:12:28
// Design Name: 
// Module Name: freq_switch
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


module freq_switch(
    input [11:10]SW, 
    CLOCK, output chosen_clk
    );
    
    wire clk_1, clk_2, clk_3;
    
    CLK_2Hz slow (CLOCK, clk_1);
    CLK_5Hz middle (CLOCK, clk_2);
    CLK_10Hz fast (CLOCK, clk_3);
    
    assign chosen_clk = SW[13] ? clk_3 : (SW[12] ? clk_2 : clk_1);
endmodule
