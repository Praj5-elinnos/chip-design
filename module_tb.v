//==============================================================================
// Elinnos Test Module
// 
// Description: Testbench for 8-bit register module.
//              This module provides comprehensive testing for the register_8bit
//              design including reset, enable, and data functionality.
//
// Company: Elinnos Technologies
// Author: Chip Design Team
// Date: December 2024
// Version: 1.0
//
// Usage: xrun module.v module_tb.v
//==============================================================================

`timescale 1ns/1ps

module module_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg enable;
    wire [7:0] data_out;
    
    // Instantiate the register_8bit module
    register_8bit uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .enable(enable),
        .data_out(data_out)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        enable = 0;
        data_in = 8'h00;
        
        // Display header
        $display("=================================================");
        $display("Elinnos Register 8-bit Test Starting");
        $display("=================================================");
        $display("Time\t rst\t enable\t data_in\t data_out");
        $display("-------------------------------------------------");
        
        // Wait a few clock cycles
        #20;
        
        // Release reset
        rst = 0;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Test 1: Load data with enable high
        enable = 1;
        data_in = 8'hAA;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Test 2: Change data with enable high
        data_in = 8'h55;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Test 3: Disable enable (data should hold)
        enable = 0;
        data_in = 8'hFF;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Test 4: Enable again with new data
        enable = 1;
        data_in = 8'h33;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Test 5: Test reset functionality
        rst = 1;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        // Release reset and test again
        rst = 0;
        data_in = 8'hCC;
        #10;
        $display("%0t\t %b\t %b\t %h\t %h", $time, rst, enable, data_in, data_out);
        
        $display("-------------------------------------------------");
        $display("Elinnos Register 8-bit Test Completed");
        $display("=================================================");
        
        // Finish simulation
        #20;
        $finish;
    end
    
    // VCD dump for waveform viewing (Xcelium compatible)
    initial begin
        $dumpfile("register_8bit.vcd");
        $dumpvars(0, module_tb);
        $dumpon;
    end
    
    // Monitor signal changes
    initial begin
        $monitor("Time=%0t clk=%b rst=%b enable=%b data_in=%h data_out=%h", 
                 $time, clk, rst, enable, data_in, data_out);
    end

endmodule

//==============================================================================
// End of Testbench
//==============================================================================