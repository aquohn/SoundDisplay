`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2019 06:10:43
// Design Name: 
// Module Name: Eagle
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

module Eagle(
    input oled_clk,
    input clk100m,
    input clk20,
    input frame_begin,
    input [4:0] r,
    input [5:0] g,
    input [4:0] b,
    input [15:0] sw, //set zoom level
    input [12:0] pixel_index,
    input btnU_signal,
    input btnR_signal,
    input btnL_signal,
    input btnD_signal,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    
    parameter UP = 0;
    parameter DOWN = 1;
    parameter LEFT = 2;
    parameter RIGHT = 3;
    
    parameter TOGGLE_8 = 12_499_999;
    parameter TOGGLE_4 = 24_999_999;
    parameter TOGGLE_2 = 49_999_999;

    wire bird_clk;
    reg [1:0] dir = 2'b00;
    reg [1:0] frame_bird_cnt = 2'b00;
    reg [1:0] bird_cnt = 2'b00;
    reg [31:0] toggle;
    
    wire [15:0] up_out [0:2];
    wire [15:0] down_out [0:2];
    wire [15:0] left_out [0:2];
    wire [15:0] right_out [0:2]; 
    
    Clk_Gen bird_clk_gen(.clk100m(clk100m), .clk_out(bird_clk), .toggle(toggle));
    
    up1 up1_bram (.clk(oled_clk), .addr(pixel_index), .pixel(up_out[0]));
    up2 up2_bram (.clk(oled_clk), .addr(pixel_index), .pixel(up_out[1]));
    up3 up3_bram (.clk(oled_clk), .addr(pixel_index), .pixel(up_out[2]));
    
    down1 down1_bram (.clk(oled_clk), .addr(pixel_index), .pixel(down_out[0]));
    down2 down2_bram (.clk(oled_clk), .addr(pixel_index), .pixel(down_out[1]));
    down3 down3_bram (.clk(oled_clk), .addr(pixel_index), .pixel(down_out[2]));
    
    left1 left1_bram (.clk(oled_clk), .addr(pixel_index), .pixel(left_out[0]));
    left2 left2_bram (.clk(oled_clk), .addr(pixel_index), .pixel(left_out[1]));
    left3 left3_bram (.clk(oled_clk), .addr(pixel_index), .pixel(left_out[2]));
        
    right1 right1_bram (.clk(oled_clk), .addr(pixel_index), .pixel(right_out[0]));
    right2 right2_bram (.clk(oled_clk), .addr(pixel_index), .pixel(right_out[1]));
    right3 right3_bram (.clk(oled_clk), .addr(pixel_index), .pixel(right_out[2]));
    
    always @(*) begin
        led = sw;
        seg = 7'b1111111;
        an = 4'b1111;
    end
    
    always @(posedge clk20) begin
        case ({btnU_signal, btnD_signal, btnL_signal, btnR_signal})
            4'b1000: dir <= UP;
            4'b0100: dir <= DOWN;
            4'b0010: dir <= LEFT;
            4'b0001: dir <= RIGHT;
        endcase
    end
    
    always @(posedge bird_clk) begin
        if (r > g[5:1] && r > b) toggle <= TOGGLE_2;
        else if (b > g[5:1] && b > r) toggle <= TOGGLE_8;
        else toggle <= TOGGLE_4;
        
        bird_cnt <= bird_cnt + 1;
    end
    
    always @(posedge oled_clk) begin
        if (frame_begin) begin
            frame_bird_cnt <= bird_cnt;
        end
        
        case (dir)
            UP: begin
                if (frame_bird_cnt == 3) oled_data <= up_out[1];
                else oled_data <= up_out[frame_bird_cnt];
            end
            DOWN: begin
                if (frame_bird_cnt == 3) oled_data <= down_out[1];
                else oled_data <= down_out[frame_bird_cnt];
            end
            LEFT: begin
                if (frame_bird_cnt == 3) oled_data <= left_out[1];
                else oled_data <= left_out[frame_bird_cnt];        
            end
            default: begin
                if (frame_bird_cnt == 3) oled_data <= right_out[1];
                else oled_data <= right_out[frame_bird_cnt];         
            end
        endcase
    end
endmodule
