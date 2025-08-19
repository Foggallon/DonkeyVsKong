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
    output logic done,
    output logic [10:0] xpos,
    output logic [10:0] ypos
);

import kong_pkg::*;

typedef enum logic [0:0] {
    ST_IDLE,
    ST_FALL_DOWN
} STATE_T;

STATE_T state, state_nxt;

logic done_nxt;
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
    end else begin
        state <= state_nxt;
        done <= done_nxt;
        mov_counter <= mov_counter_nxt;
        velocity <= velocity_nxt;
        xpos <= xpos_nxt;
        ypos <= ypos_nxt;
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
            if(ypos == 736) begin
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
            xpos_nxt = xpos_kong + 12;
            ypos_nxt = KONG_PLATFORM_YPOS + 64;
            mov_counter_nxt = '0;
            velocity_nxt = '0;
        end

        ST_FALL_DOWN: begin
            xpos_nxt = xpos;
            if (mov_counter == JUMP_TAKI_W_MIARE) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity + 1;
                if (ypos + velocity >= 736) begin
                    ypos_nxt = 736;
                    done_nxt = '1;
                end else begin
                    ypos_nxt = ypos + velocity;
                    done_nxt = '0;
                end
            end else begin
                mov_counter_nxt = mov_counter +1;
                velocity_nxt = velocity;
                ypos_nxt = ypos;
                done_nxt = '0;
            end
        end

        default: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            mov_counter_nxt = '0;
            velocity_nxt = '0;
            done_nxt = '0;
        end
    endcase
end
endmodule