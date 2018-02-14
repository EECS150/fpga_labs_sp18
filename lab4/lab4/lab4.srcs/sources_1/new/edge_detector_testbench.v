`timescale 1ns/100ps

`define CLK_PERIOD 10
`define EDGE_DETECTOR_WIDTH 1

module edge_detector_testbench();
    // Generate 100 Mhz clock
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // I/O of edge detector
    reg [`EDGE_DETECTOR_WIDTH-1:0] signal_in;
    wire [`EDGE_DETECTOR_WIDTH-1:0] edge_detect_pulse;

    edge_detector #(
        .width(`EDGE_DETECTOR_WIDTH)
    ) DUT (
        .clk(clk),
        .signal_in(signal_in),
        .edge_detect_pulse(edge_detect_pulse)
    );

    initial begin
        // Set initial state, wait for 1 clock cycle
        signal_in = 0;
        @(posedge clk);

        fork
            // This thread provides the inputs for the edge detector
            begin
                // Pulse signal_in for 10 clock cycles
                signal_in[0] = 1'b1;
                repeat (10) @(posedge clk);
                signal_in[0] = 1'b0;

                // Wait for 10 clock cycles
                repeat (10) @(posedge clk);

                // Pulse signal_in for 1 clock cycle
                signal_in[0] = 1'b1;
                repeat (1) @(posedge clk);
                signal_in[0] = 1'b0;

                // Wait for 10 clock cycles
                repeat (10) @(posedge clk);
            end

            // This thread checks the output of the edge detector
            // You should be getting used to this 2-thread pattern by now
            begin
                // Wait for the rising edge of the edge detector output
                @(posedge edge_detect_pulse);

                // Let 1 clock cycle elapse (#1 is a Verilog oddity since the edge_detect_pulse should change right after
                //   the rising clock edge, not at the same instant as the rising edge).
                @(posedge clk); #1;

                // Check that the edge detector output is now low
                if (edge_detect_pulse[0] !== 1'b0) $display("Failure 1: Your edge detector's output wasn't 1 clock cycle wide");

                // Wait for the 2nd rising edge, and same logic
                @(posedge edge_detect_pulse);
                @(posedge clk); #1;
                if (edge_detect_pulse[0] !== 1'b0) $display("Failure 2: Your edge detector's output wasn't 1 clock cycle wide");
            end
        join
        $display("Test Done! If any failures were printed, fix them! Otherwise this testbench passed.");
        $finish();
    end
endmodule
