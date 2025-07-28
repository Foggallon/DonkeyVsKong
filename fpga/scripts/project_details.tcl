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
    ../rtl/Packages/vgaPkg.sv
    ../rtl/ROM/imageRom.sv
    ../rtl/MainMenu/drawMenu.sv
    ../rtl/delay.sv
    ../rtl/top_game.sv
    ../rtl/VGA/vgaTiming.sv
    ../rtl/VGA/vga_if.sv
    ../rtl/movement.sv
    ../rtl/drawCharacter.sv
    rtl/top_game_basys3.sv
    ../rtl/Packages/keyboardPkg.sv
    ../rtl/Packages/mapPkg.sv
    ../rtl/drawLadder.sv
    ../rtl/ladderControl.sv
    ../rtl/slopedRamp.sv
    ../rtl/Keyboard/keyDecoder.sv
    ../rtl/Packages/characterPkg.sv
    ../rtl/animation.sv
    ../rtl/animationLadder.sv
    ../rtl/animationPlatform.sv
}

# Specify Verilog design files location
set verilog_files {
    rtl/clk_wiz_65.v
    rtl/clk_wiz_65_clk_wiz.v
    ../rtl/Keyboard/PS2Receiver.v
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