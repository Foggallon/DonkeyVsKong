/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
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

module image_rom #(parameter
    PIXELS = 4096,
    BITS = 8,
    ROM_FILE = "../../rtl/MainMenu/DonkeyVsKong.dat"
    )(
    input  logic clk ,
    input  logic [BITS-1:0] address,  // address = {addry, addrx}
    output logic [11:0] rgb
);

    /**
     * Local variables and signals
     */

    reg [11:0] rom [0:PIXELS];

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh(ROM_FILE, rom);

    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule