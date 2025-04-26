/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 25;     // 40 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


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
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .vcount,
        .vsync,
        .vblnk,
        .hcount,
        .hsync,
        .hblnk
    );

    /**
     * Tasks and functions
     */

    task check_vga_values();
        begin
           assert ((hcount >= 0) && (hcount <= HOR_TOTAL_TIME -1)) 
                else $error("hcout out of defined value range, hcount:%d at time:%t ps", hcount, $realtime);

            assert ((vcount >= 0) && (vcount <= VER_TOTAL_TIME -1)) 
                else $error("vcout out of defined value range, vcount:%d at time:%t ps", vcount, $realtime);
        end
    endtask

    task check_sync_signals();
        begin
            if ((hcount >= HOR_SYNC_START) && (hcount < HOR_SYNC_STOP))
                assert (hsync) 
                    else $error("hsync was not asserted at time:%t ps", $realtime);
            else
                assert (!hsync)
                    else $error("hsync was not deasserted at time:%t ps", $realtime);

            if ((vcount == VER_SYNC_START) && (hcount == '0))
                assert (vsync)
                    else $error("vblnk was not asserted at time:%t ps", $realtime);
            
            if ((vcount >= VER_SYNC_START) && (vcount < VER_SYNC_STOP)) 
                assert (vsync) 
                    else $error("vsync was not asserted at time:%t ps", $realtime);
            else
                assert (!vsync)
                    else $error("vsync was not deasserted at time:%t ps", $realtime);
        end
    endtask

    task check_blnk_signals();
        begin
            if ((hcount >= HOR_BLANK_START) && (hcount <= HOR_TOTAL_TIME-1))
                assert (hblnk) 
                    else $error("hblnk was not asserted at time:%t ps", $realtime);
            else
                assert (!hblnk)
                    else $error("hblnk was not deasserted at time:%t ps", $realtime);

            if ((vcount == VER_BLANK_START) && (hcount == '0))
                assert (vblnk)
                    else $error("vblnk was not asserted at time:%t ps", $realtime);

            if (vcount >= VER_BLANK_START)
                assert (vblnk) 
                    else $error("vblnk asserted at time:%t ps", $realtime);
            else
                assert (!vblnk)
                    else $error("vblnk was not deasserted at time:%t ps", $realtime);
        end
    endtask

    /**
     * Assertions
     */

    property hcount_reset;
        @(posedge clk) (hcount == HOR_TOTAL_TIME -1) |=> (hcount == 0);
    endproperty

    property vcount_reset;
        @(posedge clk) ((vcount == VER_TOTAL_TIME -1) && (hcount == HOR_TOTAL_TIME -1)) |=> (vcount == 0);
    endproperty

    assert property (hcount_reset) else $error("hcount did not reset to 0. hcount:%d at time:%t ps", hcount, $realtime);
    assert property (vcount_reset) else $error("vcount did not reset to 0. vcount:%d at time:%t ps", vcount, $realtime);
    
    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);
        @(posedge clk) begin
        check_vga_values();
        check_sync_signals();
        check_blnk_signals();
        end

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule