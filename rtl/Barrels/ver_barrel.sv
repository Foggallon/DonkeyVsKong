/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Jakub Bukowski
 *
 * Description:
 * Module for barrels falling straight down.
 */

module ver_barrel(
    input logic clk,
    input logic rst,
    input logic barrel,
    input logic [10:0] xpos_kong,
    input logic [10:0] ypos_donkey,
    input logic [10:0] xpos_donkey,
    output logic done,
    output logic barrel_hit,
    output logic [10:0] xpos,
    output logic [10:0] ypos
);

import kong_pkg::*;
import barrel_pkg::*;
import platform_pkg::*;
import vga_pkg::*;

typedef enum logic [0:0] {
    ST_IDLE,
    ST_FALL_DOWN
} STATE_T;

STATE_T state, state_nxt;

localparam DONKEY_WIDTH = 48;

logic done_nxt, barrel_hit_nxt;
logic [10:0] xpos_nxt, ypos_nxt;
logic [20:0] mov_counter, mov_counter_nxt;
logic [10:0] velocity, velocity_nxt;

always_ff @(posedge clk) begin : state_seq_blk
    if (rst) begin
        state <= ST_IDLE;
        done <= '0;
        mov_counter <= '0;
        velocity <= '0;
        xpos <= '0;
        ypos <= '0;
        barrel_hit <= '0;
    end else begin
        state <= state_nxt;
        done <= done_nxt;
        mov_counter <= mov_counter_nxt;
        velocity <= velocity_nxt;
        xpos <= xpos_nxt;
        ypos <= ypos_nxt;
        barrel_hit <= barrel_hit_nxt;
    end
end

always_comb begin : state_comb_blk
    case (state)
        ST_IDLE: begin
            if (barrel) begin
                state_nxt = ST_FALL_DOWN;
            end else begin
                state_nxt = ST_IDLE;
            end
        end

        ST_FALL_DOWN: begin
            if(ypos == (VER_PIXELS - PLATFORM_HEIGHT) || barrel_hit) begin
                state_nxt = ST_IDLE;
            end else begin
                state_nxt = ST_FALL_DOWN;
            end
        end

        default: begin
            state_nxt = ST_IDLE;
        end

    endcase
end

always_comb begin : out_comb_blk
    case (state)
        ST_IDLE: begin
            done_nxt = '0;
            barrel_hit_nxt = '0;
            xpos_nxt = xpos_kong + 12;
            ypos_nxt = KONG_PLATFORM_YPOS + CHARACTER_HEIGHT;
            mov_counter_nxt = '0;
            velocity_nxt = '0;
        end

        ST_FALL_DOWN: begin
            xpos_nxt = xpos;
            if ((xpos + (BARREL_WIDTH - HIT_OFFSET) >= xpos_donkey) && (xpos <= xpos_donkey + (DONKEY_WIDTH - HIT_OFFSET)) && 
                (ypos + BARREL_HEIGHT >= ypos_donkey) && (ypos <= ypos_donkey + BARREL_HEIGHT) && (!barrel_hit)) begin
                done_nxt = '1;
                barrel_hit_nxt = '1;
            end else begin
                done_nxt = (ypos + velocity >= VER_PIXELS - PLATFORM_HEIGHT) ? '1 : '0 ;
                barrel_hit_nxt = '0;
            end
            if (mov_counter == JUMP_TAKI_W_MIARE) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity + 1;
                if (ypos + velocity >= VER_PIXELS - PLATFORM_HEIGHT) begin
                    ypos_nxt = VER_PIXELS - PLATFORM_HEIGHT;
                end else begin
                    ypos_nxt = ypos + velocity;
                end
            end else begin
                mov_counter_nxt = mov_counter + 1;
                velocity_nxt = velocity;
                ypos_nxt = ypos;
            end
        end

        default: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            mov_counter_nxt = '0;
            velocity_nxt = '0;
            done_nxt = '0;
            barrel_hit_nxt = '0;
        end
    endcase
end
endmodule