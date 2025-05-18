/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * 
 * Author: Jakub Bukowski
 * Modified: Dawid Bodzek
 * 
 * Description:
 * The project top module.
 */

module top_game (
   input  logic clk40MHz,
   input  logic rst,
   
   input  logic clk100MHz,
   input  logic ps2_clk,
   input  logic ps2_data,
   
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

   assign vs = draw_donkey_if.vsync;
   assign hs = draw_donkey_if.hsync;
   assign {r,g,b} = draw_donkey_if.rgb;

   /**
    * Interface definitions
    */

   vga_if draw_menu_if();
   vga_if vga_timing_if();
   vga_if draw_donkey_if();

   /**
    * Local variables and signals
    */

   logic [11:0] rgb_pixel;
   logic [11:0] pixel_addr;
   logic [11:0] xpos, ypos;
   logic [15:0] released;

   logic [6:0]ascii_code;
   
   /**
    * Submodules instances
    */

   ps2_keyboard_to_ascii u_ps2_keyboard_to_ascii (
      .clk(clk100MHz),
      .ps2_clk,
      .ps2_data,
      .ascii_code(ascii_code), //--NASZ KOD ASCII--
      .ascii_new(),   //--FLAGA NOWEGO KODU ASCII--
      .released
   );

   vga_timing u_vga_timing (
      .clk(clk40MHz),
      .rst,
      
      .out(vga_timing_if)
  );

   draw_menu u_draw_menu (
      .clk(clk40MHz),
      .rst,

      //.rgb_pixel,
      //.pixel_addr,

      .in(vga_timing_if),
      .out(draw_menu_if)
   );

   draw_donkey u_draw_donkey (
      .clk(clk40MHz),
      .rst,

      .pixel_addr,
      .rgb_pixel,

      .xpos(xpos),
      .ypos(ypos),

      .in(draw_menu_if),
      .out(draw_donkey_if)
   );
   
   image_rom  #(
    .BITS(12),
    .PIXELS(4096),
    .ROM_FILE("../../rtl/ROM/Donkey_v1.dat")
   
   ) u_image_rom_donkey
   (
      .clk(clk40MHz),
      
      .address(pixel_addr),
      .rgb(rgb_pixel)

   );

   movement u_movement (
      .clk(clk40MHz),
      .rst(rst),
      .released,
      .xpos(xpos),
      .ypos(ypos),
      .keyCode(ascii_code)
   );

   endmodule
