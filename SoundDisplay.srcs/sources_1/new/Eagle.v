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
    input seg_clk,
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
    output [6:0] seg,
    output reg [3:0] an
    );
    
    parameter AN_0 = 4'b0111;
    parameter AN_1 = 4'b1011;
    parameter AN_2 = 4'b1101;
    parameter AN_3 = 4'b1110;
    
    parameter SEG_H = 7'b0001001;
    parameter SEG_I = 7'b1001111;
    parameter SEG_G = 7'b0000100;
    parameter SEG_M = 7'b1101010;
    parameter SEG_E = 7'b0000110;
    parameter SEG_D = 7'b0100001;
    parameter SEG_L = 7'b1000111;
    parameter SEG_O = 7'b1000000;
    parameter SEG_W = 7'b1010101;
    parameter SEG_SPACE = 7'b1111111;
    
    parameter UP = 0;
    parameter DOWN = 1;
    parameter LEFT = 2;
    parameter RIGHT = 3;
    
    parameter REDMAX = 0;
    parameter BLUEMAX = 1;
    parameter GREENMAX = 2;
    parameter UPDATE_MAX = 4'b1111;
    
    parameter TOGGLE_8 = 12_499_999;
    parameter TOGGLE_4 = 24_999_999;
    parameter TOGGLE_16 = 6_249_999;
    
    reg [1:0] seg_cnt = 2'b00;
    reg [6:0] seg_arr [0:3];

    wire bird_clk;
    reg [1:0] dir = 2'b00;
    reg [1:0] frame_bird_cnt = 2'b00;
    reg [1:0] bird_cnt = 2'b00;
    reg [1:0] max_col = REDMAX;
    reg [31:0] toggle;
    reg [4:0] update_cnt = 5'b0;
    
    wire [15:0] up_out [0:2];
    wire [15:0] down_out [0:2];
    wire [15:0] left_out [0:2];
    wire [15:0] right_out [0:2]; 
    
    Clk_Gen bird_clk_gen(.clk100m(clk100m), .clk_out(bird_clk), .toggle(toggle));
    
    // "incorrect" indexing is intentional
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
    right2 right2_bram (.clk(oled_clk), .addr(pixel_index), .pixel(right_out[2]));
    right3 right3_bram (.clk(oled_clk), .addr(pixel_index), .pixel(right_out[1]));
    
    assign seg = seg_arr[seg_cnt];
    
    always @(*) begin
        case (max_col)
            REDMAX: begin
                toggle = TOGGLE_4;
                led[4:0] = r;
                case (1'b1)
                    r[4]: led[4:0] = 5'b11111;
                    r[3]: begin
                        led[3:0] = 4'b1111;
                        led[4] = 1'b0;
                    end
                    r[2]: begin
                        led[2:0] = 3'b111;
                        led[4:3] = 2'b11;
                    end
                    r[1]: begin
                        led[1:0] = 2'b11;
                        led[4:2] = 3'b000;
                    end
                    r[0]: begin
                        led[0] = 1'b1;
                        led[4:1] = 4'b0000;
                    end
                    default: led[4:0] = 5'b00000;
                endcase
                led[15:5] = 11'b0;
                seg_arr[0] = SEG_SPACE;
                seg_arr[1] = SEG_L;
                seg_arr[2] = SEG_O;
                seg_arr[3] = SEG_W;
            end
            BLUEMAX: begin
                toggle = TOGGLE_16;
                led[9:0] = 10'b1111111111;
                led[15] = 1'b0;
                case (1'b1)
                    b[4]: led[14:10] = 5'b11111;
                    b[3]: begin
                        led[13:10] = 4'b1111;
                        led[14] = 1'b0;
                    end
                    b[2]: begin
                        led[12:10] = 3'b111;
                        led[14:13] = 2'b11;
                    end
                    b[1]: begin
                        led[11:10] = 2'b11;
                        led[14:12] = 3'b000;
                    end
                    b[0]: begin
                        led[10] = 1'b1;
                        led[14:11] = 4'b0000;
                    end
                    default: led[14:10] = 5'b00000;
                endcase
                seg_arr[0] = SEG_H;
                seg_arr[1] = SEG_I;
                seg_arr[2] = SEG_G;
                seg_arr[3] = SEG_H;
            end
            default: begin
                toggle = TOGGLE_8;
                led[15:10] = 6'b0;
                led[4:0] = 5'b11111;
                led[9:5] = g;
                case (1'b1)
                    g[4]: led[9:5] = 5'b11111;
                    g[3]: begin
                        led[8:5] = 4'b1111;
                        led[9] = 1'b0;
                    end
                    g[2]: begin
                        led[7:5] = 3'b111;
                        led[9:8] = 2'b11;
                    end
                    g[1]: begin
                        led[6:5] = 2'b11;
                        led[9:7] = 3'b000;
                    end
                    g[0]: begin
                        led[5] = 1'b1;
                        led[9:6] = 4'b0000;
                    end
                    default: led[9:5] = 5'b00000;
                endcase
                seg_arr[0] = SEG_SPACE;
                seg_arr[1] = SEG_M;
                seg_arr[2] = SEG_E;
                seg_arr[3] = SEG_D;
            end
        endcase
    end
    
    always @(posedge bird_clk) begin
        bird_cnt <= (bird_cnt == 2'b10) ? 2'b00 : bird_cnt + 1;
    end
    
    always @(posedge oled_clk) begin
        if (frame_begin) begin
            frame_bird_cnt <= bird_cnt;
        end
        
        case (dir)
            UP: begin
                oled_data <= up_out[frame_bird_cnt];
            end
            DOWN: begin
                oled_data <= down_out[frame_bird_cnt];
            end
            LEFT: begin
                oled_data <= left_out[frame_bird_cnt];        
            end
            default: begin
                oled_data <= right_out[frame_bird_cnt];         
            end
        endcase
    end
    
    always @(posedge clk20) begin
        case ({btnU_signal, btnD_signal, btnL_signal, btnR_signal})
            4'b1000: dir <= UP;
            4'b0100: dir <= DOWN;
            4'b0010: dir <= LEFT;
            4'b0001: dir <= RIGHT;
        endcase
        
        if (update_cnt < UPDATE_MAX) begin
            update_cnt <= update_cnt + 1;
        end else begin
            update_cnt <= 5'b00000;
            if (r > g && r > b) max_col <= REDMAX;
            else if (b > g && b > r) max_col <= BLUEMAX;
            else max_col <= GREENMAX;
        end
    end
    
    //cycling through characters
    always @(posedge seg_clk) begin
        case (seg_cnt) //lol this is an FSM
            2'b00: begin
                an <= AN_1;
                seg_cnt <= 2'b01;
            end
            2'b01: begin
                an <= AN_2;
                seg_cnt <= 2'b10;
            end
            2'b10: begin
                an <= AN_3;
                seg_cnt <= 2'b11;
            end
            2'b11: begin
                an <= AN_0;
                seg_cnt <= 2'b00;
            end
        endcase
    end
endmodule
