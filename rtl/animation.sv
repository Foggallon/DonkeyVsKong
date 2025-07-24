/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * 
 */

 module animation (
    input logic         clk,
    input logic         rst,
    input logic         start_game,
    output logic        animation,
    output logic [11:0] xpos,
    output logic [11:0] ypos,
    output logic [3:0]  counter,
    output logic [3:0]  ctl
);

    import vgaPkg::*;
    import keyboardPkg::*;
    import characterPkg::*;
    import mapPkg::*;

    typedef enum logic [2:0] {
        ST_LADDER,
        ST_JUMP,
        ST_FALL_DOWN,
        ST_IDLE
    } STATE_T;

    STATE_T state, state_nxt;

    logic [2:0] jump_ctl, jump_ctl_nxt;
    logic [3:0] counter_nxt, ctl_nxt;
    logic animation_nxt;
    logic [20:0] mov_counter, mov_counter_nxt;
    logic [11:0] xpos_nxt, ypos_nxt, velocity, velocity_nxt;

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : state_register
        state <= rst ? ST_LADDER : state_nxt;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            xpos <= 484;
            ypos <= VER_PIXELS - 96;
            mov_counter <= '0;
            velocity <= '0;
            animation <= '1;
            counter <= '0;
            ctl <= '0;
            jump_ctl <= '0;
        end else begin
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            mov_counter <= mov_counter_nxt;
            velocity <= velocity_nxt;
            animation <= animation_nxt;
            counter <= counter_nxt;
            ctl <= ctl_nxt;
            jump_ctl <= jump_ctl_nxt;
        end
    end

    always_comb begin :next_state_logic
        case (state)
            ST_LADDER: begin
                state_nxt = ((ypos <= 175) ? ST_JUMP : ST_LADDER);
            end

            ST_JUMP: begin
                state_nxt = (ypos <= (175 - DONKEY_JUMP_HEIGHT) ? ST_FALL_DOWN : ST_JUMP);
            end

            ST_FALL_DOWN: begin
                state_nxt = ((ypos >= 175) ? ST_IDLE : ST_FALL_DOWN);
            end

            ST_IDLE: begin
                state_nxt = ((jump_ctl == 4) ? ST_IDLE : ST_JUMP);
            end

            default: begin
                state_nxt = ST_IDLE;
            end
        endcase
    end

    always_comb begin
        case (state)
            ST_LADDER: begin
                animation_nxt = animation;
                xpos_nxt = xpos;
                velocity_nxt = velocity;
                jump_ctl_nxt = jump_ctl;
                ctl_nxt = ctl;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN && start_game) begin
                    mov_counter_nxt = '0;
                    ypos_nxt = ((ypos <= 175) ? ypos : ypos - 1);
                    if (ypos <= 576 && ypos % 32 == 0)
                        counter_nxt = counter < 16 ? counter + 1 : counter;
                    else
                        counter_nxt = counter;
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    ypos_nxt = ypos;
                    counter_nxt = counter;
                end
            end

            ST_JUMP: begin
                animation_nxt = animation;
                xpos_nxt = xpos;
                counter_nxt = counter;
                ctl_nxt = ctl;
                jump_ctl_nxt = jump_ctl;
                if (mov_counter == JUMP_TAKI_W_MIARE) begin
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity +1;
                    if (ypos - velocity <= 175 - DONKEY_JUMP_HEIGHT) begin
                        ypos_nxt = (175 - DONKEY_JUMP_HEIGHT);
                        velocity_nxt = '0;
                    end else
                        ypos_nxt = ypos - velocity;
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                end
            end

            ST_FALL_DOWN: begin
                xpos_nxt = xpos;
                counter_nxt = counter;
                animation_nxt = animation;
                if (mov_counter == JUMP_TAKI_W_MIARE) begin
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity +1;
                    ypos_nxt = ((ypos + velocity >= 175) ? 175 : (ypos + velocity));
                    ctl_nxt = ((ypos + velocity >= 175) ? (ctl | (1 << jump_ctl)) : ctl);
                    jump_ctl_nxt = ((ypos + velocity >= 175) ? jump_ctl + 1 : jump_ctl);
                end else begin
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    ctl_nxt = ctl;
                    jump_ctl_nxt = jump_ctl;
                end
            end

            ST_IDLE: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                animation_nxt = ((jump_ctl == 4) ? '0 : animation);
                mov_counter_nxt = '0;
                velocity_nxt = '0;
                counter_nxt = counter;
                ctl_nxt = ctl;
                jump_ctl_nxt = jump_ctl;
            end

            default: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                animation_nxt = animation;
                mov_counter_nxt = '0;
                velocity_nxt = '0;
                counter_nxt = counter;
                ctl_nxt = ctl;
                jump_ctl_nxt = jump_ctl;
            end
        endcase
    end

endmodule