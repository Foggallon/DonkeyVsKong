/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 * Modified: Dawid Bodzek
 *
 * Description: Module for Kong movement control
 * 
 */

module kong_movement (
    input  logic        clk,
    input  logic        rst,
    input  logic        left,
    input  logic        right,
    input  logic        game_en,
    input  logic        animation,
    output logic [10:0] xpos,
    output logic [10:0] ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import kong_pkg::*;
    import vga_pkg::*;
    import platform_pkg::*;

    /**
     * Local variables and signals
     */

    localparam KONG_XPOS_LIMIT = 640;

    logic [20:0] mov_counter, mov_counter_nxt;
    logic [10:0] xpos_nxt, ypos_nxt;

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_GO_LEFT,
        ST_GO_RIGHT
    } STATE_T;

    STATE_T state, state_nxt;

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
            xpos <= KONG_PLATFORM_XPOS;
            ypos <= KONG_PLATFORM_YPOS;
            mov_counter <= '0;
        end else begin
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            mov_counter <= mov_counter_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_IDLE: begin
                if (left && game_en && !animation) begin
                    state_nxt = ST_GO_LEFT;
                end else if (right && game_en && !animation) begin
                    state_nxt = ST_GO_RIGHT;
                end else begin
                    state_nxt = ST_IDLE;
                end
            end

            ST_GO_LEFT: begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_LEFT);
            end

            ST_GO_RIGHT: begin
                state_nxt = (mov_counter == MOVE_TAKI_NIE_MACQUEEN ? ST_IDLE : ST_GO_RIGHT);
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
            end

            ST_GO_LEFT: begin
                ypos_nxt = ypos;
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
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN) begin
                    mov_counter_nxt = '0;
                    xpos_nxt = ((xpos + CHARACTER_WIDTH) == KONG_XPOS_LIMIT ? xpos : (xpos + 1));
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    xpos_nxt = xpos;
                end
            end

            default: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                mov_counter_nxt = mov_counter;
            end
        endcase
    end

endmodule