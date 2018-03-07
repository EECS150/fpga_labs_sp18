module edge_detector #(
  parameter width = 1
)(
  input clk,
  input [width-1:0] signal_in,
  output [width-1:0] edge_detect_pulse
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
  assign edge_detect_pulse = 0;
endmodule