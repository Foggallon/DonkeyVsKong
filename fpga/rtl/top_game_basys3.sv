/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_game_basys3 (
    input  wire clk,
    input  wire btnC,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire JA1,

    inout wire PS2Clk,
    inout wire PS2Data
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

     wire pclk;
     wire pclk_mirror;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)

    /**
     * Signals assignments
     */

    assign JA1 = pclk_mirror;

    /**
     * FPGA submodules placement
     */

    clk_wiz_65 u_clk_wiz_65 (
        .clk,
        .clk65MHz(pclk),
        .locked()
    );

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR pclk_oddr (
        .Q(pclk_mirror),
        .C(pclk),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );

    /**
     *  Project functional top module
     */

    top_game u_top_game (
        .clk65MHz(pclk),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync)
    );

endmodule