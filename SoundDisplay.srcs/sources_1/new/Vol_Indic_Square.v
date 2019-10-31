`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2019 19:42:17
// Design Name: 
// Module Name: Vol_Indic_Square
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

/**
 * sw[0]/sw[1]: select colour theme
 * sw[2]: select border thickness
 * sw[3]: toggle square volume indicator
 * sw[4]: toggle border
 * sw[5]: toggle 4 squares volume indicator
 * sw[7]: toggle moving square 
 * sw[9]: left 2 anodes display
 * sw[10]: middle 2 anodes display
 * sw[11]: 10Hz frequency
 * sw[12]: 5Hz frequency
 * sw[13]: pause
 * sw[14]: force readout to 0
 * sw[15]: constant LED indicator (Task 1 requirement)
 */
 
module Vol_Indic_Square(
    input mic_clk,
    input oled_clk,
    input [15:0] sw,
    input [11:0] mic_in,
    input [6:0] x,
    input [5:0] y,
    output reg [15:0] led,
    output reg [15:0] intensity_reg,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    
    reg [12:0] counter = 0;
    reg [11:0] peak_intensity = 12'b0;

    reg [6:0] seg_tens = 7'b0;   
    reg [6:0] seg_ones = 7'b0;
    
    reg [12:0] freq_count = 0;
    reg [17:0] freq_count_oled = 0;
    
    reg [6:0] left = 7'd43;
    reg [6:0] right = 7'd53;
    reg [6:0] up = 7'd55;
    reg [6:0] down = 7'd60;
    
    reg [15:0] colour_border, colour_bg, colour_high, colour_mid, colour_low, colour_mid_high, colour_mid_mid;

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
    
    always @ (posedge mic_clk) begin
        // Find the peak intensity of the audio signal by using find max
        peak_intensity <= (freq_count == 0) ? 0 : (mic_in > peak_intensity) ? mic_in[11:0] : peak_intensity[11:0];
    
        // Enhancement feature to set sampling frequency
        if (sw[12] == 1) begin
            freq_count <= (freq_count == 1999) ? 0 : freq_count + 1; // 5Hz frequency
        end 
        else if (sw[11] == 1) begin
            freq_count <= (freq_count == 999) ? 0 : freq_count + 1; // 10Hz frequency
        end else begin
            freq_count <= (freq_count == 4999) ? 0 : freq_count + 1; // 2Hz frequency
        end
       
        // Enhancement feature to set anode display pattern
        if (sw[9] == 1) begin
            an <= (an == 4'b0111) ? 4'b1011 : 4'b0111;
            seg <= (an == 4'b0111) ? seg_ones : seg_tens; // Using the first 2 anodes from the left
        end
        else if (sw[10] == 1) begin
            an <= (an == 4'b1011) ? 4'b1101 : 4'b1011;
            seg <= (an == 4'b1011) ? seg_ones : seg_tens; // Using the middle 2 anodes
        end 
        else begin
            an <= (an == 4'b1101) ? 4'b1110 : 4'b1101;
            seg <= (an == 4'b1101) ? seg_ones : seg_tens; // Using the right 2 anodes
        end
        
        if (freq_count == 0 && sw[13] == 0) begin
            if (sw[14] == 1) begin // Set the reading to 0
                intensity_reg <= 15'b0;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1000000;
            end
            
            else if (peak_intensity >= 3954) begin
                intensity_reg <= 15'b111111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0010010;
            end
            
            else if (peak_intensity >= 3818) begin
                intensity_reg <= 15'b011111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0011001;
            end
            
            else if (peak_intensity >= 3682) begin
                intensity_reg <= 15'b001111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0110000;
            end
            
            else if (peak_intensity >= 3545) begin
                intensity_reg <= 15'b000111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0100100;
            end
            
            else if (peak_intensity >= 3409) begin
                intensity_reg <= 15'b000011111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b1111001;
            end
            
            else if (peak_intensity >= 3273) begin
                intensity_reg <= 15'b000001111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b1000000;
            end
            
            else if (peak_intensity >= 3137) begin
                intensity_reg <= 15'b000000111111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0011000;
            end
            
            else if (peak_intensity >= 3000) begin
                intensity_reg <= 15'b000000011111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0000000;
            end
            
            else if (peak_intensity >= 2864) begin
                intensity_reg <= 15'b000000001111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1111000;
            end
            
            else if (peak_intensity >= 2728) begin
                intensity_reg <= 15'b000000000111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0000010;
            end
            
            else if (peak_intensity >= 2592) begin
                intensity_reg <= 15'b000000000011111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0010010;
            end
            
            else if (peak_intensity >= 2456) begin
                intensity_reg <= 15'b000000000001111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0011001;
            end
            
            else if (peak_intensity >= 2320) begin
                intensity_reg <= 15'b000000000000111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0110000;
            end
            
            else if (peak_intensity >= 2200) begin
                intensity_reg <= 15'b000000000000011;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0100100;
            end

            else if (peak_intensity >= 2070) begin
                intensity_reg <= 15'b000000000000001;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1111001;
            end
            
            else begin
                intensity_reg <= 15'b000000000000000;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1000000;
            end
        end
        
        if (sw[15] == 0) begin
            led <= intensity_reg;
        end else begin // MUX to read from mic_in instead of the peak intensity
            if (freq_count == 0) begin
                led <= mic_in;
                seg_tens <= 7'b1111111;
                seg_ones <= 7'b1111111;
            end
        end
    end
    
    always @(posedge oled_clk) begin    
        // draw screen
        oled_data <= colour_bg;
        
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
        
        if (~sw[5] && ~sw[3] && y > 2 && y < 61 && x > 2 && x < 93) begin : gensquare
             integer i;
             for (i = 0; i < 15; i = i + 1) begin
                if (x >= 43 - 3 * i && x <= 52 + 3 * i && y >= 28 - 2 * i && y <= 36 + 2 * i && intensity_reg[i]) begin
                    if (i < 3) begin
                        oled_data <= colour_low;
                    end else if (i < 6) begin
                        oled_data <= colour_mid_mid;
                    end else if (i < 9) begin
                        oled_data <= colour_mid;
                    end else if (i < 12) begin
                        oled_data <= colour_mid_high;
                    end else begin
                        oled_data <= colour_high;
                    end 
                end
            end
        end
        
        if (freq_count_oled == 0 && ~sw[5] && sw[7]) begin : genmovingsquare
            integer i;
            for (i = 0; i < 15; i = i + 1) begin
                if (i == 2 && intensity_reg[2]) begin
                    left <= (left == 7'b1010010) ? 7'b1010010 : left + 1; // move right
                    right <= (right == 7'b1011100) ? 7'b1011100 : right + 1;
                end else if (i == 6 && intensity_reg[6]) begin
                    left <= (left == 7'b0000011) ? 7'b0000011 : left - 1; // move left
                    right <= (right == 7'b0001101) ? 7'b0001101 : right - 1;
                end else if (i == 10 && intensity_reg[10]) begin
                    up <= (up == 7'b0000011) ? 7'b0000011 : up - 1; // move up
                    down <= (down == 7'b0001000) ? 7'b00001000 : down - 1; 
                end else if (i == 14 && intensity_reg[14]) begin
                    up <= (up == 7'b0110111) ? 7'b0110111 : up + 1; // move down
                    down <= (down == 7'b0111100) ? 7'b0111100 : down + 1; 
                end
            end
        end else if (sw[7] && y >= 3 && y <= 60 && x >= 3 && x <= 92) begin
            if (x >= left && x <= right && y >= up && y <= down) begin
                oled_data <= colour_mid_high;
            end
        end   
        
        if (sw[5]) begin : genmultiplesquare
            integer i;
            for (i = 0; i < 15; i = i + 1) begin
               if (x > 16 - i && x <= 33 + i && y > 16 - i && y <= 18 + i && intensity_reg[i]) begin
                   if (i < 3) begin
                       oled_data <= colour_low;
                   end else if (i < 6) begin
                       oled_data <= colour_mid_mid;
                   end else if (i < 9) begin
                       oled_data <= colour_mid;
                   end else if (i < 12) begin
                       oled_data <= colour_mid_high;
                   end else begin
                       oled_data <= colour_high;
                   end 
               end
               
               if (x > 16 - i && x <= 33 + i && y >= 45 - i && y < 47 + i && intensity_reg[i]) begin
                   if (i < 3) begin
                       oled_data <= colour_low;
                   end else if (i < 6) begin
                       oled_data <= colour_mid_mid;
                   end else if (i < 9) begin
                       oled_data <= colour_mid;
                   end else if (i < 12) begin
                       oled_data <= colour_mid_high;
                   end else begin
                       oled_data <= colour_high;
                   end 
               end
               
               if (x >= 61 - i && x < 79 + i && y > 16 - i && y <= 18 + i && intensity_reg[i]) begin
                   if (i < 3) begin
                       oled_data <= colour_low;
                   end else if (i < 6) begin
                       oled_data <= colour_mid_mid;
                   end else if (i < 9) begin
                       oled_data <= colour_mid;
                   end else if (i < 12) begin
                       oled_data <= colour_mid_high;
                   end else begin
                       oled_data <= colour_high;
                   end 
               end
               
               if (x >= 61 - i && x < 79 + i && y >= 45 - i && y < 47 + i && intensity_reg[i]) begin
                   if (i < 3) begin
                        oled_data <= colour_low;
                   end else if (i < 6) begin
                       oled_data <= colour_mid_mid;
                   end else if (i < 9) begin
                       oled_data <= colour_mid;
                   end else if (i < 12) begin
                       oled_data <= colour_mid_high;
                   end else begin
                       oled_data <= colour_high;
                   end 
               end
           end
       end
   end
endmodule