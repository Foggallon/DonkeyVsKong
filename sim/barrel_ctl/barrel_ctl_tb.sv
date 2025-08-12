/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Module vertical barrel movement
 */

module barrel_ctl_tb;

    timeunit 1ns;
    timeprecision 1ps;
    

    /**
     * Local parameters
     */

    localparam real CLK_PERIOD = 15.38461538;     // 65 MHz

    /**
     * Local variables and signals
     */

    logic clk, rst, key;
    logic [4:0] barrel, done;

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

    barrel_ctl #(.BARRELS(5)) dut (     // For use set delay_counter to 5
        .clk,
        .rst,
        .animation('0),
        .key(key),
        .start_game('1),
        .barrel(barrel),
        .done(done)
    );    

    /**
     * Main Test
     */
  
    initial begin
        @(posedge rst);
        @(negedge rst);
        @(posedge clk);
        done = '0;
        key = '1;

        #10_000;
        done = 5'b0_0001;
        @(posedge clk) begin
        done = '0;
        end

        #10_000;
        done = 5'b0_0010;
        @(posedge clk) begin
        done = '0;
        end

        #10_000;
        done = 5'b0_0100;
        @(posedge clk) begin
        done = '0;
        end

        #200
        // End the simulation.
        $display("Simulation is over, check the waveforms.");
        $finish;
    end

endmodule