/**
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Modified: Jakub Bukowski
 * 
 * Description:
 * The project top module.
 */

 module top_game(
    input logic clk40MHz,
    input logic clk100MHz,
    input logic rst,
    inout logic ps2_clk,
    inout logic ps2_data,
    output logic hs,
    output logic vs,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue
 );

 timeunit 1ns;
 timeprecision 1ps;
 //Interface definitions
 vga_if draw_menu_if();

 //Signals from VGA timing
 wire [10:0] vcount_tim, hcount_tim;
 wire vsync_tim, hsync_tim;
 wire vblnk_tim, hblnk_tim;

 // Wires and local variables
    logic [11:0] address;
    logic [11:0] rgb; 

 image_rom u_image_rom (
    .clk(clk40MHz),
    .address(address),
    .rgb(rgb)
 );

 draw_menu u_draw_menu(
    .clk(clk40MHz),
    .rst(rst),
    .vcount(vcount_tim),
    .hcount(hcount_tim),
    .hsync(hsync_tim),
    .vsync(vsync_tim),
    .vblnk(vblnk_tim),
    .hblnk(hblnk_tim),

    .out(draw_menu_if)
 );
 endmodule
