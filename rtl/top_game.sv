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
   input  logic clk65MHz,
   input  logic rst,
   
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
   vga_if draw_ladder_if();
   vga_if ramp_if();
   vga_if gameMap_if();

   /**
    * Local variables and signals
    */

   logic [11:0] rgb_pixel, rgb_pixel_menu, rgb_pixel_ladder, rgb_pixel_ramp, rgb_pixel_map;
   logic [10:0] pixel_addr_ramp, pixel_addr_map;
   logic [9:0] pixel_addr_ladder;
   logic [11:0] pixel_addr;
   logic [13:0] pixel_addr_menu;
   logic [11:0] xpos, ypos;
   logic [15:0] keycode;
   logic [31:0] ascii_code;
   logic left, right, jump, rotate, start_game, up, down;
   
   /**
    * Submodules instances
    */

   PS2Receiver u_PS2Receiver (
      .clk(clk65MHz),
      .kclk(ps2_clk),
      .kdata(ps2_data),
      .keycode(keycode),
      .oflag()
   );       

   bin2ascii u_bin2ascii (
      .I(keycode),
      .O(ascii_code)
  );

  keyDecoder u_keyDecoder (
      .clk(clk65MHz),
      .rst,
      
      .left,
      .right,
      .jump,
      .start_game(start_game),
      .up,
      .down,

      .keyCode(ascii_code),

      .rotate
   );

   vgaTiming u_vgaTiming (
      .clk(clk65MHz),
      .rst,
      
      .out(vga_timing_if)
  );

  imageRom  #(
      .BITS(14),
      .PIXELS(12292),
      .ROM_FILE("../../rtl/ROM/proba.dat")
   ) u_imageRom_menu (
      .clk(clk65MHz),
      
      .address(pixel_addr_menu),
      .rgb(rgb_pixel_menu)
   );

   drawMenu u_drawMenu (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .pixel_addr(pixel_addr_menu),
      .rgb_pixel(rgb_pixel_menu),

      .in(vga_timing_if),
      .out(draw_menu_if)
   );

   drawLadder u_drawLadder (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .pixel_addr(pixel_addr_ladder),
      .rgb_pixel(rgb_pixel_ladder),

      .in(draw_menu_if),
      .out(draw_ladder_if)
   );

   imageRom  #(
        .BITS(10),
        .PIXELS(1028),
        .ROM_FILE("../../rtl/LevelElements/drabinka.dat")
   ) u_imageRom_3 (
      .clk(clk65MHz),
      
      .address(pixel_addr_ladder),
      .rgb(rgb_pixel_ladder)
   );

   slopedRamp u_slopedRamp (
      .clk(clk65MHz),
      .rst,
      .pixel_addr(pixel_addr_ramp),
      .rgb_pixel(rgb_pixel_ramp),
      .start_game,
      .in(draw_ladder_if),
      .out(ramp_if)
   );

   imageRom  #(
      .BITS(11),
      .PIXELS(2052),
      .ROM_FILE("../../rtl/LevelElements/platforma.dat")
   ) u_imageRom_2 (
      .clk(clk65MHz),
      
      .address(pixel_addr_ramp),
      .rgb(rgb_pixel_ramp)
   );

   gameMap u_gameMap (
        .clk(clk65MHz),
        .rst,
        .rgb_pixel(rgb_pixel_map),
        .pixel_addr(pixel_addr_map),
        .start_game,

        .in(ramp_if),
        .out(gameMap_if)
    );

   imageRom  #(
      .BITS(11),
      .PIXELS(2052),
      .ROM_FILE("../../rtl/LevelElements/platforma.dat")
   ) u_imageRom_map (
      .clk(clk65MHz),
      
      .address(pixel_addr_map),
      .rgb(rgb_pixel_map)
   );

   drawCharacter u_drawCharacter_donkey (
      .clk(clk65MHz),
      .rst,

      .rotate,
      .start_game,

      .pixel_addr,
      .rgb_pixel,

      .xpos(xpos),
      .ypos(ypos),

      .in(gameMap_if),
      .out(draw_donkey_if)
   );
   
   imageRom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/Donkey/Donkey_v1.dat")
   
   ) u_imageRom_donkey (
      .clk(clk65MHz),
      
      .address(pixel_addr),
      .rgb(rgb_pixel)
   );

   movement u_movement (
      .clk(clk65MHz),
      .rst(rst),
      .xpos(xpos),
      .ypos(ypos),
      
      .start_game,
      .left,
      .right,
      .jump,
      .down,
      .up
   );

endmodule
