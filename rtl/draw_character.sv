/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 * 
 * Modified: Jakub Bukowski
 *
 * Description:
 * Draw character module.
 */

module draw_character #(parameter
    CHARACTER_HEIGHT = 64,
    CHARACTER_WIDTH = 64
    )(
    input  logic        clk,
    input  logic        rst,
    input  logic        rotate,
    input  logic        start_game,
    input  logic        en,
    input  logic [10:0] xpos,
    input  logic [10:0] ypos,
    input  logic [11:0] rgb_pixel,
    output logic [11:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

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

    logic [11:0] pixel_addr_nxt;

    localparam BLACK = 12'h0_0_0;

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
            pixel_addr <= pixel_addr_nxt;
        end
    end

    always_comb begin : out_comb_blk
        if (vblnk_buf || hblnk_buf) begin
            rgb_nxt = 12'h8_8_8;
        end else begin
            if (en && start_game) begin
                if((vcount_buf >= ypos) && (vcount_buf < ypos + CHARACTER_HEIGHT) && (hcount_buf >=  xpos) && (hcount_buf < xpos + CHARACTER_WIDTH)) begin
                    rgb_nxt = (rgb_pixel == BLACK ? rgb_buf : rgb_pixel);
                end else begin
                    rgb_nxt = rgb_buf;
                end
            end else begin
                rgb_nxt = rgb_buf;
            end
        end
    end

    always_comb begin : out_comb_rotate_blk
        if (rotate) begin
            pixel_addr_nxt = {6'(in.vcount - ypos), 6'((CHARACTER_WIDTH - 1) - (in.hcount - xpos))};
        end else begin
            pixel_addr_nxt = {6'(in.vcount - ypos), 6'(in.hcount - xpos)};
        end
    end
endmodule