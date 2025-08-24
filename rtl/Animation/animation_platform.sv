/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * The module renders horizontal platforms during the startup animation and selectively during gameplay. 
 * Platform visibility is controlled by the ctl signal, which can disable specific platforms making place for platforms from
 * incline platform module.
 */

module animation_platform (
    input  logic        clk,
    input  logic        rst,
    input  logic        start_game,
    input  logic [3:0]  ctl,        // This signal is responsible for disabling platforms. A bit set to 1 at a given position 
                                    // indicates that the corresponding platform is deactivated.
    input  logic [11:0] rgb_pixel,
    output logic [10:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import platform_pkg::*;
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
                // Draw always (during animation and game).
                if ((vcount_buf >= PLATFORM_1_VSTART) && (vcount_buf <= PLATFORM_1_VSTART + PLATFORM_HEIGHT) && 
                    (hcount_buf >= PLATFORM_1_HSTART) && (hcount_buf < PLATFORM_1_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 6'(in.hcount)};
                end else  if ((vcount_buf >= PLATFORM_1_VSTART) && (vcount_buf <= PLATFORM_1_VSTART + PLATFORM_HEIGHT) && 
                              (hcount_buf >= PLATFORM_1_HSTOP) && (hcount_buf < HOR_PIXELS) && ctl[3] == 0) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 6'(in.hcount)};
                end else if ((vcount_buf >= PLATFORM_VSTART_2) && (vcount_buf <= PLATFORM_VSTART_2 + PLATFORM_HEIGHT) && 
                             (hcount_buf >= 0) && (hcount_buf < HOR_PIXELS - 128) && ctl[2] == 0) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount + 4), 6'(in.hcount)};
                end else if ((vcount_buf >= PLATFORM_VSTART) && (vcount_buf <= PLATFORM_VSTART + PLATFORM_HEIGHT) && 
                             (hcount_buf >= 2 * PLATFORM_WIDTH) && (hcount_buf < HOR_PIXELS) && ctl[1] == 0) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount + 52), 6'(in.hcount)};
                // Draw always (during animation and game).
                end else if ((vcount_buf >= PLATFORM_2_VSTART) && (vcount_buf <= PLATFORM_2_VSTART + PLATFORM_HEIGHT) && 
                             (hcount_buf >= PLATFORM_2_HSTART) && (hcount_buf < PLATFORM_2_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount + 16), 6'(in.hcount)};
                end else if ((vcount_buf >= PLATFORM_2_VSTART) && (vcount_buf <= PLATFORM_2_VSTART + PLATFORM_HEIGHT) && 
                             (hcount_buf >= PLATFORM_2_HSTOP) && (hcount_buf < PLATFORM_2_HSTOP + (4 * PLATFORM_WIDTH)) && ctl[0] == 0) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount + 16), 6'(in.hcount)};
                // Draw always (during animation and game).
                end else if ((vcount_buf >= PLATFORM_3_VSTART) && (vcount_buf <= PLATFORM_3_VSTART + PLATFORM_HEIGHT) && 
                             (hcount_buf >= PLATFORM_3_HSTART) && (hcount_buf < PLATFORM_3_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 6'(in.hcount)};
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