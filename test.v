
`timescale 1ns/1ps

module test_cpu;
    reg clk = 0;
    reg rst_n = 0;
    reg [31:0] data;
    
    always #5 clk = ~clk;
    
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
        #10 data = 32'h12345678;
        $display("Test data: %h", data);
        #10 data = 32'hABCDEF00;
        $display("Updated test data: %h", data);
        #5 data = 32'h55555555;
        $display("Pattern test data: %h", data);
        $display("Simulation completed successfully");
        $finish;
    end
endmodule