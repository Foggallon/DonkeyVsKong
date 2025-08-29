/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * This module is responsible for rendering the ladders during game startup.
 */

module animation_ladder (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_en,
    input  logic        animation,  // The signal remains at 1 while the animation is in progress, 
                                    // and switches to 0 once the animation has completed.
    input  logic [3:0]  counter,    // Counter reduces the displayed image by one ladder (32 pixels) with each increment.
    input  logic [11:0] rgb_pixel,
    output logic [9:0]  pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import ladder_pkg::*;
    import animation_pkg::*;
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

    logic [9:0] pixel_addr_nxt;

    /**
     * Signals buffer
     */

    delay #(.WIDTH(38), .CLK_DEL(2)) u_delay (
        .clk,
        .rst,
        .din({in.hcount, in.hsync, in.hblnk, in.vcount, in.vsync, in.vblnk, in.rgb}),
        .dout({hcount_buf, hsync_buf, hblnk_buf, vcount_buf, vsync_buf, vblnk_buf, rgb_buf})
    );

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
            pixel_addr <= pixel_addr_nxt;
        end
    end

    always_comb begin : out_comb_blk
        if (vblnk_buf || hblnk_buf) begin
            rgb_nxt = 12'h8_8_8;
            pixel_addr_nxt = pixel_addr;
        end else begin
            if (game_en && animation) begin
                if ((vcount_buf >= LADDER_VSTART) && (vcount_buf <= (VER_PIXELS - (LADDER_HEIGHT * counter))) &&
                    (hcount_buf >= LADDER_HSTART) && (hcount_buf < LADDER_HSTART + LADDER_WIDTH)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
                end else if ((vcount_buf >= LADDER_VSTART) && (vcount_buf <= (VER_PIXELS - (LADDER_HEIGHT * counter))) &&
                             (hcount_buf >= LADDER_HSTART_2) && (hcount_buf < LADDER_HSTART_2 + LADDER_WIDTH)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount - 4)};
                end else begin
                    rgb_nxt = rgb_buf;
                    pixel_addr_nxt = pixel_addr;
                end
            end else begin
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
            end
        end
    end

endmodule