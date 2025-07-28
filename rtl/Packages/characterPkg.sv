/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek & Jakub Bukowski
 *
 * Description:
 * Package with characters constants.
 */

package characterPkg;

    localparam CHARACTER_HEIGHT = 64;
    localparam JUMP_TAKI_W_MIARE = 1_400_000;
    localparam MOVE_TAKI_NIE_MACQUEEN = 250_000;

    //------------ Kong ------------
    localparam KONG_ANIMATION_INITIAL_XPOS = 484;
    localparam KONG_ANIMATION_INITIAL_YPOS = 672;
    localparam KONG_PLATFORM_YPOS = 175;
    //-------------------------------

    //----------- Donkey ------------
    localparam CHARACTER_WIDTH = 48;
    localparam DONKEY_JUMP_HEIGHT = 58;
    localparam DONKEY_INITIAL_XPOS = 128;
    localparam DONKEY_INITIAL_YPOS = 672;
    //-------------------------------

endpackage