`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M.
//
//  STUDENT A NAME: Andrew Lau Jia Jun
//  STUDENT A MATRICULATION NUMBER: A0182815B
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
    
    input [15:0] sw,       // Switch to use microphone (1) or to use zero signal (0)
    output [11:0] led,    // led to display the input value from mic_in
    
    input oled_reset,        // Reset signal for OLED
    output [7:0] JB        // Control signals to OLED

    );
    
    reg [3:0] system_mode = 4'b0000;

    wire clk20k, clk6p25m;
    wire [11:0] mic_in; //data from mic
    
    reg [15:0] oled_data;
    reg oled_reset_pipe, oled_reset_ff;
    wire sample_pixel, oled_reset_signal;
    wire [12:0] pixel_index;
    
    //Audio part
    clk_voice clk_voice_mod (.clk_in(clk_in), .clk_out(clk20k));
    
    Audio_Capture audio_capture (.CLK(clk_in), .cs(clk20k), .MISO(J_MIC3_Pin3),
        .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));
    
    assign led = (sw[0] == 1) ? 0 : mic_in;
    
    //oled part
    assign oled_reset_signal = ~oled_reset_ff & oled_reset_pipe;
    clk_oled clk_oled_mod (.clk_in(clk_in), .clk_out(clk6p25m));
    Oled_Display oled_display (.clk(clk6p25m), .reset(oled_reset_signal), .pixel_data(oled_data),
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]),
    .sample_pixel(sample_pixel), .pixel_index(pixel_index));
    
    always @(posedge clk6p25m) begin
        oled_reset_pipe <= oled_reset;
        oled_reset_ff <= oled_reset_pipe;
        
        oled_data <= (pixel_index < 13'd96) ? {5'b00000, 6'b000000, 5'b11111} : 13'b0;
    end
    
endmodule