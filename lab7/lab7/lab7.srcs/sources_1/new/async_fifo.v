`include "util.vh"

module async_fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input wr_clk,
    input rd_clk,

    input wr_en,
    input rd_en,
    input [data_width-1:0] din,

    output full,
    output empty,
    output [data_width-1:0] dout
);
    assign dout = 0;
    assign full = 1'b1;
    assign empty = 1'b0;
endmodule
