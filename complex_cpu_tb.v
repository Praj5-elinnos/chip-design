`timescale 1ns/1ps

//==============================================================================
// Complex CPU Testbench
// Generates extensive signal activity for VCD dump
//==============================================================================

module complex_cpu_tb;

    // Clock and reset
    reg clk;
    reg rst;
    
    // CPU interface signals
    reg [31:0] instruction;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire [31:0] address;
    wire mem_read;
    wire mem_write;
    wire [3:0] cpu_state;
    
    // Test vectors
    reg [31:0] test_instructions [0:31];
    reg [31:0] test_data [0:31];
    integer test_count;
    integer cycle_count;
    
    // DUT instantiation
    complex_cpu dut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .data_in(data_in),
        .data_out(data_out),
        .address(address),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .cpu_state(cpu_state)
    );
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test stimulus
    initial begin
        // Initialize VCD dump
        $dumpfile("dummy_waveforms.vcd");
        $dumpvars(0, complex_cpu_tb);
        
        // Initialize test vectors
        initialize_test_vectors;
        
        // Reset sequence
        rst = 1'b1;
        instruction = 32'h00000000;
        data_in = 32'h00000000;
        test_count = 0;
        cycle_count = 0;
        
        repeat (5) @(posedge clk);
        rst = 1'b0;
        
        // Run test sequence
        repeat (200) begin
            @(posedge clk);
            
            // Update instruction every 5 cycles
            if (cycle_count % 5 == 0) begin
                instruction = test_instructions[test_count % 32];
                data_in = test_data[test_count % 32];
                test_count = test_count + 1;
            end
            
            // Generate some random data activity
            if (cycle_count % 3 == 0) begin
                data_in = $random;
            end
            
            cycle_count = cycle_count + 1;
            
            // Display progress
            if (cycle_count % 20 == 0) begin
                $display("Cycle %0d: State=%0d, Addr=%08h, Data=%08h", 
                         cycle_count, cpu_state, address, data_out);
            end
        end
        
        // Additional stress test with rapid instruction changes
        $display("Starting stress test...");
        repeat (100) begin
            @(posedge clk);
            instruction = $random;
            data_in = $random;
            cycle_count = cycle_count + 1;
        end
        
        // Final simulation time
        repeat (10) @(posedge clk);
        
        $display("Simulation completed at cycle %0d", cycle_count);
        $finish;
    end
    
    // Initialize test instruction patterns
    task initialize_test_vectors;
        begin
            // R-type instructions (ADD, SUB, AND, OR)
            test_instructions[0]  = 32'h00221020; // ADD $2, $1, $2
            test_instructions[1]  = 32'h00432022; // SUB $4, $2, $3
            test_instructions[2]  = 32'h00642824; // AND $5, $3, $4
            test_instructions[3]  = 32'h00853825; // OR  $7, $4, $5
            
            // I-type instructions (ADDI, LW, SW)
            test_instructions[4]  = 32'h20010001; // ADDI $1, $0, 1
            test_instructions[5]  = 32'h20020002; // ADDI $2, $0, 2
            test_instructions[6]  = 32'h8C230000; // LW $3, 0($1)
            test_instructions[7]  = 32'hAC240004; // SW $4, 4($1)
            
            // J-type instructions
            test_instructions[8]  = 32'h08000010; // J 0x10
            test_instructions[9]  = 32'h0C000020; // JAL 0x20
            
            // More complex patterns
            test_instructions[10] = 32'h00A62820; // ADD $5, $5, $6
            test_instructions[11] = 32'h00E73022; // SUB $6, $7, $7
            test_instructions[12] = 32'h01094024; // AND $8, $8, $9
            test_instructions[13] = 32'h012A4825; // OR $9, $9, $10
            test_instructions[14] = 32'h014B5026; // XOR $10, $10, $11
            test_instructions[15] = 32'h016C5827; // NOR $11, $11, $12
            
            // Shift operations
            test_instructions[16] = 32'h00016080; // SLL $12, $1, 2
            test_instructions[17] = 32'h00026882; // SRL $13, $2, 2
            test_instructions[18] = 32'h00037083; // SRA $14, $3, 2
            
            // Branch instructions
            test_instructions[19] = 32'h10220001; // BEQ $1, $2, 1
            test_instructions[20] = 32'h14230001; // BNE $1, $3, 1
            test_instructions[21] = 32'h18240001; // BLEZ $1, 1
            test_instructions[22] = 32'h1C250001; // BGTZ $1, 1
            
            // Load/Store variants
            test_instructions[23] = 32'h8C010008; // LW $1, 8($0)
            test_instructions[24] = 32'hAC02000C; // SW $2, 12($0)
            test_instructions[25] = 32'h90030010; // LB $3, 16($0)
            test_instructions[26] = 32'hA0040014; // SB $4, 20($0)
            
            // Immediate operations
            test_instructions[27] = 32'h2001FFFF; // ADDI $1, $0, -1
            test_instructions[28] = 32'h24027FFF; // ADDIU $2, $0, 32767
            test_instructions[29] = 32'h3003FFFF; // ANDI $3, $0, 65535
            test_instructions[30] = 32'h3404AAAA; // ORI $4, $0, 43690
            test_instructions[31] = 32'h38055555; // XORI $5, $0, 21845
            
            // Initialize test data patterns
            test_data[0]  = 32'h12345678;
            test_data[1]  = 32'h9ABCDEF0;
            test_data[2]  = 32'hFEDCBA98;
            test_data[3]  = 32'h76543210;
            test_data[4]  = 32'hAAAAAAAA;
            test_data[5]  = 32'h55555555;
            test_data[6]  = 32'hF0F0F0F0;
            test_data[7]  = 32'h0F0F0F0F;
            test_data[8]  = 32'hFF00FF00;
            test_data[9]  = 32'h00FF00FF;
            test_data[10] = 32'hFFFF0000;
            test_data[11] = 32'h0000FFFF;
            test_data[12] = 32'h80000000;
            test_data[13] = 32'h7FFFFFFF;
            test_data[14] = 32'h40000000;
            test_data[15] = 32'h20000000;
            test_data[16] = 32'h10000000;
            test_data[17] = 32'h08000000;
            test_data[18] = 32'h04000000;
            test_data[19] = 32'h02000000;
            test_data[20] = 32'h01000000;
            test_data[21] = 32'h00800000;
            test_data[22] = 32'h00400000;
            test_data[23] = 32'h00200000;
            test_data[24] = 32'h00100000;
            test_data[25] = 32'h00080000;
            test_data[26] = 32'h00040000;
            test_data[27] = 32'h00020000;
            test_data[28] = 32'h00010000;
            test_data[29] = 32'h00008000;
            test_data[30] = 32'h00004000;
            test_data[31] = 32'h00002000;
        end
    endtask
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: clk=%b rst=%b state=%0d instruction=%08h data_out=%08h", 
                 $time, clk, rst, cpu_state, instruction, data_out);
    end
    
endmodule