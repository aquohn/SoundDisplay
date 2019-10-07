`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M
//
//  STUDENT A NAME: Andrew 
//  STUDENT A MATRICULATION NUMBER: 
//
//  STUDENT B NAME: John Khoo
//  STUDENT B MATRICULATION NUMBER: A0190732H 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk_in,         // 100MHz board clock
    
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    
    input mic_sw           // Switch to use microphone (1) or to use zero signal (0)
    );

    reg [11:0] mic_in;
    wire clk_v;
    
    clk_voice clk_voice_mod (.clk_in(clk_in), .clk_out(clk_v));
    Audio_Capture mic_capture (.CLK(clk_in), .cs(clk_v), .MISO(J_MIC3_Pin3),
    .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));
    
    //TODO: Complete audio part here...

endmodule