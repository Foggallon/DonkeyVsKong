/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Map
 */

module gameMap (
    input logic         clk,
    input logic         rst,
    input logic         start_game,
    input logic  [11:0] rgb_pixel,
    output logic [10:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vgaPkg::*;

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

    logic [10:0] pixel_addr_nxt;
 
    /**
     * Signals buffer
     */
 
    delay #(.WIDTH(38), .CLK_DEL(2)) u_delay (
        .clk,
        .rst,
        .din({in.hcount, in.hsync, in.hblnk, in.vcount, in.vsync, in.vblnk, in.rgb}),
        .dout({hcount_buf, hsync_buf, hblnk_buf, vcount_buf, vsync_buf, vblnk_buf, rgb_buf})
    );

    always_ff @(posedge clk) begin
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

    always_comb begin
        if (vblnk_buf || hblnk_buf) begin
            rgb_nxt = 12'h8_8_8;
            pixel_addr_nxt = pixel_addr;
        end else begin
            if ((vcount_buf >= VER_PIXELS - 32) && (vcount_buf <= VER_PIXELS) && (hcount_buf >= 0) && (hcount_buf < HOR_PIXELS/2) && start_game) begin
                rgb_nxt = rgb_pixel;
                pixel_addr_nxt = {5'(in.vcount), 6'(in.hcount)};
            end else if ((vcount_buf >= 239) && (vcount_buf <= 271) && (hcount_buf >= 0) && (hcount_buf < 640) && start_game) begin
                rgb_nxt = rgb_pixel;
                pixel_addr_nxt = {5'(in.vcount + 16), 6'(in.hcount)};
            end else if ((vcount_buf >= 128) && (vcount_buf <= 160) && (hcount_buf >= 320) && (hcount_buf < 576) && start_game) begin
                rgb_nxt = rgb_pixel;
                pixel_addr_nxt = {5'(in.vcount), 6'(in.hcount)};
            end else begin
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
            end
        end
    end
        
endmodule