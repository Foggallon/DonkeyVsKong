/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for drawing menu that waits for players to begin the game.
 */

 module draw_menu (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_en,
    input  logic        donkey_win,
    input  logic        kong_win,
    input  logic [11:0] rgb_pixel,
    input  logic [11:0] rgb_pixel_donkey,
    input  logic [11:0] rgb_pixel_kong,
    output logic [13:0] pixel_addr,
    
    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;
    logic [11:0] rgb_buf;
 
    logic [10:0] hcount_buf;
    logic hblnk_buf;
    logic hsync_buf;
 
    logic [10:0] vcount_buf;
    logic vblnk_buf;
    logic vsync_buf;

    localparam GAME_BACKGROUND = 12'h0_0_0;
 
    /**
     * Signals buffer
     */
 
    delay #(.WIDTH(38), .CLK_DEL(2)) u_delay (
        .clk,
        .rst,
        .din({in.hcount, in.hsync, in.hblnk, in.vcount, in.vsync, in.vblnk, in.rgb}),
        .dout({hcount_buf, hsync_buf, hblnk_buf, vcount_buf, vsync_buf, vblnk_buf, rgb_buf})
    );
 
    /**
     * Internal logic
     */
 
    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb    <= '0;
            pixel_addr <= '0;
        end else begin
            out.vcount <= vcount_buf;
            out.vsync  <= vsync_buf;
            out.vblnk  <= vblnk_buf;
            out.hcount <= hcount_buf;
            out.hsync  <= hsync_buf;
            out.hblnk  <= hblnk_buf;
            out.rgb    <= rgb_nxt;
            pixel_addr <= {7'(in.vcount >> 3), 7'(in.hcount >> 3)};
        end
    end

    always_comb begin : out_comb_blk
        if (vblnk_buf || hblnk_buf) begin
            rgb_nxt = 12'h8_8_8;
        end else begin
            if((vcount_buf >= 0) && (vcount_buf < VER_PIXELS) && (hcount_buf >= 0) && (hcount_buf < HOR_PIXELS)) begin
                if (donkey_win) begin
                    rgb_nxt = rgb_pixel_donkey;
                end else if (kong_win) begin
                    rgb_nxt = rgb_pixel_kong;
                end else if (game_en) begin
                    rgb_nxt = GAME_BACKGROUND;
                end else begin
                    rgb_nxt = rgb_pixel;
                end
            end else begin
                rgb_nxt = rgb_buf;
            end
        end
    end

endmodule
