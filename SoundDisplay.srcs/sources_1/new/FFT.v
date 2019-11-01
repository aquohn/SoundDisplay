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
    input [11:0] mic_in,
    output reg [4:0] r = 5'b0,
    output reg [5:0] g = 6'b0,
    output reg [4:0] b = 5'b0
    );
    
    reg clk20k_reg, clk20k_pipe;
    wire clk20k_signal;
    wire fft_reset;
    reg ampl_done = 1'b0; // asserted with last amplitude readout
    wire fft_in_rdy, fft_out_rdy, ampl_rdy;
    
    // ampl bram signals
    reg load_update = 1'b0; // is set if shifting BRAM data to accomodate new data point
    reg ampl_write = 1'b0; // ampl bram write enable
    reg ampl_use2 = 1'b0; // asserted if the next write cycle will write from reg2
    reg [9:0] ampl_pos = 10'b0; //start position of next fft data block
    reg [12:0] ampl_reg1 = 12'b0, ampl_reg2 = 12'b0; // registers to store amplitude for shifting purposes
    wire [12:0] ampl_in; // amplitude selected to be written
    reg [9:0] sample_cnt = 10'b0; // number of data points shifted so far
    reg [9:0] ampl_addr_in = 10'b0; // the address to write amplitude data to
    wire [12:0] ampl_out; // amplitude value read out to fft
    wire [12:0] ampl_old; // amplitude value read out for shifting
    
    // running totals of colours
    wire [33:0] r_sum;
    wire [33:0] g_sum;
    wire [33:0] b_sum;
    
    // fft signals
    reg load_fft = 1'b0; // whether or not data is being loaded into the fft
    reg [9:0] freq_addr = 10'b0; // the address of the frequency data being read out
    reg [9:0] load_cnt = 10'b0; // the number of amplitudes read in thus far
    reg [9:0] ampl_addr_out = 10'b0; // the address from which to read amplitude data
    wire fft_done; // strobed on fft completion
    reg fft_done_pipe; // strobed one cycle after fft completion
    wire [23:0] freq_re, freq_im; // real and imaginary parts of frequency
    wire [22:0] freq_re_abs, freq_im_abs; // real and imaginary parts of frequency
    wire [23:0] freq_mag; // magnitude of frequency
    
    parameter N_SUB_1 = 1023; // one less than the transform size
    
    // a for loading mic_in data, b for reading it into the fft core
    // can remove enable if it works without it
    ampl_bram ampl_data (.clka(clk100m), .ena(1'b1), .wea(ampl_write), .addra(ampl_addr_in), .dina(ampl_in),
    .douta(ampl_old), .clkb(clk100m), .enb(1'b1), .addrb(ampl_addr_out), .doutb(ampl_out), .web(1'b0));
    
    // TODO switch off clkena if done and waiting for next input
    // input is all positive and real, and hence is 0-padded
    xfft_0 fft_core (.aclk(clk100m), .s_axis_config_tdata(8'b00000001), .s_axis_config_tvalid(1'b1),
    .s_axis_data_tdata({19'b0, ampl_out}), .s_axis_data_tvalid(1'b1), .s_axis_data_tlast(ampl_done),
    .s_axis_data_tready(fft_in_rdy), .m_axis_data_tdata({freq_im, freq_re}), 
    .m_axis_data_tvalid(fft_out_rdy), .m_axis_data_tready(1'b1), .aresetn(~fft_reset), 
    .m_axis_data_tlast(fft_done));    
    
    /*
      input [7:0]s_axis_config_tdata; //1 for forward, 0 for inverse
      input s_axis_config_tvalid; //tie to 1, config doesn't change
      output s_axis_config_tready; //ignore, config doesn't change
      input [31:0]s_axis_data_tdata; // im and real parts
    */
    
    assign clk20k_signal = clk20k_pipe & ~clk20k_reg;
    assign ampl_in = (ampl_use2) ? ampl_reg2 : ampl_reg1;
    assign fft_reset = clk20k & ~clk20k_pipe; // assert reset for 2 cycles after 20k posedge
     
    always @(posedge clk100m) begin
        // "debounce" positive edge of clk20k (sound updates)
        clk20k_pipe <= clk20k;
        clk20k_reg <= clk20k_pipe;
        
        // read old data out from BRAM and shift
        if (clk20k_signal) begin // read mic data
            load_update <= 1; // begin loading new audio data
            ampl_use2 <= 1'b0; // use register 1 to write on first cycle
            ampl_reg1 <= {1'b0, mic_in}; //add sign bit
            ampl_reg2 <= ampl_old;
            ampl_write <= 1'b0;
            ampl_addr_in <= ampl_pos;
        end else if (load_update) begin // shift data down the BRAM
            ampl_write <= ~ampl_write; // alternate between read and write cycles
            if (ampl_write) begin // write cycle now, read cycle next
                ampl_addr_in <= (ampl_addr_in == N_SUB_1) ? 10'b0 : ampl_addr_in + 1;
                if (ampl_use2) begin
                    ampl_reg1 <= ampl_old;
                end else begin
                    ampl_reg2 <= ampl_old;
                end
                ampl_use2 <= ~ampl_use2;
                sample_cnt <= sample_cnt + 1;
            end else begin // read cycle now, write cycle next
                if (sample_cnt == N_SUB_1) begin // last piece of data being written
                    // next piece of data will be written one position later
                    ampl_pos <= (ampl_pos == N_SUB_1) ? 10'b0 : ampl_pos + 1;
                    load_update <= 1'b0;
                    ampl_write <= 1'b0;
                    sample_cnt <= 10'b0;
                end
            end
        end
        
        // if new data is available, run the fft
        if (fft_reset) begin
            ampl_addr_out <= ampl_pos;
            load_fft <= 1'b1;
            ampl_done <= 1'b0;
            load_cnt <= 10'b0;
            freq_addr <= 10'b0;
        end
        
        // read data from BRAM into FFT core
        if (load_fft & ~fft_reset) begin
            if (fft_in_rdy) begin
                // fetch next amplitude
                ampl_addr_out <= (ampl_addr_out == N_SUB_1) ? 10'b0 : ampl_addr_out + 1;
                load_cnt <= load_cnt + 1;
            end
            
            // all data loaded
            if (load_cnt == N_SUB_1) begin
                load_fft <= 1'b0;
                ampl_done <= 1'b1;
            end
        end
        
        if (fft_out_rdy) begin
            freq_addr <= freq_addr + 1;
        end
        
        // delay done signal to allow last value to be added
        fft_done_pipe <= fft_done;
    end
    
    // accumalate the FFT outputs
    (* use_dsp = "yes" *) Freq_To_Colour freq_to_colour (.clk(clk100m), .we(fft_out_rdy),
    .reset(fft_done_pipe), .addr(freq_addr), .freq_mag(freq_mag), .r_sum({r_sum}), 
    .g_sum({g_sum}), .b_sum({b_sum})); 
    
    //magnitude hack from https://openofdm.readthedocs.io/en/latest/verilog.html
    
    assign freq_re_abs = (freq_re[23]) ? ~(freq_re[22:0]) + 1 : freq_re[22:0];
    assign freq_im_abs = (freq_im[23]) ? ~(freq_im[22:0]) + 1 : freq_im[22:0];
    assign freq_mag = (freq_re_abs > freq_im_abs) ? freq_re_abs + (freq_im_abs << 2) : freq_im_abs + (freq_re_abs << 2);
        
     always @(posedge clk100m) begin
        // update the RGB values being presented
        if (fft_done_pipe) begin
            r <= r_sum[33:29];
            g <= g_sum[33:28];
            b <= b_sum[33:29];
        end
     end
    
endmodule
