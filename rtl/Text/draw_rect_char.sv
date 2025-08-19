/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * Draw rectangular with characters on the screen.
 */

 module draw_rect_char#(parameter
    SCALE=2,
    TEXT_POS_X = 128,
    TEXT_POS_Y = 128,
    TEXT_WIDTH = 256,
    TEXT_HEIGHT = 128
 )(
    input  logic clk,
    input  logic rst,
    input  logic [7:0] char_line_pixels,
    output logic [7:0] char_xy,
    output logic [3:0] char_line,
    

    vga_if.in in,
    vga_if.out out
);

timeunit 1ns;
timeprecision 1ps;

/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt;
logic [11:0] rgb_h, rgb_h1, rgb_h2;
logic [10:0] hcount, vcount, hcount1, vcount1, hcount2, vcount2;
logic hsync, vsync, hblnk, vblnk, hsync1, vsync1, hblnk1, vblnk1, hsync2, vsync2, hblnk2, vblnk2;
logic [7:0] char_xy_nxt;
logic [3:0] char_line_nxt;



/**
 * Internal logic
 */

always_ff @(posedge clk) begin : rect_buff
    if(rst) begin
        hcount <= '0;
        hblnk <= '0;
        hsync <= '0;
        vcount <= '0;
        vblnk <= '0;
        vsync <= '0;
        rgb_h <= '0;
    end
    else begin
        hcount <= in.hcount;
        hblnk <= in.hblnk;
        hsync <= in.hsync;
        vcount <= in.vcount;
        vblnk <= in.vblnk;
        vsync <= in.vsync;
        rgb_h <= in.rgb;
    end
end

always_ff @(posedge clk) begin : rect_buff1
    if(rst) begin
        hcount1 <= '0;
        hblnk1 <= '0;
        hsync1 <= '0;
        vcount1 <= '0;
        vblnk1 <= '0;
        vsync1 <= '0;
        rgb_h1 <= '0;
    end
    else begin
        hcount1 <= hcount;
        hblnk1 <= hblnk;
        hsync1 <= hsync;
        vcount1 <= vcount;
        vblnk1 <= vblnk;
        vsync1 <= vsync;
        rgb_h1 <= rgb_h; 
    end
end

always_ff @(posedge clk) begin : rect_ff_blk
    if (rst) begin
        vcount2 <= '0;
        vsync2  <= '0;
        vblnk2  <= '0;
        hcount2 <= '0;
        hsync2  <= '0;
        hblnk2  <= '0;
        rgb_h2  <= '0;
    end else begin
        vcount2 <= vcount1;
        vsync2  <= vsync1;
        vblnk2  <= vblnk1;
        hcount2 <= hcount1;
        hsync2  <= hsync1;
        hblnk2  <= hblnk1;
        rgb_h2  <= rgb_h1;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        char_xy <= '0;
        char_line <= '0;
    end else begin
        char_xy <= char_xy_nxt;
        char_line <= char_line_nxt; 
    end
end

always_comb begin 
    char_line_nxt = 4'((in.vcount - TEXT_POS_Y)>>SCALE);
    char_xy_nxt = {5'((in.hcount - TEXT_POS_X)>>(3+SCALE)), 3'((in.vcount - TEXT_POS_Y)>>(4+SCALE))};
end

always_ff @(posedge clk) begin
    if(rst) begin
        out.hcount <= '0;
        out.hsync  <= '0;
        out.hblnk  <= '0;
        out.vcount <= '0;
        out.vsync  <= '0;
        out.vblnk  <= '0;
        out.rgb    <= '0;
    end
    else begin
        out.hcount <= hcount2;
        out.hsync  <= hsync2;
        out.hblnk  <= hblnk2;
        out.vcount <= vcount2;
        out.vsync  <= vsync2;
        out.vblnk  <= vblnk2;
        out.rgb    <= rgb_nxt; 
    end
end


always_comb begin : rect_comb_blk
    if (vblnk2 || hblnk2) begin 
        rgb_nxt = 12'h0_0_0;
    end else begin
        if(hcount2 >= TEXT_POS_X && vcount2 >= TEXT_POS_Y && hcount2 < (TEXT_POS_X + TEXT_WIDTH) && vcount2 < (TEXT_POS_Y + TEXT_HEIGHT)) begin
            if (char_line_pixels[(7-3'((hcount2 - TEXT_POS_X)>>SCALE))]) begin
                rgb_nxt = 12'hf_f_f;
            end else begin
                rgb_nxt = rgb_h2;
            end
        end
        else begin
            rgb_nxt = rgb_h2;
        end
    end
end
endmodule