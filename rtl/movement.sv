/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
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
    input logic start_game,
    input logic up,
    input logic down,
    input logic animation,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import vgaPkg::*;
    import keyboardPkg::*;
    import characterPkg::*;
    import mapPkg::*;

    /**
     * Local variables and signals
     */

    logic ladder, done, done_nxt, end_of_ramp;
    logic [1:0] ramp;
    logic [11:0] limit_ypos, limit_ypos_max, landing_ypos;
    logic [20:0] mov_counter, mov_counter_nxt;
    logic [11:0] xpos_nxt, ypos_nxt, save_ypos, save_ypos_nxt, velocity, velocity_nxt;

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_IDLE_LADDER,
        ST_GO_LEFT,
        ST_GO_RIGHT,
        ST_JUMP,
        ST_FALL_DOWN,
        ST_GO_UP,
        ST_GO_DOWN
    } STATE_T;

    STATE_T state, state_nxt;

    ladderControl u_ladderControl (
        .clk,
        .rst,
        .xpos,
        .ypos,
        .ladder(ladder),
        .ramp(ramp),
        .limit_ypos_min(limit_ypos),
        .limit_ypos_max(limit_ypos_max),
        .end_of_ramp(end_of_ramp),
        .landing_ypos(landing_ypos)
    );

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
            xpos <= DONKEY_INITIAL_XPOS;
            ypos <= DONKEY_INITIAL_YPOS;
            mov_counter <= '0;
            save_ypos <= '0;
            velocity <= '0;
            done <= '0;
        end else begin
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            mov_counter <= mov_counter_nxt;
            save_ypos <= save_ypos_nxt;
            velocity <= velocity_nxt;
            done <= done_nxt;
        end
    end

    always_comb begin : next_state_logic
        case (state)
            ST_IDLE: begin
                if (end_of_ramp & !animation)
                    state_nxt = ST_FALL_DOWN;
                else if (left & start_game & !animation)
                    state_nxt = ST_GO_LEFT;
                else if (right & start_game & !animation)
                    state_nxt = ST_GO_RIGHT;
                else if (jump & start_game & !animation)
                    state_nxt = ST_JUMP;
                else if (up & start_game & ladder & !animation)
                    state_nxt = ST_GO_UP;
                else if (down & start_game & ladder & !animation)
                    state_nxt = ST_GO_DOWN;
                else
                    state_nxt = ST_IDLE;
            end

            ST_IDLE_LADDER: begin
                if (done)
                    state_nxt = ST_IDLE;
                else if (up)
                    state_nxt = ST_GO_UP;
                else if (down)
                    state_nxt = ST_GO_DOWN;
                else
                    state_nxt = ST_IDLE_LADDER;
            end

            ST_GO_UP: begin
                state_nxt = ((mov_counter == MOVE_TAKI_NIE_MACQUEEN) ? ST_IDLE_LADDER : ST_GO_UP);
            end

            ST_GO_DOWN: begin
                state_nxt = ((mov_counter == MOVE_TAKI_NIE_MACQUEEN) ? ST_IDLE_LADDER : ST_GO_DOWN);
            end

            ST_GO_LEFT: begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_LEFT);
            end

            ST_GO_RIGHT: begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_RIGHT);
            end

            ST_JUMP: begin
                state_nxt = (ypos <= (save_ypos - DONKEY_JUMP_HEIGHT) ? ST_FALL_DOWN : ST_JUMP);
            end

            ST_FALL_DOWN: begin
                state_nxt = (ypos >= save_ypos ? ST_IDLE : ST_FALL_DOWN);
            end

            default:
                state_nxt = ST_IDLE;

        endcase
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                mov_counter_nxt = '0;
                save_ypos_nxt = (end_of_ramp ? landing_ypos : ypos);
                velocity_nxt = (end_of_ramp ? velocity : '0);
                done_nxt = '0;
            end

            ST_IDLE_LADDER: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                mov_counter_nxt = '0;
                save_ypos_nxt = save_ypos;
                velocity_nxt = '0;
                done_nxt = done;
            end

            ST_GO_LEFT: begin
                velocity_nxt = velocity;
                save_ypos_nxt = save_ypos;
                done_nxt = done;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos -1));
                    if ((ramp == 2'b01) & ((xpos - 16) % PLATFORM_WIDTH == 0))
                        ypos_nxt = ypos + PLATFORM_OFFSET;
                    else if ((ramp == 2'b10) & (xpos % PLATFORM_WIDTH == 0))
                        ypos_nxt = ypos - PLATFORM_OFFSET;
                    else
                        ypos_nxt = ypos;
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    xpos_nxt = xpos;
                    ypos_nxt = ypos;
                end
            end

            ST_GO_RIGHT: begin
                velocity_nxt = velocity;
                save_ypos_nxt = save_ypos;
                done_nxt = done;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    xpos_nxt = ((xpos + CHARACTER_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
                    if ((ramp == 2'b01) & ((xpos + 52) % PLATFORM_WIDTH == 0))
                        ypos_nxt = ypos - PLATFORM_OFFSET;
                    else if ((ramp == 2'b10) & (xpos % PLATFORM_WIDTH == 0))
                        ypos_nxt = ypos + PLATFORM_OFFSET;
                    else
                        ypos_nxt = ypos;
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    xpos_nxt = xpos;
                    ypos_nxt = ypos;
                end
            end

            ST_JUMP: begin
                save_ypos_nxt = save_ypos;
                done_nxt = done;
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    if (left)
                        xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos - 1));
                    else if (right)
                        xpos_nxt = ((xpos + CHARACTER_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
                    else
                        xpos_nxt = xpos;
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin
                    xpos_nxt = xpos;
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity +1;
                    if (ypos - velocity <= save_ypos - DONKEY_JUMP_HEIGHT) begin
                        ypos_nxt = (save_ypos - DONKEY_JUMP_HEIGHT);
                        velocity_nxt = '0;
                    end else
                        ypos_nxt = ypos - velocity;
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    xpos_nxt = xpos;
                end
            end

            ST_FALL_DOWN: begin
                done_nxt = done;
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    if (left) begin
                        xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos - 1));
                            if ((ramp == 2'b01) & ((xpos - 16) % PLATFORM_WIDTH == 0))
                                save_ypos_nxt = save_ypos + PLATFORM_OFFSET;
                            else if ((ramp == 2'b10) & (xpos % PLATFORM_WIDTH == 0))
                                save_ypos_nxt = save_ypos - PLATFORM_OFFSET;
                            else
                                save_ypos_nxt = save_ypos;
                    end else if (right) begin
                        xpos_nxt = ((xpos + CHARACTER_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
                            if ((ramp == 2'b01) & ((xpos + 52) % PLATFORM_WIDTH == 0))
                                save_ypos_nxt = save_ypos - PLATFORM_OFFSET;
                            else if ((ramp == 2'b10) & (xpos % PLATFORM_WIDTH == 0))
                                save_ypos_nxt = save_ypos + PLATFORM_OFFSET;
                            else
                                save_ypos_nxt = save_ypos;
                    end else begin
                        save_ypos_nxt = save_ypos;
                        xpos_nxt = xpos;
                    end
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin
                    save_ypos_nxt = save_ypos;
                    xpos_nxt = xpos;
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity +1;
                    ypos_nxt = ((ypos + velocity >= save_ypos) ? save_ypos : (ypos + velocity));
                end else begin
                    save_ypos_nxt = save_ypos;
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    xpos_nxt = xpos;
                end
            end

            ST_GO_UP: begin
                xpos_nxt = xpos;
                velocity_nxt = velocity;
                save_ypos_nxt = save_ypos;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    ypos_nxt = ((ypos <= limit_ypos) ? ypos : ypos - 1);
                    done_nxt = ((ypos <= limit_ypos) ? '1 : '0);
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    ypos_nxt = ypos;
                    done_nxt = done;
                end
            end

            ST_GO_DOWN: begin
                xpos_nxt = xpos;
                velocity_nxt = velocity;
                save_ypos_nxt = save_ypos;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    ypos_nxt = ((ypos >= limit_ypos_max) ? ypos : ypos + 1);
                    done_nxt = ((ypos >= limit_ypos_max) ? '1 : '0);
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    ypos_nxt = ypos;
                    done_nxt = done;
                end
            end

            default: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                mov_counter_nxt = mov_counter;
                save_ypos_nxt = save_ypos;
                velocity_nxt = velocity;
                done_nxt = done;
            end
        endcase
    end

endmodule
