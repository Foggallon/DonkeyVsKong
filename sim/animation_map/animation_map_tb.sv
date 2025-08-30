/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for map generated for animation at the start of the game
 */

 module animation_map_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam real CLK_PERIOD = 15.38461538;     // 65 MHz

    /**
     * Local variables and signals
     */

    vga_if vga_timing_if();
    vga_if animation_platform_if();
    vga_if incline_platform_if();
    vga_if dut_if();
    vga_if animation_ladder_if();

    logic clk, rst;
    logic [3:0] r, g, b;
    logic [11:0] rgb_pixel, rgb_pixel_2, rgb_pixel_3, rgb_pixel_shield;
    logic [10:0] pixel_addr, pixel_addr_2;
    logic [9:0] pixel_addr_3;
    logic [11:0] pixel_addr_shield;
    assign {r,g,b} = dut_if.rgb;

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end

    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .out(vga_timing_if)

    );

    incline_platform u_incline_platform (
        .clk,
        .rst,
        .pixel_addr(pixel_addr_2),
        .rgb_pixel(rgb_pixel_2),
        .game_en('1),
        .ctl('1),
        .in(vga_timing_if),
        .out(incline_platform_if)
    );

    image_rom  #(
        .BITS(11),
        .PIXELS(2052),
        .ROM_FILE("../../rtl/ROM/platforma.dat")
   ) u_image_rom_2 (
      .clk,
      
      .address(pixel_addr_2),
      .rgb(rgb_pixel_2)
   );

    animation_platform u_animation_platform (
        .clk,
        .rst,
        .pixel_addr(pixel_addr),
        .rgb_pixel(rgb_pixel),
        .game_en('1),
        .ctl('1),
        .in(incline_platform_if),
        .out(animation_platform_if)
    );

    image_rom  #(
        .BITS(11),
        .PIXELS(2052),
        .ROM_FILE("../../rtl/ROM/platforma.dat")
   ) u_image_rom (
      .clk,
      
      .address(pixel_addr),
      .rgb(rgb_pixel)
   );

    animation_ladder dut (
        .clk,
        .rst,
        .pixel_addr(pixel_addr_3),
        .rgb_pixel(rgb_pixel_3),
        .game_en('1),
        .animation('1),
        .counter(4'b1010),
        .in(animation_platform_if),
        .out(animation_ladder_if)
    );

    image_rom  #(
        .BITS(10),
        .PIXELS(1028),
        .ROM_FILE("../../rtl/ROM/drabinka.dat")
   ) u_image_rom_3 (
      .clk,
      
      .address(pixel_addr_3),
      .rgb(rgb_pixel_3)
   );

   draw_shield #(
        .XPOS(380),
        .YPOS(64),
        .OFFSET(64)
    ) u_draw_shield (
        .clk,
        .rst,
        .start_game('1),
        .en('1),
        .rgb_pixel(rgb_pixel_shield),
        .pixel_addr(pixel_addr_shield),
        .was_shield_picked_up('0),
        
        .in(animation_ladder_if),
        .out(dut_if)
     );

    image_rom  #(
        .BITS(12),
        .PIXELS(4096),
        .ROM_FILE("../../rtl/ROM/Panienka.dat")
   ) u_image_rom_shield (
        .clk,
        
        .address(pixel_addr_shield),
        .rgb(rgb_pixel_shield)
   );
    tiff_writer #(
        .XDIM(16'd1344),
        .YDIM(16'd806),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk),
        .r({r,r}),
        .g({g,g}),
        .b({b,b}),
        .go(dut_if.vsync)
    );

    /**
     * Main test
     */

    initial begin
        rst = 1'b0;
        # 30 rst = 1'b1;
        # 30 rst = 1'b0;

        wait (dut_if.vsync == 1'b0);
        @(negedge dut_if.vsync) $display("Info: negedge VS at %t",$time);
        @(negedge dut_if.vsync) $display("Info: negedge VS at %t",$time);

        // End the simulation.
        $display("Simulation is over, check the tiff file.");
        $finish;
    end

endmodule