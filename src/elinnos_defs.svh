//==============================================================================
// Elinnos Design Definitions Header File
// 
// Description: Common definitions, parameters, and utilities for Elinnos
//              chip design projects. This header provides standardized
//              constants, data types, and macros for SystemVerilog designs.
//
// Company: Elinnos Technologies
// Author: Chip Design Team
// Date: December 2024
// Version: 1.0
//
// Usage: `include "elinnos_defs.svh" at the top of your SystemVerilog modules
//==============================================================================

`ifndef ELINNOS_DEFS_SVH
`define ELINNOS_DEFS_SVH

//==============================================================================
// Common Data Width Parameters
//==============================================================================
`define BYTE_WIDTH          8
`define WORD_WIDTH          16  
`define DWORD_WIDTH         32
`define QWORD_WIDTH         64
`define ADDR_WIDTH          32
`define DATA_WIDTH          32

//==============================================================================
// RISC-V ISA Related Definitions
//==============================================================================
`define RISCV_XLEN          32
`define RISCV_REG_COUNT     32
`define RISCV_REG_ADDR_W    5
`define RISCV_INST_WIDTH    32
`define RISCV_PC_WIDTH      32

// RISC-V Instruction Opcodes
`define OPCODE_LUI          7'b0110111
`define OPCODE_AUIPC        7'b0010111
`define OPCODE_JAL          7'b1101111
`define OPCODE_JALR         7'b1100111
`define OPCODE_BRANCH       7'b1100011
`define OPCODE_LOAD         7'b0000011
`define OPCODE_STORE        7'b0100011
`define OPCODE_OP_IMM       7'b0010011
`define OPCODE_OP           7'b0110011
`define OPCODE_FENCE        7'b0001111
`define OPCODE_SYSTEM       7'b1110011

// ALU Operations
`define ALU_ADD             4'b0000
`define ALU_SUB             4'b0001
`define ALU_AND             4'b0010
`define ALU_OR              4'b0011
`define ALU_XOR             4'b0100
`define ALU_SLL             4'b0101
`define ALU_SRL             4'b0110
`define ALU_SRA             4'b0111
`define ALU_SLT             4'b1000
`define ALU_SLTU            4'b1001

//==============================================================================
// Memory System Definitions  
//==============================================================================
`define CACHE_LINE_SIZE     64    // bytes
`define CACHE_WAYS          4     // 4-way set associative
`define CACHE_SIZE_KB       16    // 16KB cache
`define CACHE_ADDR_TAG_W    20
`define CACHE_ADDR_IDX_W    6
`define CACHE_ADDR_OFFSET_W 6

// Memory Access Types
`define MEM_READ            1'b0
`define MEM_WRITE           1'b1

// Memory Strobe Patterns
`define STRB_BYTE           4'b0001
`define STRB_HALF           4'b0011  
`define STRB_WORD           4'b1111

//==============================================================================
// Bus Interface Definitions (AXI4-Lite Compatible)
//==============================================================================
`define AXI_ADDR_WIDTH      32
`define AXI_DATA_WIDTH      32
`define AXI_STRB_WIDTH      4
`define AXI_ID_WIDTH        4
`define AXI_LEN_WIDTH       8

// AXI Response Types
`define AXI_RESP_OKAY       2'b00
`define AXI_RESP_EXOKAY     2'b01
`define AXI_RESP_SLVERR     2'b10
`define AXI_RESP_DECERR     2'b11

//==============================================================================
// Clock and Reset Definitions
//==============================================================================
`define CLK_FREQ_100MHZ     100_000_000
`define CLK_FREQ_50MHZ      50_000_000
`define CLK_FREQ_25MHZ      25_000_000

`define RST_ACTIVE_LOW      1'b0
`define RST_ACTIVE_HIGH     1'b1

//==============================================================================
// Debug and Test Definitions
//==============================================================================
`define DEBUG_ENABLE        1
`define TRACE_ENABLE        1
`define PERF_COUNTERS       1

`ifdef DEBUG_ENABLE
    `define DBG_PRINT(msg)  $display(\"[DEBUG %0t] %s\", $time, msg)
    `define DBG_PRINTF(fmt, args) $display(\"[DEBUG %0t] \" + fmt, $time, args)
`else
    `define DBG_PRINT(msg)
    `define DBG_PRINTF(fmt, args)
`endif

//==============================================================================
// Common Data Structures and Type Definitions
//==============================================================================

// Pipeline Stage Control Signals
typedef struct packed {
    logic valid;
    logic ready;
    logic stall;
    logic flush;
} pipeline_ctrl_t;

// Memory Request Structure
typedef struct packed {
    logic [`ADDR_WIDTH-1:0]     addr;
    logic [`DATA_WIDTH-1:0]     wdata;
    logic [3:0]                 strb;
    logic                       we;
    logic                       req;
} mem_req_t;

// Memory Response Structure  
typedef struct packed {
    logic [`DATA_WIDTH-1:0]     rdata;
    logic                       ready;
    logic                       error;
} mem_resp_t;

// CPU Register File Entry
typedef struct packed {
    logic [`DATA_WIDTH-1:0]     data;
    logic                       valid;
    logic                       dirty;
} cpu_reg_t;

// Cache Line Structure
typedef struct packed {
    logic [`CACHE_ADDR_TAG_W-1:0]   tag;
    logic [`DATA_WIDTH*16-1:0]      data;  // 64 bytes = 16 words
    logic                           valid;
    logic                           dirty;
    logic [1:0]                     lru_bits;
} cache_line_t;

//==============================================================================
// Utility Macros
//==============================================================================

// Clock Edge Macros
`define POSEDGE(clk)        posedge clk
`define NEGEDGE(clk)        negedge clk
`define BOTH_EDGES(clk)     posedge clk or negedge clk

// Reset Condition Macros
`define ASYNC_RST_NEG(clk, rst) posedge clk or negedge rst
`define ASYNC_RST_POS(clk, rst) posedge clk or posedge rst
`define SYNC_RST(clk)       posedge clk

// Array Initialization Macros
`define ZERO_ARRAY(width)   '{width{1'b0}}
`define ONES_ARRAY(width)   '{width{1'b1}}

// Bit Manipulation Macros  
`define GET_BITS(signal, high, low)     signal[high:low]
`define SET_BIT(signal, bit_pos)        signal[bit_pos] = 1'b1
`define CLR_BIT(signal, bit_pos)        signal[bit_pos] = 1'b0
`define TOGGLE_BIT(signal, bit_pos)     signal[bit_pos] = ~signal[bit_pos]

// Sign Extension Macro
`define SIGN_EXTEND(value, from_width, to_width) \\
    {{(to_width-from_width){value[from_width-1]}}, value}

//==============================================================================
// Performance Counter Definitions
//==============================================================================
`ifdef PERF_COUNTERS
typedef struct packed {
    logic [`QWORD_WIDTH-1:0]    cycle_count;
    logic [`QWORD_WIDTH-1:0]    inst_count;
    logic [`QWORD_WIDTH-1:0]    cache_hits;
    logic [`QWORD_WIDTH-1:0]    cache_misses;
    logic [`QWORD_WIDTH-1:0]    pipeline_stalls;
    logic [`QWORD_WIDTH-1:0]    branch_taken;
    logic [`QWORD_WIDTH-1:0]    branch_mispred;
} perf_counters_t;
`endif

//==============================================================================
// Simulation and Synthesis Directives
//==============================================================================

`ifdef SYNTHESIS
    // Synthesis-specific defines
    `define SYN_KEEP            (* keep = \"true\" *)
    `define SYN_DONT_TOUCH      (* dont_touch = \"true\" *)
    `define SYN_BLACK_BOX       (* black_box = \"true\" *)
`else
    // Simulation-specific defines
    `define SYN_KEEP
    `define SYN_DONT_TOUCH  
    `define SYN_BLACK_BOX
    
    // Simulation time controls
    `define SIM_TIMEOUT         #1000000
    `define SIM_DELAY(ns)       #(ns)
`endif

//==============================================================================
// Assertion Macros for Verification
//==============================================================================
`ifdef ASSERTIONS_ON
    `define ASSERT(cond, msg) \\
        assert(cond) else $error(\"ASSERTION FAILED: %s\", msg)
        
    `define ASSERT_CLK(clk, cond, msg) \\
        assert property (@(posedge clk) cond) else $error(\"ASSERTION FAILED: %s\", msg)
        
    `define COVER(cond, msg) \\
        cover(cond) $info(\"COVERAGE: %s\", msg)
`else
    `define ASSERT(cond, msg)
    `define ASSERT_CLK(clk, cond, msg) 
    `define COVER(cond, msg)
`endif

//==============================================================================
// Technology-Specific Definitions
//==============================================================================

// FPGA vendor-specific definitions
`ifdef XILINX
    `define FPGA_VENDOR         \"Xilinx\"
    `define USE_XILINX_PRIMS    1
`elsif INTEL  
    `define FPGA_VENDOR         \"Intel\"
    `define USE_INTEL_PRIMS     1
`elsif LATTICE
    `define FPGA_VENDOR         \"Lattice\"
    `define USE_LATTICE_PRIMS   1
`else
    `define FPGA_VENDOR         \"Generic\"
    `define USE_GENERIC_PRIMS   1
`endif

//==============================================================================
// End of Header File
//==============================================================================

`endif // ELINNOS_DEFS_SVH

//==============================================================================
// Usage Example:
//
// `include \"elinnos_defs.svh\"
//
// module my_module (
//     input  logic                    clk,
//     input  logic                    rst_n,
//     input  mem_req_t               mem_req,
//     output mem_resp_t              mem_resp
// );
//
//     always_ff @(`ASYNC_RST_NEG(clk, rst_n)) begin
//         if (!rst_n) begin
//             // Reset logic
//         end else begin
//             `DBG_PRINT(\"Processing memory request\");
//             // Normal operation
//         end
//     end
//
// endmodule
//==============================================================================