`timescale 1ns/1ns

module keypad_decoder_testbench();
  reg clock;
  reg reset;

  initial clock = 0;
  always #(8/2) clock <= ~clock;

  // YOUR CODE HERE.

  initial begin
    reset = 0;
    @(posedge clock);
    reset = 1;
    @(posedge clock);
    reset = 0;

    // YOUR CODE HERE.

    $finish();
  end
endmodule
