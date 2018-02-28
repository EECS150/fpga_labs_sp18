`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data.
);

// An idea of what you might need, to get you started.
localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);

// 1: Generate MCLK from sys_clk. MCLK's frequency must be an integer multiple
// of the sample rate, and hence LRCK rate, as defined in the PMOD I2S reference
// manual and the Cirrus Logic CS4344 data sheet.

// 2: Generate the LRCK, the left-right clock.

// 3. Generate the bit clock, or serial clock. It clocks transmitted bits for a 
// whole sample on each half-cycle of the lr_clock. The frequency of this clock
// relative to the lr_clock determines how wide our samples can be.

endmodule