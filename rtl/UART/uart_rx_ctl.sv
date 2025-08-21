/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * This module implements a simple UART receive controller that reads two consecutive 8-bit values from a UART interface,
 * combines them into a single 16-bit word, and signals when the data is valid.
 */

module uart_rx_ctl (
    input  logic        clk,
    input  logic        rst,
    input  logic        rx_empty,   // RX FIFO empty flag.
    input  logic [7:0]  r_data,     // 8-bit data read from the UART FIFO.
    output logic        rd_uart,    // Signal to read next 8-bit data from FIFO.
    output logic        uart_en,    // Signal when the data is valid.
    output logic [15:0] uart_data   // Output combining two received UART bytes {MSB, LSB}.
);

    

    /**
     * Local variables and signals
     */

    typedef enum logic [0:0] {ST_READ_MSB, ST_READ_LSB} STATE_T;
    STATE_T state, state_nxt;

    logic rd_uart_nxt, uart_en_nxt;
    logic [7:0] msb, msb_nxt;
    logic [15:0] uart_data_nxt;

    always_ff @(posedge clk) begin : state_seg_blk
        if (rst) begin
            state <= ST_READ_MSB;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            uart_data <= 0;
            rd_uart <= '0;
            uart_en <= '0;
            msb <= 0;
        end else begin
            uart_data <= uart_data_nxt;
            rd_uart <= rd_uart_nxt;
            uart_en <= uart_en_nxt;
            msb <= msb_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_READ_MSB: begin
                state_nxt = (!rx_empty && !rd_uart) ? ST_READ_LSB : ST_READ_MSB;
            end

            ST_READ_LSB: begin
                state_nxt = (!rx_empty && !rd_uart) ? ST_READ_MSB : ST_READ_LSB;
            end

            default: begin
                state_nxt = ST_READ_MSB;
            end
        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_READ_MSB: begin
                if (!rx_empty && !rd_uart) begin
                    msb_nxt = r_data;
                    uart_data_nxt = '0;
                    rd_uart_nxt = '1;
                    uart_en_nxt = '0;
                end else begin
                    msb_nxt = msb;
                    uart_data_nxt = uart_data;
                    uart_en_nxt = '0;
                    rd_uart_nxt = '0;
                end
            end

            ST_READ_LSB: begin
                if (!rx_empty && !rd_uart) begin
                    uart_data_nxt = {msb, r_data};
                    msb_nxt = msb;
                    rd_uart_nxt = '1;
                    uart_en_nxt = '1;
                end else begin
                    msb_nxt = msb;
                    uart_data_nxt = uart_data;
                    rd_uart_nxt = '0;
                    uart_en_nxt = '0;
                end
            end

            default: begin
                msb_nxt = msb;
                uart_data_nxt = uart_data;
                rd_uart_nxt = '0;
                uart_en_nxt = '0;
            end
        endcase
    end

endmodule