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
    //input logic [15:0] released,
    input logic [31:0]  keyCode,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);

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
        xpos <= '0;
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
            if (keyCode[15:0] == 'h3143)
                state_nxt = ST_GO_LEFT;
            else if (keyCode[15:0] == 'h3233)
                state_nxt = ST_GO_RIGHT;
            else if (keyCode[15:0] == 'h3239)
                state_nxt = ST_JUMP;
            else
                state_nxt = ST_IDLE;
        end

        ST_GO_LEFT: begin
            if (keyCode[15:0] == 'h3239)
                state_nxt = ST_JUMP;
            if (keyCode[31:16] == 'h4630)
                state_nxt = ST_IDLE;
            else
                state_nxt = ST_GO_LEFT;
        end

        ST_GO_RIGHT: begin
            if (keyCode[15:0] == 'h3239)
                state_nxt = ST_JUMP;
            if (keyCode[15:0] == 'h3143)
                state_nxt = ST_GO_LEFT;
            if (keyCode[31:16] == 'h4630)
                state_nxt = ST_IDLE;
            else
                state_nxt = ST_GO_RIGHT;
        end

        ST_JUMP: begin
            if (ypos <= ypos_jump - 58)
                state_nxt = ST_FALL_DOWN;
            else
                state_nxt = ST_JUMP;
        end

        ST_FALL_DOWN: begin
            if (ypos >= ypos_jump)
                state_nxt = ST_IDLE;
            else
                state_nxt = ST_FALL_DOWN;
        end

        default:
            state_nxt = ST_IDLE;

    endcase
end

always_comb begin
    case (state)
        ST_IDLE: begin
            xpos_nxt = xpos;
            ypos_nxt = 700;
            mov_counter_nxt = '0;
            ypos_jump_nxt = 700;
            velocity_nxt = '0;
        end

        ST_GO_LEFT: begin
            ypos_nxt = ypos;
            velocity_nxt = velocity;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == 80_000) begin
                mov_counter_nxt = '0;
                xpos_nxt = xpos -1;
            end else begin
                mov_counter_nxt = mov_counter +1;
                xpos_nxt = xpos;
            end
        end

        ST_GO_RIGHT: begin
            ypos_nxt = ypos;
            velocity_nxt = velocity;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == 80_000) begin
                mov_counter_nxt = '0;
                xpos_nxt = xpos +1;
            end else begin
                mov_counter_nxt = mov_counter +1;
                xpos_nxt = xpos;
            end
        end

        ST_JUMP: begin
            xpos_nxt = xpos;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == 1_400_000) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity +1;
                if (ypos - velocity <= ypos_jump -58) begin
                    ypos_nxt = (ypos_jump - 58);
                    velocity_nxt = '0;
                end else
                    ypos_nxt = ypos - velocity;
            end else begin
                mov_counter_nxt = mov_counter +1;
                velocity_nxt = velocity;
                ypos_nxt = ypos;
            end
        end

        ST_FALL_DOWN: begin
            xpos_nxt = xpos;
            ypos_jump_nxt = ypos_jump;
            if (mov_counter == 1_400_000) begin
                mov_counter_nxt = '0;
                velocity_nxt = velocity +1;
                if (ypos + velocity >= ypos_jump) 
                    ypos_nxt = ypos_jump;
                else
                    ypos_nxt = ypos + velocity;
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
