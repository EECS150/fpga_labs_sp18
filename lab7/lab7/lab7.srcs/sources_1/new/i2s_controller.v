`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128,
  parameter BIT_DEPTH = 24
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

  input [BIT_DEPTH-1:0] pcm_data,
  input [1:0] pcm_data_valid,
  output reg [1:0] pcm_data_ready,

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data.
);

  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.

  assign sdin = 1'b0;
  assign sclk = 1'b0;
  assign mclk = 1'b0;
  assign lrck = 1'b0;

endmodule
