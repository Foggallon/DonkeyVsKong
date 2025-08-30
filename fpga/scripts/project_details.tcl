# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Dawid Bodzek
#
# Description:
# Project details required for generate_bitstream.tcl

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  
set project_name DonkeyVsKong

# Top module name                               
set top_module top_game_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location
set xdc_files {
    constraints/top_game_basys3.xdc
    constraints/clk_wiz_65.xdc
}

# Specify SystemVerilog design files location
set sv_files {
    ../rtl/Packages/vga_pkg.sv
    ../rtl/ROM/image_rom.sv
    ../rtl/MainMenu/draw_menu.sv
    ../rtl/Common/delay.sv
    ../rtl/top_game.sv
    ../rtl/VGA/vga_timing.sv
    ../rtl/VGA/vga_if.sv
    ../rtl/Movement/donkey_movement.sv
    ../rtl/Common/draw_character.sv
    rtl/top_game_basys3.sv
    ../rtl/Packages/keyboard_pkg.sv
    ../rtl/Packages/donkey_pkg.sv
    ../rtl/Packages/kong_pkg.sv
    ../rtl/Packages/platform_pkg.sv
    ../rtl/Packages/barrel_pkg.sv
    ../rtl/Packages/ladder_pkg.sv
    ../rtl/Packages/animation_pkg.sv
    ../rtl/Map/draw_ladder.sv
    ../rtl/Common/map_control.sv
    ../rtl/Map/incline_platform.sv
    ../rtl/Keyboard/key_decoder.sv
    ../rtl/Animation/start_animation.sv
    ../rtl/Animation/animation_ladder.sv
    ../rtl/Animation/animation_platform.sv
    ../rtl/Barrels/hor_barrel.sv
    ../rtl/Barrels/draw_barrel.sv
    ../rtl/Barrels/barrel_ctl.sv
    ../rtl/Barrels/ver_barrel.sv
    ../rtl/Movement/kong_movement.sv
    ../rtl/UART/uart_rx_ctl.sv
    ../rtl/UART/uart_tx_ctl.sv
    ../rtl/Utility/draw_health.sv
    ../rtl/game_fsm.sv
    ../rtl/Utility/draw_shield.sv
    ../rtl/Utility/health_shielding.sv
    ../rtl/Utility/touch_lady.sv
}

# Specify Verilog design files location
set verilog_files {
    rtl/clk_wiz_65.v
    rtl/clk_wiz_65_clk_wiz.v
    ../rtl/Keyboard/ps2_receiver.v
    ../rtl/Keyboard/bin2ascii.v
    ../rtl/Keyboard/debouncer.v
    ../rtl/UART/fifo.v
    ../rtl/UART/mod_m_counter.v
    ../rtl/UART/uart_rx.v
    ../rtl/UART/uart_tx.v
    ../rtl/UART/uart.v
}

# Specify VHDL design files location
#set vhdl_files {
#}

# Specify files for a memory initialization
#set mem_files {
#
#}