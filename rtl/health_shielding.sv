/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * This module is responsible for handling the state of the is_shielded signal.
 */

 module health_shielding #(parameter
    XPOS_SHIELD = 300,
    YPOS_SHIELD = 200,
    OFFSET= 64
    ) 
    (
        input  logic        clk,
        input  logic        rst,
        input  logic        start_game,
        input  logic [9:0]  hit,
        input  logic [10:0] xpos_donkey,
        input  logic [10:0] ypos_donkey,
        output logic        is_shielded
 );

 logic is_shielded_nxt;

 always_ff @(posedge clk) begin
    if (rst) begin
        is_shielded <= '0;
    end else begin
        is_shielded <= is_shielded_nxt;
    end
 end

 always_comb begin : shield_comb_blk
    if (rst) begin
        is_shielded_nxt = '0;
    end else begin
        if (start_game) begin
            if(xpos_donkey >= XPOS_SHIELD && xpos_donkey < XPOS_SHIELD + OFFSET 
                && ypos_donkey >= YPOS_SHIELD && ypos_donkey < YPOS_SHIELD + OFFSET) begin
                is_shielded_nxt = '1;
            end else if (hit) begin
                is_shielded_nxt = '0;
            end else begin
                is_shielded_nxt = is_shielded;
            end
        end else begin
            is_shielded_nxt = is_shielded;
        end
    end
 end

 endmodule