/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Jakub Bukowski
 *
 * Description:
 * 
 */

module movement(
    input logic clk,
    input logic rst,
    input logic [6:0] keyCode,

    output logic [11:0] xpos
);

//local variables
logic [11:0] xpos_nxt;
logic [11:0] xposOld = INITIAL_XPOS;
localparam INITIAL_XPOS = 40;
//localparam INITIAL_YPOS = 0;
int speedLimiter = 0;


always_ff @(posedge clk) begin
    if(rst) begin
        xpos <= '0;
    end
    else begin
        xpos <= xpos_nxt;
    end
end

always_comb begin
    if(keyCode == 'h57 || keyCode == 'h77)begin
        speedLimiter += 1;
        if ((speedLimiter%10) == 0) begin
            xpos_nxt = xposOld + 1;
            xposOld = xpos_nxt;
        end
        else begin
            xpos_nxt = xposOld;
        end
    end
    else begin

    end
end

endmodule
