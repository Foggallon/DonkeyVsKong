/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for draw_barrel module
 */

 module draw_barrel_tb;

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
    vga_if dut_if();

    logic clk, rst;
    logic [3:0] r, g, b;
    logic [11:0] rgb_pixel;
    logic [9:0] pixel_addr;
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

    draw_barrel #(.BARRELS(5)) dut (
        .clk,
        .rst,
        .game_en('1),
        .animation('0),
        .xpos({11'd100, 11'd400, 11'd300, 11'd700, 11'd900}),
        .ypos({11'd100, 11'd400, 11'd300, 11'd700, 11'd50}),
        .barrel('1),
        .pixel_addr(pixel_addr),
        .rgb_pixel(rgb_pixel),

        .in(vga_timing_if),
        .out(dut_if)
    );

    image_rom  #(
      .BITS(10),
      .PIXELS(1028),
      .ROM_FILE("../../rtl/ROM/Barrel.dat")
    ) u_image_rom_barrel (
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