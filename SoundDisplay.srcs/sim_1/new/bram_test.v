`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2019 03:53:18
// Design Name: 
// Module Name: bram_test
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


module bram_test(

    );

    reg clk100m;
    reg wea;
    wire [9:0] startaddr;
    reg [9:0]addra;
    wire [12:0]dina;
    reg enb;
    reg [9:0]addrb;
    wire [12:0]doutb;
    wire clk6p25m, clk20, clk20k;
    reg [9:0] cnt;
    
    assign startaddr = addra + 1;
    assign dina = addra;
    
    always begin
        clk100m = 1'b0;
        #5 clk100m = 1'b1;
        #5;
    end
    
    initial cnt = 9'd0;
    
    blk_mem_gen_0 bram (.clka(clk20k), .wea(1'b1), .addra(addra), .dina(dina), .clkb(clk100m), 
    .enb(1'b1), .addrb(addrb), .doutb(doutb));
    Clk_Gen clk_gen (.clk100m(clk100m), .clk6p25m(clk6p25m), .clk20(clk20), .clk20k(clk20k));
    
    always @(posedge clk100m) begin
        cnt <= cnt + 1;
        addrb <= addrb + 1;
        if (cnt == 10'd1023) begin
            cnt <= 10'd0;
            addrb <= startaddr;
        end
    end
    
    always @(posedge clk20k) begin
        addra <= addra + 1;
        if (addra == 10'd1023) begin
            addra <= 10'd0;
        end        
    end
        
endmodule
