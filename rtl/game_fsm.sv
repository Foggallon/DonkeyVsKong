/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * FSM to control game
 */

module game_fsm (
    input  logic       clk,
    input  logic       rst,
    input  logic       start_game,
    input  logic       start_game_uart,
    input  logic       animation,
    input  logic       touch_lady,
    input  logic       is_shielded,
    input  logic [9:0] barrel_hit,
    output logic       game_en,
    output logic       donkey_hit,
    output logic [2:0] health_en
);

    typedef enum logic [2:0] {
        ST_WAIT_FOR_PLAYERS,
        ST_GAME,
        ST_DONKEY_WIN,
        ST_KONG_WIN
    } STATE_T;

    STATE_T state, state_nxt;

    logic game_en_nxt, donkey_hit_nxt;
    logic [2:0] health_counter, health_counter_nxt;
    logic [2:0] health_en_nxt;

    always_ff @(posedge clk) begin : state_seg_blk
        if (rst) begin
            state <= ST_WAIT_FOR_PLAYERS;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            game_en <= '0;
            health_en <= '0;
            health_counter <= '0;
            donkey_hit <= '0;
        end else begin
            game_en <= game_en_nxt;
            health_en <= health_en_nxt;
            health_counter <= health_counter_nxt;
            donkey_hit <= donkey_hit_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_WAIT_FOR_PLAYERS: begin
                state_nxt = (start_game && start_game_uart && !animation) ? ST_GAME : ST_WAIT_FOR_PLAYERS;
            end

            ST_GAME: begin
                if (touch_lady) begin
                    state_nxt = ST_DONKEY_WIN;
                end else if (health_en == '0) begin
                    state_nxt = ST_KONG_WIN;
                end else begin
                    state_nxt = ST_GAME;
                end
            end

            ST_DONKEY_WIN: begin
                state_nxt = ST_DONKEY_WIN;
            end

            ST_KONG_WIN: begin
                state_nxt = ST_KONG_WIN;
            end

            default: begin
                state_nxt = ST_WAIT_FOR_PLAYERS;
            end

        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_WAIT_FOR_PLAYERS: begin
                game_en_nxt = (start_game && start_game_uart) ? '1 : '0;
                health_en_nxt = (!animation) ? '1 : '0;
                health_counter_nxt = '0;
                donkey_hit_nxt = '0;
            end

            ST_GAME: begin
                game_en_nxt = game_en;
                if (barrel_hit) begin
                    health_counter_nxt = is_shielded ? health_counter : health_counter + 1;
                    health_en_nxt = is_shielded ? health_en : (health_en & ~(1'b1 << health_counter));
                    donkey_hit_nxt = is_shielded ? '0 : '1;
                end else begin
                    health_en_nxt = health_en;
                    health_counter_nxt = health_counter;
                    donkey_hit_nxt = '0;
                end
            end

            ST_DONKEY_WIN: begin
                game_en_nxt = game_en;
                health_en_nxt = health_en;
                health_counter_nxt = health_counter;
                donkey_hit_nxt = '0;
            end

            ST_KONG_WIN: begin
                game_en_nxt = game_en;
                health_en_nxt = health_en;
                health_counter_nxt = health_counter;
                donkey_hit_nxt = '0;
            end

            default: begin
                game_en_nxt = game_en;
                health_en_nxt = health_en;
                health_counter_nxt = health_counter;
                donkey_hit_nxt = '0;
            end

        endcase
    end

endmodule