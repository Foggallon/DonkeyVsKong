/**
 * MTM UEC2
 * Author: Dawid Bodzek
 * 
 * Modified: Jakub Bukowski
 *
 * Description:
 * Draw Donkey character.
 */

 module draw_donkey (
    input  logic clk,
    input  logic rst,

    input logic [11:0]xpos,
    input logic [11:0]ypos,
    
    input  logic [11:0] rgb_pixel,
    output logic [11:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

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


    localparam HEIGHT = 64;
    localparam WIDTH = 48;

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
            pixel_addr <= {6'(in.vcount - ypos), 6'(in.hcount - xpos)};
            /* Odbicie lustrzane
            pixel_addr <= {6'(in.vcount - 10), 6'(63 - (in.hcount + 10))}; */
        end
    end

    always_comb begin
        if (vblnk_buf || hblnk_buf) begin
            rgb_nxt = 12'h8_8_8;
        end else begin
            if((vcount_buf >= ypos) && (vcount_buf < ypos + HEIGHT) && (hcount_buf >=  xpos) && (hcount_buf < xpos + WIDTH))
                rgb_nxt = rgb_pixel;
            else
                rgb_nxt = rgb_buf;
        end
    end

endmodule