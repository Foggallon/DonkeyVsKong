/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 * Modified: Dawid Bodzek
 *
 * Description:
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

module image_rom (
    input  logic clk ,
    input  logic [19:0] address,  // address = {addry[5:0], addrx[5:0]}
    output logic [11:0] rgb
);

    /**
     * Local variables and signals
     */

    reg [11:0] rom [0:786432];

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh("../../rtl/MainMenu/ROM/DonkeyVsKong.dat", rom);

    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule