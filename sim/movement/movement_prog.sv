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
  
    output logic [6:0] keyCode
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
  
      #10_000_000;
      keyCode = 'h64;

      repeat (2) #500_000_000;

      keyCode = '0;

      repeat (2) #300_000_000;

      keyCode = 'h41;      

      repeat (2) #500_000_000;
  
      // End the simulation.
      $display("Simulation is over, check the waveforms.");
      $finish;
      end
      
  
   endmodule