/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * 
 * Author: Jakub Bukowski && Dawid Bodzek
 * 
 * Description:
 * Key decoder for keyboard
 */

module keyDecoder(
    input logic clk,
    input logic rst,

    input logic [31:0] keyCode,

    output logic left,
    output logic right,
    output logic jump,
    output logic rotate,
    output logic up,
    output logic down,
    output logic start_game // temporary
);

import keyboardPkg::*;

logic left_nxt, right_nxt, jump_nxt, rotate_nxt, down_nxt, up_nxt;
logic start_game_nxt; // temporary

always_ff @(posedge clk) begin
    if (rst) begin
       left <= '0;
       right <= '0;
       jump <= '0; 
       rotate <= '0;
       start_game <= '0; // temp
       up <= '0;
       down <= '0;
    end else begin
        left <= left_nxt;
        right <= right_nxt;
        jump <= jump_nxt;
        rotate <= rotate_nxt;
        start_game <= start_game_nxt; // temp
        up <= up_nxt;
        down <= down_nxt;
    end
end

always_comb begin

    left_nxt = '0;
    right_nxt = '0;
    jump_nxt = '0;
    start_game_nxt = start_game; // temp
    up_nxt = '0;
    down_nxt = '0;

    if (keyCode[15:0] == A & keyCode[31:16] != RELEASED) begin
        left_nxt = '1;
        rotate_nxt = '1;
    end else if (keyCode[15:0] == D & keyCode[31:16] != RELEASED) begin
        right_nxt = '1;
        rotate_nxt = '0;
    end else if (keyCode[15:0] == SPACE & keyCode[31:16] != RELEASED) begin
        jump_nxt = '1;
        rotate_nxt = rotate;
    end else if (keyCode[15:0] == A & keyCode[31:16] != RELEASED) 
        rotate_nxt = '1;
    else if (keyCode[15:0] == W & keyCode[31:16] != RELEASED) begin
        up_nxt = '1;
        rotate_nxt = rotate;
    end else if (keyCode[15:0] == S & keyCode[31:16] != RELEASED) begin
        down_nxt = '1;
        rotate_nxt = rotate;
    
    // temp
    end else if (keyCode[15:0] == ENTER & keyCode[31:16] != RELEASED) begin
        start_game_nxt = '1;
        rotate_nxt = rotate;
    end else begin
        left_nxt = '0;
        right_nxt = '0;
        jump_nxt = '0;
        rotate_nxt = rotate;
        start_game_nxt = start_game; // temp
    end

end

endmodule
