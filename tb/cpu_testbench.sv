// Advanced CPU Testbench with Coverage
// Comprehensive verification environment

`timescale 1ns/1ps

module cpu_testbench;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter CLK_PERIOD = 10; // 100MHz
    
    // Clock and Reset
    logic clk = 0;
    logic rst_n = 0;
    
    // CPU Interface Signals
    logic [ADDR_WIDTH-1:0]  imem_addr;
    logic [DATA_WIDTH-1:0]  imem_data;
    logic                   imem_req;
    logic                   imem_ready;
    
    logic [ADDR_WIDTH-1:0]  dmem_addr;
    logic [DATA_WIDTH-1:0]  dmem_wdata;
    logic [DATA_WIDTH-1:0]  dmem_rdata;
    logic [3:0]             dmem_strb;
    logic                   dmem_we;
    logic                   dmem_req;
    logic                   dmem_ready;
    
    // Debug Signals
    logic [DATA_WIDTH-1:0]  debug_pc;
    logic [4:0]             debug_reg_addr;
    logic [DATA_WIDTH-1:0]  debug_reg_data;
    logic                   debug_valid;
    
    // Memory Controller Signals
    logic [ADDR_WIDTH-1:0]  ddr_addr;
    logic [DATA_WIDTH-1:0]  ddr_wdata;
    logic [DATA_WIDTH-1:0]  ddr_rdata;
    logic [3:0]             ddr_strb;
    logic                   ddr_we;
    logic                   ddr_req;
    logic                   ddr_ready;
    
    // Performance Counters
    logic [31:0]            cache_hits;
    logic [31:0]            cache_misses;
    logic [31:0]            total_accesses;
    
    // Test Control
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // DUT Instantiation
    cpu_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) cpu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .imem_addr(imem_addr),
        .imem_data(imem_data),
        .imem_req(imem_req),
        .imem_ready(imem_ready),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),
        .dmem_strb(dmem_strb),
        .dmem_we(dmem_we),
        .dmem_req(dmem_req),
        .dmem_ready(dmem_ready),
        .debug_pc(debug_pc),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_data(debug_reg_data),
        .debug_valid(debug_valid)
    );
    
    // Memory Controller
    memory_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem_ctrl_inst (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_addr(dmem_addr),
        .cpu_wdata(dmem_wdata),
        .cpu_rdata(dmem_rdata),
        .cpu_strb(dmem_strb),
        .cpu_we(dmem_we),
        .cpu_req(dmem_req),
        .cpu_ready(dmem_ready),
        .ddr_addr(ddr_addr),
        .ddr_wdata(ddr_wdata),
        .ddr_rdata(ddr_rdata),
        .ddr_strb(ddr_strb),
        .ddr_we(ddr_we),
        .ddr_req(ddr_req),
        .ddr_ready(ddr_ready),
        .cache_hits(cache_hits),
        .cache_misses(cache_misses),
        .total_accesses(total_accesses)
    );
    
    // Instruction Memory Model
    logic [DATA_WIDTH-1:0] instruction_mem [0:1023];
    
    always_comb begin
        imem_ready = imem_req;
        if (imem_req && imem_addr < 32'h1000) begin
            imem_data = instruction_mem[imem_addr[11:2]];
        end else begin
            imem_data = 32'h00000013; // NOP instruction
        end
    end
    
    // DDR Memory Model
    logic [DATA_WIDTH-1:0] ddr_mem [0:65535];
    logic ddr_delay_counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ddr_ready <= 1'b0;
            ddr_delay_counter <= 1'b0;
            ddr_rdata <= '0;
        end else begin
            if (ddr_req && !ddr_ready) begin
                ddr_delay_counter <= ddr_delay_counter + 1;
                if (ddr_delay_counter == 1'b1) begin // 2-cycle delay
                    ddr_ready <= 1'b1;
                    if (!ddr_we) begin
                        ddr_rdata <= ddr_mem[ddr_addr[17:2]];
                    end else begin
                        ddr_mem[ddr_addr[17:2]] <= ddr_wdata;
                    end
                end
            end else if (!ddr_req) begin
                ddr_ready <= 1'b0;
                ddr_delay_counter <= 1'b0;
            end
        end
    end
    
    // Test Tasks
    task reset_system();
        $display("=== Resetting System ===");
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        $display("Reset complete");
    endtask
    
    task load_program();
        $display("=== Loading Test Program ===");
        // Simple test program
        instruction_mem[0] = 32'h00100093; // addi x1, x0, 1
        instruction_mem[1] = 32'h00200113; // addi x2, x0, 2
        instruction_mem[2] = 32'h002081b3; // add x3, x1, x2
        instruction_mem[3] = 32'h40208233; // sub x4, x1, x2
        instruction_mem[4] = 32'h002092b3; // sll x5, x1, x2
        instruction_mem[5] = 32'h0020a333; // slt x6, x1, x2
        instruction_mem[6] = 32'h00000013; // nop
        instruction_mem[7] = 32'h00000013; // nop
        $display("Program loaded");
    endtask
    
    task run_cpu_test(input int cycles);
        $display("=== Running CPU Test for %0d cycles ===", cycles);
        test_count++;
        
        repeat(cycles) begin
            @(posedge clk);
            if (debug_valid) begin
                $display("PC: 0x%08h, Reg[%0d] = 0x%08h", 
                        debug_pc, debug_reg_addr, debug_reg_data);
            end
        end
        
        // Check results
        if (debug_pc > 32'h10) begin
            $display("✅ Test PASSED - CPU executed instructions");
            pass_count++;
        end else begin
            $display("❌ Test FAILED - CPU did not progress");
            fail_count++;
        end
    endtask
    
    task test_cache_performance();
        $display("=== Testing Cache Performance ===");
        test_count++;
        
        // Wait for some cache activity
        repeat(100) @(posedge clk);
        
        real hit_rate = (cache_hits * 100.0) / total_accesses;
        $display("Cache Statistics:");
        $display("  Total Accesses: %0d", total_accesses);
        $display("  Cache Hits: %0d", cache_hits);
        $display("  Cache Misses: %0d", cache_misses);
        $display("  Hit Rate: %.2f%%", hit_rate);
        
        if (total_accesses > 0) begin
            $display("✅ Cache Performance Test PASSED");
            pass_count++;
        end else begin
            $display("❌ Cache Performance Test FAILED");
            fail_count++;
        end
    endtask
    
    // Coverage Collection
    covergroup cpu_coverage @(posedge clk);
        pc_coverage: coverpoint debug_pc {
            bins low_mem = {[0:32'h100]};
            bins mid_mem = {[32'h101:32'h500]};
            bins high_mem = {[32'h501:32'hFFF]};
        }
        
        reg_coverage: coverpoint debug_reg_addr {
            bins reg_range[] = {[0:31]};
        }
        
        cache_hit_coverage: coverpoint cache_hits {
            bins zero = {0};
            bins low = {[1:10]};
            bins medium = {[11:100]};
            bins high = {[101:1000]};
        }
    endgroup
    
    cpu_coverage cov_inst = new();
    
    // Main Test Sequence
    initial begin
        $display("🚀 Starting Advanced CPU Testbench");
        $display("=====================================");
        
        // Initialize
        reset_system();
        load_program();
        
        // Run Tests
        run_cpu_test(50);
        test_cache_performance();
        
        // Wait for completion
        repeat(20) @(posedge clk);
        
        // Final Report
        $display("\n📊 TEST SUMMARY");
        $display("================");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("Coverage: %.2f%%", cov_inst.get_coverage());
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED!");
        end else begin
            $display("❌ %0d TESTS FAILED", fail_count);
        end
        
        // Generate VCD
        $dumpfile("cpu_simulation.vcd");
        $dumpvars(0, cpu_testbench);
        
        $finish;
    end
    
    // Timeout Protection
    initial begin
        #(CLK_PERIOD * 10000);
        $display("⚠️  TIMEOUT - Simulation ended");
        $finish;
    end
    
    // Monitor Critical Signals
    always @(posedge clk) begin
        if (debug_valid && debug_pc == 32'hDEADBEEF) begin
            $display("💀 ERROR: CPU reached invalid PC");
            $finish;
        end
    end

endmodule