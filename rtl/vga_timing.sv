/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Vga timing controller.
 */

module vga_timing (
    input  logic clk,
    input  logic rst,

    output logic [10:0] hcount,
    output logic [10:0] vcount,
    output logic hsync,
    output logic vsync,
    output logic hblnk,
    output logic vblnk
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [10:0] hcount_nxt, vcount_nxt;
logic hblnk_nxt, vblnk_nxt, hsync_nxt, vsync_nxt;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    if (rst) begin
        vcount <= '0;
        vsync <= '0;
        vblnk <= '0;
        hcount <= '0;
        hsync <= '0;
        hblnk <= '0;
    end else begin
        hcount <= hcount_nxt;
        vcount <= vcount_nxt;
        hblnk <= hblnk_nxt;
        vblnk <= vblnk_nxt;
        hsync <= hsync_nxt;
        vsync <= vsync_nxt;
    end
end

always_comb begin
    if (hcount == HOR_TOTAL_TIME -1) begin
        hcount_nxt = '0;
        hblnk_nxt = '0;
        hsync_nxt = '0;
    end else begin
        hcount_nxt = hcount +1;
        if (hcount == HOR_BLANK_START -1)
            hblnk_nxt = '1;
        else
            hblnk_nxt = hblnk;
        if ((hcount >= HOR_SYNC_START -1) && (hcount < HOR_SYNC_STOP -1))
            hsync_nxt = '1;
        else
            hsync_nxt = '0;
    end
end

always_comb begin
    if ((vcount == VER_TOTAL_TIME -1) && (hcount == HOR_TOTAL_TIME -1)) begin
        vcount_nxt = '0;
        vblnk_nxt = '0;
        vsync_nxt = '0;
    end else begin
        if (hcount == HOR_TOTAL_TIME -1)
            vcount_nxt = vcount +1;
        else 
            vcount_nxt = vcount;
        if ((vcount == VER_BLANK_START -1) && (hcount == HOR_TOTAL_TIME -1))
            vblnk_nxt = '1;
        else
            vblnk_nxt = vblnk;
        if ((vcount >= VER_SYNC_START -1) && (hcount == HOR_TOTAL_TIME -1))
            if (vcount < VER_SYNC_STOP -1)
                vsync_nxt = '1;
            else
                vsync_nxt = '0;
        else
            vsync_nxt = vsync;
        end
    end

endmodule