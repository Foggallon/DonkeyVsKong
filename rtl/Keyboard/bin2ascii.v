`timescale 1ns / 1ps
/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek & Jakub Bukowski
 *
 * Description:
 * Module for converting binary numbers to ASCII code
 * Source:
 * https://digilent.com/reference/programmable-logic/basys-3/demos/keyboard
 */


module bin2ascii(
    input [15:0] I,
    output reg [31:0] O
    );
    genvar i;
    generate for (i=0; i< 4; i=i+1)
        always@(I)
        if (I[4*i+3:4*i] >= 4'h0 && I[4*i+3:4*i] <= 4'h9)
            O[8*i+7:8*i] = 8'd48 + I[4*i+3:4*i];
        else
            O[8*i+7:8*i] = 8'd55 + I[4*i+3:4*i];
    endgenerate
endmodule
