module synchronizer #(parameter width = 1) (
  input [width-1:0] async_signal,
  input clk,
  output [width-1:0] sync_signal
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
  assign sync_signal = 0;
endmodule
