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

    localparam real CLK_PERIOD = 15.38461538;     // 65 MHz

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    vga_if vga_timing_tb();

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
        .out(vga_timing_tb)
    );

    /**
     * Tasks and functions
     */

    task check_vga_values();
        begin
           assert ((vga_timing_tb.hcount >= 0) && (vga_timing_tb.hcount <= HOR_TOTAL_TIME -1)) 
                else $error("hcout out of defined value range, hcount:%d at time:%t ps", vga_timing_tb.hcount, $realtime);

            assert ((vga_timing_tb.vcount >= 0) && (vga_timing_tb.vcount <= VER_TOTAL_TIME -1)) 
                else $error("vcout out of defined value range, vcount:%d at time:%t ps", vga_timing_tb.vcount, $realtime);
        end
    endtask

    task check_sync_signals();
        begin
            if ((vga_timing_tb.hcount >= HOR_SYNC_START) && (vga_timing_tb.hcount < HOR_SYNC_STOP))
                assert (vga_timing_tb.hsync) 
                    else $error("hsync was not asserted at time:%t ps", $realtime);
            else
                assert (!vga_timing_tb.hsync)
                    else $error("hsync was not deasserted at time:%t ps", $realtime);

            if ((vga_timing_tb.vcount == VER_SYNC_START) && (vga_timing_tb.hcount == '0))
                assert (vga_timing_tb.vsync)
                    else $error("vblnk was not asserted at time:%t ps", $realtime);
            
            if ((vga_timing_tb.vcount >= VER_SYNC_START) && (vga_timing_tb.vcount < VER_SYNC_STOP)) 
                assert (vga_timing_tb.vsync) 
                    else $error("vsync was not asserted at time:%t ps", $realtime);
            else
                assert (!vga_timing_tb.vsync)
                    else $error("vsync was not deasserted at time:%t ps", $realtime);
        end
    endtask

    task check_blnk_signals();
        begin
            if ((vga_timing_tb.hcount >= HOR_BLANK_START) && (vga_timing_tb.hcount <= HOR_TOTAL_TIME-1))
                assert (vga_timing_tb.hblnk) 
                    else $error("hblnk was not asserted at time:%t ps", $realtime);
            else
                assert (!vga_timing_tb.hblnk)
                    else $error("hblnk was not deasserted at time:%t ps", $realtime);

            if ((vga_timing_tb.vcount == VER_BLANK_START) && (vga_timing_tb.hcount == '0))
                assert (vga_timing_tb.vblnk)
                    else $error("vblnk was not asserted at time:%t ps", $realtime);

            if (vga_timing_tb.vcount >= VER_BLANK_START)
                assert (vga_timing_tb.vblnk) 
                    else $error("vblnk asserted at time:%t ps", $realtime);
            else
                assert (!vga_timing_tb.vblnk)
                    else $error("vblnk was not deasserted at time:%t ps", $realtime);
        end
    endtask

    /**
     * Assertions
     */

    property hcount_reset;
        @(posedge clk) (vga_timing_tb.hcount == HOR_TOTAL_TIME -1) |=> (vga_timing_tb.hcount == 0);
    endproperty

    property vcount_reset;
        @(posedge clk) ((vga_timing_tb.vcount == VER_TOTAL_TIME -1) && (vga_timing_tb.hcount == HOR_TOTAL_TIME -1)) |=> (vga_timing_tb.vcount == 0);
    endproperty

    assert property (hcount_reset) else $error("hcount did not reset to 0. hcount:%d at time:%t ps", vga_timing_tb.hcount, $realtime);
    assert property (vcount_reset) else $error("vcount did not reset to 0. vcount:%d at time:%t ps", vga_timing_tb.vcount, $realtime);
    
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

        wait (vga_timing_tb.vsync == 1'b0);
        @(negedge vga_timing_tb.vsync);
        @(negedge vga_timing_tb.vsync);

        $finish;
    end

endmodule