`define CLOCK_FREQ 125_000_000

module debouncer_fpga_test (
    input CLK_125MHZ_FPGA,      // 125 MHz clock signal.
    input RESET,
    input [2:0] BUTTONS,        // Momentary push-buttons.
    input [1:0] SWITCHES,       // [UNUSED] Slide switches.
    output [5:0] LEDS,          // Board LEDs.
    output AUDIO_PWM            // [UNUSED] Audio output.
);
    // Here are some time constants used for the button debouncer
    localparam integer B_SAMPLE_COUNT_MAX = 0.00076 * `CLOCK_FREQ;
    localparam integer B_PULSE_COUNT_MAX = 0.11364/0.00076;

    wire [3:0] cleaned_button_signals;

    // The button_parser is a wrapper for the synchronizer -> debouncer -> edge detector signal chain
    button_parser #(
        .width(4),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) b_parser (
        .clk(CLK_125MHZ_FPGA),
        .in({RESET, BUTTONS}),
        .out(cleaned_button_signals)
    );

    // Here is the test adder
    reg [5:0] number = 0;
    assign LEDS[5:0] = number;

    always @ (posedge CLK_125MHZ_FPGA) begin
        if (|cleaned_button_signals[2:1]) begin
            number <= number + 1;
        end
        else if (cleaned_button_signals[0]) begin
            number <= number - 1;
        end
        else if (cleaned_button_signals[3]) begin
            number <= 0;
        end
        else begin
            number <= number;
        end
    end

endmodule
