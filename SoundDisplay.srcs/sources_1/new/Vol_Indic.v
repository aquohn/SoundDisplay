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

/**
 * sw[0]/sw[1]: select colour theme
 * sw[2]: select border thickness
 * sw[3]: toggle volume bar
 * sw[4]: toggle border
 * sw[11]: 10Hz frequency
 * sw[12]: 5Hz frequency
 * sw[13]: pause
 * sw[14]: force readout to 0
 * sw[15]: constant LED indicator (Task 1 requirement)
 */
 
module Vol_Indic(
    input in_CLK,
    input [15:9] sw,
    input [11:0] mic_in,
    input [6:0] x,
    input [5:0] y,
    output reg [14:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp = 1'b1
    );
    
    reg [12:0] counter = 0;
    reg [11:0] peak_intensity = 12'b0;

    reg [6:0] seg_tens = 7'b0;   
    reg [6:0] seg_ones = 7'b0;
    
    reg [12:0] freq_count = 0;
    
    reg [15:0] colour_border, colour_bg, colour_high, colour_mid, colour_low;
    
    always @(*) begin
        case (sw[1:0])
            2'b01: begin
                colour_border = {5'd4, 6'd15, 5'd11};
                colour_bg = {5'd29, 6'd58, 5'd25};
                colour_high = {5'd19, 6'd47, 5'd24};
                colour_mid = {5'd3, 6'd20, 5'd18};
                colour_low = {5'd4, 6'd15, 5'd11};                
            end
            2'b10: begin
                colour_border = {5'd27, 6'd41, 5'd2};
                colour_bg = {5'd27, 6'd51, 5'd23};
                colour_high = {5'd22, 6'd53, 5'd22};
                colour_mid = {5'd6, 6'd50, 5'd17};
                colour_low = {5'd13, 6'd40, 5'd17};                        
            end
            2'b11: begin
                colour_border = `OLED_WHITE;
                colour_bg = `OLED_BLACK;
                colour_high = `OLED_RED;
                colour_mid = `OLED_YELLOW;
                colour_low = `OLED_YELLOW; 
            end
            default: begin
                colour_border = `OLED_WHITE;
                colour_bg = `OLED_BLACK;
                colour_high = `OLED_RED;
                colour_mid = `OLED_YELLOW;
                colour_low = `OLED_GREEN;                    
            end    
        endcase
    end
    
    always @ (posedge in_CLK) begin
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
        
        if (freq_count == 0 && sw[15] == 0 && sw[13] == 0) begin
            if (sw[14] == 1) begin // Set the reading to 0
                led <= 15'b0;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1000000;
            end
            
            else if (peak_intensity >= 3954) begin
                led <= 15'b111111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0010010;
            end
            
            else if (peak_intensity >= 3818) begin
                led <= 15'b011111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0011001;
            end
            
            else if (peak_intensity >= 3682) begin
                led <= 15'b001111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0110000;
            end
            
            else if (peak_intensity >= 3545) begin
                led <= 15'b000111111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b0100100;
            end
            
            else if (peak_intensity >= 3409) begin
                led <= 15'b000011111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b1111001;
            end
            
            else if (peak_intensity >= 3273) begin
                led <= 15'b000001111111111;
                seg_tens <= 7'b1111001;
                seg_ones <= 7'b1000000;
            end
            
            else if (peak_intensity >= 3137) begin
                led <= 15'b000000111111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0011000;
            end
            
            else if (peak_intensity >= 3000) begin
                led <= 15'b000000011111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0000000;
            end
            
            else if (peak_intensity >= 2864) begin
                led <= 15'b000000001111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1111000;
            end
            
            else if (peak_intensity >= 2728) begin
                led <= 15'b000000000111111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0000010;
            end
            
            else if (peak_intensity >= 2592) begin
                led <= 15'b000000000011111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0010010;
            end
            
            else if (peak_intensity >= 2456) begin
                led <= 15'b000000000001111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0011001;
            end
            
            else if (peak_intensity >= 2320) begin
                led <= 15'b000000000000111;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0110000;
            end
            
            else if (peak_intensity >= 2200) begin
                led <= 15'b000000000000011;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b0100100;
            end

            else if (peak_intensity >= 2070) begin
                led <= 15'b000000000000001;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1111001;
            end
            
            else begin
                led <= 15'b000000000000000;
                seg_tens <= 7'b1000000;
                seg_ones <= 7'b1000000;
            end
        end
        else if (sw[15] == 1) begin // MUX to read from mic_in instead of the peak intensity
            led <= mic_in;
            seg_tens <= 7'b1111111;
            seg_ones <= 7'b1111111;
        end
        
        // draw screen
        oled_data <= colour_bg;
        
        // draw border
        if (~sw[4]) begin
            
        end

        // draw bars
        if (~sw[3] && x >= 40 && x <= 55) begin
            if (y >= 59 && y <= 61 & led[0]) begin
                oled_data <= colour_low;
            end else if (y >= 55 && y <= 57 & led[1]) begin
                oled_data <= colour_low;
            end else if (y >= 51 && y <= 53 & led[2]) begin
                oled_data <= colour_low;
            end else if (y >= 47 && y <= 49 & led[3]) begin
                oled_data <= colour_low;
            end else if (y >= 43 && y <= 45 & led[4]) begin
                oled_data <= colour_low;

            end else if (y >= 39 && y <= 41 & led[5]) begin
                oled_data <= colour_med;
            end else if (y >= 35 && y <= 37 & led[6]) begin
                oled_data <= colour_med;
            end else if (y >= 31 && y <= 33 & led[7]) begin
                oled_data <= colour_med;
            end else if (y >= 27 && y <= 29 & led[8]) begin
                oled_data <= colour_med;
            end else if (y >= 23 && y <= 25 & led[9]) begin
                oled_data <= colour_med;

            end else if (y >= 19 && y <= 21 & led[10]) begin
                oled_data <= colour_high;
            end else if (y >= 15 && y <= 17 & led[11]) begin
                oled_data <= colour_high;
            end else if (y >= 11 && y <= 13 & led[12]) begin
                oled_data <= colour_high;
            end else if (y >= 7 && y <= 9 & led[13]) begin
                oled_data <= colour_high;
            end else if (y >= 3 && y <= 5 & led[14]) begin
                oled_data <= colour_high;
        end
        
        // Find the peak intensity of the audio signal by using find max
        peak_intensity <= (freq_count == 0) ? 0 : (mic_in > peak_intensity) ? mic_in[11:0] : peak_intensity[11:0];
    end
endmodule
