/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for contoling movement with sloped ramps on the map
 */

module rampControl (
    input logic         clk,
    input logic         rst,
    input logic  [11:0] xpos,
    input logic  [11:0] ypos,
    output logic [11:0] ramp_start,
    output logic        ramp
);

    timeunit 1ns;
    timeprecision 1ps;

    import mapPkg::*;
    import vgaPkg::*;
    import characterPkg::*;

    /**
     * Local variables and signals
     */

    logic ramp_nxt;
    logic [11:0] ramp_start_nxt;

    always_ff @(posedge clk) begin
        ramp <= rst ? '0 : ramp_nxt;
        ramp_start <= rst ? '0 : ramp_start_nxt;
    end

    always_comb begin
        if ((ypos >= VER_PIXELS - 94) && (ypos <= VER_PIXELS - 126) && 
            (xpos >= HOR_PIXELS/2) && (xpos <= HOR_PIXELS)) begin
            ramp_nxt = '1;
            ramp_start_nxt = HOR_PIXELS/2;
        end else begin
            ramp_nxt = '0;
            ramp_start_nxt = ramp_start;
        end
    end

endmodule