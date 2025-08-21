/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Dawid Bodzek && Jakub Bukowski
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_game_basys3 (
    input  wire       clk,
    input  wire       btnC,
    input  wire       PS2Clk,
    input  wire       PS2Data,
    input  wire       JA1,
    output wire [1:1] JA,
    output wire       Vsync,
    output wire       Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    logic clk65MHz;

    /**
     * FPGA submodules placement
     */

    clk_wiz_65 u_clk_wiz_65 (
        .clk,
        .clk65MHz,
        .locked()
    );

    /**
     *  Project functional top module
     */

    top_game u_top_game (
        .clk65MHz,
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .rx(JA1),
        .tx(JA)
    );

endmodule