/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * This module handles drawing a character with given dimensions and provides functionality to flip the character.
 */

 module draw_health#(parameter
    XPOS = 800,
    YPOS = 16
    ) (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_en,
    input  logic        en,
    input  logic [11:0] rgb_pixel,
    input  logic [2:0]  health_en,
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

    reg [3:0] i; 


    localparam BLACK = 12'h0_0_0;
    localparam OFFSET = 64;

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
            pixel_addr_nxt = pixel_addr;
        end else begin
            if (en && game_en) begin
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
                for(i = 0; i < 3; i++) begin
                    if((vcount_buf >= YPOS) && (vcount_buf < YPOS + OFFSET) && (hcount_buf >= XPOS + (OFFSET*i)) && (hcount_buf < XPOS + (OFFSET*(i+1))) && health_en[i]==1) begin
                        rgb_nxt =  rgb_pixel == BLACK ? rgb_buf : rgb_pixel;    // remove background
                        pixel_addr_nxt = {6'(in.vcount - YPOS), 6'(in.hcount - XPOS + (i*OFFSET))};
                    end
                end
            end else begin
                rgb_nxt = rgb_buf;
                pixel_addr_nxt = pixel_addr;
            end
        end
    end

endmodule