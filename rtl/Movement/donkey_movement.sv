/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 * Modified: Dawid Bodzek
 *
 * Description:
 * This module manages the movement of the character donkey.
 */

module donkey_movement (
    input  logic        clk,
    input  logic        rst,
    input  logic        left,
    input  logic        right,
    input  logic        jump,
    input  logic        start_game,
    input  logic        up,
    input  logic        down,
    input  logic  [9:0] hit,
    input  logic        animation,  // The signal remains at 1 while the animation is in progress, 
                                    // and switches to 0 once the animation has completed.
    output logic [10:0] xpos,
    output logic [10:0] ypos,
    output logic        is_on_ladder
);

    timeunit 1ns;
    timeprecision 1ps;

    import donkey_pkg::*;
    import vga_pkg::*;
    import ladder_pkg::*;
    import platform_pkg::*;

    /**
     * Local variables and signals
     */

    logic ladder, done, done_nxt, end_of_platform;
    logic [1:0] platform;
    logic [10:0] limit_ypos, limit_ypos_max, landing_ypos;
    logic [20:0] mov_counter, mov_counter_nxt;
    logic [10:0] xpos_nxt, ypos_nxt, save_ypos, save_ypos_nxt, velocity, velocity_nxt;

    typedef enum logic [3:0] {
        ST_IDLE,
        ST_IDLE_LADDER,
        ST_RESET,
        ST_GO_LEFT,
        ST_GO_RIGHT,
        ST_JUMP,
        ST_FALL_DOWN,
        ST_GO_UP,
        ST_GO_DOWN
    } STATE_T;

    STATE_T state, state_nxt;

    map_control u_map_control (
        .clk,
        .rst,
        .xpos,
        .ypos,
        .ladder(ladder),
        .platform(platform),
        .limit_ypos_min(limit_ypos),
        .limit_ypos_max(limit_ypos_max),
        .end_of_platform(end_of_platform),
        .landing_ypos(landing_ypos)
    );

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : state_seg_blk
        if (rst) begin
            state <= ST_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
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

    always_comb begin : state_comb_blk
        case (state)
            ST_IDLE: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else if (end_of_platform && !animation) begin
                    state_nxt = ST_FALL_DOWN;
                end else if (left && start_game && !animation) begin
                    state_nxt = ST_GO_LEFT;
                end else if (right && start_game && !animation) begin
                    state_nxt = ST_GO_RIGHT;
                end else if (jump && start_game && !animation) begin
                    state_nxt = ST_JUMP;
                end else if (up && start_game & ladder && !animation) begin
                    state_nxt = ST_GO_UP;
                end else if (down && start_game & ladder && !animation) begin
                    state_nxt = ST_GO_DOWN;
                end else begin
                    state_nxt = ST_IDLE;
                end
            end

            ST_IDLE_LADDER: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else if (done) begin
                    state_nxt = ST_IDLE;
                end else if (up) begin
                    state_nxt = ST_GO_UP;
                end else if (down) begin
                    state_nxt = ST_GO_DOWN;
                end else begin
                    state_nxt = ST_IDLE_LADDER;
                end
            end

            ST_GO_UP: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin
                    state_nxt = ((mov_counter == MOVE_TAKI_NIE_MACQUEEN) ? ST_IDLE_LADDER : ST_GO_UP);
                end
            end

            ST_GO_DOWN: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin 
                state_nxt = ((mov_counter == MOVE_TAKI_NIE_MACQUEEN) ? ST_IDLE_LADDER : ST_GO_DOWN);
                end
            end

            ST_GO_LEFT: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_LEFT);
                end
            end

            ST_GO_RIGHT: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_RIGHT);
                end
            end

            ST_JUMP: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin
                state_nxt = (ypos <= (save_ypos - DONKEY_JUMP_HEIGHT) ? ST_FALL_DOWN : ST_JUMP);
                end
            end

            ST_FALL_DOWN: begin
                if (hit) begin
                    state_nxt = ST_RESET;
                end else begin
                state_nxt = (ypos >= save_ypos ? ST_IDLE : ST_FALL_DOWN);
                end
            end

            ST_RESET: begin
                state_nxt = ST_IDLE;
            end

            default:
                state_nxt = ST_IDLE;

        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_IDLE: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                mov_counter_nxt = '0;
                save_ypos_nxt = (end_of_platform ? landing_ypos : ypos);
                velocity_nxt = (end_of_platform ? velocity : '0);
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
                    if ((platform == 2'b01) && ((xpos - 16) % PLATFORM_WIDTH == 0)) begin   // when on incline platform
                        ypos_nxt = ypos + PLATFORM_OFFSET;
                    end else if ((platform == 2'b10) && (xpos % PLATFORM_WIDTH == 0)) begin
                        ypos_nxt = ypos - PLATFORM_OFFSET;
                    end else begin
                        ypos_nxt = ypos;
                    end
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
                    if ((platform == 2'b01) && ((xpos + 52) % PLATFORM_WIDTH == 0)) begin   // when on incline platform
                        ypos_nxt = ypos - PLATFORM_OFFSET;
                    end else if ((platform == 2'b10) && (xpos % PLATFORM_WIDTH == 0)) begin
                        ypos_nxt = ypos + PLATFORM_OFFSET;
                    end else begin
                        ypos_nxt = ypos;
                    end
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    xpos_nxt = xpos;
                    ypos_nxt = ypos;
                end
            end

            ST_JUMP: begin
                save_ypos_nxt = save_ypos;
                done_nxt = done;
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin  // move left or right when jumping
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    if (left) begin    
                        xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos - 1));
                    end else if (right) begin
                        xpos_nxt = ((xpos + CHARACTER_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
                    end else begin
                        xpos_nxt = xpos;
                    end
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin    // update ypos
                    xpos_nxt = xpos;
                    mov_counter_nxt = '0;
                    if (ypos - velocity <= save_ypos - DONKEY_JUMP_HEIGHT) begin
                        ypos_nxt = (save_ypos - DONKEY_JUMP_HEIGHT);
                        velocity_nxt = '0;
                    end else begin
                        ypos_nxt = ypos - velocity;
                        velocity_nxt = velocity + 1;
                    end
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    xpos_nxt = xpos;
                end
            end

            ST_FALL_DOWN: begin
                done_nxt = done;    
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin      // move left or right when falling down
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    if (left) begin
                        xpos_nxt = ((xpos - 1) <= 0 ? xpos : (xpos - 1));
                            if ((platform == 2'b01) && ((xpos - 16) % PLATFORM_WIDTH == 0)) begin   // when on incline platform
                                save_ypos_nxt = save_ypos + PLATFORM_OFFSET;                        // update landing position
                            end else if ((platform == 2'b10) && (xpos % PLATFORM_WIDTH == 0)) begin
                                save_ypos_nxt = save_ypos - PLATFORM_OFFSET;
                            end else begin
                                save_ypos_nxt = save_ypos;
                            end
                    end else if (right) begin
                        xpos_nxt = ((xpos + CHARACTER_WIDTH) == HOR_PIXELS ? xpos : (xpos + 1));
                            if ((platform == 2'b01) && ((xpos + 52) % PLATFORM_WIDTH == 0)) begin   // when on incline platform
                                save_ypos_nxt = save_ypos - PLATFORM_OFFSET;                        // update landing position
                            end else if ((platform == 2'b10) && (xpos % PLATFORM_WIDTH == 0)) begin
                                save_ypos_nxt = save_ypos + PLATFORM_OFFSET;
                            end else begin
                                save_ypos_nxt = save_ypos;
                            end
                    end else begin
                        save_ypos_nxt = save_ypos;
                        xpos_nxt = xpos;
                    end
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin    // update ypos
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

            ST_GO_UP: begin     // only on ladders
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

            ST_GO_DOWN: begin   // only on ladders
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

            ST_RESET: begin
                xpos_nxt = DONKEY_INITIAL_XPOS;
                ypos_nxt = DONKEY_INITIAL_YPOS;
                mov_counter_nxt = mov_counter;
                save_ypos_nxt = save_ypos;
                velocity_nxt = velocity;
                done_nxt = done;
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

    always_comb begin : ladder_check_comb_blk
        if (start_game) begin
            is_on_ladder = '0;
            if ((ypos >= LADDER_1_VSTART) && (ypos <= LADDER_1_VSTOP) && 
                (xpos >= LADDER_1_HSTART) && (xpos < LADDER_1_HSTART + LADDER_WIDTH) && !animation) begin
                        is_on_ladder = '1;
            end else if ((ypos >= LADDER_2_VSTART) && (ypos <= LADDER_2_VSTOP) &&
                         (xpos >= LADDER_2_HSTART) && (xpos < LADDER_2_HSTART + LADDER_WIDTH) && !animation) begin
                        is_on_ladder = '1;
            end else if ((ypos >= LADDER_3_VSTART) && (ypos <= LADDER_3_VSTOP) &&
                         (xpos >= LADDER_3_HSTART) && (xpos < LADDER_3_HSTART + LADDER_WIDTH) && !animation) begin
                        is_on_ladder = '1;
            end else if ((ypos >= LADDER_4_VSTART) && (ypos <= LADDER_4_VSTOP) &&
                         (xpos >= LADDER_4_HSTART) && (xpos < LADDER_4_HSTART + LADDER_WIDTH) && !animation) begin
                        is_on_ladder = '1;
            end else begin
                is_on_ladder = '0;
            end
        end else begin
            is_on_ladder = '0;
        end
    end
endmodule