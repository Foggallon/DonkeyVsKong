/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * This module is responsible for detecting if the win condition for Donkey was achieved.
 */

 module touch_lady #(parameter
    XPOS_LADY = 300,
    YPOS_LADY = 200,
    OFFSET= 64
    ) 
    (
        input  logic        clk,
        input  logic        rst,
        input  logic        game_en,
        input  logic [10:0] xpos_donkey,
        input  logic [10:0] ypos_donkey,
        output logic        touch_lady
 );

 logic touch_lady_nxt;

 always_ff @(posedge clk) begin
    if (rst) begin
        touch_lady <= '0;
    end else begin
        touch_lady <= touch_lady_nxt;
    end
 end

 always_comb begin : shield_comb_blk
    if (rst) begin
        touch_lady_nxt = '0;
    end else begin
        if (game_en) begin
            if(xpos_donkey >= XPOS_LADY && xpos_donkey < XPOS_LADY + OFFSET 
                && ypos_donkey >= YPOS_LADY && ypos_donkey < YPOS_LADY + OFFSET) begin
                touch_lady_nxt = '1;
            end else begin
                touch_lady_nxt = '0;
            end
        end else begin
            touch_lady_nxt = touch_lady;
        end
    end
 end

 endmodule