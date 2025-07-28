/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * Interface for input and output signals of the VGA module.
 */

interface vga_if();

    timeunit 1ns;
    timeprecision 1ps;

    logic [10:0] vcount, hcount;
    logic vsync, hsync;
    logic vblnk, hblnk;
    logic [11:0] rgb;

    modport in(
        input vcount,
        input hcount,
        input vsync,
        input hsync,
        input vblnk,
        input hblnk,
        input rgb
    );

    modport out(
        output vcount,
        output hcount,
        output vsync,
        output hsync,
        output vblnk,
        output hblnk,
        output rgb
    );

endinterface