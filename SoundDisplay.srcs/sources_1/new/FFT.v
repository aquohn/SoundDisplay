`timescale 1ns / 1ps
`include "Constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2019 22:50:20
// Design Name: 
// Module Name: FFT
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


/* Basic sketch of idea: Create a 1024-bit BRAM to serve as an "addressable shift register" and
 * write into it at 20kHz. Whenever a sound value is registered, recalculate the FFT at 100MHz. Whenever
 * the FFT is recalculated, send a "new signal" value for one cycle to tell the outside world to process
 * the new signal. The whole process of update sample - recalculate FFT - recalculate end user value
 * should complete within 0.016s - the period for the 60Hz OLED update.
 *
 * Space invaders: group frequencies into 3: low frequency for red, middle frequency for green, 
 * high frequency for blue. Calculate the magnitude^2 (real^2 + im^2) of each frequency value (or use CORDIC
 * core to get actual magnitude?), and scale the sum of each bin to 31/63. Use the resultant RGB value as the
 * background, and the complementary colour (~colour) as the stage (player, bullets etc.).
 *
 * Fractals: iteration count is mapped to several colours. Use the same matching of frequency to colour, but split
 * into levels. Each level increases the value of R by 1, G by 2 or B by 1
 */

module FFT(
    input clk100m,
    input clk20k,
    input [12:0] mic_in,
    output reg [4:0] r,
    output reg [5:0] g,
    output reg [4:0] b
    );
    
    reg clk20k_reg, clk20k_pipe, load_update = 1'b0;
    wire clk20k_signal;
    wire fft_reset;
    wire ampl_valid, ampl_done;
    wire fft_in_rdy, fft_out_rdy, ampl_rdy;
    
    // ampl bram signals
    reg ampl_write = 1'b0, ampl_use2 = 1'b0;
    wire [12:0] ampl_in; //amplitude selected to be written
    reg [12:0] ampl_reg1, ampl_reg2; // store amplitude for shirting purposes
    reg [9:0] sample_cnt = 10'b0; // number of data points shifted so fat
    reg [9:0] ampl_addr_in, ampl_addr_out;
    wire [12:0] ampl_out; // amplitude value read out to fft
    wire [12:0] ampl_old; // amplitude value read out for shifting
    
    // running totals of colours
    wire [4:0] r_sum;
    wire [5:0] g_sum;
    wire [4:0] b_sum;
    
    // fft signals
    reg [9:0] freq_addr;
    wire fft_done;
    reg fft_done_pipe;
    wire [22:0] freq_re, freq_im;
    wire [23:0] freq_mag;
    
    parameter MAX_SAMPLES = 1023;
    
    // a for loading mic_in data, b for reading it into the fft core
    // can remove enable if it works without it
    ampl_bram ampl_data (.clka(clk100m), .ena(1'b1), .wea(ampl_write), .addra(ampl_addr_in), .dina(ampl_in),
    .douta(ampl_old), .clkb(clk100m), .enb(1'b1), .addrb(ampl_addr_out), .doutb(mic_in), .web(1'b0));
    
    xfft_0 fft_core (.aclk(clk100m), .s_axis_config_tdata(8'b00000001), .s_axis_config_tvalid(1'b1),
    .s_axis_data_tdata({19'b0, ampl_out}), .s_axis_data_tvalid(ampl_valid), .s_axis_data_tlast(ampl_done),
    .s_axis_data_tready(fft_in_rdy), .m_axis_data_tdata({1'b0, freq_im, 1'b0, freq_re}), 
    .m_axis_data_tvalid(fft_out_rdy), .m_axis_data_tready(1'b1), .aresetn(~fft_reset), 
    .m_axis_data_tlast(fft_done));    
    
    /*
      input [7:0]s_axis_config_tdata; //1 for forward, 0 for inverse
      input s_axis_config_tvalid; //tie to 1, config doesn't change
      output s_axis_config_tready; //ignore, config doesn't change
      input [31:0]s_axis_data_tdata; // im and real parts
    */
    
    assign clk20k_signal = clk20k_pipe & ~clk20k_reg;
    //magnitude hack from https://openofdm.readthedocs.io/en/latest/verilog.html
    assign freq_mag = (freq_re > freq_im) ? freq_re + (freq_im << 2) : freq_im + (freq_re << 2);
    assign ampl_in = (ampl_use2) ? ampl_reg2 : ampl_reg1;
     
    always @(posedge clk100m) begin
        // "debounce" positive edge of clk20k (sound updates)
        clk20k_pipe <= clk20k;
        clk20k_reg <= clk20k_pipe;
        if (clk20k_signal) load_update <= 1; // begin loading new audio data
        
        // read old data out from BRAM and shift
        if (clk20k_signal) begin // read mic data
            ampl_reg1 <= mic_in;
            ampl_reg2 <= ampl_old;
            ampl_write <= 1'b0;            
        end else if (load_update) begin // shift data down the BRAM
            ampl_write <= ~ampl_write; // alternate between read and write cycles
            if (ampl_write) begin // write cycle now, read cycle next
                ampl_addr_in <= (ampl_addr_in == MAX_SAMPLES) ? 10'b0 : ampl_addr_in + 1;
                if (ampl_use2) begin
                    ampl_reg1 <= ampl_old;
                end else begin
                    ampl_reg2 <= ampl_old;
                end
                sample_cnt <= (sample_cnt == MAX_SAMPLES) ? 10'b0 : sample_cnt + 1;
            end else begin // read cycle now, write cycle next
                if (sample_cnt == MAX_SAMPLES) begin // last piece of data being written
                    // next piece of data will be written one position later
                    ampl_addr_in <= (ampl_addr_in == MAX_SAMPLES) ? 10'b0 : ampl_addr_in + 1;
                    load_update <= 1'b0;
                    ampl_write <= 1'b0;
                end
                ampl_use2 <= ~ampl_use2;
                sample_cnt <= 10'b0;
            end
        end
        
        // read data from BRAM into FFT core
        
        
        fft_done_pipe <= fft_done;
    end
    
    // accumalate the FFT outputs
    (* use_dsp48 = "yes" *) Freq_To_Colour freq_to_colour (.clk(clk100m), .we(fft_out_rdy),
    .reset(fft_done_pipe), .addr(freq_addr), .freq_mag(freq_mag), .r_sum({30'b0, r_sum}), 
    .g_sum({29'b0, g_sum}), .b_sum({30'b0, b_sum})); 
        
     always @(posedge clk100m) begin
        // update the RGB values being presented
        if (fft_done_pipe) begin
            r <= r_sum[31:27];
            g <= g_sum[31:26];
            b <= b_sum[31:27];
        end
     end
    
endmodule
