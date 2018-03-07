module z1top #(
    // We are using a 125 MHz clock for our design.
    // It is declared as a parameter so the testbench can override it if desired.
    parameter CLOCK_FREQ = 125_000_000,

    // These are used for the button debouncer.
    // They are overridden in the testbench for faster runtime.
    parameter integer B_SAMPLE_COUNT_MAX = 0.0002 * CLOCK_FREQ,
    parameter integer B_PULSE_COUNT_MAX = 0.03/0.0002,
    
    parameter integer LRCK_FREQ_HZ = 44100,
    parameter integer MCLK_TO_LRCK_RATIO = 256,
    
    // This is the sample width, or the number of bits per sample sent in each audio frame.
    // Make sure this parameter is used everywhere it needs to be, consistently.
    parameter integer BIT_DEPTH = 8
)(
    input RESET,
    input CLK_125MHZ_FPGA,      // 125 MHz clock signal.
    input [2:0] BUTTONS,        // Momentary push-buttons.
    input [1:0] SWITCHES,       // Slide switches
    output [5:0] LEDS,          // Board LEDs.
    
    // You may not have plugged this in!
    output [7:0] PMOD_LEDS,

    // I2S Signals
    output MCLK,                // Master Clock.
    output LRCLK,               // Left-right Clock.
    output SCLK,                // Serial Clock.
    output SDIN,                // Serial audio data output.

    // Crummy audio output
    output AUDIO_PWM
);
  wire reset;
  wire [2:0] clean_buttons;

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
  
  // YOUR CODE HERE.
  //    tone_generator
  //    piano_fsm,
  //    rom,
  //    piano_scale_rom,
  //    uart...

  reg [BIT_DEPTH-1:0] pcm_data;
  reg [1:0] pcm_data_valid;
  wire [1:0] pcm_data_ready;

  // For the first part of the lab, you might want to just use this.
  i2s_controller #(
    .SYS_CLOCK_FREQ(CLOCK_FREQ),
    .LRCK_FREQ_HZ(LRCK_FREQ_HZ),
    .MCLK_TO_LRCK_RATIO(MCLK_TO_LRCK_RATIO),
    .BIT_DEPTH(BIT_DEPTH)
  ) i2s_control (
    .sys_reset(reset),
    .sys_clk(CLK_125MHZ_FPGA),

    .pcm_data(pcm_data),
    .pcm_data_valid(pcm_data_valid),
    .pcm_data_ready(pcm_data_ready),

    // I2S control signals
    .mclk(MCLK),
    .sclk(SCLK),
    .lrck(LRCLK),
    .sdin(SDIN)
  );
endmodule
