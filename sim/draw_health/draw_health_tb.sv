/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * Testbench for draw_health module.
 */

module draw_health_tb;

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
    vga_if draw_menu_if();
    vga_if dut_if();

    logic clk, rst;
    logic [3:0] r, g, b;
    logic [11:0] rgb_pixel_health, rgb_pixel_shield;
    logic [11:0] pixel_addr_health, pixel_addr_shield;
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

    vga_timing u_vgaTiming (
        .clk,
        .rst,
        .out(vga_timing_if)

    );

    draw_health #(
      .XPOS(800),
      .YPOS(16)
   )
   u_draw_health (
      .clk,
      .rst,
      .game_en('1),
      .en('1),
      .health_en('1),
      .rgb_pixel(rgb_pixel_health),
      .is_shielded('1),
      .pixel_addr(pixel_addr_health),
      .pixel_addr_shield(pixel_addr_shield),
      .rgb_pixel_shield(rgb_pixel_shield),
      
      .in(vga_timing_if),
      .out(dut_if)
   );

   image_rom  #(
        .BITS(12),
        .PIXELS(4096),
        .ROM_FILE("../../rtl/ROM/Donkey_v1.dat")
   ) u_imageRom (
      .clk,
      .address(pixel_addr_health),
      .rgb(rgb_pixel_health)
   );
   image_rom  #(
        .BITS(12),
        .PIXELS(4096),
        .ROM_FILE("../../rtl/ROM/Umbrella.dat")
   ) u_imageRomShield (
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