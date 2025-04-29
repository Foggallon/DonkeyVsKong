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
}

# Specify SystemVerilog design files location
set sv_files {
    ../rtl/vga_pkg.sv
    ../rtl/vga_timing.sv
    ../rtl/vga_if.sv
    rtl/top_game_basys3.sv
}

# Specify Verilog design files location
#set verilog_files {
#
#}

# Specify VHDL design files location
#set vhdl_files {
#
#}

# Specify files for a memory initialization
#set mem_files {
#
#}