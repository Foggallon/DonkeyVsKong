/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * 
 */

module ver_barrel_dmg #(parameter 
    BARRELS = 5             // Max barrels count = 16
    )(
    input  logic                      clk,
    input  logic                      rst,
    input  logic        [BARRELS-1:0] barrel,
    input  logic                      xpos_donkey,
    input  logic                      ypos_donkey,
    input  logic  [BARRELS-1:0][10:0] xpos,
    input  logic  [BARRELS-1:0][10:0] ypos,
    output logic        [BARRELS-1:0] hit
);

    logic [BARRELS-1:0] hit_nxt;
    reg [3:0] i;

    always_ff @(posedge clk) begin : out_reg_blk
        if (rst) begin
            hit <= '0;
        end else begin
            hit <= hit_nxt;
        end
    end

    always_comb begin : out_comb_blk;
        for (i = 0; i < BARRELS; i++) begin
            if ((xpos[i] + 24 >= xpos_donkey) && (xpos[i] <= xpos_donkey + 40) && (ypos_donkey == ypos[i] + 64) && barrel[i]) begin
                hit_nxt[i] = '1;
            end else begin
                hit_nxt[i] = '0;
            end
        end
    end

endmodule