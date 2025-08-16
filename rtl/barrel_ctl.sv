/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module horizontal barrel movement
 */

module barrel_ctl #(parameter
    DELAY_TIME = 162_500_000,
    BARRELS = 5         // Max barrels count = 7
    )(
    input  logic               clk,
    input  logic               rst,
    input  logic               start_game,
    input  logic               animation,
    input  logic               key,
    input  logic [BARRELS-1:0] done,
    output logic [BARRELS-1:0] barrel
);

    typedef enum logic [0:0] {
        ST_IDLE = 1'b0,
        ST_DELAY = 1'b1
    } STATE_T;

    STATE_T state, state_nxt;

    logic [2:0] barrel_counter, barrel_counter_nxt;
    logic [BARRELS-1:0] barrel_nxt, done_prev, done_prev_nxt;
    logic [28:0] delay_counter, delay_counter_nxt;

    always_ff @(posedge clk) begin : state_seq_blk
        if (rst) begin
            state <= ST_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            barrel <= '0;
            delay_counter <= '0;
            barrel_counter <= '0;
            done_prev <= '0;
        end else begin
            barrel <= barrel_nxt;
            delay_counter <= delay_counter_nxt;
            barrel_counter <= barrel_counter_nxt;
            done_prev <= done_prev_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state) 
            ST_IDLE: begin
                if (key && start_game && !animation) begin
                    state_nxt = ST_DELAY;
                end else begin
                    state_nxt = ST_IDLE;
                end
            end

            ST_DELAY: begin
                state_nxt = delay_counter == DELAY_TIME ? ST_IDLE : ST_DELAY;
            end

            default: begin
                state_nxt = ST_IDLE;
            end
        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_IDLE: begin
                done_prev_nxt = done;
                delay_counter_nxt = '0;
                if (key && (barrel_counter < BARRELS)) begin
                    barrel_nxt = (barrel ^ done) | (1'b1 << barrel_counter);
                    barrel_counter_nxt = (barrel_counter == BARRELS - 1) || (barrel == '1) ? (barrel_counter % (BARRELS - 1)) : barrel_counter + 1;
                end else if (done != '0 && (done != done_prev)) begin
                    barrel_nxt = (barrel ^ done);
                    barrel_counter_nxt = barrel_counter % (BARRELS - 1);
                end else begin
                    barrel_nxt = barrel;
                    barrel_counter_nxt = barrel_counter;
                end
            end

            ST_DELAY: begin
                done_prev_nxt = done;
                delay_counter_nxt = ((delay_counter == DELAY_TIME) ? '0 : delay_counter + 1);
                if (done != '0 && (done != done_prev)) begin
                    barrel_counter_nxt = barrel_counter % (BARRELS - 1);
                    barrel_nxt = (barrel ^ done);
                end else begin
                    barrel_counter_nxt = barrel_counter;
                    barrel_nxt = barrel;
                end
            end

            default: begin
                barrel_nxt = barrel;
                barrel_counter_nxt = barrel_counter;
                delay_counter_nxt = delay_counter;
                done_prev_nxt = done;
            end
        endcase
    end

endmodule 