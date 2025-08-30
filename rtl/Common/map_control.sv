/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for controlling the movement of characters or barrels across the game map. 
 * It outputs signals enabling ladder climbing, falling from ramps, movement along inclined ramps, 
 * and landing positions from ramps.
 */

module map_control #(parameter
    CHARACTER_WIDTH = 64,
    CHARACTER_HEIGHT = 64
    )(
    input  logic        clk,
    input  logic        rst,
    input  logic [10:0] xpos,
    input  logic [10:0] ypos,
    output logic        ladder,
    output logic [1:0]  platform,       
    output logic [10:0] limit_ypos_min,
    output logic [10:0] limit_ypos_max,
    output logic        end_of_platform,
    output logic [10:0] landing_ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import ladder_pkg::*;
    import platform_pkg::*;

    /**
     * Local variables and signals
     */

    logic ladder_nxt, end_of_platform_nxt;
    logic [10:0] limit_ypos_min_nxt, limit_ypos_max_nxt, landing_ypos_nxt;
    logic [1:0] platform_nxt;

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            ladder <= '0;
            limit_ypos_min <= '0;
            limit_ypos_max <= '0;
            platform <= '0;
            end_of_platform <= '0;
            landing_ypos <= '0;
        end else begin
            ladder <= ladder_nxt;
            limit_ypos_min <= limit_ypos_min_nxt;
            limit_ypos_max <= limit_ypos_max_nxt;
            platform <= platform_nxt;
            end_of_platform <= end_of_platform_nxt;
            landing_ypos <= landing_ypos_nxt;
        end
    end

    always_comb begin : out_comb_ladder_blk
        if ((ypos >= LADDER_1_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_1_VSTOP) && 
            (xpos >= LADDER_1_HSTART - LADDER_OFFSET) && (xpos <= LADDER_1_HSTART + LADDER_WIDTH - LADDER_OFFSET)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_1_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_1_VSTOP - CHARACTER_HEIGHT;
        end else if ((ypos >= LADDER_2_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_2_VSTOP) && 
                     (xpos >= LADDER_2_HSTART- LADDER_OFFSET) && (xpos <= LADDER_2_HSTART + LADDER_WIDTH - LADDER_OFFSET)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_2_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_2_VSTOP - CHARACTER_HEIGHT;
        end else if ((ypos >= LADDER_3_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_3_VSTOP) && 
                     (xpos >= LADDER_3_HSTART - LADDER_OFFSET) && (xpos <= LADDER_3_HSTART + LADDER_WIDTH - LADDER_OFFSET)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_3_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_3_VSTOP - CHARACTER_HEIGHT;
        end else if ((ypos >= LADDER_4_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_4_VSTOP) && 
                     (xpos >= LADDER_4_HSTART - LADDER_OFFSET) && (xpos <= LADDER_4_HSTART + LADDER_WIDTH - LADDER_OFFSET)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_4_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_4_VSTOP - CHARACTER_HEIGHT;
        end else if ((ypos >= LADDER_5_VSTART - CHARACTER_HEIGHT) && (ypos <= LADDER_5_VSTOP) && 
                     (xpos >= LADDER_5_HSTART - LADDER_OFFSET) && (xpos <= LADDER_5_HSTART + LADDER_WIDTH - LADDER_OFFSET)) begin
            ladder_nxt = '1;
            limit_ypos_min_nxt = LADDER_5_VSTART - CHARACTER_HEIGHT;
            limit_ypos_max_nxt = LADDER_5_VSTOP - (CHARACTER_HEIGHT + PLATFORM_HEIGHT);
        end else begin
            ladder_nxt = '0;
            limit_ypos_min_nxt = limit_ypos_min;
            limit_ypos_max_nxt = limit_ypos_max;
        end
    end

    always_comb begin : out_comb_platform_blk
        if ((ypos >= VER_PIXELS - 2 * PLATFORM_WIDTH - (CHARACTER_HEIGHT - PLATFORM_OFFSET - 2)) && (ypos <= VER_PIXELS - (CHARACTER_HEIGHT + PLATFORM_HEIGHT)) &&
            (xpos >= HOR_PIXELS/2 - PLATFORM_WIDTH) && (xpos <= HOR_PIXELS)) begin
            platform_nxt = 2'b01;
        end else if ((ypos >= 294 - (CHARACTER_HEIGHT - PLATFORM_OFFSET - 2)) && (ypos <= 450 - (CHARACTER_HEIGHT + PLATFORM_HEIGHT)) && 
                     (xpos >= 2 * PLATFORM_WIDTH) && (xpos <= HOR_PIXELS)) begin
            platform_nxt = 2'b01;
        end else if ((ypos >= 475 - (CHARACTER_HEIGHT - PLATFORM_OFFSET - 2)) && (ypos <= 623 - CHARACTER_HEIGHT) && 
                     (xpos >= 0) && (xpos <= HOR_PIXELS - 3 * PLATFORM_WIDTH)) begin
            platform_nxt = 2'b10;
        end else if ((ypos >= 175 - (CHARACTER_HEIGHT - PLATFORM_OFFSET - 2)) && (ypos <= 255 - CHARACTER_HEIGHT) && 
                     (xpos >= HOR_PIXELS - 5 * PLATFORM_WIDTH) && (xpos <= HOR_PIXELS - 3 * PLATFORM_WIDTH)) begin
            platform_nxt = 2'b10;
        end else begin
            platform_nxt = '0;
        end
    end
    
    always_comb begin : out_comb_end_of_platform_blk
        if ((ypos >= EO_PLATFORM_1_VSTART - CHARACTER_HEIGHT) && (ypos <= EO_PLATFORM_1_VSTOP - CHARACTER_HEIGHT) &&
            (xpos >= HOR_PIXELS - (2 * PLATFORM_WIDTH))) begin
            end_of_platform_nxt = '1;
            landing_ypos_nxt = LANDING_POS_1 - CHARACTER_HEIGHT;
        end else if ((ypos >= EO_PLATFORM_2_VSTART - CHARACTER_HEIGHT) && (ypos <= EO_PLATFORM_2_VSTOP - CHARACTER_HEIGHT) &&
                     (xpos <= (2 * PLATFORM_WIDTH) - CHARACTER_WIDTH)) begin
            end_of_platform_nxt = '1;
            landing_ypos_nxt = LANDING_POS_2 - CHARACTER_HEIGHT;
        end else if ((ypos >= EO_PLATFORM_3_VSTART - CHARACTER_HEIGHT) && (ypos <= EO_PLATFORM_3_VSTOP - CHARACTER_HEIGHT) &&
                     (xpos >= HOR_PIXELS - (2 * PLATFORM_WIDTH))) begin
            end_of_platform_nxt = '1;
            landing_ypos_nxt = LANDING_POS_3 - CHARACTER_HEIGHT;
        end else if ((ypos >= EO_PLATFORM_4_VSTART - CHARACTER_HEIGHT) && (ypos <= EO_PLATFORM_4_VSTOP - CHARACTER_HEIGHT) &&
                     (xpos >= PLATFORM_3_HSTOP)) begin
            end_of_platform_nxt = '1;
            landing_ypos_nxt = LANDING_POS_4 - CHARACTER_HEIGHT;
        end else begin
            end_of_platform_nxt = '0;
            landing_ypos_nxt = landing_ypos;
        end
    end

endmodule