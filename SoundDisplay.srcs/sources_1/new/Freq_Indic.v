`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2019 10:29:56
// Design Name: 
// Module Name: Freq_Indic
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


module Freq_Indic(
    input [15:0] sw,
    input oled_clk,
    input frame_begin,
    input [464:0] freq_cnts,
    input [6:0] x,
    input [5:0] y,
    output reg [15:0] oled_data
    );
    
    wire [30:0] freq_bins [0:14];
    reg [5:0] freq_reg [0:14];
    reg [6:0] seg_tens = 7'b0;   
    reg [6:0] seg_ones = 7'b0;
    reg [12:0] freq_count = 0;
    reg [15:0] colour_border, colour_bg, colour_high, colour_mid, colour_low, colour_mid_high, colour_mid_mid;
    
    genvar j;
    for (j = 0; j < 15; j = j + 1) begin
        assign freq_bins[j] = freq_cnts[30 * (j + 1) -: 31];
    end

    always @(*) begin
        case ({sw[1], sw[0]})
            2'b01: begin //ocean
                    colour_border = {5'd4, 6'd15, 5'd11};
                    colour_bg = {5'd29, 6'd58, 5'd25};
                    colour_high = {5'd19, 6'd47, 5'd24};
                    colour_mid_high = {5'd11, 6'd37, 5'd30};
                    colour_mid = {5'd5, 6'd30, 5'd30};
                    colour_mid_mid = {5'd2, 6'd14, 5'd15};
                    colour_low = {5'd4, 6'd15, 5'd11};                
                end
                2'b10: begin //earth
                    colour_border = {5'd27, 6'd46, 5'd2};
                    colour_bg = {5'd29, 6'd56, 5'd21};
                    colour_high = {5'd22, 6'd58, 5'd15};
                    colour_mid_high = {5'd15, 6'd59, 5'd16};
                    colour_mid = {5'd6, 6'd50, 5'd10};
                    colour_mid_mid = {5'd13, 6'd40, 5'd10};
                    colour_low = {5'd8, 6'd30, 5'd9};                                 
                end
                2'b11: begin //enhancement colour scheme: sunset
                    colour_border = {5'd31, 6'd54, 5'd22};
                    colour_bg = {5'd6, 6'd14, 5'd10};
                    colour_high = {5'd31, 6'd41, 5'd22};
                    colour_mid_high = {5'd25, 6'd46, 5'd30};
                    colour_mid = {5'd18, 6'd32, 5'd22};
                    colour_mid_mid = {5'd21, 6'd33, 5'd20};
                    colour_low = {5'd10, 6'd21, 5'd15}; 
                end
                default: begin
                    colour_border = `OLED_WHITE;
                    colour_bg = `OLED_BLACK;
                    colour_high = `OLED_RED;
                    colour_mid_high = {5'd31, 6'd31, 5'd0};
                    colour_mid = `OLED_YELLOW;
                    colour_mid_mid = {5'd22, 6'd58, 5'd5};
                    colour_low = `OLED_GREEN;                    
                end    
        endcase       
    end
    
    always @(posedge oled_clk) begin    
            // draw screen
            oled_data <= colour_bg;
            
            // store frequency values for this frame
            if (frame_begin) begin : storefreq
                integer k;
                for (k = 0; k < 15; k = k + 1) begin
                    freq_reg[k] <= freq_reg[k][17:12];
                end
            end
            
            // draw border
            if (~sw[4]) begin
                case (sw[2]) 
                    1'b0: begin
                        if (x == 0 || x == 95 || y == 0 || y == 63) begin
                            oled_data <= colour_border;
                        end
                    end
                    1'b1: begin
                        if (x <= 2 || x >= 93 || y <= 2 || y >= 61) begin
                            oled_data <= colour_border;
                        end
                    end
                endcase
            end
            
            if (~sw[3] && y > 2 && y < 61) begin : genverbars
                integer i;
                for (i = 0; i < 15 ; i = i + 1) begin
                    if (x >= (3 + 6 * i) && x <= (7 + 6 * i) 
                    && y >= (57 - freq_reg[i])) begin
                        if (freq_reg[i] < 12) begin
                            oled_data <= colour_low;
                        end else if (freq_reg[i] < 24) begin
                            oled_data <= colour_mid_mid;
                        end else if (freq_reg[i] < 36) begin
                            oled_data <= colour_mid;
                        end else if (freq_reg[i] < 48) begin
                            oled_data <= colour_mid_high;
                        end else begin
                            oled_data <= colour_high;
                        end 
                    end
                end
            end
       end
endmodule
