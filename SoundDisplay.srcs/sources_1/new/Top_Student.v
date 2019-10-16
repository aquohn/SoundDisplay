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
    
    input [15:0] sw,
    input btnC,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp,
    
    output [7:0] JB        // Control signals to OLED
    );
    
    reg [3:0] sys_mode = 4'b0000;
    reg btnC_pipe, btnC_ff, btnU_pipe, btnU_ff, btnR_pipe, btnR_ff, btnL_pipe, btnL_ff, btnD_pipe, btnD_ff;
    wire btnC_signal, btnU_signal, btnR_signal, btnL_signal, btnD_signal;
    wire clk20k, clk6p25m;
    parameter MODE_MAX = 4'b1111; // change to actual number of modes later
    
    wire [11:0] mic_in; //data from mic
    
    reg [15:0] oled_data;
    wire frame_begin;
    wire [12:0] pixel_index;
    
    //output from basic functionality
    wire [11:0] led_basic;
    wire [6:0] seg_basic;
    wire [3:0] an_basic;
    wire dp_basic;
    wire [15:0] oled_basic;
    
    //output from ...
    
    // Button debouncing
    assign btnC_signal = ~btnC_ff & btnC_pipe;
    assign btnU_signal = ~btnU_ff & btnC_pipe;
    assign btnR_signal = ~btnR_ff & btnC_pipe;
    assign btnL_signal = ~btnL_ff & btnC_pipe;
    assign btnD_signal = ~btnD_ff & btnD_pipe;
    
    // Mic setup
    clk_voice clk_voice_mod (.clk_in(clk_in), .clk_out(clk20k));
    Audio_Capture audio_capture (.CLK(clk_in), .cs(clk20k), .MISO(J_MIC3_Pin3),
        .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));
    
    // Oled setup
    clk_oled clk_oled_mod (.clk_in(clk_in), .clk_out(clk6p25m));
    Oled_Display oled_display (.clk(clk6p25m), .reset(btnC_signal), .pixel_data(oled_data),
        .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]),
        .frame_begin(frame_begin), .pixel_index(pixel_index));
    
    // Basic functionality module
    Vol_Indic vol_indic (.sw(sw[15]), .mic_in(mic_in), .led(led_basic), .oled_data(oled_basic), .seg(seg_basic),
        .an(an_basic), .dp(dp_basic));
    
    // Multiplexer to select output from chosen module
    
    // combinational always block; ensure every case gives a value for every one of:
    // led, oled_data, seg, an, dp 
    always @(*) begin
        case (sys_mode)
            default: begin //default to basic functionality
                led = {4'b0000, led_basic};
                oled_data = oled_basic;
                seg = seg_basic;
                an = an_basic;
                dp = dp_basic;
            end
        endcase
    end 
    
    always @(posedge clk6p25m) begin
        btnC_pipe <= btnC;
        btnC_ff <= btnC_pipe;
        btnU_pipe <= btnU;
        btnU_ff <= btnU_pipe;
        btnL_pipe <= btnL;
        btnL_ff <= btnL_pipe;
        btnL_pipe <= btnL;
        btnL_ff <= btnL_pipe;
        btnD_pipe <= btnD;
        btnD_ff <= btnD_pipe;
        
        if (btnD_signal) begin
            sys_mode <= (sys_mode == 4'b0000) ? MODE_MAX : sys_mode - 1;
        end else if (btnU_signal) begin
            sys_mode <= (sys_mode == MODE_MAX) ? 4'b0000 : sys_mode + 1;
        end
    end
    
endmodule