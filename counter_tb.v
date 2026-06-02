`timescale 1ns/1ps

module counter_tb;
  reg clk;
  reg rst;
  wire [3:0] count;
  
  // Instantiate the counter
  counter uut (
    .clk(clk),
    .rst(rst),
    .count(count)
  );
  
  // Clock generation - 10ns period
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Test sequence
  initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);
    
    // Initialize
    rst = 1;
    #20 rst = 0;  // Release reset after 20ns
    
    // Let counter run for several cycles
    #200;
    
    // Apply reset again
    rst = 1;
    #20 rst = 0;
    
    // Run more cycles
    #100;
    
    $display("Simulation completed successfully");
    $finish;
  end
  
  // Monitor the count value
  always @(posedge clk) begin
    $display("Time: %0t, Reset: %b, Count: %d", $time, rst, count);
  end
  
endmodule