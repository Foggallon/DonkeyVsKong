/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Main test for movement module.
 */

module movement_prog (
  input logic clk,
  input logic rst,

  output logic jump,
  output logic left,
  output logic right
    
  );
  
  timeunit 1ns;
  timeprecision 1ps;
  
    /**
     * Main Test
     */
  
    initial begin
      @(posedge rst);
      @(negedge rst);
      @(posedge clk);
      jump = '0;
      left = '0;
      right = '0;
  
      #20_000_000;
      jump = '1;

      repeat (2) #500_000_000;
      jump = '0;
      right = '1;
      repeat (2) #500_000_000;

      // End the simulation.
      $display("Simulation is over, check the waveforms.");
      $finish;
      end
      
  
   endmodule