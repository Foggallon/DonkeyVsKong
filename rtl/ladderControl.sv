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
    output logic [1:0]  ramp,
    output logic [11:0] limit_ypos_min,
    output logic [11:0] limit_ypos_max,
    output logic        end_of_ramp,
    output logic [11:0] landing_ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import mapPkg::*;
    import vgaPkg::*;
    import characterPkg::*;

    /**
     * Local variables and signals
     */

    logic ladder_nxt, end_of_ramp_nxt;
    logic [11:0] limit_ypos_min_nxt, limit_ypos_max_nxt, landing_ypos_nxt;
    logic [1:0] ramp_nxt;

    always_ff @(posedge clk) begin
        ladder <= rst ? '0 : ladder_nxt;
        limit_ypos_min <= rst ? '0 : limit_ypos_min_nxt;
        limit_ypos_max <= rst ? '0 : limit_ypos_max_nxt;
        ramp <= rst ? '0 : ramp_nxt;
        end_of_ramp <= rst ? '0 : end_of_ramp_nxt;
        landing_ypos <= rst ? '0 : landing_ypos_nxt;
    end

    always_comb begin 
        if ((ypos >= LADDER_1_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_1_VSTOP) && 
            (xpos >= LADDER_1_HSTART - 16) && (xpos <= LADDER_1_HSTOP - 16)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_1_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_1_VSTOP - 64;
        end else if ((ypos >= LADDER_2_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_2_VSTOP) && 
                     (xpos >= LADDER_2_HSTART- 16) && (xpos <= LADDER_2_HSTOP - 16)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_2_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_2_VSTOP - 64;
        end else if ((ypos >= LADDER_3_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_3_VSTOP) && 
                     (xpos >= LADDER_3_HSTART - 16) && (xpos <= LADDER_3_HSTOP - 16)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_3_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_3_VSTOP - 64;
        end else if ((ypos >= LADDER_4_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_4_VSTOP) && 
                     (xpos >= LADDER_4_HSTART - 16) && (xpos <= LADDER_4_HSTOP - 16)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_4_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_4_VSTOP - 64;
        end else if ((ypos >= LADDER_5_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_5_VSTOP) && 
                     (xpos >= LADDER_5_HSTART - 16) && (xpos <= LADDER_5_HSTOP - 16)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_5_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_5_VSTOP - 96;
        end else begin
            ladder_nxt = '0;
            limit_ypos_min_nxt = limit_ypos_min;
            limit_ypos_max_nxt = limit_ypos_max;
        end
    end

    always_comb begin
        if ((ypos >= VER_PIXELS - 128 - 58) && (ypos <= VER_PIXELS - 96) &&
            (xpos >= HOR_PIXELS/2 - 64) && (xpos <= HOR_PIXELS)) begin
            ramp_nxt = 2'b01;
        end else if ((ypos >= 450 - 156 - 58) && (ypos <= 450 - 96) && 
                     (xpos >= 128) && (xpos <= HOR_PIXELS)) begin
            ramp_nxt = 2'b01;
        end else if ((ypos >= 475 - 58) && (ypos <= 623 - 64) && 
                     (xpos >= 0) && (xpos <= HOR_PIXELS - 192)) begin
            ramp_nxt = 2'b10;
        end else if ((ypos >= 175 - 58) && (ypos <= 191) && 
                     (xpos >= HOR_PIXELS - 320) && (xpos <= HOR_PIXELS - 192)) begin
            ramp_nxt = 2'b10;
        end else begin
            ramp_nxt = '0;
        end
    end
    
    always_comb begin
        if ((ypos >= 619 - 96 - 58) && (ypos <= 623 - 92) &&
            (xpos >= HOR_PIXELS - 128)) begin
            end_of_ramp_nxt = '1;
            landing_ypos_nxt = VER_PIXELS - 124;
        end else if ((ypos >= 350 - 58) && (ypos <= 354) &&
                     (xpos <= 128 - 48)) begin
            end_of_ramp_nxt = '1;
            landing_ypos_nxt = 543 - 64;
        end else if ((ypos >= 187 - 58) && (ypos <= 191) &&
                     (xpos >= HOR_PIXELS - 128)) begin
            end_of_ramp_nxt = '1;
            landing_ypos_nxt = 366 - 64;
        end else if ((ypos >= 64 - 58) && (ypos <= 68) &&
                     (xpos >= 576)) begin
            end_of_ramp_nxt = '1;
            landing_ypos_nxt = 239 - 64;
        end else begin
            end_of_ramp_nxt = '0;
            landing_ypos_nxt = landing_ypos;
        end
    end

endmodule
