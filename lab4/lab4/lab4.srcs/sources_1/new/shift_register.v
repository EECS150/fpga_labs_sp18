module shift_register #(
  parameter DEPTH = 10,
  parameter WIDTH = 4
)(
  input [WIDTH-1:0] in,
  input shift,
  output [WIDTH*DEPTH-1:0] out
);
  // YOUR CODE HERE.
  assign out = 0;
endmodule
