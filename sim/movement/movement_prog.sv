/**
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Main test for movement module.
 */

 module movement_prog (
    input logic clk,
    input logic rst,
    input logic [11:0] xpos,
    input logic [11:0] ypos,
  
    output logic [6:0]  keyCode,
    output logic [15:0] released
  );
  
    timeunit 1ns;
    timeprecision 1ps;
  
    /**
     * Local parameters
     */
  
  
    /**
     * Local variables and signals
     */
  
    /**
     * Main Test
     */
  
    initial begin
      @(posedge rst);
      @(negedge rst);
      @(posedge clk);
      keyCode = '0;
      released = '0;
  
      #20_000_000;
      keyCode = 'h32;

      repeat (5) #500_000_000;

      // End the simulation.
      $display("Simulation is over, check the waveforms.");
      $finish;
      end
      
  
   endmodule