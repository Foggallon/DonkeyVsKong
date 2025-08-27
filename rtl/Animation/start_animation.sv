/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * The main module responsible for animation, resets the animation signal 
 * and sets the ctl signal, which controls the deactivation of horizontal platforms and the activation of inclined ones.
 * Increments counter signal every 32 pixels to reduce the displayed image by one ladder in animation_ladder module.
 */

module start_animation (
    input  logic        clk,
    input  logic        rst,
    input  logic        start_game,
    output logic        animation, // The signal remains at 1 while the animation is in progress, 
                                   // and switches to 0 once the animation has completed.
    output logic [10:0] xpos,
    output logic [10:0] ypos,
    output logic [3:0]  counter,
    output logic [3:0]  ctl,
    output logic        is_on_ladder
);

    import kong_pkg::*;
    import ladder_pkg::*;

    typedef enum logic [2:0] {
        ST_LADDER,
        ST_JUMP,
        ST_FALL_DOWN,
        ST_IDLE
    } STATE_T;

    STATE_T state, state_nxt;

    logic [2:0] jump_ctl, jump_ctl_nxt;
    logic [3:0] counter_nxt, ctl_nxt;
    logic animation_nxt, is_on_ladder_nxt;
    logic [20:0] mov_counter, mov_counter_nxt;
    logic [10:0] xpos_nxt, ypos_nxt, velocity, velocity_nxt;

    localparam JUMPS = 4;
    localparam LADDER_ANIMATION_START = 576;

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : state_seg_blk
        if (rst) begin
            state <= ST_LADDER;
        end else begin
            state <= state_nxt;
        end
    end

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            xpos <= KONG_ANIMATION_INITIAL_XPOS;
            ypos <= KONG_ANIMATION_INITIAL_YPOS;
            mov_counter <= '0;
            velocity <= '0;
            animation <= '1;
            counter <= '0;
            ctl <= '0;
            jump_ctl <= '0;
            is_on_ladder <= '0;
        end else begin
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            mov_counter <= mov_counter_nxt;
            velocity <= velocity_nxt;
            animation <= animation_nxt;
            counter <= counter_nxt;
            ctl <= ctl_nxt;
            jump_ctl <= jump_ctl_nxt;
            is_on_ladder <= is_on_ladder_nxt;
        end
    end

    always_comb begin : state_comb_blk
        case (state)
            ST_LADDER: begin
                state_nxt = ((ypos <= KONG_PLATFORM_YPOS) ? ST_JUMP : ST_LADDER);
            end

            ST_JUMP: begin
                state_nxt = (ypos <= (KONG_PLATFORM_YPOS - KONG_JUMP_HEIGHT) ? ST_FALL_DOWN : ST_JUMP);
            end

            ST_FALL_DOWN: begin
                state_nxt = ((ypos >= KONG_PLATFORM_YPOS) ? ST_IDLE : ST_FALL_DOWN);
            end

            ST_IDLE: begin
                state_nxt = ((jump_ctl == JUMPS) ? ST_IDLE : ST_JUMP);
            end

            default: begin
                state_nxt = ST_IDLE;
            end
        endcase
    end

    always_comb begin : out_comb_blk
        case (state)
            ST_LADDER: begin
                animation_nxt = animation;
                xpos_nxt = xpos;
                velocity_nxt = velocity;
                jump_ctl_nxt = jump_ctl;
                ctl_nxt = ctl;
                is_on_ladder_nxt =  start_game ? '1 : '0;
                if (mov_counter == MOVE_TAKI_NIE_MACQUEEN && start_game) begin
                    mov_counter_nxt = '0;
                    ypos_nxt = ((ypos <= KONG_PLATFORM_YPOS) ? ypos : ypos - 1);
                    if (ypos <= LADDER_ANIMATION_START && ypos % LADDER_HEIGHT == 0) begin
                        counter_nxt = counter < 16 ? counter + 1 : counter;     // increment every 32 pixels (ladder height)
                    end else begin
                        counter_nxt = counter;
                    end
                end else begin
                    mov_counter_nxt = mov_counter + 1;
                    ypos_nxt = ypos;
                    counter_nxt = counter;
                end
            end

            ST_JUMP: begin
                animation_nxt = animation;
                is_on_ladder_nxt = '0;
                counter_nxt = counter;
                ctl_nxt = ctl;
                jump_ctl_nxt = jump_ctl;
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin  // move left when jumping
                    xpos_nxt = xpos - 1;
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin    // change ypos
                    mov_counter_nxt = '0;
                    xpos_nxt = xpos;
                    if (ypos - velocity <= KONG_PLATFORM_YPOS - KONG_JUMP_HEIGHT) begin
                        ypos_nxt = (KONG_PLATFORM_YPOS - KONG_JUMP_HEIGHT);
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
                counter_nxt = counter;
                animation_nxt = animation;
                is_on_ladder_nxt = '0;
                if (mov_counter % (2 * MOVE_TAKI_NIE_MACQUEEN) == 0) begin  // move left when falling down
                    xpos_nxt = xpos - 1;
                    mov_counter_nxt = mov_counter + 1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    ctl_nxt = ctl;
                    jump_ctl_nxt = jump_ctl;
                end else if (mov_counter == JUMP_TAKI_W_MIARE) begin    // update ypos
                    mov_counter_nxt = '0;
                    velocity_nxt = velocity +1;
                    xpos_nxt = xpos;
                    if (ypos + velocity >= KONG_PLATFORM_YPOS) begin   // when on kong platform
                        ypos_nxt = KONG_PLATFORM_YPOS;
                        ctl_nxt = (ctl | (1'b1 << jump_ctl));   // the bit is set upon landing
                        jump_ctl_nxt = jump_ctl + 1;
                    end else begin
                        ypos_nxt = ypos + velocity;
                        ctl_nxt = ctl;
                        jump_ctl_nxt = jump_ctl;
                    end
                end else begin
                    mov_counter_nxt = mov_counter +1;
                    velocity_nxt = velocity;
                    ypos_nxt = ypos;
                    ctl_nxt = ctl;
                    jump_ctl_nxt = jump_ctl;
                    xpos_nxt = xpos;
                end
            end

            ST_IDLE: begin
                xpos_nxt = xpos;
                ypos_nxt = ypos;
                animation_nxt = ((jump_ctl == JUMPS) ? '0 : animation);
                mov_counter_nxt = '0;
                velocity_nxt = '0;
                counter_nxt = counter;
                ctl_nxt = ctl;
                jump_ctl_nxt = jump_ctl;
                is_on_ladder_nxt = '0;
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
                is_on_ladder_nxt = '0;
            end
        endcase
    end

endmodule