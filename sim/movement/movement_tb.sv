/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for movement module.
 */

 module movement_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     *  Local parameters
     */

    localparam real CLK_PERIOD = 15.38461538;     // 65 MHz

    /**
     * Local variables and signals
     */

    logic clk, rst, jump, left, right;
    wire  [10:0] xpos, ypos;
    

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end

    /**
     * Submodules instances
     */

    donkey_movement dut (
        .clk,
        .rst,

        .jump,
        .left,
        .right,
        .game_en('1),
        .animation('0),
        .down('0),
        .up('0),
        .donkey_hit('0),
        .is_on_ladder(),

        .xpos,
        .ypos
    );

    movement_prog u_movement_prog (
        .clk,
        .rst,

        .jump,
        .left,
        .right
    );

endmodule