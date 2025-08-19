module char_rom (
    input logic clk,
    input logic rst,
    input logic [7:0] char_xy,

    output logic [6:0] char_code
);

localparam ROM_TEXT = ({"Ready                           "});

logic [255:0][7:0] rom = {<<8{ROM_TEXT}};
logic [6:0] char_code_nxt;
logic [4:0] char_xpos;
logic [2:0] char_ypos;

assign char_xpos = char_xy[7:3];
assign char_ypos = char_xy[2:0];

assign char_code_nxt = rom[char_xpos + char_ypos*32][6:0];

always_ff @(posedge clk) begin
    if(rst) begin
        char_code <= '0;
    end else begin
        char_code <= char_code_nxt[6:0];
    end
end

endmodule