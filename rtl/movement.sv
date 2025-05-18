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
    input logic [15:0] released,
    input logic [6:0]  keyCode,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);

/**
 * Local variables and signals
 */

logic [16:0] mov_counter, mov_counter_nxt;
logic [11:0] xpos_nxt, ypos_nxt;

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
    end else begin
        xpos <= xpos_nxt;
        ypos <= ypos_nxt;
        mov_counter <= mov_counter_nxt;
    end

end

always_comb begin : next_state_logic
    case (state)
        ST_IDLE: begin
            if ((keyCode == 'h41 || keyCode == 'h61) & (released != 16'hF041 || released != 16'hF061))
                state_nxt = ST_GO_LEFT;
            else if ((keyCode == 'h44 || keyCode == 'h64) & (released != 16'hF044 || released != 16'hF064))
                state_nxt = ST_GO_RIGHT;
            else if (keyCode == 'h20 & released != 16'hF020)
                state_nxt = ST_JUMP;
            else
                state_nxt = ST_IDLE;
        end

        ST_GO_LEFT: begin
            if (keyCode == 'h32)
                state_nxt = ST_JUMP;
            else if (released == 16'hF041 || released == 16'hF061)
                state_nxt = ST_IDLE;
            else
                state_nxt = ST_GO_LEFT;
        end

        ST_GO_RIGHT: begin
            if (keyCode == 'h32)
                state_nxt = ST_JUMP;
            else if (released == 16'hF044 || released == 16'hF064)
                state_nxt = ST_IDLE;
            else
                state_nxt = ST_GO_RIGHT;
        end

        ST_JUMP: begin

        end


        ST_FALL_DOWN: begin

        end

    endcase
end

always_comb begin
    case (state)
        ST_IDLE: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            mov_counter_nxt = '0;
        end

        ST_GO_LEFT: begin
            if (mov_counter == 80_000) begin
                mov_counter_nxt = '0;
                xpos_nxt = xpos -1;
            end else begin
                mov_counter_nxt = mov_counter +1;
                xpos_nxt = xpos;
            end
        end

        ST_GO_RIGHT: begin
            if (mov_counter == 80_000) begin
                mov_counter_nxt = '0;
                xpos_nxt = xpos +1;
            end else begin
                mov_counter_nxt = mov_counter +1;
                xpos_nxt = xpos;
            end
        end
    endcase
end

endmodule
