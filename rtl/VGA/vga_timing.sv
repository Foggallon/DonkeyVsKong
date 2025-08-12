/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Vga timing controller.
 */

module vga_timing (
    input  logic clk,
    input  logic rst,

    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */

    logic [10:0] hcount_nxt, vcount_nxt;
    logic hblnk_nxt, vblnk_nxt, hsync_nxt, vsync_nxt;

    assign out.rgb = '0;

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            out.vcount <= '0;
            out.vsync <= '0;
            out.vblnk <= '0;
            out.hcount <= '0;
            out.hsync <= '0;
            out.hblnk <= '0;
        end else begin
            out.hcount <= hcount_nxt;
            out.vcount <= vcount_nxt;
            out.hblnk <= hblnk_nxt;
            out.vblnk <= vblnk_nxt;
            out.hsync <= hsync_nxt;
            out.vsync <= vsync_nxt;
        end
    end

    always_comb begin : out_hor_comb_blk
        if (out.hcount == HOR_TOTAL_TIME -1) begin
            hcount_nxt = '0;
            hblnk_nxt = '0;
            hsync_nxt = '0;
        end else begin
            hcount_nxt = out.hcount +1;
            if (out.hcount == HOR_BLANK_START -1)
                hblnk_nxt = '1;
            else
                hblnk_nxt = out.hblnk;
            if ((out.hcount >= HOR_SYNC_START -1) && (out.hcount < HOR_SYNC_STOP -1))
                hsync_nxt = '1;
            else
                hsync_nxt = '0;
        end
    end

    always_comb begin : out_ver_comb_blk
        if ((out.vcount == VER_TOTAL_TIME -1) && (out.hcount == HOR_TOTAL_TIME -1)) begin
            vcount_nxt = '0;
            vblnk_nxt = '0;
            vsync_nxt = '0;
        end else begin
            if (out.hcount == HOR_TOTAL_TIME -1)
                vcount_nxt = out.vcount +1;
            else 
                vcount_nxt = out.vcount;
            if ((out.vcount == VER_BLANK_START -1) && (out.hcount == HOR_TOTAL_TIME -1))
                vblnk_nxt = '1;
            else
                vblnk_nxt = out.vblnk;
            if ((out.vcount >= VER_SYNC_START -1) && (out.hcount == HOR_TOTAL_TIME -1))
                if (out.vcount < VER_SYNC_STOP -1)
                    vsync_nxt = '1;
                else
                    vsync_nxt = '0;
            else
                vsync_nxt = out.vsync;
            end
        end

    endmodule