`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 33_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);

    // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.

    assign data_in_ready = 1'b0;
    assign serial_out = 1'b1;
endmodule
