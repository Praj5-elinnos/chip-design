`timescale 1ns/1ps

module counter_tb;
  reg clk;
  reg rst;
  wire [3:0] count;
  
  // Instantiate the counter
  counter dut (
    .clk(clk),
    .rst(rst),
    .count(count)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period
  end
  
  // Test sequence
  initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);
    
    // Initialize
    rst = 1;
    #20;
    
    // Release reset and let counter run
    rst = 0;
    #100;
    
    // Assert reset again
    rst = 1;
    #20;
    
    // Release reset and run
    rst = 0;
    #80;
    
    $finish;
  end
  
  // Monitor
  initial begin
    $monitor("Time=%0t rst=%b count=%d", $time, rst, count);
  end
endmodule