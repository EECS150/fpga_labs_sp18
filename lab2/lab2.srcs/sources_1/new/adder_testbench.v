`timescale 1ns/1ns

module adder_testbench();
    reg clock;

    initial clock = 0;
    always #(2) clock <= ~clock;
    // Self test of the structural adder
    wire [13:0] adder_operand1, adder_operand2;
    wire [14:0] structural_out, behavioral_out;
    wire test_fail;

    structural_adder structural_test_adder (
        .a(adder_operand1),
        .b(adder_operand2),
        .sum(structural_out)
    );

    behavioral_adder behavioral_test_adder (
        .a(adder_operand1),
        .b(adder_operand2),
        .sum(behavioral_out)
    );

    adder_tester tester (
        .adder_operand1(adder_operand1),
        .adder_operand2(adder_operand2),
        .structural_sum(structural_out),
        .behavioral_sum(behavioral_out),
        .clk(clock),
        .test_fail(test_fail)
    );

    initial begin
        #700_000_000;
        #700_000_000;
        $finish();
    end
endmodule
