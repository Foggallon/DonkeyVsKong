/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Package with map related constants.
 */

package mapPkg;

    localparam BLACK = 12'h0_0_0;

    //---------- Animation ----------
    localparam LADDER_VSTART = 271;
    localparam LADDER_HSTART = 480;
    localparam LADDER_HSTART_2 = 516;
    localparam PLATFORM_VSTART = 362;
    localparam PLATFORM_VSTART_2 = 539;
    //-------------------------------

    //------- End of platform -------
    localparam EO_PLATFORM_1_VSTART = 465;
    localparam EO_PLATFORM_1_VSTOP = 531;

    localparam EO_PLATFORM_2_VSTART = 292;
    localparam EO_PLATFORM_2_VSTOP = 354;

    localparam EO_PLATFORM_3_VSTART = 129;
    localparam EO_PLATFORM_3_VSTOP = 191;

    localparam EO_PLATFORM_4_VSTART = 4;
    localparam EO_PLATFORM_4_VSTOP = 68;

    localparam LANDING_POS_1 = 644;
    localparam LANDING_POS_2 = 479;
    localparam LANDING_POS_3 = 302;
    localparam LANDING_POS_4 = 175;
    //-------------------------------

    //------- Sloped Platforms ------
    localparam SP_VSTART_1 = 732;
    localparam SP_HSTART_1 = 510;
    
    localparam SP_VSTART_2 = 539;
    localparam SP_HSTART_2 = 0;

    localparam SP_VSTART_3 = 414;
    localparam SP_HSTART_3 = 126;

    localparam SP_VSTART_4 = 239;
    localparam SP_HSTART_4 = 638;
    //-------------------------------

    //---------- Platforms ----------
    localparam PLATFORM_OFFSET = 4;
    localparam PLATFORM_WIDTH = 64;
    localparam PLATFORM_HEIGHT = 32;

    localparam PLATFORM_1_VSTART = 736;
    localparam PLATFORM_1_HSTART = 0;
    localparam PLATFORM_1_HSTOP = 512;

    localparam PLATFORM_2_VSTART = 239;
    localparam PLATFORM_2_HSTART = 0;
    localparam PLATFORM_2_HSTOP = 640;

    localparam PLATFORM_3_VSTART = 128;
    localparam PLATFORM_3_HSTART = 320;
    localparam PLATFORM_3_HSTOP = 576;
    //-------------------------------

    //---------- Ladders ------------
    localparam LADDER_OFFSET = 16;
    localparam LADDER_WIDTH = 32;
    localparam LADDER_HEIGHT = 32;

    localparam LADDER_1_VSTART = 591;
    localparam LADDER_1_VSTOP = 716;
    localparam LADDER_1_HSTART = 796;

    localparam LADDER_2_VSTART = 398;
    localparam LADDER_2_VSTOP = 567;
    localparam LADDER_2_HSTART = 412;

    localparam LADDER_3_VSTART = 410;
    localparam LADDER_3_VSTOP = 555;
    localparam LADDER_3_HSTART = 220;

    localparam LADDER_4_VSTART = 247;
    localparam LADDER_4_VSTOP = 372;
    localparam LADDER_4_HSTART = 796;

    localparam LADDER_5_VSTART = 128;
    localparam LADDER_5_VSTOP = 271;
    localparam LADDER_5_HSTART = 544;

    localparam DECORATION_1_VSTART = 704;
    localparam DECORATION_1_VSTART_2 = 588;
    localparam DECORATION_1_HSTART = 320;

    localparam DECORATION_2_VSTART = 271;
    localparam DECORATION_2_VSTART_2 = 354;
    localparam DECORATION_2_HSTART = 576;
    //-------------------------------

endpackage