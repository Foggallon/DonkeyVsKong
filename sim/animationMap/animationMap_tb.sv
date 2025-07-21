/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for map generated for animation at the start of the game
 */

 module animationMap_tb;

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
    vga_if ladder_if();
    vga_if dut_if();

    logic clk, rst;
    logic [3:0] r, g, b;
    logic [11:0] rgb_pixel, rgb_pixel_3;
    logic [10:0] pixel_addr;
    logic [9:0] pixel_addr_3;
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

    vgaTiming u_vgaTiming (
        .clk,
        .rst,
        .out(vga_timing_if)

    );

    animationLadder u_animationLadder (
        .clk,
        .rst,
        .pixel_addr(pixel_addr_3),
        .rgb_pixel(rgb_pixel_3),
        .start_game('1),
        .en('1),
        .in(vga_timing_if),
        .out(ladder_if)
    );

    imageRom  #(
        .BITS(10),
        .PIXELS(1028),
        .ROM_FILE("../../rtl/LevelElements/drabinka.dat")
   ) u_imageRom_3 (
      .clk,
      
      .address(pixel_addr_3),
      .rgb(rgb_pixel_3)

   );

    animationPlatform dut (
        .clk,
        .rst,
        .pixel_addr(pixel_addr),
        .rgb_pixel(rgb_pixel),
        .start_game('1),
        .ramp_en(4'b0000),
        .in(ladder_if),
        .out(dut_if)
    );

    imageRom  #(
        .BITS(11),
        .PIXELS(2052),
        .ROM_FILE("../../rtl/LevelElements/platforma.dat")
   ) u_imageRom_2 (
      .clk,
      
      .address(pixel_addr),
      .rgb(rgb_pixel)
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