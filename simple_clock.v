// Simple Clock Generator - Verilog
// Author: ChipDesigner.AI
// Description: Basic clock generator with configurable frequency

module simple_clock #(
    parameter CLOCK_PERIOD = 10  // Clock period in time units (10ns = 100MHz)
) (
    output reg clk,
    input wire reset_n
);

    // Internal clock signal
    reg internal_clk = 1'b0;
    
    // Clock generation
    always begin
        #(CLOCK_PERIOD/2) internal_clk = ~internal_clk;
    end
    
    // Output clock with reset capability
    always @(*) begin
        if (!reset_n)
            clk = 1'b0;
        else
            clk = internal_clk;
    end

endmodule

// Testbench for simple_clock
module tb_simple_clock;
    
    reg clk;
    reg reset_n;
    
    // Instantiate the clock generator
    simple_clock #(.CLOCK_PERIOD(20)) dut (
        .clk(clk),
        .reset_n(reset_n)
    );
    
    // Test sequence
    initial begin
        $dumpfile("simple_clock.vcd");
        $dumpvars(0, tb_simple_clock);
        
        // Initialize
        reset_n = 1'b0;
        #50;
        
        /
        reset_n = 1'b1;
        #200;
        
        // Test reset again
        reset_n = 1'b0;
        #30;
        reset_n = 1'b1;
        #100;
        
        $finish;
    end
    
    // Monitor clock edges
    always @(posedge clk) begin
        $display("Time: %0t - Clock rising edge", $time);
    end

endmodule