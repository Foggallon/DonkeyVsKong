module image_rom (
    input logic clk,
    input logic [11:0] address,
    output logic [11:0] rgb
);

reg [11:0] rom [0:4095];

initial $redmemh("../../rtl/MainMenu/DonkeyVsKong.dat",rom);

always_ff @(posedge clk) begin
    rgb <= rom[address];
end

endmodule