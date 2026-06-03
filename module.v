// Elinnos Header
// Copyright (c) 2023 Elinnos, Inc.
// All rights reserved.
// This code is for educational purposes only.

`timescale 1ns/1ps // timescale 1ns/1ps

//==============================================================================
// Module: register_8bit
// Description: 8-bit register with enable control and asynchronous reset
// Author: Elinnos Design Team
// Date: 2023
//==============================================================================
module register_8bit(
    input clk,              // Clock input - rising edge triggered
    input rst,              // Asynchronous reset - active high
    input [7:0] data_in,    // 8-bit data input
    input enable,           // Enable signal - data loaded when high
    output reg [7:0] data_out   // 8-bit registered data output
);

// Register logic: load data when enabled, reset to 0 on reset
always @(posedge clk or posedge rst) begin
    if (rst)
        data_out <= 8'b00000000;   // Reset output to 0
    else if (enable)
        data_out <= data_in;       // Load input data when enabled
    // Note: data_out holds previous value when enable is low
end



//==============================================================================
// End of Module
//==============================================================================
// Footer Information:
// - Module implementation completed
// - For questions or support, contact Elinnos Design Team
// - Last modified: 2024
//==============================================================================