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
    input logic released,

    input logic [6:0] keyCode,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);

//local variables
logic [11:0] xpos_nxt;
localparam logic [11:0]INITIAL_XPOS = 40;
localparam logic [11:0]INITIAL_YPOS = 100;
logic [11:0] xposOld = INITIAL_XPOS;
int speedLimiter = 0;


always_ff @(posedge clk) begin
    if(rst) begin
        xpos <= '0;
        ypos <= '0;
    end
    else begin
        xpos <= xpos_nxt;
        ypos <= INITIAL_YPOS;
    end
end


always_comb begin
    if(keyCode == 'h64 || keyCode == 'h44)begin
        speedLimiter += 1;
        if ((speedLimiter%10) == 0) begin
            xpos_nxt = xposOld + 1;
            xposOld = xpos_nxt;
        end
        else begin
            xpos_nxt = xposOld;
        end
    end
    else if(keyCode == 'h41 || keyCode == 'h61) begin
        speedLimiter += 1;
        if((speedLimiter%10) == 0) begin
            xpos_nxt = xposOld - 1;
            xposOld = xpos_nxt;
        end
        else begin
            xpos_nxt = xposOld;
        end
    end
    else begin
        speedLimiter = 0;
    end
end

endmodule
