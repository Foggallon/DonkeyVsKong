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
   input  logic       clk65MHz,
   input  logic       rst,
   input  logic       ps2_clk,
   input  logic       ps2_data,
   input  logic       rx,
   output logic       tx,       
   output logic       vs,
   output logic       hs,
   output logic [3:0] r,
   output logic [3:0] g,
   output logic [3:0] b
);

   timeunit 1ns;
   timeprecision 1ps;

   /**
    * Interface definitions
    */

   vga_if vga_timing_if();
   vga_if draw_menu_if();
   vga_if draw_ladder_if();
   vga_if incline_platform_if();
   vga_if animation_platform_if();
   vga_if animation_ladder_if();
   vga_if draw_animation_kong_if();
   vga_if draw_barrel_if();
   vga_if draw_kong_if();
   vga_if draw_donkey_if();

   /**
    * Local variables and signals
    */

   // Keyboard
   logic oflag, right, left, jump, down, up, start_game, rotate;
   logic [15:0] keycode;
   logic [31:0] ascii_code;

   // UART
   logic rd_uart, wr_uart, tx_full, rx_empty;
   logic [7:0] r_data, w_data;

   // Keyboard - UART
   logic right_uart, left_uart, down_uart, up_uart;
   logic [15:0] keycode_uart;
   logic [31:0] ascii_code_uart;
   
   // Start game menu
   logic [11:0] rgb_pixel_menu;
   logic [13:0] pixel_addr_menu;

   // Ladders
   logic [9:0] pixel_addr_ladder;
   logic [11:0] rgb_pixel_ladder;

   // Incline platforms
   logic [10:0] pixel_addr_platform;
   logic [11:0] rgb_pixel_platform;

   // Animation
   logic animation;
   logic [3:0] counter, ctl_animation;
   logic [10:0] xpos_animation, ypos_animation;

   // Animation - ladder
   logic [9:0] pixel_addr_animation_ladder;
   logic [11:0] rgb_pixel_animation_ladder;
   logic is_on_ladder, is_on_ladder_donkey;

   // Animation - platform
   logic [10:0] pixel_addr_animation_platform;
   logic [11:0] rgb_pixel_animation_platform;

   // Animation - kong
   logic [11:0] pixel_addr_animation_kong, rgb_pixel_animation_kong, rgb_pixel_animation_kong_back;

   // Barrels
   logic [4:0] barrel_hor, barrel_ver;
   logic [11:0] pixel_addr_barrel, rgb_pixel_barrel;
   logic [9:0][10:0] xpos_barrel, ypos_barrel;

   // Barrels - horizontal / vertical
   logic hit_1, hit_2, hit_3, hit_4, hit_5, hit_6, hit_7, hit_8, hit_9, hit_10;
   logic done_1, done_2, done_3, done_4, done_5;
   logic done_ver_1, done_ver_2, done_ver_3, done_ver_4, done_ver_5;
   logic [10:0] xpos_barrel_1, ypos_barrel_1, xpos_barrel_1_v, ypos_barrel_1_v;
   logic [10:0] xpos_barrel_2, ypos_barrel_2, xpos_barrel_2_v, ypos_barrel_2_v;
   logic [10:0] xpos_barrel_3, ypos_barrel_3, xpos_barrel_3_v, ypos_barrel_3_v;
   logic [10:0] xpos_barrel_4, ypos_barrel_4, xpos_barrel_4_v, ypos_barrel_4_v;
   logic [10:0] xpos_barrel_5, ypos_barrel_5, xpos_barrel_5_v, ypos_barrel_5_v;

   // Kong - player 2
   logic [10:0] xpos_kong, ypos_kong;
   logic [11:0] pixel_addr_kong, rgb_pixel_kong;

   // Donkey - player 1
   logic [10:0] xpos_donkey, ypos_donkey;
   logic [11:0] pixel_addr_donkey, rgb_pixel_donkey, rgb_pixel_donkey_back;

   /**
    * Signals assignments
    */

   assign xpos_barrel[0] = xpos_barrel_1;
   assign ypos_barrel[0] = ypos_barrel_1;
   assign xpos_barrel[1] = xpos_barrel_2;
   assign ypos_barrel[1] = ypos_barrel_2;
   assign xpos_barrel[2] = xpos_barrel_3;
   assign ypos_barrel[2] = ypos_barrel_3;
   assign xpos_barrel[3] = xpos_barrel_4;
   assign ypos_barrel[3] = ypos_barrel_4;
   assign xpos_barrel[4] = xpos_barrel_5;
   assign ypos_barrel[4] = ypos_barrel_5;
   assign xpos_barrel[5] = xpos_barrel_1_v;
   assign ypos_barrel[5] = ypos_barrel_1_v;
   assign xpos_barrel[6] = xpos_barrel_2_v;
   assign ypos_barrel[6] = ypos_barrel_2_v;
   assign xpos_barrel[7] = xpos_barrel_3_v;
   assign ypos_barrel[7] = ypos_barrel_3_v;
   assign xpos_barrel[8] = xpos_barrel_4_v;
   assign ypos_barrel[8] = ypos_barrel_4_v;
   assign xpos_barrel[9] = xpos_barrel_5_v;
   assign ypos_barrel[9] = ypos_barrel_5_v;

   assign vs = draw_donkey_if.vsync;
   assign hs = draw_donkey_if.hsync;
   assign {r,g,b} = draw_donkey_if.rgb;
   
   /**
    * Keyboard
    */
  
   ps2_receiver u_ps2_receiver (
      .clk(clk65MHz),
      .kclk(ps2_clk),
      .kdata(ps2_data),
      .keycode(keycode),
      .oflag(oflag)
   );       

   bin2ascii u_bin2ascii (
      .I(keycode),
      .O(ascii_code)
   );

   key_decoder u_key_decoder (
      .clk(clk65MHz),
      .rst,
      .left(left),
      .right(right),
      .jump(jump),
      .start_game(start_game),
      .up(up),
      .down(down),
      .keyCode(ascii_code),
      .rotate(rotate)
   );

   /**
    * UART
    */

   uart #(.DBIT(8), .SB_TICK(16), .DVSR(33), .DVSR_BIT(7), .FIFO_W(1)) u_uart (
      .clk(clk65MHz),
      .reset(rst),
      .rd_uart(rd_uart),
      .wr_uart(wr_uart),
      .rx(rx),
      .w_data(w_data),

      .tx_full(tx_full),
      .rx_empty(rx_empty),
      .tx(tx),
      .r_data(r_data)
  );

   uart_rx_ctl u_uart_rx_ctl(
      .clk(clk65MHz),
      .rst(rst),
      .rx_empty,
      .r_data,
      .rd_uart,
      .uart_data(keycode_uart)
   );

   uart_tx_ctl u_uart_tx_ctl(
      .clk(clk65MHz),
      .rst(rst),
      .keycode,
      .oflag,
      .tx_full,
      .w_data,
      .wr_uart
   );

  /**
   * Keyboard - UART
   */

   bin2ascii u_bin2ascii_uart (
      .I(keycode_uart),
      .O(ascii_code_uart)
   );

   key_decoder u_key_decoder_uart (
      .clk(clk65MHz),
      .rst,
      .left(left_uart),
      .right(right_uart),
      .jump(),
      .start_game(),
      .up(up_uart),
      .down(down_uart),
      .keyCode(ascii_code_uart),
      .rotate()
   );

   /**
    * VGA
    */

   vga_timing u_vga_timing (
      .clk(clk65MHz),
      .rst,
      
      .out(vga_timing_if)
  );

   /**
    * Start game menu
    */

   draw_menu u_draw_menu (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .rgb_pixel(rgb_pixel_menu),
      .pixel_addr(pixel_addr_menu),

      .in(vga_timing_if),
      .out(draw_menu_if)
   );

   image_rom  #(
      .BITS(14),
      .PIXELS(12292),
      .ROM_FILE("../../rtl/ROM/DonkeyVsKong_small.dat")
   ) u_image_rom_menu (
      .clk(clk65MHz),
      .address(pixel_addr_menu),
      .rgb(rgb_pixel_menu)
   );

   /**
    * Ladders 
    */

   draw_ladder u_draw_ladder (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .animation,
      .pixel_addr(pixel_addr_ladder),
      .rgb_pixel(rgb_pixel_ladder),

      .in(draw_menu_if),
      .out(draw_ladder_if)
   );

   image_rom  #(
        .BITS(10),
        .PIXELS(1028),
        .ROM_FILE("../../rtl/ROM/drabinka.dat")
   ) u_image_rom_ladder (
      .clk(clk65MHz),
      
      .address(pixel_addr_ladder),
      .rgb(rgb_pixel_ladder)
   );

   /**
    * Incline platforms
    */

   incline_platform u_incline_platform (
      .clk(clk65MHz),
      .rst,
      .pixel_addr(pixel_addr_platform),
      .rgb_pixel(rgb_pixel_platform),
      .start_game,
      .ctl(ctl_animation),

      .in(draw_ladder_if),
      .out(incline_platform_if)
   );

   image_rom  #(
      .BITS(11),
      .PIXELS(2052),
      .ROM_FILE("../../rtl/ROM/platforma.dat")
   ) u_image_rom_incline_platform (
      .clk(clk65MHz),
      .address(pixel_addr_platform),
      .rgb(rgb_pixel_platform)
   );

   /**
    * Animation
    */

   start_animation u_start_animation (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .animation(animation),
      .counter(counter),
      .ctl(ctl_animation),
      .xpos(xpos_animation),
      .ypos(ypos_animation)
   );

   animation_platform u_animation_platform (
        .clk(clk65MHz),
        .rst,
        .pixel_addr(pixel_addr_animation_platform),
        .rgb_pixel(rgb_pixel_animation_platform),
        .start_game,
        .ctl(ctl_animation),
        .in(incline_platform_if),
        .out(animation_platform_if)
   );

   image_rom  #(
        .BITS(11),
        .PIXELS(2052),
        .ROM_FILE("../../rtl/ROM/platforma.dat")
   ) u_image_rom_animation_platform (
      .clk(clk65MHz),
      .address(pixel_addr_animation_platform),
      .rgb(rgb_pixel_animation_platform)
   );

   animation_ladder u_animation_ladder (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .animation,
      .counter,
      .rgb_pixel(rgb_pixel_animation_ladder),
      .pixel_addr(pixel_addr_animation_ladder),
      .is_on_ladder,

      .in(animation_platform_if),
      .out(animation_ladder_if)
   );

   image_rom  #(
        .BITS(10),
        .PIXELS(1028),
        .ROM_FILE("../../rtl/ROM/drabinka.dat")
   ) u_image_rom_animation_ladder (
      .clk(clk65MHz),
      
      .address(pixel_addr_animation_ladder),
      .rgb(rgb_pixel_animation_ladder)
   );

   draw_character #(
      .CHARACTER_HEIGHT(64),
      .CHARACTER_WIDTH(64)
   ) u_draw_character_animation_kong (
      .clk(clk65MHz),
      .rst,
      .rotate('0),
      .start_game,
      .pixel_addr(pixel_addr_animation_kong),
      .rgb_pixel(rgb_pixel_animation_kong),
      .rgb_pixel_back(rgb_pixel_animation_kong_back),
      .xpos(xpos_animation),
      .ypos(ypos_animation),
      .en(animation),
      .is_on_ladder,

      .in(animation_ladder_if),
      .out(draw_animation_kong_if)
   );
   
   image_rom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Kong.dat")
   
   ) u_image_rom_kong (
      .clk(clk65MHz),
      .address(pixel_addr_animation_kong),
      .rgb(rgb_pixel_animation_kong)
   );

   image_rom #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Kong_Back.dat")
   )
   u_image_rom_kong_back (
      .clk(clk65MHz),
      .address(pixel_addr_animation_kong),
      .rgb(rgb_pixel_animation_kong_back)
   );

   /**
    * Barrels
    */
   
   draw_barrel #(.BARRELS(10)) u_draw_barrel (
      .clk(clk65MHz),
      .rst(rst),
      .start_game,
      .animation,
      .barrel({barrel_ver, barrel_hor}),
      .xpos(xpos_barrel),
      .ypos(ypos_barrel),
      .rgb_pixel(rgb_pixel_barrel),
      .pixel_addr(pixel_addr_barrel),

      .in(draw_animation_kong_if),
      .out(draw_barrel_if)
   );

   image_rom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Barrel.dat")
   ) u_image_rom_barrel (
      .clk(clk65MHz),
      
      .address(pixel_addr_barrel),
      .rgb(rgb_pixel_barrel)
   );

   hor_barrel u_ver_barrel_1 (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_1),
      .barrel(barrel_hor[0]),
      .done(done_1),
      .xpos(xpos_barrel_1),
      .ypos(ypos_barrel_1)
   );

   hor_barrel u_ver_barrel_2 (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_2),
      .barrel(barrel_hor[1]),
      .done(done_2),
      .xpos(xpos_barrel_2),
      .ypos(ypos_barrel_2)
   );

   hor_barrel u_ver_barrel_3 (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_3),
      .barrel(barrel_hor[2]),
      .done(done_3),
      .xpos(xpos_barrel_3),
      .ypos(ypos_barrel_3)
   );

   hor_barrel u_ver_barrel_4 (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_4),
      .barrel(barrel_hor[3]),
      .done(done_4),
      .xpos(xpos_barrel_4),
      .ypos(ypos_barrel_4)
   );

   hor_barrel u_ver_barrel_5 (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_5),
      .barrel(barrel_hor[4]),
      .done(done_5),
      .xpos(xpos_barrel_5),
      .ypos(ypos_barrel_5)
   );

   ver_barrel u_ver_barrel_1_v (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_6),
      .barrel(barrel_ver[0]),
      .done(done_ver_1),
      .xpos(xpos_barrel_1_v),
      .ypos(ypos_barrel_1_v)
   );

   ver_barrel u_ver_barrel_2_v (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_7),
      .barrel(barrel_ver[1]),
      .done(done_ver_2),
      .xpos(xpos_barrel_2_v),
      .ypos(ypos_barrel_2_v)
   );

   ver_barrel u_ver_barrel_3_v (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_8),
      .barrel(barrel_ver[2]),
      .done(done_ver_3),
      .xpos(xpos_barrel_3_v),
      .ypos(ypos_barrel_3_v)
   );

   ver_barrel u_ver_barrel_4_v (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_9),
      .barrel(barrel_ver[3]),
      .done(done_ver_4),
      .xpos(xpos_barrel_4_v),
      .ypos(ypos_barrel_4_v)
   );

   ver_barrel u_ver_barrel_5_v (
      .clk(clk65MHz),
      .rst(rst),
      .xpos_kong,
      .xpos_donkey,
      .ypos_donkey,
      .hit(hit_10),
      .barrel(barrel_ver[4]),
      .done(done_ver_5),
      .xpos(xpos_barrel_5_v),
      .ypos(ypos_barrel_5_v)
   );

   barrel_ctl #(
      .BARRELS(5),
      .DELAY_TIME(162_500_000)
   ) u_barrel_ctl_hor (
      .clk(clk65MHz),
      .rst(rst),
      .start_game,
      .animation,
      .key(up_uart),
      .done({done_5, done_4, done_3, done_2, done_1}),
      .barrel(barrel_hor)
   );
   
   barrel_ctl #(
      .BARRELS(5), 
      .DELAY_TIME(20_500_000)
   ) u_barrel_ctl_ver (
      .clk(clk65MHz),
      .rst(rst),
      .start_game,
      .animation,
      .key(down_uart),
      .done({done_ver_5, done_ver_4, done_ver_3, done_ver_2, done_ver_1}),
      .barrel(barrel_ver)
   );

   /**
    * Kong - player 2
    */

   kong_movement u_kong_movement (
      .clk(clk65MHz),
      .rst,
      .start_game,
      .animation,
      .left(left_uart),
      .right(right_uart),
      .xpos(xpos_kong),
      .ypos(ypos_kong)
   );

   draw_character #(
      .CHARACTER_HEIGHT(64),
      .CHARACTER_WIDTH(64)
   ) u_draw_character_kong (
      .clk(clk65MHz),
      .rst,
      .rotate('0),
      .start_game,
      .is_on_ladder('0),
      .rgb_pixel_back('0),
      .pixel_addr(pixel_addr_kong),
      .rgb_pixel(rgb_pixel_kong),
      .xpos(xpos_kong),
      .ypos(ypos_kong),
      .en(!animation),

      .in(draw_barrel_if),
      .out(draw_kong_if)
   );
   
   image_rom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Kong.dat")
   
   ) u_image_rom_kong_2 (
      .clk(clk65MHz),
      .address(pixel_addr_kong),
      .rgb(rgb_pixel_kong)
   );

   /**
    * Donkey - player 1
    */

   donkey_movement u_donkey_movement (
      .clk(clk65MHz),
      .rst(rst),
      .xpos(xpos_donkey),
      .ypos(ypos_donkey),
      .hit({hit_10, hit_9, hit_8, hit_7, hit_6, hit_5, hit_4, hit_3, hit_2, hit_1}),
      .start_game,
      .animation,
      .is_on_ladder(is_on_ladder_donkey),
      .left,
      .right,
      .jump,
      .down,
      .up
   );

    draw_character #(
      .CHARACTER_HEIGHT(64),
      .CHARACTER_WIDTH(48)
   ) u_draw_character_donkey (
      .clk(clk65MHz),
      .rst,
      .rotate,
      .start_game,
      .is_on_ladder(is_on_ladder_donkey),
      .pixel_addr(pixel_addr_donkey),
      .rgb_pixel(rgb_pixel_donkey),
      .rgb_pixel_back(rgb_pixel_donkey_back),
      .xpos(xpos_donkey),
      .ypos(ypos_donkey),
      .en(!animation),

      .in(draw_kong_if),
      .out(draw_donkey_if)
   );
   
   image_rom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Donkey_v1.dat")
   
   ) u_image_rom_donkey (
      .clk(clk65MHz),
      
      .address(pixel_addr_donkey),
      .rgb(rgb_pixel_donkey)
   );

   image_rom  #(
      .BITS(12),
      .PIXELS(4096),
      .ROM_FILE("../../rtl/ROM/Barrel.dat")
   
   ) u_image_rom_donkey_back (
      .clk(clk65MHz),
      
      .address(pixel_addr_donkey),
      .rgb(rgb_pixel_donkey_back)
   );
endmodule