`timescale 1ns / 1ps
`include "Constants.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2019 14:44:17
// Design Name: 
// Module Name: Space_Invader
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

/**
* sw[0]/sw[1]: select colour theme
* sw[2]: select border thickness
* sw[3]: toggle 1 circle volume indicator
* sw[4]: toggle border
* sw[5]: toggle 5 circles display
* sw[7]: toggle moving circle display
* sw[9]: left 2 anodes display
* sw[10]: middle 2 anodes display
* sw[11]: 10Hz frequency
* sw[12]: 5Hz frequency
* sw[13]: pause
* sw[14]: force readout to 0
* sw[15]: constant LED indicator (Task 1 requirement)
*/

/**
 * Read the frequency bins of the FFT. Analyse bins as follows:
 *
 * bin[3n +: 3] governs the behaviour of alien n:
 * - If 3n is more than 1/2, create the alien if it is dead
 * - If creating an alien, use 3n + 1 to determine the alien's colour
 * - If 3n + 2 is more than 1/2, shoot the player
 *   
 */

module Space_Invader(
    input clk100m,
    input mic_clk,
    input oled_clk,
    input [15:0] sw,
    input [11:0] mic_in,
    input [15:0] intensity_reg,
    input [6:0] x,
    input [5:0] y,
    input btnU_signal,
    input btnR_signal,
    input btnL_signal,
    input mouse_data,
    input mouse_clk,
    input [464:0] freq_cnts,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output [6:0] seg,
    output reg [3:0] an
);

parameter AN_0 = 4'b0111;
parameter AN_1 = 4'b1011;
parameter AN_2 = 4'b1101;
parameter AN_3 = 4'b1110;
parameter SEG_A = 7'b0001000;
parameter SEG_E = 7'b0000110;
parameter SEG_D = 7'b0100001;
parameter SEG_0 = 7'b1000000;
parameter SEG_1 = 7'b1111001;
parameter SEG_2 = 7'b0100100;
parameter SEG_3 = 7'b0110000;
parameter SEG_4 = 7'b0011001;
parameter SEG_5 = 7'b0010010;
parameter SEG_6 = 7'b0000010;
parameter SEG_7 = 7'b1111000;
parameter SEG_8 = 7'b0000000;
parameter SEG_9 = 7'b0010000;

reg [1:0] seg_cnt = 2'b00;
reg [6:0] seg_arr [0:3];

reg [6:0] bottom_layer_left = 7'd43;
reg [6:0] bottom_layer_right = 7'd53;
reg [6:0] bottom_layer_up = 7'd53;
reg [6:0] bottom_layer_down = 7'd58;

reg [6:0] middle_layer_left = 7'd45;
reg [6:0] middle_layer_right = 7'd51;
reg [6:0] middle_layer_up = 7'd50;

reg [6:0] top_layer_left = 7'd47;
reg [6:0] top_layer_right = 7'd49;
reg [6:0] top_layer_up = 7'd48;

reg [5:0] mouse_bits;

reg [15:0] colour_border, colour_bg, colour_high, colour_mid, colour_low, colour_mid_high, colour_mid_mid;

parameter CNT_64_TOGGLE = 1562499;
parameter CNT_0P5_TOGGLE = 199_999_999;
wire game_clk;
Clk_Gen clk_game_core (.clk100m(clk100m), .clk_out(game_clk), .toggle(CNT_64_TOGGLE));

reg [4:0] score;
reg [6:0] score_arr [0:3];
reg [6:0] num_arr [0:9];

parameter ALIEN_Y = 5;
reg [15:0] alien_colours [0:4]; // note that colours persist even with change of colour theme
wire [6:0] alien_x [0:4]; //constant
reg alien_shot [0:4];
reg [5:0] alien_shot_y [0:4];
reg alien_alive [0:4];
reg [23:0] alien_cooldown [0:4];
reg game_clk_pipe, game_clk_reg;
wire game_clk_signal;

reg [23:0] player_cooldown = 24'd0;
reg player_dead = 1'b0;
reg player_shot = 1'b0;
reg [6:0] player_shot_y;
reg [6:0] player_shot_x;

parameter COOLDOWN = 24'd12500000; // 2 sec cooldown
parameter ALIEN_THRESHOLD = 3'b111;
wire [5:0] freq_params [0:14];
genvar i;
for (i = 0; i < 15; i = i + 1) begin
    assign freq_params[i] = freq_cnts[30 * (i + 1) - 13 -: 6];
end

reg btnU_pipe, btnR_pipe, btnL_pipe;

for (i = 0; i < 5; i = i + 1) begin
    assign alien_x[i] = 11 + 18 * i;
    initial begin
        alien_shot[i] = 1'b0;
        alien_cooldown[i] = 24'd0;
        alien_alive[i] = 1'b0;
        alien_shot_y[i] = ALIEN_Y;
    end    
end

initial begin
    seg_arr[0] = SEG_D;
    seg_arr[1] = SEG_E;
    seg_arr[2] = SEG_A;
    seg_arr[3] = SEG_D;
    num_arr[0] = SEG_0;
    num_arr[1] = SEG_1;
    num_arr[2] = SEG_2;
    num_arr[3] = SEG_3;
    num_arr[4] = SEG_4;
    num_arr[5] = SEG_5;
    num_arr[6] = SEG_6;
    num_arr[7] = SEG_7;
    num_arr[8] = SEG_8;
    num_arr[9] = SEG_9;
end

assign seg = (player_dead) ? seg_arr[seg_cnt] : score_arr[seg_cnt];

always @(*) begin : connections
    integer i;
    case ({sw[1], sw[0]})
        2'b01: begin //ocean
            colour_border = {5'd4, 6'd15, 5'd11};
            colour_bg = {5'd29, 6'd58, 5'd25};
            colour_high = {5'd19, 6'd47, 5'd24};
            colour_mid_high = {5'd11, 6'd37, 5'd30};
            colour_mid = {5'd5, 6'd30, 5'd30};
            colour_mid_mid = {5'd2, 6'd14, 5'd15};
            colour_low = {5'd4, 6'd15, 5'd11};                
        end
        2'b10: begin //earth
            colour_border = {5'd27, 6'd46, 5'd2};
            colour_bg = {5'd29, 6'd56, 5'd21};
            colour_high = {5'd22, 6'd58, 5'd15};
            colour_mid_high = {5'd15, 6'd59, 5'd16};
            colour_mid = {5'd6, 6'd50, 5'd10};
            colour_mid_mid = {5'd13, 6'd40, 5'd10};
            colour_low = {5'd8, 6'd30, 5'd9};                                 
        end
        2'b11: begin //enhancement colour scheme: sunset
            colour_border = {5'd31, 6'd54, 5'd22};
            colour_bg = {5'd6, 6'd14, 5'd10};
            colour_high = {5'd31, 6'd41, 5'd22};
            colour_mid_high = {5'd25, 6'd46, 5'd30};
            colour_mid = {5'd18, 6'd32, 5'd22};
            colour_mid_mid = {5'd21, 6'd33, 5'd20};
            colour_low = {5'd10, 6'd21, 5'd15}; 
        end
        default: begin
            colour_border = `OLED_WHITE;
            colour_bg = `OLED_BLACK;
            colour_high = `OLED_RED;
            colour_mid_high = {5'd31, 6'd31, 5'd0};
            colour_mid = `OLED_YELLOW;
            colour_mid_mid = {5'd22, 6'd58, 5'd5};
            colour_low = `OLED_GREEN;                    
        end    
    endcase
    
    //led[15] = player_shot;//sw[15];
    for (i = 0; i < 15; i = i + 1) begin
        led[i] = (freq_params[14 - i] > ALIEN_THRESHOLD) ? 1'b1 : 1'b0; 
    end
    
    score_arr[0] = num_arr[score / 1000];
    score_arr[1] = num_arr[(score / 100) % 10];
    score_arr[2] = num_arr[(score / 10) % 10];
    score_arr[3] = num_arr[score % 10];
end

always @(posedge mic_clk) begin 
    //cycling through characters
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

assign game_clk_signal = game_clk_pipe & ~game_clk_reg;
always @(posedge oled_clk) begin : update_game
    integer a;

    // "debounce" signals
    game_clk_pipe <= game_clk;
    game_clk_reg <= game_clk_pipe;
    btnU_pipe <= btnU_signal;
    btnR_pipe <= btnR_signal;
    btnL_pipe <= btnL_signal;
    
    // update aliens
    for (a = 0; a < 5; a = a + 1) begin
        if (alien_cooldown[a] == 24'd0) begin
            if (alien_alive[a]) begin // see if we will shoot
                if ((freq_params[(3 * a)] > ALIEN_THRESHOLD) && ~alien_shot[a]) begin
                    alien_shot[a] <= 1'b1;
                    alien_cooldown[a] <= COOLDOWN;
                end
            end else begin // see if alien will respawn, and if so, see what colour he will be
                if (freq_params[(3 * a) + 2] > ALIEN_THRESHOLD) begin
                    alien_alive[a] <= 1'b1;
                    if (freq_params[(3 * a) + 1] > 48) begin
                        alien_colours[a] <= colour_high;
                    end else if (freq_params[(3 * a) + 1] > 36) begin
                        alien_colours[a] <= colour_mid_high;
                    end else if (freq_params[(3 * a) + 1] > 24) begin
                        alien_colours[a] <= colour_mid;
                    end else if (freq_params[(3 * a) + 1] > 12) begin
                        alien_colours[a] <= colour_mid_mid;
                    end else begin
                        alien_colours[a] <= colour_low;
                    end
                end
            end
        end else begin
            alien_cooldown[a] <= alien_cooldown[a] - 1;
        end
    end
    
    if (btnU_signal & ~player_shot) begin
        player_shot <= 1'b1;
        player_shot_x <= top_layer_left + 1;
    end
    
    // draw screen
    oled_data <= colour_bg;

    // draw border
    if (~sw[4]) begin
        case (sw[2]) 
            1'b0: begin
                if (x == 0 || x == 95 || y == 0 || y == 63) begin
                    oled_data <= colour_border;
                end
            end
            1'b1: begin
                if (x <= 2 || x >= 93 || y <= 2 || y >= 61) begin
                    oled_data <= colour_border;
                end
            end
        endcase
    end

    // draw aliens
    if (y > ALIEN_Y) begin
        for (a = 0; a < 5; a = a + 1) begin
            if (alien_alive[a]) begin 
                case (y - ALIEN_Y)
                    5'd0, 5'd1: begin
                        if (x <= alien_x[a] + 5 && x >= alien_x[a] - 5) begin
                            if (player_shot && x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= COOLDOWN;
                                player_shot <= 1'b0;
                                score <= score + 1;
                                player_shot_y <= top_layer_up;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd2, 5'd3: begin
                        if (x <= alien_x[a] + 4 && x >= alien_x[a] - 4) begin
                            if (player_shot && x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= COOLDOWN;
                                player_shot <= 1'b0;
                                score <= score + 1;
                                player_shot_y <= top_layer_up;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd4, 5'd5: begin
                        if (x <= alien_x[a] + 3 && x >= alien_x[a] - 3) begin
                            if (player_shot && x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= COOLDOWN;
                                player_shot <= 1'b0;
                                score <= score + 1;
                                player_shot_y <= top_layer_up;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd6, 5'd7: begin
                        if (x <= alien_x[a] + 2 && x >= alien_x[a] - 2) begin
                            if (player_shot && x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= COOLDOWN;
                                player_shot <= 1'b0;
                                score <= score + 1;
                                player_shot_y <= top_layer_up;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd8, 5'd9: begin
                        if (x <= alien_x[a] + 1 && x >= alien_x[a] - 1) begin
                            if (player_shot && x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= COOLDOWN;
                                player_shot <= 1'b0;
                                score <= score + 1;
                                player_shot_y <= top_layer_up;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                endcase
            end
        end
    end
    
    if (~player_dead) begin
        if (y >= 3 && y <= 60 && x >= 3 && x <= 92) begin // draw player 
            if (x >= bottom_layer_left && x <= bottom_layer_right && y >= bottom_layer_up && y <= bottom_layer_down)begin
                oled_data <= colour_mid;
            end
            if (x >= middle_layer_left && x <= middle_layer_right && y >= middle_layer_up && y <= bottom_layer_down) begin
                oled_data <= colour_mid;
            end
            if(x >= top_layer_left && x <= top_layer_right && y >= top_layer_up && y <= bottom_layer_down) begin
                oled_data <= colour_mid;
            end
        end
        
        if (btnR_signal & ~btnR_pipe) begin // update location
            bottom_layer_left <= (bottom_layer_left >= 7'b1001111) ? 7'b1010010 : bottom_layer_left + 4; // move right
            bottom_layer_right <= (bottom_layer_right >= 7'b1011001) ? 7'b1011100 : bottom_layer_right + 4;
            middle_layer_left <= (middle_layer_left >= 7'b1010001) ? 7'b1010100 : middle_layer_left + 4;
            middle_layer_right <= (middle_layer_right >= 7'b1010111) ? 7'b1011010 : middle_layer_right + 4;
            top_layer_left <= (top_layer_left >= 7'b1010011) ? 7'b1010110 : top_layer_left + 4;
            top_layer_right <= (top_layer_right >= 7'b1010101) ? 7'b1011000 : top_layer_right + 4;
        end else if (btnL_signal & ~btnL_pipe) begin
            bottom_layer_left <= (bottom_layer_left <= 7'b0000110) ? 7'b0000011 : bottom_layer_left - 4; // move left
            bottom_layer_right <= (bottom_layer_right <= 7'b0010000) ? 7'b0001101 : bottom_layer_right - 4;
            middle_layer_left <= (middle_layer_left <= 7'b0001000) ? 7'b0000101 : middle_layer_left - 4;
            middle_layer_right <= (middle_layer_right <= 7'b0001110) ? 7'b0001011 : middle_layer_right - 4;
            top_layer_left <= (top_layer_left <= 7'b0001010) ? 7'b0000111 : top_layer_left - 4;
            top_layer_right <= (top_layer_right <= 7'b0001100) ? 7'b0001001 : top_layer_right - 4;
        end
    end    
    
    // draw bullet
    if (player_shot && x >= player_shot_x - 1 && x <= player_shot_x + 1 
        && y >= player_shot_y - 1 && y <= player_shot_y + 1) begin
        oled_data <= colour_mid;
    end
    
    if (game_clk_signal) begin //update bullets 
        for (a = 0; a < 5; a = a + 1) begin
            if (alien_shot[a]) begin
                if (alien_shot_y[a] < `OLED_HEIGHT - 4) begin
                    alien_shot_y[a] <= alien_shot_y[a] + 1; 
                end else begin
                    alien_shot[a] <= 1'b0;
                    alien_shot_y[a] <= ALIEN_Y + 2;
                end
            end else begin
                alien_shot_y[a] <= ALIEN_Y + 2;
            end
        end
        if (player_shot) begin
            if (player_shot_y > 6'd4) begin
                player_shot_y <= player_shot_y - 1;
            end else begin
                player_shot <= 1'b0;
                player_shot_y <= top_layer_up;
            end
        end else begin
            player_shot_y <= top_layer_up;
        end
    end
    
    // handle respawn
    if (player_dead) begin
        if (player_cooldown) begin
            player_cooldown <= player_cooldown - 1;
        end else begin
            player_dead <= 1'b0;
        end 
    end
    
    // handle alien bullets
    for (a = 0; a < 5; a = a + 1) begin
        if (alien_shot[a]) begin // check if player died
            if (((alien_shot_y[a] >= top_layer_up && alien_shot_y[a] <= middle_layer_up 
                && alien_x[a] <= top_layer_right && alien_x[a] >= top_layer_left)
            || (alien_shot_y[a] >= middle_layer_up && alien_shot_y[a] <= bottom_layer_up
            && alien_x[a] <= middle_layer_right && alien_x[a] >= middle_layer_left)
            || (alien_shot_y[a] >= bottom_layer_up && alien_shot_y[a] <= bottom_layer_down
            && alien_x[a] <= bottom_layer_right && alien_x[a] >= bottom_layer_left)) && player_dead == 1'b0) begin
                alien_shot[a] <= 1'b0;
                player_dead <= 1'b1;
                score <= 4'd0;
                player_cooldown <= COOLDOWN;
            end else if (x >= alien_x[a] - 1 && x <= alien_x[a] + 1 
            && y >= alien_shot_y[a] - 1 && y <= alien_shot_y[a] + 1) begin // draw bullet
                oled_data <= alien_colours[a];
            end
        end
        
        if (player_dead) begin // reset if player dead
            alien_shot[a] = 1'b0;
            alien_cooldown[a] = COOLDOWN;
            alien_alive[a] = 1'b0;
            alien_shot_y[a] = ALIEN_Y;
        end    
    end
end
endmodule
