/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for rendering inclined ramps. A bit set to 1 in the ctl signal activates the drawing of the corresponding ramp.
 */

module incline_platform (
    input  logic        clk,
    input  logic        rst,
    input  logic        start_game,
    input  logic [3:0]  ctl,
    input  logic [11:0] rgb_pixel,
    output logic [10:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import platform_pkg::*;

    /**
     * Local variables and signals
     */

    logic [10:0] pixel_addr_nxt;
    logic [11:0] rgb_nxt;
    logic [11:0] rgb_buf;
  
    logic [10:0] hcount_buf;
    logic hblnk_buf;
    logic hsync_buf;
  
    logic [10:0] vcount_buf;
    logic vblnk_buf;
    logic vsync_buf;

    reg [3:0] i;

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
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
                for (i = 0; i < 8; i++) begin
                    if ((vcount_buf >= IP_VSTART_1 - (i * PLATFORM_OFFSET)) && (vcount_buf <= IP_VSTART_1 + PLATFORM_HEIGHT - (i * PLATFORM_OFFSET)) &&
                        (hcount_buf >= IP_HSTART_1 + (i * PLATFORM_WIDTH)) && (hcount_buf < IP_HSTART_1 + ((i + 1) * PLATFORM_WIDTH)) && ctl[3] == 1) begin
                            rgb_nxt = rgb_pixel;
                            pixel_addr_nxt = {5'(in.vcount + ((i + 1) * PLATFORM_OFFSET)), 6'(in.hcount)};
                    end
                end
                for (i = 0; i < 14; i++) begin
                    if ((vcount_buf >= IP_VSTART_2 + (i * PLATFORM_OFFSET)) && (vcount_buf <= IP_VSTART_2 + PLATFORM_HEIGHT + (i * PLATFORM_OFFSET)) &&
                        (hcount_buf >= (i * PLATFORM_WIDTH)) && (hcount_buf < 1 + ((i + 1) * PLATFORM_WIDTH)) && ctl[2] == 1) begin
                            rgb_nxt = rgb_pixel;
                            pixel_addr_nxt = {5'(in.vcount - ((i - 1) * PLATFORM_OFFSET)), 6'(in.hcount - 3)};
                    end
                end
                for (i = 0; i < 14; i++) begin
                    if ((vcount_buf >= IP_VSTART_3 - (i * PLATFORM_OFFSET)) && (vcount_buf <= IP_VSTART_3 + PLATFORM_HEIGHT - (i * PLATFORM_OFFSET)) &&
                        (hcount_buf >= IP_HSTART_3 + (i * PLATFORM_WIDTH)) && (hcount_buf < IP_HSTART_3 + ((i + 1) * PLATFORM_WIDTH)) && ctl[1] == 1) begin
                            rgb_nxt = rgb_pixel;
                            pixel_addr_nxt = {5'(in.vcount + (i * PLATFORM_OFFSET)), 6'(in.hcount)};
                    end
                end
                for (i = 0; i < 4; i++) begin
                    if ((vcount_buf >= IP_VSTART_4 + (i * PLATFORM_OFFSET)) && (vcount_buf <= IP_VSTART_4 + PLATFORM_HEIGHT + (i * PLATFORM_OFFSET)) &&
                        (hcount_buf >= IP_HSTART_4 + (i * PLATFORM_WIDTH)) && (hcount_buf < IP_HSTART_4 + ((i + 1) * PLATFORM_WIDTH)) && ctl[0] == 1) begin
                            rgb_nxt = rgb_pixel;
                            pixel_addr_nxt = {5'(in.vcount - ((i - PLATFORM_OFFSET) * PLATFORM_OFFSET)), 6'(in.hcount)};
                    end
                end
            end else begin
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
            end
        end
    end

endmodule