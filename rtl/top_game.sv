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

module top_game (
   input  logic clk40MHz,
   input  logic rst,
   
   input  logic clk100MHz,
   inout  logic ps2_clk,
   inout  logic ps2_data,
   
   output logic vs,
   output logic hs,
   output logic [3:0] r,
   output logic [3:0] g,
   output logic [3:0] b
);

   timeunit 1ns;
   timeprecision 1ps;

   /**
    * Signals assignments
    */

   assign vs = draw_menu_if.vsync;  //---EDIT---
   assign hs = draw_menu_if.hsync;
   assign {r,g,b} = draw_menu_if.rgb;

   /**
    * Interface definitions
    */

   vga_if draw_menu_if();
   vga_if vga_timing_if();

   /**
    * Local variables and signals
    */

   logic [11:0] rgb_pixel;
   logic [19:0] pixel_addr;
   
   /**
    * Submodules instances
    */
   
   vga_timing u_vga_timing (
      .clk(clk40MHz),
      .rst,
      
      .out(vga_timing_if)
  );

   draw_menu u_draw_menu (
      .clk(clk40MHz),
      .rst,

      .rgb_pixel,
      .pixel_addr,

      .in(vga_timing_if),
      .out(draw_menu_if)
   );

   // ---EDIT---
   image_rom u_image_rom (
      .clk(clk40MHz),
      
      .address(pixel_addr),
      .rgb(rgb_pixel)

   );

   endmodule
