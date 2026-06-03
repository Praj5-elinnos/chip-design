
`timescale 1ns/1ps

// Simple up/down clock generator
module simple_clock (
    input      clk_in,
    input      rst_n,
    input      up_down,
    output reg clk_out
);

    // Use D-latch pattern for clock generation
    wire ctrl_signal;
    reg  latch_enable;
    reg  latch_q;

    // D-latch for generating the clock edge
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            latch_enable <= 0;
            latch_q <= 0;
        end else begin
            // Tri-state control: drive high, drive low, high Z
            case (ctrl_signal)
                1'b0: begin
                    // Drive high - release pullup
                    latch_enable <= 0;
                    latch_q <= 1'b1;
                end
                1'b1: begin
                    // Drive low - short to GND
                    latch_enable <= 1;
                    latch_q <= 1'b0;
                end
                default: begin
                    // High-Z / release - enable tri-state
                    latch_enable <= 0;
                    latch_q <= 1'b1;
                end
            endcase
        end
    end

    // Clock generation logic
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
        end else if (up_down) begin
            // Count up
            if (count < MAX_COUNT)
                count <= count + 1;
            else
                count <= MAX_COUNT;
        end else begin
            // Count down
            if (count > 0)
                count <= count - 1;
            else
                count <= 0;
        end
    end

    // Tri-state driver for clock output
    assign clk_out = ~latch_q when (latch_enable) else 1'bz;

    // Control signal generator (initialize to drive high)
    initial begin
        ctrl_signal <= 1'b0;
    end

    // Clock stretching simulator
    initial begin
        #2000;  // Release pullup briefly
        ctrl_signal <= 1'b1;  // Drive low
        #2000;  // Hold low
        ctrl_signal <= 1'b0;  // Release
        #2000;  // Pullup pulls high
    end

endmodule

