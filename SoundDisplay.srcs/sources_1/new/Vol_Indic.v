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
    input in_CLK,
    input [15:9]sw,
    input [11:0] mic_in,
    output reg [14:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp
    );
    
    reg [12:0] counter = 0;
    reg [11:0] peak_intensity = 12'b0;

    reg [6:0] seg_tens = 7'b0;   
    reg [6:0] seg_ones = 7'b0;
    
    reg [12:0] freq_count = 0;
    
    
    always @ (posedge in_CLK) begin
        // Enhancement feature to set sampling rate
        if (sw[12] == 1) begin
            freq_count = (freq_count == 1999) ? 0 : freq_count + 1;
        end 
        else if (sw[11] == 1) begin
            freq_count = (freq_count == 999) ? 0 : freq_count + 1;
        end else begin
            freq_count = (freq_count == 4999) ? 0 : freq_count + 1;
        end
       
        // Enhancement feature to set anode display pattern
        if (sw[9] == 1) begin
            an = (an == 4'b0111) ? 4'b1011 : 4'b0111;
            seg = (an == 4'b0111) ? seg_tens : seg_ones;
        end
        else if (sw[10] == 1) begin
            an = (an == 4'b1011) ? 4'b1101 : 4'b1011;
            seg = (an == 4'b1011) ? seg_tens : seg_ones;
        end 
        else begin
            an = (an == 4'b1101) ? 4'b1110 : 4'b1101;
            seg = (an == 4'b1101) ? seg_tens : seg_ones;
        end
        
        if (freq_count == 0 && sw[15] == 0 && sw[13] == 0) begin
            if (sw[14] == 1) begin
                led = 15'b0;
                    seg_tens = 7'b1000000;
                    seg_ones = 7'b1000000;
                end
            else if (peak_intensity >= 3954) begin
                led = 15'b111111111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b0010010;
            end
            
            else if (peak_intensity >= 3818) begin
                led = 15'b011111111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b0011001;
            end
            
            else if (peak_intensity >= 3682) begin
                led = 15'b001111111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b0110000;
            end
            
            else if (peak_intensity >= 3545) begin
                led = 15'b000111111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b0100100;
            end
            
            else if (peak_intensity >= 3409) begin
                led = 15'b000011111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b1111001;
            end
            
            else if (peak_intensity >= 3273) begin
                led = 15'b000001111111111;
                seg_tens = 7'b1111001;
                seg_ones = 7'b1000000;
            end
            
            else if (peak_intensity >= 3137) begin
                led = 15'b000000111111111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0011000;
            end
            
            else if (peak_intensity >= 3000) begin
                led = 15'b000000011111111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0000000;
            end
            
            else if (peak_intensity >= 2864) begin
                led = 15'b000000001111111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b1111000;
            end
            
            else if (peak_intensity >= 2728) begin
                led = 15'b000000000111111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0000010;
            end
            
            else if (peak_intensity >= 2592) begin
                led = 15'b000000000011111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0010010;
            end
            
            else if (peak_intensity >= 2456) begin
                led = 15'b000000000001111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0011001;
            end
            
            else if (peak_intensity >= 2320) begin
                led = 15'b000000000000111;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0110000;
            end
            
            else if (peak_intensity >= 2184) begin
                led = 15'b000000000000011;
                seg_tens = 7'b1000000;
                seg_ones = 7'b0100100;
            end

            else if (peak_intensity >= 2048) begin
                led = 15'b000000000000001;
                seg_tens = 7'b1000000;
                seg_ones = 7'b1111001;
            end
            
            else begin
                led = 15'b000000000000000;
                seg_tens = 7'b1000000;
                seg_ones = 7'b1000000;
            end
        end
        else if (sw[15] == 1) begin
            led = mic_in;
            seg_tens = 7'b1111111;
            seg_ones = 7'b1111111;
        end
        
        peak_intensity = (freq_count == 0) ? 0 : (mic_in > peak_intensity) ? mic_in[11:0] : peak_intensity[11:0];
    end
endmodule
