`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2019 16:59:18
// Design Name: 
// Module Name: VolIndic
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


module Vol_Indic(
    input sw,
    input [11:0] mic_in,
    output [11:0] led
    );
    
    assign led = (sw == 1) ? 0 : mic_in;
endmodule
