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
    ../rtl/delay.sv
    ../rtl/top_game.sv
    ../rtl/VGA/vga_timing.sv
    ../rtl/VGA/vga_if.sv
    ../rtl/donkey_movement.sv
    ../rtl/draw_character.sv
    rtl/top_game_basys3.sv
    ../rtl/Packages/keyboard_pkg.sv
    ../rtl/Packages/donkey_pkg.sv
    ../rtl/Packages/kong_pkg.sv
    ../rtl/Packages/platform_pkg.sv
    ../rtl/Packages/ladder_pkg.sv
    ../rtl/Packages/animation_pkg.sv
    ../rtl/draw_ladder.sv
    ../rtl/map_control.sv
    ../rtl/incline_platform.sv
    ../rtl/Keyboard/key_decoder.sv
    ../rtl/start_animation.sv
    ../rtl/animation_ladder.sv
    ../rtl/animation_platform.sv
    ../rtl/ver_barrel.sv
    ../rtl/draw_barrel.sv
    ../rtl/barrel_ctl.sv

}

# Specify Verilog design files location
set verilog_files {
    rtl/clk_wiz_65.v
    rtl/clk_wiz_65_clk_wiz.v
    ../rtl/Keyboard/ps2_receiver.v
    ../rtl/Keyboard/bin2ascii.v
    ../rtl/Keyboard/debouncer.v
}

# Specify VHDL design files location
#set vhdl_files {
#}

# Specify files for a memory initialization
#set mem_files {
#
#}