/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for drawMenu module.
 */

module draw_menu_tb;

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
    logic [11:0] rgb_pixel, rgb_pixel_ready;
    logic [13:0] pixel_addr, pixel_addr_ready;
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

    image_rom  #(
        .BITS(14),
        .PIXELS(12292),
        .ROM_FILE("../../rtl/ROM/Title_screen.dat")
   ) u_imageRom (
      .clk,
      
      .address(pixel_addr),
      .rgb(rgb_pixel)

   );

    draw_menu u_draw_menu (
        .clk,
        .rst,
        .rgb_pixel,
        .pixel_addr,
        .game_en('0),

        .in(vga_timing_if),
        .out(draw_menu_if)
    );

    draw_ready #(
        .XPOS(120),
        .YPOS(400)
    ) u_draw_ready (
        .clk,
        .rst,
        .game_en('0),
        .start(1'b1),
        .rgb_pixel(rgb_pixel_ready),
        .pixel_addr(pixel_addr_ready),

        .in(draw_menu_if),
        .out(dut_if)
    );

    image_rom  #(
        .BITS(14),
        .PIXELS(12292),
        .ROM_FILE("../../rtl/ROM/Ready.dat")
    ) u_imageRom2 (
        .clk,
        
        .address(pixel_addr_ready),
        .rgb(rgb_pixel_ready)

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