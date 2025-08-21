/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * This module implements a UART transmit controller that sends a 16-bit word over an 8-bit UART interface
 * in two consecutive transfers.
 */

module uart_tx_ctl (
    input  logic        clk,
    input  logic        rst,
    input  logic        oflag,      // New keycode available.
    input  logic        tx_full,    // UART transmit FIFO full.
    input  logic [15:0] keycode,    // 16-bit data word to be transmitted.
    output logic        wr_uart,    // Signal to write 8-bit data to FIFO.
    output logic [7:0]  w_data      // Data byte to be written into the UART FIFO {MSB, LSB}.
);

    timeunit 1ns;
    timeprecision 1ps;  

    /**
     * Local variables and signals
     */

    typedef enum logic [0:0] {ST_SEND_MSB, ST_SEND_LSB} STATE_T;
    STATE_T state, state_nxt;
    

    logic wr_uart_nxt;
    logic [7:0] w_data_nxt;
    logic [15:0] save_keycode, save_keycode_nxt;

    always_ff @(posedge clk) begin : state_seg_blk
        if (rst) begin
            state <= ST_SEND_MSB;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            wr_uart <= '0;
            w_data <= '0;
            save_keycode <= '0;
        end else begin
            wr_uart <= wr_uart_nxt;
            w_data <= w_data_nxt;
            save_keycode <= save_keycode_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_SEND_MSB: begin
                state_nxt = (oflag && !tx_full)  ? ST_SEND_LSB : ST_SEND_MSB;
            end

            ST_SEND_LSB: begin
                state_nxt = (!tx_full) ? ST_SEND_MSB : ST_SEND_LSB;
            end

            default: begin
                state_nxt = ST_SEND_MSB;
            end
        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_SEND_MSB: begin
                if (oflag && !tx_full) begin
                    save_keycode_nxt = keycode; // Save keycode when oflag was asserted nad FIFO is not full.
                    w_data_nxt  = keycode[15:8];
                    wr_uart_nxt = '1;
                end else begin
                    save_keycode_nxt = save_keycode;
                    w_data_nxt  = w_data;
                    wr_uart_nxt = '0;
                end
            end

            ST_SEND_LSB: begin
                if (!tx_full) begin
                    w_data_nxt  = save_keycode[7:0];
                    wr_uart_nxt = '1;
                    save_keycode_nxt = save_keycode;
                end else begin
                    w_data_nxt  = w_data;
                    wr_uart_nxt = '0;
                    save_keycode_nxt = save_keycode;
                end
            end

            default: begin
                w_data_nxt  = w_data;
                wr_uart_nxt = '0;
                save_keycode_nxt = keycode;
            end
        endcase
    end

endmodule