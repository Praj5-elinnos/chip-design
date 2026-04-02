// Advanced Memory Controller with Cache
// High-performance memory subsystem

module memory_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter CACHE_SIZE = 1024,
    parameter CACHE_WAYS = 4
) (
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU Interface
    input  logic [ADDR_WIDTH-1:0]  cpu_addr,
    input  logic [DATA_WIDTH-1:0]  cpu_wdata,
    output logic [DATA_WIDTH-1:0]  cpu_rdata,
    input  logic [3:0]             cpu_strb,
    input  logic                   cpu_we,
    input  logic                   cpu_req,
    output logic                   cpu_ready,
    
    // DDR Interface
    output logic [ADDR_WIDTH-1:0]  ddr_addr,
    output logic [DATA_WIDTH-1:0]  ddr_wdata,
    input  logic [DATA_WIDTH-1:0]  ddr_rdata,
    output logic [3:0]             ddr_strb,
    output logic                   ddr_we,
    output logic                   ddr_req,
    input  logic                   ddr_ready,
    
    // Performance Counters
    output logic [31:0]            cache_hits,
    output logic [31:0]            cache_misses,
    output logic [31:0]            total_accesses
);

    // Cache Line Structure
    typedef struct packed {
        logic                       valid;
        logic                       dirty;
        logic [19:0]               tag;
        logic [DATA_WIDTH-1:0]     data[4]; // 4-word cache line
    } cache_line_t;
    
    // Cache Memory
    cache_line_t cache_mem [CACHE_SIZE/CACHE_WAYS-1:0][CACHE_WAYS-1:0];
    
    // Cache Controller State Machine
    typedef enum logic [2:0] {
        IDLE,
        CACHE_CHECK,
        CACHE_HIT,
        CACHE_MISS,
        DDR_READ,
        DDR_WRITE,
        CACHE_UPDATE
    } cache_state_t;
    
    cache_state_t state, next_state;
    
    // Address Breakdown
    logic [19:0] addr_tag;
    logic [7:0]  addr_index;
    logic [3:0]  addr_offset;
    
    assign {addr_tag, addr_index, addr_offset} = cpu_addr;
    
    // Cache Hit/Miss Logic
    logic cache_hit;
    logic [1:0] hit_way;
    logic [1:0] replace_way;
    
    // Performance Counters
    logic [31:0] hit_counter, miss_counter, access_counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            hit_counter <= '0;
            miss_counter <= '0;
            access_counter <= '0;
            
            // Initialize cache
            for (int i = 0; i < CACHE_SIZE/CACHE_WAYS; i++) begin
                for (int j = 0; j < CACHE_WAYS; j++) begin
                    cache_mem[i][j].valid <= 1'b0;
                    cache_mem[i][j].dirty <= 1'b0;
                    cache_mem[i][j].tag <= '0;
                end
            end
        end else begin
            state <= next_state;
            
            // Update performance counters
            if (cpu_req && state == IDLE) begin
                access_counter <= access_counter + 1;
            end
            
            if (cache_hit && state == CACHE_CHECK) begin
                hit_counter <= hit_counter + 1;
            end else if (!cache_hit && state == CACHE_CHECK) begin
                miss_counter <= miss_counter + 1;
            end
        end
    end
    
    // Cache Hit Detection
    always_comb begin
        cache_hit = 1'b0;
        hit_way = 2'b00;
        
        for (int i = 0; i < CACHE_WAYS; i++) begin
            if (cache_mem[addr_index][i].valid && 
                cache_mem[addr_index][i].tag == addr_tag) begin
                cache_hit = 1'b1;
                hit_way = i[1:0];
                break;
            end
        end
    end
    
    // LRU Replacement Policy (simplified)
    logic [1:0] lru_counter [CACHE_SIZE/CACHE_WAYS-1:0];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < CACHE_SIZE/CACHE_WAYS; i++) begin
                lru_counter[i] <= 2'b00;
            end
        end else if (cache_hit && state == CACHE_HIT) begin
            lru_counter[addr_index] <= hit_way;
        end else if (state == CACHE_UPDATE) begin
            lru_counter[addr_index] <= (lru_counter[addr_index] + 1) % CACHE_WAYS;
        end
    end
    
    assign replace_way = lru_counter[addr_index];
    
    // State Machine
    always_comb begin
        next_state = state;
        cpu_ready = 1'b0;
        ddr_req = 1'b0;
        ddr_we = 1'b0;
        ddr_addr = '0;
        ddr_wdata = '0;
        ddr_strb = '0;
        cpu_rdata = '0;
        
        case (state)
            IDLE: begin
                if (cpu_req) begin
                    next_state = CACHE_CHECK;
                end
                cpu_ready = !cpu_req;
            end
            
            CACHE_CHECK: begin
                if (cache_hit) begin
                    next_state = CACHE_HIT;
                end else begin
                    next_state = CACHE_MISS;
                end
            end
            
            CACHE_HIT: begin
                cpu_rdata = cache_mem[addr_index][hit_way].data[addr_offset[3:2]];
                cpu_ready = 1'b1;
                next_state = IDLE;
            end
            
            CACHE_MISS: begin
                // Check if we need to write back dirty line
                if (cache_mem[addr_index][replace_way].valid && 
                    cache_mem[addr_index][replace_way].dirty) begin
                    next_state = DDR_WRITE;
                end else begin
                    next_state = DDR_READ;
                end
            end
            
            DDR_READ: begin
                ddr_req = 1'b1;
                ddr_we = 1'b0;
                ddr_addr = {addr_tag, addr_index, 4'b0000}; // Aligned address
                
                if (ddr_ready) begin
                    next_state = CACHE_UPDATE;
                end
            end
            
            DDR_WRITE: begin
                ddr_req = 1'b1;
                ddr_we = 1'b1;
                ddr_addr = {cache_mem[addr_index][replace_way].tag, addr_index, 4'b0000};
                ddr_wdata = cache_mem[addr_index][replace_way].data[0];
                ddr_strb = 4'b1111;
                
                if (ddr_ready) begin
                    next_state = DDR_READ;
                end
            end
            
            CACHE_UPDATE: begin
                next_state = CACHE_HIT;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Cache Update Logic
    always_ff @(posedge clk) begin
        if (state == CACHE_UPDATE && ddr_ready) begin
            cache_mem[addr_index][replace_way].valid <= 1'b1;
            cache_mem[addr_index][replace_way].dirty <= 1'b0;
            cache_mem[addr_index][replace_way].tag <= addr_tag;
            cache_mem[addr_index][replace_way].data[0] <= ddr_rdata;
        end
        
        // Handle cache writes
        if (state == CACHE_HIT && cpu_we) begin
            cache_mem[addr_index][hit_way].data[addr_offset[3:2]] <= cpu_wdata;
            cache_mem[addr_index][hit_way].dirty <= 1'b1;
        end
    end
    
    // Performance Counter Outputs
    assign cache_hits = hit_counter;
    assign cache_misses = miss_counter;
    assign total_accesses = access_counter;
    
endmodule