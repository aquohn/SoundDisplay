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
    input [6:0] x,
    input [5:0] y,
    input mouse_data,
    input mouse_clk,
    input [15:0] intensity_reg,
    input [464:0] freq_cnts,
    output reg [15:0] led,
    output reg [15:0] oled_data,
    output reg [6:0] seg,
    output reg [3:0] an
);

reg [12:0] counter = 0;

reg [6:0] seg_tens = 7'b0;   
reg [6:0] seg_ones = 7'b0;

reg [6:0] bottom_layer_left = 7'd43;
reg [6:0] bottom_layer_right = 7'd53;
reg [6:0] bottom_layer_up = 7'd55;
reg [6:0] bottom_layer_down = 7'd60;

reg [6:0] middle_layer_left = 7'd45;
reg [6:0] middle_layer_right = 7'd51;
reg [6:0] middle_layer_up = 7'd52;

reg [6:0] top_layer_left = 7'd47;
reg [6:0] top_layer_right = 7'd49;
reg [6:0] top_layer_up = 7'd50;

reg [5:0] mouse_bits;

reg [15:0] colour_border, colour_bg, colour_high, colour_mid, colour_low, colour_mid_high, colour_mid_mid;

parameter CNT_64_TOGGLE = 1562499;
parameter CNT_0P5_TOGGLE = 199_999_999;
wire game_clk, alien_clk;
Clk_Gen clk_alien_core (.clk100m(clk100m), .clk_out(alien_clk), .toggle(CNT_0P5_TOGGLE));
Clk_Gen clk_game_core (.clk100m(clk100m), .clk_out(game_clk), .toggle(CNT_64_TOGGLE));

reg [4:0] score;

parameter ALIEN_Y = 7;
reg [15:0] alien_colours [0:4]; // note that colours persist even with change of colour theme
wire [6:0] alien_x [0:4]; //constant
reg alien_shot [0:4];
reg [5:0] alien_shot_y [0:4];
reg alien_alive [0:4];
reg alien_cooldown [0:4];

reg player_dead = 1'b0;
reg player_shot = 1'b0;
reg [4:0] player_shot_y;
reg [4:0] player_shot_x;

wire [5:0] freq_params [0:14];
genvar i;
for (i = 0; i < 15; i = i + 1) begin
    assign freq_params[i] = freq_cnts[30 * (i + 1) - 13 -: 6];
end

for (i = 0; i < 5; i = i + 1) begin
    assign alien_x[i] = 7 + 10 * i;
    initial begin
        alien_shot[i] = 1'b0;
        alien_shot_y[i] = ALIEN_Y + 2;
        alien_alive[i] = 1'b1;
        alien_cooldown[i] = 1'b0;
        alien_colours[i] = colour_border;
    end    
end

always @(*) begin
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
end

// counting the number of bits receiving from the Mouse Data 
// 33 bits to be received from the Mouse 
always @(posedge mouse_clk) begin
    if(mouse_bits <= 31) mouse_bits <= mouse_bits + 1;
    else mouse_bits <= 0;

    if(mouse_bits == 1 && mouse_data == 1 && player_shot == 1'b0) begin // shoot if the mouse is left clicked
        player_shot <= 1'b1;
        player_shot_x <= top_layer_left + 1;
        player_shot_y <= top_layer_up;
    end
end

// move bullets
always @(posedge game_clk) begin : game_update
    integer i;
    for (i = 0; i < 5; i = i + 1) begin
        if (alien_shot[i]) begin
           if (alien_shot_y[i] == `OLED_HEIGHT - 1) begin
                alien_shot[i] <= 1'b0;
                alien_shot_y[i] <= ALIEN_Y + 2;
            end else begin
                alien_shot_y[i] <= alien_shot_y[i] + 1; 
            end 
        end
    end
    if (player_shot) begin
        if (player_shot_y == 0) begin
            player_shot <= 1'b0;
            player_shot_y <= top_layer_up;
        end else begin
            player_shot_y <= player_shot_y - 1;
        end
    end
end

// spawn aliens and shoot
always @(posedge alien_clk) begin : alien_update
    
end

// update position of player
always @(posedge mic_clk) begin : genspaceship
    // check if player died
    integer i;
    for (i = 0; i < 5; i = i + 1) begin
        if (alien_shot[i] &&
        ((alien_shot_y[i] > top_layer_up && alien_shot_y[i] < middle_layer_up 
            && alien_x[i] < top_layer_right && alien_x[i] > top_layer_left)
        || (alien_shot_y[i] > middle_layer_up && alien_shot_y[i] < bottom_layer_up
            && alien_x[i] < middle_layer_right && alien_x[i] > middle_layer_left)
        || (alien_shot_y[i] > bottom_layer_up && alien_shot_y[i] < bottom_layer_down
            && alien_x[i] < bottom_layer_right && alien_x[i] > bottom_layer_left))) begin
            player_dead <= 1'b1;
            score <= 4'd0;
        end            
    end

    // TODO mouse control
    if (intensity_reg[4]) begin
        bottom_layer_left <= (bottom_layer_left == 7'b1010010) ? 7'b1010010 : bottom_layer_left + 1; // move right
        bottom_layer_right <= (bottom_layer_right == 7'b1011100) ? 7'b1011100 : bottom_layer_right + 1;
        middle_layer_left <= (middle_layer_left == 7'b1010100) ? 7'b1010100 : middle_layer_left + 1;
        middle_layer_right <= (middle_layer_right == 7'b1011010) ? 7'b1011010 : middle_layer_right + 1;
        top_layer_left <= (top_layer_left == 7'b1010110) ? 7'b1010110 : top_layer_left + 1;
        top_layer_right <= (top_layer_right == 7'b1011000) ? 7'b1011000 : top_layer_right + 1;
    end else if (intensity_reg[14]) begin
        bottom_layer_left <= (bottom_layer_left == 7'b0000011) ? 7'b0000011 : bottom_layer_left - 1; // move left
        bottom_layer_right <= (bottom_layer_right == 7'b0001101) ? 7'b0001101 : bottom_layer_right - 1;
        middle_layer_left <= (middle_layer_left == 7'b0000101) ? 7'b0000101 : middle_layer_left - 1;
        middle_layer_right <= (middle_layer_right == 7'b0001011) ? 7'b0001011 : middle_layer_right - 1;
        top_layer_left <= (top_layer_left == 7'b0000111) ? 7'b0000111 : top_layer_left - 1;
        top_layer_right <= (top_layer_right == 7'b0001001) ? 7'b0001001 : top_layer_right - 1;
    end
end

always @(posedge oled_clk) begin
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
    if (y > ALIEN_Y) begin : draw_aliens
        integer a;
        for (a = 0; a < 5; a = a + 1) begin
            if (alien_alive[a]) begin 
                case (y - ALIEN_Y)
                    5'd0: begin
                        if (x <= alien_x[a] + 2 && x >= alien_x[a] - 2) begin
                            if (x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= 1'b1;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd1: begin
                        if (x <= alien_x[a] + 1 && x >= alien_x[a] - 1) begin
                            if (x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= 1'b1;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                    5'd2: begin
                        if (x == alien_x[a]) begin
                            if (x == player_shot_x && y == player_shot_y) begin
                                alien_alive[a] <= 1'b0;
                                alien_cooldown[a] <= 1'b1;
                            end
                            oled_data <= alien_colours[a];
                        end
                    end
                endcase
            end
        end
    end
    
    // draw player
    if (y >= 3 && y <= 60 && x >= 3 && x <= 92 && ~player_dead) begin
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
end
endmodule
