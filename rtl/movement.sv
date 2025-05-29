/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 * Modified: Dawid Bodzek
 *
 * Description:
 * 
 */

module movement(
    input logic clk,
    input logic rst,

    input logic left,
    input logic right,
    input logic jump,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);

import vga_pkg::*;
import keyboard_pkg::*;
import character_pkg::*;

/**
 * Local variables and signals
 */

logic [20:0] mov_counter, mov_counter_nxt;
logic [11:0] xpos_nxt, ypos_nxt, ypos_jump, ypos_jump_nxt, velocity, velocity_nxt;

typedef enum logic [3:0] {
    ST_IDLE,
    ST_GO_LEFT,
    ST_GO_RIGHT,
    ST_JUMP,
    ST_FALL_DOWN
} STATE_T;

STATE_T state, state_nxt;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin : state_register
    if (rst) begin
        state <= ST_IDLE;
    end else begin
        state <= state_nxt;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        xpos <= 1;
        ypos <= '0;
        mov_counter <= '0;
        ypos_jump <= '0;
        velocity <= '0;
    end else begin
        xpos <= xpos_nxt;
        ypos <= ypos_nxt;
        mov_counter <= mov_counter_nxt;
        ypos_jump <= ypos_jump_nxt;
        velocity <= velocity_nxt;
    end

end

always_comb begin : next_state_logic
    case (state)
        ST_IDLE: begin
            if (left)
                state_nxt = ST_GO_LEFT;
            else if (right)
                state_nxt = ST_GO_RIGHT;
            else if (jump)
                state_nxt = ST_JUMP;
            else
                state_nxt = ST_IDLE;
        end

        ST_GO_LEFT: begin
            state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_LEFT);
        end

        ST_GO_RIGHT: begin
            state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_RIGHT);
        end

        ST_JUMP: begin
            state_nxt = (ypos <= (ypos_jump - DONKEY_JUMP_HEIGHT) ? ST_FALL_DOWN : ST_JUMP);
        end

        ST_FALL_DOWN: begin
            state_nxt = (ypos >= ypos_jump ? ST_IDLE : ST_FALL_DOWN);
        end

        default:
            state_nxt = ST_IDLE;

    endcase
end

always_comb begin
    case (state)
        ST_IDLE: begin
            xpos_nxt = xpos;
            ypos_nxt = DONKEY_INITIAL_YPOS;
            mov_counter_nxt = '0;
            ypos_jump_nxt = DONKEY_INITIAL_YPOS;
            velocity_nxt = '0;
        end

        ST_GO_LEFT: begin
            ypos_nxt = ypos;
            velocity_nxt = velocity;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                mov_counter_nxt = '0;
                xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos -1));
            end else begin
                mov_counter_nxt = mov_counter + 1;
                xpos_nxt = xpos;
            end
        end

        ST_GO_RIGHT: begin
            ypos_nxt = ypos;
            velocity_nxt = velocity;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                mov_counter_nxt = '0;
                xpos_nxt = ((xpos + DONKEY_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
            end else begin
                mov_counter_nxt = mov_counter + 1;
                xpos_nxt = xpos;
            end
        end

        ST_JUMP: begin
            xpos_nxt = xpos;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == JUMP_TAKI_W_MIARE) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity +1;
                if (ypos - velocity <= ypos_jump - DONKEY_JUMP_HEIGHT) begin
                    ypos_nxt = (ypos_jump - DONKEY_JUMP_HEIGHT);
                    velocity_nxt = '0;
                end else
                    ypos_nxt = ypos - velocity;
            end else begin
                mov_counter_nxt = mov_counter + 1;
                velocity_nxt = velocity;
                ypos_nxt = ypos;
            end
        end

        ST_FALL_DOWN: begin
            xpos_nxt = xpos;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == JUMP_TAKI_W_MIARE) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity +1;
                ypos_nxt = ((ypos + velocity >= ypos_jump) ? ypos_jump : (ypos + velocity));
            end else begin
                mov_counter_nxt = mov_counter +1;
                velocity_nxt = velocity;
                ypos_nxt = ypos;
            end
        end

        default: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            mov_counter_nxt = mov_counter;
            ypos_jump_nxt = ypos_jump;
            velocity_nxt = velocity;
        end
    endcase
end

endmodule
