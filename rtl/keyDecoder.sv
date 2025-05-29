/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * 
 * Author: Jakub Bukowski && Dawid Bodzek
 * 
 * Description:
 * The project top module.
 *
 */
module keyDecoder(
    input logic clk,
    input logic rst,

    input logic [31:0] keyCode,

    output logic left,
    output logic right,
    output logic jump,
    output logic [15:0]previous
);

import keyboard_pkg::*;

logic left_nxt, right_nxt, jump_nxt, previous_nxt;

always_ff @(posedge clk) begin
    if (rst) begin
       left <= '0;
       right <= '0;
       jump <= '0; 
       previous <= '0;
    end else begin
        left <= left_nxt;
        right <= right_nxt;
        jump <= jump_nxt;
        previous <= previous_nxt;
    end
end

always_comb begin
    if (keyCode[15:0] == A & keyCode[31:16] != RELEASED) begin
        left_nxt = '1;
        previous_nxt = keyCode[31:16];
        right_nxt = '0;
        jump_nxt = '0;
    end else if (keyCode[15:0] == D & keyCode[31:16] != RELEASED) begin
        right_nxt = '1;
        previous_nxt = keyCode[31:16];
        left_nxt = '0;
        jump_nxt = '0;
    end else if (keyCode[15:0] == SPACE & keyCode[31:16] != RELEASED) begin
        jump_nxt = '1;
        previous_nxt = keyCode[31:16];
        left_nxt = '0;
        right_nxt = '0;
    end else begin
        left_nxt = '0;
        right_nxt = '0;
        jump_nxt = '0;
        previous_nxt = '0;
    end

    //previous_nxt = keyCode[15:0] == A ? '1 : '0;

end

endmodule
