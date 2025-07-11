/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for making ladders on game map
 */

module ladderControl (
    input logic clk,
    input logic rst,
    input logic start_game,
    input logic  [11:0] rgb_pixel,
    output logic [9:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import mapPkg::*;

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
        end else begin
            if (start_game) begin
                if ((vcount_buf >= LADDER_1_VSTART) && (vcount_buf <= LADDER_1_VSTOP) && 
                    (hcount_buf >= LADDER_1_HSTART) && (hcount_buf < LADDER_1_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + RAMP_OFFSET)};
                // Decoration
                end else if (((vcount_buf >= 704) && (vcount_buf <= 736) || (vcount_buf >= 588) && (vcount_buf <= 640)) &&
                            (hcount_buf >= 320) && (hcount_buf < 352)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
                //---------
                end else if ((vcount_buf >= LADDER_2_VSTART) && (vcount_buf <= LADDER_2_VSTOP) &&
                             (hcount_buf >= LADDER_2_HSTART) && (hcount_buf < LADDER_2_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount - RAMP_OFFSET)};
                end else if ((vcount_buf >= LADDER_3_VSTART) && (vcount_buf <= LADDER_3_VSTOP) &&
                             (hcount_buf >= LADDER_3_HSTART) && (hcount_buf < LADDER_3_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount - RAMP_OFFSET)};
                end else if ((vcount_buf >= LADDER_4_VSTART) && (vcount_buf <= LADDER_4_VSTOP) &&
                             (hcount_buf >= LADDER_4_HSTART) && (hcount_buf < LADDER_4_HSTOP)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount + RAMP_OFFSET)};            
                // Decoration
                end else if (((vcount_buf >= 271) && (vcount_buf <= 302) || (vcount_buf >= 354) && (vcount_buf <= 386) ) && 
                            (hcount_buf >= 576) && (hcount_buf < 608)) begin
                    rgb_nxt = rgb_pixel;
                    pixel_addr_nxt = {5'(in.vcount), 5'(in.hcount)};
                //----------
                end else if ((vcount_buf >= LADDER_5_VSTART) && (vcount_buf <= LADDER_5_VSTOP) &&
                             (hcount_buf >= LADDER_5_HSTART) && (hcount_buf < LADDER_5_HSTOP)) begin
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
