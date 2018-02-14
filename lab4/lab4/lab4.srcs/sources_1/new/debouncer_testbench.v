`timescale 1ns/100ps

`define CLK_PERIOD 10
`define DEBOUNCER_WIDTH 2
`define SAMPLE_COUNT_MAX 10
`define PULSE_COUNT_MAX 5

/*
    This testbench checks that your debouncer smooths-out the input signals properly. Refer to the spec for details.
    This testbench should be throughly commented.
*/

module debouncer_testbench();
    // Generate 100 Mhz clock
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // I/O of debouncer
    reg [`DEBOUNCER_WIDTH-1:0] glitchy_signal;
    wire [`DEBOUNCER_WIDTH-1:0] debounced_signal;

    debouncer #(
        .width(`DEBOUNCER_WIDTH),
        .sample_count_max(`SAMPLE_COUNT_MAX),
        .pulse_count_max(`PULSE_COUNT_MAX)
    ) DUT (
        .clk(clk),
        .glitchy_signal(glitchy_signal),
        .debounced_signal(debounced_signal)
    );

    // Testbench variables
    integer test1_done = 0;
    integer test2_output_should_rise = 0;
    integer test2_output_should_fall = 0;
    integer test2_done = 0;

    initial begin
        glitchy_signal = 3'd0;
        @(posedge clk);

        // We will use our first glitchy_signal to verify that if a signal bounces around and goes low
        //  before the saturating counter saturates, that the output never goes high
        fork
            // This thread will provide the glitchy signal
            begin
                // Initially act glitchy
                repeat (10) begin
                    glitchy_signal[0] = ~glitchy_signal[0];
                    @(posedge clk);
                end

                // Bring the signal high and hold until before the saturating counter should saturate, then pull low
                glitchy_signal[0] = 1'b1;
                repeat (`SAMPLE_COUNT_MAX * (`PULSE_COUNT_MAX - 1)) @(posedge clk);

                // Pull the signal low and wait, the debouncer shouldn't set its output high
                glitchy_signal[0] = 1'b0;
                repeat (`SAMPLE_COUNT_MAX * (`PULSE_COUNT_MAX + 1)) @(posedge clk);
                test1_done = 1;
            end
            // This thread will check that the output of the debouncer never goes high
            begin: test1_checker
                while (!test1_done) begin
                    if (debounced_signal[0] !== 1'b0) $display("Failure 0: The debounced output[0] wasn't 0 for the entire test.");
                    @(posedge clk);
                end
            end
        join

        // We will use the second glitchy_signal to verify that if a signal bounces around and stays high
        //   long enough for the counter to saturate, that the output goes high and stays there until the glitchy_signal falls
        fork
            begin
                // Initially act glitchy
                repeat (10) begin
                    glitchy_signal[1] = ~glitchy_signal[1];
                    @(posedge clk);
                end
                // Bring the signal high and hold past the point at which the debouncer should saturate
                glitchy_signal[1] = 1'b1;
                repeat (`SAMPLE_COUNT_MAX * (`PULSE_COUNT_MAX + 1)) @(posedge clk);
                test2_output_should_rise = 1;
                repeat (`SAMPLE_COUNT_MAX * (3)) @(posedge clk);

                // Pull the signal low and the output should immediately fall
                @(posedge clk);
                glitchy_signal[1] = 1'b0;
                test2_output_should_fall = 1;

                // Wait for some time to ensure the signal stays low
                repeat (`SAMPLE_COUNT_MAX * (`PULSE_COUNT_MAX + 1)) @(posedge clk);
                test2_done = 1;
            end
            begin
                while (!test2_output_should_rise) begin
                    @(posedge clk);
                end
                if (debounced_signal[1] !== 1'b1) begin // test2_output_should_rise = 1
                    $display("Failure 1: The debounced output[1] should have gone high by now");
                end
                while (!test2_output_should_fall) begin
                    if (debounced_signal[1] !== 1'b1) $display("Failure 2: The debounced output[1] should stay high once the counter saturates");
                    @(posedge clk);
                end
                if (debounced_signal[1] !== 1'b0) begin
                    $display("Failure 3: The debounced output[1] should have fallen as soon as the glitchy signal fell");
                end
                while (!test2_done) begin
                    if (debounced_signal[1] !== 1'b0) $display("Failure 4: The debounced output[1] should remain low after the glitchy signal falls");
                    @(posedge clk);
                end
            end
        join

        repeat (100) @(posedge clk);
        $display("Test Done! If any failures were printed, fix them! Otherwise this testbench passed.");
        $finish();
    end
endmodule
