`timescale 1ns / 1ps
`include "Constants.v"

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
    
    input mouse_data,
    input mouse_clk,
    
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp,
   
    output [7:0] JB        // Control signals to OLED
    );
    
    reg [3:0] sys_mode = 4'b0000;
    reg btnC_pipe, btnC_reg, btnU_pipe, btnU_reg, btnR_pipe, btnR_reg, btnL_pipe, btnL_reg, btnD_pipe, btnD_reg;
    wire btnC_signal, btnU_signal, btnR_signal, btnL_signal, btnD_signal;
    wire clk20k, clk6p25m, clk20;
    parameter MODE_MAX = 4'b0101; // change to actual number of modes later
    wire [15:0] intensity_reg;
    
    // signals for mic
    wire [11:0] mic_in; //data from mic
    wire [3:0] an1, an2; 
    
    // signals for oled
    reg [15:0] oled_data;
    wire frame_begin;
    wire [12:0] pixel_index;
    wire [6:0] x;
    wire [5:0] y;
    
    // output from FFT
    wire [23:0] freq_re; 
    wire [23:0] freq_im; 
    // real and imaginary parts of frequency
    wire [22:0] freq_re_abs; 
    wire [22:0] freq_im_abs; 
    wire [23:0] freq_mag; // magnitude of frequency
    wire [9:0] freq_addr; // the address of the frequency data being read out
    wire fft_done; // strobed on fft completion
    wire fft_out_rdy; // asserted when there is valid data from the fft
    
    //output from basic functionality
    wire [15:0] led_basic;
    wire [6:0] seg_basic;
    wire [3:0] an_basic;
    wire [15:0] oled_basic;
    
    //output from fractal
    wire [15:0] led_fractal;
    wire [6:0] seg_fractal;
    wire [3:0] an_fractal;
    wire [15:0] oled_fractal;
    
    //output from vertical bar volume indicator
    wire [15:0] led_vertical;
    wire [6:0] seg_vertical;
    wire [3:0] an_vertical;
    wire [15:0] oled_vertical;
    
    //output from square volume indicator
    wire [15:0] led_square;
    wire [6:0] seg_square;
    wire [3:0] an_square;
    wire [15:0] oled_square;
    
    //output from circle volume indicator
    wire [15:0] led_circle;
    wire [6:0] seg_circle;
    wire [3:0] an_circle;
    wire [15:0] oled_circle;
    
    //output from space invader game
    wire [15:0] led_space;
    wire [6:0] seg_space;
    wire [3:0] an_space;
    wire [15:0] oled_space;
    
    // Button debouncing
    assign btnC_signal = ~btnC_reg & btnC_pipe;
    assign btnU_signal = ~btnU_reg & btnU_pipe;
    assign btnR_signal = ~btnR_reg & btnR_pipe;
    assign btnL_signal = ~btnL_reg & btnL_pipe;
    assign btnD_signal = ~btnD_reg & btnD_pipe;
    
    // Clock setup
    Clk_Gen clk_gen (.clk100m(clk_in), .clk6p25m(clk6p25m), .clk20(clk20), .clk20k(clk20k));
    
    // Mic setup
    Audio_Capture audio_capture (.CLK(clk_in), .cs(clk20k), .MISO(J_MIC3_Pin3),
        .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));
   
    // Oled setup
    Oled_Display oled_display (.clk(clk6p25m), .reset(btnC_signal), .pixel_data(oled_data),
        .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]),
        .frame_begin(frame_begin), .pixel_index(pixel_index));
    Coord_Sys coord_sys (.pixel_index(pixel_index), .x(x), .y(y));
    
    // FFT module
    FFT fft (.clk100m(clk_in), .clk20k(clk20k), .mic_in(mic_in), .freq_mag(freq_mag),
        .freq_addr(freq_addr), .fft_done(fft_done), .fft_out_rdy(fft_out_rdy),
        .freq_re(freq_re), .freq_im(freq_im), .freq_re_abs(freq_re_abs), .freq_im_abs(freq_im_abs)); 
    
    // Basic functionality module
    Vol_Indic vol_indic (.mic_clk(clk20k), .oled_clk(clk6p25m), .sw(sw), .mic_in(mic_in), .led(led_basic), .oled_data(oled_basic), .seg(seg_basic),
            .an(an_basic), .x(x), .y(y), .intensity_reg(intensity_reg));
            
    // Vertical Bar Volume Indicator 
    Vol_Indic_Ver_Bar vol_indic_ver (.mic_clk(clk20k), .oled_clk(clk6p25m), .sw(sw), .mic_in(mic_in), .led(led_vertical), .oled_data(oled_vertical), .seg(seg_vertical),
                .an(an_vertical), .x(x), .y(y), .intensity_reg(intensity_reg));
                
    // Vertical Bar Volume Indicator 
    Vol_Indic_Square vol_indic_square (.mic_clk(clk20k), .oled_clk(clk6p25m), .sw(sw), .mic_in(mic_in), .led(led_square), .oled_data(oled_square), .seg(seg_square),
                .an(an_square), .x(x), .y(y), .intensity_reg(intensity_reg));
                
    // Vertical Bar Volume Indicator 
    Vol_Indic_Circle vol_indic_circle (.mic_clk(clk20k), .oled_clk(clk6p25m), .sw(sw), .mic_in(mic_in), .led(led_circle), .oled_data(oled_circle), .seg(seg_circle),
                .an(an_circle), .x(x), .y(y), .intensity_reg(intensity_reg));
            
    // Fractal visualiser module
    Fractal fractal (.x(x), .freq_mag(freq_mag), .freq_addr(freq_addr), .fft_done(fft_done), 
            .fft_out_rdy(fft_out_rdy), .mic_clk(clk20k), .oled_clk(clk6p25m), .clk100m(clk_in),
            .led(led_fractal), .oled_data(oled_fractal), .seg(seg_fractal), .an(an_fractal), 
            .frame_begin(frame_begin), .clk20(clk20));
    
    // Space Invader Game 
    Space_Invader space_invader (.mic_clk(clk20k), .oled_clk(clk6p25m), .sw(sw), .mic_in(mic_in), .led(led_space), .oled_data(oled_space), .seg(seg_space),
                .an(an_space), .x(x), .y(y), .intensity_reg(intensity_reg), .mouse_data(mouse_data), .mouse_clk(mouse_clk));      
    
    
    // Multiplexer to select output from chosen module
    //
    // This is a combinational always block; ensure every case gives a value for
    // all of these signals:
    // led, oled_data, seg, an, dp 
    always @(*) begin
        case (sys_mode)
            4'b0001: begin
                led = led_fractal;
                oled_data = oled_fractal;
                seg = seg_fractal;
                an = an_fractal;
                dp = 1'b1;
            end
            4'b0010: begin
                led = led_vertical;
                oled_data = oled_vertical;
                seg = seg_vertical;
                an = an_vertical;
                dp = 1'b1;
            end
            4'b0011: begin
                led = led_square;
                oled_data = oled_square;
                seg = seg_square;
                an = an_square;
                dp = 1'b1;
            end
            4'b0100: begin
                led = led_circle;
                oled_data = oled_circle;
                seg = seg_circle;
                an = an_circle;
                dp = 1'b1;
            end
            4'b0101: begin
                led = led_space;
                oled_data = oled_space;
                seg = seg_space;
                an = an_space;
                dp = 1'b1;
            end
            default: begin //default to basic functionality
                led = led_basic;
                oled_data = oled_basic;
                seg = seg_basic;
                an = an_basic;
                dp = 1'b1;
            end
        endcase
    end 
    
    always @(posedge clk20) begin
        btnC_pipe <= btnC;
        btnC_reg <= btnC_pipe;
        btnU_pipe <= btnU;
        btnU_reg <= btnU_pipe;
        btnL_pipe <= btnL;
        btnL_reg <= btnL_pipe;
        btnL_pipe <= btnL;
        btnL_reg <= btnL_pipe;
        btnD_pipe <= btnD;
        btnD_reg <= btnD_pipe;
        
        if (sw[15]) begin
            if (btnD_signal) begin
                sys_mode <= (sys_mode == MODE_MAX) ? 4'b0000 : sys_mode + 1;
            end else if (btnU_signal) begin
                sys_mode <= (sys_mode == 4'b0000) ? MODE_MAX : sys_mode - 1;
            end
        end
    end
endmodule