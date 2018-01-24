`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// UC Berkeley, EECS 151/251A FPGA Lab
// Lab 0, Spring 2018
// Module: ml505top.v 
//------------------------------------------------------------------------------

module ml505top(
    input CLK_50MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS
    );

    and(LEDS[0], BUTTONS[0], SWITCHES[0]);
    assign LEDS[5:1] = 0;

endmodule