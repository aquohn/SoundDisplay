`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M
//
//  STUDENT A NAME: Andrew Lau
//  STUDENT A MATRICULATION NUMBER: 
//
//  STUDENT B NAME: John Khoo
//  STUDENT B MATRICULATION NUMBER: A0190732H 
//
//////////////////////////////////////////////////////////////////////////////////

// JA - microphone, JB - video

module Top_Student (
    input clk_in,         // 100MHz board clock
    
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    
    input audio_sw,           // Switch to use microphone (1) or to use zero signal (0)
    
    input oled_reset,        // Reset signal for OLED
    output [7:0] JB        // Control signals to OLED
    );

    reg [11:0] mic_in;
    reg [15:0] oled_data;
    reg oled_reset_pipe, oled_reset_ff;
    wire clk20k, clk6p25m, oled_reset_signal;
    
    initial begin
        oled_data = 16'h07E0;
    end
    
    clk_voice clk_voice_mod (.clk_in(clk_in), .clk_out(clk6p25m));
    Audio_Capture audio_capture (.CLK(clk_in), .cs(clk6p25m), .MISO(J_MIC3_Pin3),
    .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));
    
    //TODO: Complete audio part here...
    
    assign oled_reset_signal = oled_reset_ff & oled_reset_pipe;
    clk_oled clk_oled_mod (.clk_in(clk_in), .clk_out(clk20k));
    Oled_Display oled_display (.clk(clk6p25m), .reset(oled_reset_pipe), .pixel_data(oled_data),
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]));
    
    always @(posedge clk6p25m) begin
        oled_reset_pipe <= oled_reset;
        oled_reset_ff <= oled_reset_pipe;
    end
    
    /*
    input clk, reset;
    output frame_begin, sending_pixels, sample_pixel;
    output [PixelCountWidth-1:0] pixel_index;
    input [15:0] pixel_data;
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    output [4:0] teststate;
    */
    
    

endmodule
