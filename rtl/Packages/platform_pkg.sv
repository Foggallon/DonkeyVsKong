/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Dawid Bodzek
 *
 * Description:
 * Package with platform related constants.
 */

 package platform_pkg;

    localparam EO_PLATFORM_1_VSTART = 529;
    localparam EO_PLATFORM_1_VSTOP = 595;

    localparam EO_PLATFORM_2_VSTART = 356;
    localparam EO_PLATFORM_2_VSTOP = 418;

    localparam EO_PLATFORM_3_VSTART = 193;
    localparam EO_PLATFORM_3_VSTOP = 255;

    localparam EO_PLATFORM_4_VSTART = 68;
    localparam EO_PLATFORM_4_VSTOP = 132;

    localparam LANDING_POS_1 = 708;
    localparam LANDING_POS_2 = 543;
    localparam LANDING_POS_3 = 366;
    localparam LANDING_POS_4 = 239;

    localparam IP_VSTART_1 = 732;
    localparam IP_HSTART_1 = 510;
    
    localparam IP_VSTART_2 = 539;
    localparam IP_HSTART_2 = 0;

    localparam IP_VSTART_3 = 414;
    localparam IP_HSTART_3 = 126;

    localparam IP_VSTART_4 = 239;
    localparam IP_HSTART_4 = 638;

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

endpackage