/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for contoling movement with ladders on the map
 */

module ladderControl (
    input logic         clk,
    input logic         rst,
    input logic  [11:0] xpos,
    input logic  [11:0] ypos,
    output logic        ladder,
    output logic [11:0] limit_ypos_min,
    output logic [11:0] limit_ypos_max
);

    timeunit 1ns;
    timeprecision 1ps;

    import mapPkg::*;
    import characterPkg::*;

    /**
     * Local variables and signals
     */

    logic ladder_nxt;
    logic [11:0] limit_ypos_min_nxt, limit_ypos_max_nxt;

    always_ff @(posedge clk) begin
        ladder <= rst ? '0 : ladder_nxt;
        limit_ypos_min <= rst ? '0 : limit_ypos_min_nxt;
        limit_ypos_max <= rst ? '0 : limit_ypos_max_nxt;
    end

    always_comb begin 
        if ((ypos >= LADDER_1_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_1_VSTOP) && 
            (xpos >= LADDER_1_HSTART) && (xpos < LADDER_1_HSTOP)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_1_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_1_VSTOP - 96;
        end else if ((ypos >= LADDER_2_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_2_VSTOP) && 
                     (xpos >= LADDER_2_HSTART) && (xpos < LADDER_2_HSTOP)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_2_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_2_VSTOP - 96;
        end else if ((ypos >= LADDER_3_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_3_VSTOP) && 
                     (xpos >= LADDER_3_HSTART) && (xpos < LADDER_3_HSTOP)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_3_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_3_VSTOP - 96;
        end else if ((ypos >= LADDER_4_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_4_VSTOP) && 
                     (xpos >= LADDER_4_HSTART) && (xpos < LADDER_4_HSTOP)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_4_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_4_VSTOP - 96;
        end else if ((ypos >= LADDER_5_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_5_VSTOP) && 
                     (xpos >= LADDER_5_HSTART) && (xpos < LADDER_5_HSTOP)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_5_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_5_VSTOP - 96;
        end else begin
            ladder_nxt = '0;
            limit_ypos_min_nxt = limit_ypos_min;
            limit_ypos_max_nxt = limit_ypos_max;
        end
    end

endmodule
