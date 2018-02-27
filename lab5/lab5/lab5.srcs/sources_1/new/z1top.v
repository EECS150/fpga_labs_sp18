module z1top # (
    // We are using a 125 MHz clock for our design
    // It is declared as a parameter so the testbench can override it if desired
    parameter CLOCK_FREQ = 125_000_000,

    // Our UART uses a baud rate of 115.2 KBaud
    parameter BAUD_RATE = 115_200,

    // These are used for the button debouncer
    // They are overridden in the testbench for faster runtime
    parameter integer B_SAMPLE_COUNT_MAX = 0.00076 * CLOCK_FREQ,
    parameter integer B_PULSE_COUNT_MAX = 0.11364/0.00076

)(
    input RESET,
    input CLK_125MHZ_FPGA,      // 125 MHz clock signal.
    input [2:0] BUTTONS,        // Momentary push-buttons.
    input [1:0] SWITCHES,       // Slide switches
    output [5:0] LEDS,          // Board LEDs.

    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    // Use our input processing circuits from Lab 4 to get button signals
    // Pressing any button will reset the FPGA design
    wire [2:0] buttons;
    wire reset;

    wire any_reset;
    assign any_reset = |({reset, buttons});
    button_parser #(
        .width(4),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) b_parser (
        .clk(CLK_125MHZ_FPGA),
        .in({RESET, BUTTONS}),
        .out({reset, buttons})
    );

    reg [7:0] data_in;
    wire [7:0] data_out;
    wire data_in_valid, data_in_ready, data_out_valid, data_out_ready;

    // This UART is on the FPGA and communicates with your desktop
    // using the FPGA_SERIAL_TX, and FPGA_SERIAL_RX signals. The ready/valid
    // interface for this UART is used on the FPGA design.
    uart # (
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(CLK_125MHZ_FPGA),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    // This is a small state machine that will pull a character from the uart_receiver
    // over the ready/valid interface, modify that character, and send the character
    // to the uart_transmitter, which will send it over the serial line.

    // If a ASCII letter is received, its case will be reversed and sent back. Any other
    // ASCII characters will be echoed back without any modification.
    reg has_char;
    reg [7:0] char;

    always @(posedge CLK_125MHZ_FPGA) begin
        if (reset) has_char <= 1'b0;
        else has_char <= has_char ? !data_in_ready : data_out_valid;
    end

    always @(posedge CLK_125MHZ_FPGA) begin
        if (!has_char) char <= data_out;
    end

    always @ (*) begin
        if (char >= 8'd65 && char <= 8'd90) data_in = char + 8'd32;
        else if (char >= 8'd97 && char <= 8'd122) data_in = char - 8'd32;
        else data_in = char;
    end

    assign data_in_valid = has_char;
    assign data_out_ready = !has_char;

endmodule
