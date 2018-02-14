`define CLOCK_FREQ 125_000_000

module z1top (
    input CLK_125MHZ_FPGA,      // 125 MHz clock signal.
    input RESET,
    input [2:0] BUTTONS,        // Momentary push-buttons.
    input [1:0] SWITCHES,       // Slide switches
    // Uncomment for the hex keypad.
    // input [3:0] KEYPAD_ROWS,    // Hex keypad row lines.
    // output [3:0] KEYPAD_COLS,   // Hex keypad column lines.
    output [5:0] LEDS,          // Board LEDs.
    output AUDIO_PWM            // Audio output.
);
    // Here are some time constants used for buttons.
    localparam integer B_SAMPLE_COUNT_MAX = 0.00076 * `CLOCK_FREQ;
    localparam integer B_PULSE_COUNT_MAX = 0.11364/0.00076;

    wire reset;
    wire [2:0] clean_buttons;   // Cleaned input from the push buttons.

    // The button_parser is a wrapper for the synchronizer -> debouncer -> edge detector signal chain
    button_parser #(
        .width(4),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) b_parser (
        .clk(CLK_125MHZ_FPGA),
        .in({RESET, BUTTONS}),
        .out({reset, clean_buttons})
    );

    // Connection between music_streamer and tone_generator
    wire [23:0] tone_to_play;

    tone_generator audio_controller (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .output_enable(1'b1),
        .tone_switch_period(tone_to_play),
        .square_wave_out(AUDIO_PWM)
    );

    // YOUR CODE HERE. Maybe. Maybe a hex keypad decoder?
    
    music_streamer streamer (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .tempo_up(clean_buttons[0]),
        .tempo_down(clean_buttons[1]),
        .tempo_reset(clean_buttons[2]),
        .play_pause(1'b0),
        .switch_mode(1'b0),
        .switch_fn(1'b0),
        .edit_next_node(1'b0),
        .edit_prev_node(1'b0),
        .tone(tone_to_play),
        // You should probably change these. It seems like a waste of LEDs.
        .led_paused(LEDS[5]),
        .led_regular_play(LEDS[4]),
        .led_reverse_play(LEDS[3]),
        .led_play_seq(LEDS[2]),
        .led_edit_seq(LEDS[1])
    );
    
endmodule
