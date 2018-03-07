module uart #(
    parameter CLOCK_FREQ = 33_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output [7:0] data_out,
    output data_out_valid,
    input data_out_ready,

    input serial_in,
    output serial_out
);

    // We create these intermediate registers in the UART module
    // that are given the synthesis attribute 'iob'. This tells
    // xst to pack these registers in IOBs (Input/Output Blocks),
    // on the FPGA. These blocks contain flip-flops, similar to those
    // on SLICEs, but the flip-flops on IOBs are sized larger,
    // can drive higher currents, and have higher slew rates.
    reg serial_in_reg, serial_out_reg /* synthesis iob="true" */;
    wire serial_out_tx;
    assign serial_out = serial_out_reg;
    always @ (posedge clk) begin
        serial_out_reg <= reset ? 1'b1 : serial_out_tx;
        serial_in_reg <= reset ? 1'b1 : serial_in;
    end

    uart_transmitter #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uatransmit (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .serial_out(serial_out_tx)
    );

    uart_receiver #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uareceive (
        .clk(clk),
        .reset(reset),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(serial_in_reg)
    );
endmodule
