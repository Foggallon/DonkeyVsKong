/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module for horizontal barrel movement.
 */

module hor_barrel (
    input  logic        clk,
    input  logic        rst,
    input  logic        barrel,     // Enable movement of a barrel.
    input  logic [10:0] xpos_kong,  // Update starting xpos with kong position.
    input  logic [10:0] xpos_donkey,
    input  logic [10:0] ypos_donkey,
    output logic        hit,
    output logic        done,       // Set to 1 for one clock cycle when barrel stopped rolling.
    output logic [10:0] xpos,
    output logic [10:0] ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import donkey_pkg::*;
    import platform_pkg::*;

    logic done_nxt, end_of_platform, hit_nxt;
    logic [1:0] platform, fall_ctl, fall_ctl_nxt;
    logic [10:0] xpos_nxt, ypos_nxt, landing_ypos, velocity, velocity_nxt;
    logic [20:0] mov_counter, mov_counter_nxt;

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_GO_HOR,
        ST_FALL_DOWN
    } STATE_T;

    STATE_T state, state_nxt;

    map_control u_map_control (
        .clk,
        .rst,
        .xpos,
        .ypos,
        .ladder(),
        .platform(platform),
        .limit_ypos_min(),
        .limit_ypos_max(),
        .end_of_platform(end_of_platform),
        .landing_ypos(landing_ypos)
    );

    always_ff @(posedge clk) begin : state_seq_blk
        if (rst) begin
            state <= ST_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            done <= '0;
            xpos <= xpos_kong;
            ypos <= 175;
            fall_ctl <= '0;
            velocity <= '0;
            mov_counter <= '0;
            hit <= '0;
        end else begin
            done <= done_nxt;
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            fall_ctl <= fall_ctl_nxt;
            velocity <= velocity_nxt;
            mov_counter <= mov_counter_nxt;
            hit <= hit_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_IDLE : begin
                if (barrel && (fall_ctl == 0)) begin
                    state_nxt = ST_GO_HOR;
                end else begin
                    state_nxt = ST_IDLE;
                end
            end

            ST_GO_HOR: begin
                state_nxt = end_of_platform ? ST_FALL_DOWN : ST_GO_HOR;
            end

            ST_FALL_DOWN: begin
                if (ypos >= landing_ypos && fall_ctl != 3) begin
                    state_nxt = ST_GO_HOR;
                end else if (fall_ctl == 3) begin
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
                hit_nxt = '0;
                xpos_nxt = xpos_kong;
                ypos_nxt = 175;
                fall_ctl_nxt = '0;
                velocity_nxt = '0;
                mov_counter_nxt = '0;
            end

            ST_GO_HOR: begin
                velocity_nxt = '0;
                fall_ctl_nxt = fall_ctl;
                if ((platform == 2'b01) && (xpos_donkey + 48 >= xpos) && (ypos_donkey >= ypos) && (ypos_donkey <= ypos + 48)) begin
                    done_nxt = '1;
                    hit_nxt = '1;
                end else if ((platform == 2'b10) && (xpos_donkey <= xpos + 48) && (ypos_donkey >= ypos) && (ypos_donkey <= ypos + 48)) begin
                    done_nxt = '1;
                    hit_nxt = '1;
                end else begin
                    done_nxt = '0;
                    hit_nxt = '0;
                end
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    xpos_nxt = (platform == 2'b01 || (ypos <= 450 - 96 && ypos >= 292)) ? xpos - 1 : xpos + 1;
                    if ((platform == 2'b01) & ((xpos - 16) % PLATFORM_WIDTH == 0)) begin    // when on incline platform
                        ypos_nxt = ypos + PLATFORM_OFFSET;
                    end else if ((platform == 2'b10) & (xpos % PLATFORM_WIDTH == 0)) begin
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

            ST_FALL_DOWN: begin
                xpos_nxt = xpos;
                if ((xpos + 40 >= xpos_donkey) && (xpos <= xpos_donkey + 40) && (ypos_donkey >= ypos + 32) && (ypos + 64 <= ypos_donkey)) begin
                    done_nxt = '1;
                    hit_nxt = '1;
                end else begin
                    done_nxt = (fall_ctl == 3) ? '1 : done;
                    hit_nxt = '0;
                end
                if (mov_counter == JUMP_TAKI_W_MIARE) begin
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity + 1;
                    if (ypos + velocity >= landing_ypos) begin
                        ypos_nxt = landing_ypos;
                        fall_ctl_nxt = fall_ctl + 1;
                    end else begin
                        ypos_nxt = ypos + velocity;
                        fall_ctl_nxt = fall_ctl;
                    end
                end else begin
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    fall_ctl_nxt = fall_ctl;
                end
            end

            default: begin
                done_nxt = '0;
                hit_nxt = '0;
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                fall_ctl_nxt = '0;
                velocity_nxt = '0;
                mov_counter_nxt = '0;
            end
        endcase
    end

endmodule