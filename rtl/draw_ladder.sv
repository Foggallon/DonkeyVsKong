/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for making ladders on game map
 */

module draw_ladder (
    input  logic        clk,
    input  logic        rst,
    input  logic        start_game,
    input  logic        animation,
    input  logic [11:0] rgb_pixel,
    output logic [9:0]  pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import ladder_pkg::*;
    import platform_pkg::*;

    /**
     * Local variables and signals
     */

    logic [9:0] pixel_addr_nxt;
    logic [11:0] rgb_nxt;
    logic [11:0] rgb_buf;
  
    logic [10:0] hcount_buf;
    logic hblnk_buf;
    logic hsync_buf;
  
    logic [10:0] vcount_buf;
    logic vblnk_buf;
    logic vsync_buf;

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
            if (start_game) begin
                if ((vcount_buf >= LADDER_1_VSTART) && (vcount_buf <= LADDER_1_VSTOP) && 
                    (hcount_buf >= LADDER_1_HSTART) && (hcount_buf < LADDER_1_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + PLATFORM_OFFSET)};
                end else if (((vcount_buf >= DECORATION_1_VSTART) && (vcount_buf <= DECORATION_1_VSTART + LADDER_HEIGHT) || 
                             (vcount_buf >= DECORATION_1_VSTART_2) && (vcount_buf <= DECORATION_1_VSTART_2 + LADDER_HEIGHT)) &&
                             (hcount_buf >= DECORATION_1_HSTART) && (hcount_buf < DECORATION_1_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
                end else if ((vcount_buf >= LADDER_2_VSTART) && (vcount_buf <= LADDER_2_VSTOP) &&
                             (hcount_buf >= LADDER_2_HSTART) && (hcount_buf < LADDER_2_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + PLATFORM_OFFSET)};
                end else if ((vcount_buf >= LADDER_3_VSTART) && (vcount_buf <= LADDER_3_VSTOP) &&
                             (hcount_buf >= LADDER_3_HSTART) && (hcount_buf < LADDER_3_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + PLATFORM_OFFSET)};
                end else if ((vcount_buf >= LADDER_4_VSTART) && (vcount_buf <= LADDER_4_VSTOP) &&
                             (hcount_buf >= LADDER_4_HSTART) && (hcount_buf < LADDER_4_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + PLATFORM_OFFSET)};            
                end else if (((vcount_buf >= DECORATION_2_VSTART) && (vcount_buf <= DECORATION_2_VSTART + LADDER_HEIGHT) || 
                             (vcount_buf >= DECORATION_2_VSTART_2) && (vcount_buf <= DECORATION_2_VSTART_2 + LADDER_HEIGHT)) &&
                             (hcount_buf >= DECORATION_2_HSTART) && (hcount_buf < DECORATION_2_HSTART + LADDER_WIDTH) && !animation) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
                end else if ((vcount_buf >= LADDER_5_VSTART) && (vcount_buf <= LADDER_5_VSTOP) &&
                             (hcount_buf >= LADDER_5_HSTART) && (hcount_buf < LADDER_5_HSTART + LADDER_WIDTH)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
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