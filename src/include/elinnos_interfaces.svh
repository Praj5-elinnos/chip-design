//==============================================================================
// Elinnos Interface Definitions Header File
// 
// Description: Common SystemVerilog interfaces and modports for Elinnos
//              chip design projects. This header provides reusable interface
//              definitions for standard bus protocols and internal connections.
//
// Company: Elinnos Technologies  
// Author: Chip Design Team
// Date: December 2024
// Version: 1.0
//
// Usage: `include \"elinnos_interfaces.svh\" after including elinnos_defs.svh
//==============================================================================

`ifndef ELINNOS_INTERFACES_SVH
`define ELINNOS_INTERFACES_SVH

`include \"elinnos_defs.svh\"

//==============================================================================
// Memory Interface - Standard memory bus with ready/valid handshaking
//==============================================================================
interface mem_if #(
    parameter ADDR_WIDTH = `ADDR_WIDTH,
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input logic clk,
    input logic rst_n
);

    // Address and data signals
    logic [ADDR_WIDTH-1:0]  addr;
    logic [DATA_WIDTH-1:0]  wdata;
    logic [DATA_WIDTH-1:0]  rdata;
    logic [3:0]             strb;
    logic                   we;
    logic                   req;
    logic                   ready;
    logic                   error;

    // Master modport (CPU, DMA, etc.)
    modport master (
        output  addr, wdata, strb, we, req,
        input   rdata, ready, error
    );

    // Slave modport (Memory, peripherals)  
    modport slave (
        input   addr, wdata, strb, we, req,
        output  rdata, ready, error
    );

    // Monitor modport for verification
    modport monitor (
        input   addr, wdata, rdata, strb, we, req, ready, error
    );

endinterface : mem_if

//==============================================================================
// AXI4-Lite Interface - Industry standard bus interface
//==============================================================================
interface axi4_lite_if #(
    parameter ADDR_WIDTH = `AXI_ADDR_WIDTH,
    parameter DATA_WIDTH = `AXI_DATA_WIDTH
) (
    input logic aclk,
    input logic aresetn
);

    // Write Address Channel
    logic [ADDR_WIDTH-1:0]      awaddr;
    logic [2:0]                 awprot;
    logic                       awvalid;
    logic                       awready;

    // Write Data Channel  
    logic [DATA_WIDTH-1:0]      wdata;
    logic [DATA_WIDTH/8-1:0]    wstrb;
    logic                       wvalid;
    logic                       wready;

    // Write Response Channel
    logic [1:0]                 bresp;
    logic                       bvalid;
    logic                       bready;

    // Read Address Channel
    logic [ADDR_WIDTH-1:0]      araddr;
    logic [2:0]                 arprot;
    logic                       arvalid;
    logic                       arready;

    // Read Data Channel
    logic [DATA_WIDTH-1:0]      rdata;
    logic [1:0]                 rresp;
    logic                       rvalid;
    logic                       rready;

    // Master modport
    modport master (
        output  awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready,
                araddr, arprot, arvalid, rready,
        input   awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );

    // Slave modport
    modport slave (
        input   awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready,
                araddr, arprot, arvalid, rready,
        output  awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );

endinterface : axi4_lite_if

//==============================================================================
// CPU Debug Interface - For RISC-V debug module connection
//==============================================================================
interface cpu_debug_if #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input logic clk,
    input logic rst_n
);

    // Debug signals
    logic [DATA_WIDTH-1:0]      pc;
    logic [4:0]                 reg_addr;
    logic [DATA_WIDTH-1:0]      reg_data;
    logic [DATA_WIDTH-1:0]      csr_data;
    logic                       valid;
    logic                       halt_req;
    logic                       resume_req;
    logic                       step_req;
    logic                       halted;
    logic                       running;

    // Debug Master (Debug Module)
    modport master (
        input   pc, reg_data, csr_data, valid, halted, running,
        output  reg_addr, halt_req, resume_req, step_req
    );

    // Debug Slave (CPU Core)
    modport slave (
        output  pc, reg_data, csr_data, valid, halted, running,
        input   reg_addr, halt_req, resume_req, step_req
    );

endinterface : cpu_debug_if

//==============================================================================
// Cache Control Interface - For cache coherency and control
//==============================================================================
interface cache_ctrl_if (
    input logic clk,
    input logic rst_n
);

    // Cache control signals
    logic           flush_req;
    logic           flush_ack;
    logic           invalidate_req;
    logic           invalidate_ack;
    logic           writeback_req;
    logic           writeback_ack;
    logic           cache_enable;
    logic [31:0]    cache_config;

    // Statistics
    logic [31:0]    hit_count;
    logic [31:0]    miss_count;
    logic [31:0]    eviction_count;

    // Controller modport
    modport controller (
        output  flush_req, invalidate_req, writeback_req, cache_enable, cache_config,
        input   flush_ack, invalidate_ack, writeback_ack, hit_count, miss_count, eviction_count
    );

    // Cache modport
    modport cache (
        input   flush_req, invalidate_req, writeback_req, cache_enable, cache_config,
        output  flush_ack, invalidate_ack, writeback_ack, hit_count, miss_count, eviction_count
    );

endinterface : cache_ctrl_if

//==============================================================================
// Interrupt Interface - Standard interrupt controller interface
//==============================================================================
interface interrupt_if #(
    parameter NUM_INTERRUPTS = 32
) (
    input logic clk,
    input logic rst_n
);

    // Interrupt signals
    logic [NUM_INTERRUPTS-1:0]  irq;
    logic [NUM_INTERRUPTS-1:0]  irq_enable;
    logic [NUM_INTERRUPTS-1:0]  irq_pending;
    logic [4:0]                 irq_id;
    logic                       irq_valid;
    logic                       irq_ack;

    // Interrupt Controller modport
    modport controller (
        input   irq, irq_ack,
        output  irq_enable, irq_pending, irq_id, irq_valid
    );

    // CPU modport  
    modport cpu (
        output  irq_ack,
        input   irq_id, irq_valid
    );

    // Peripheral modport
    modport peripheral (
        output  irq,
        input   irq_enable, irq_pending
    );

endinterface : interrupt_if

//==============================================================================
// Clock and Reset Interface - Standard clock domain interface
//==============================================================================
interface clk_rst_if (
    input logic clk,
    input logic rst_n
);

    // Clock control
    logic       clk_enable;
    logic       clk_ready;
    logic [7:0] clk_divider;
    
    // Reset control
    logic       soft_reset;
    logic       reset_done;

    // Clock generator modport
    modport generator (
        input   clk_enable, clk_divider, soft_reset,
        output  clk_ready, reset_done
    );

    // Consumer modport
    modport consumer (
        output  clk_enable, clk_divider, soft_reset,
        input   clk_ready, reset_done
    );

endinterface : clk_rst_if

//==============================================================================
// Performance Monitor Interface - For performance counters and profiling
//==============================================================================
interface perf_monitor_if (
    input logic clk,
    input logic rst_n
);

    // Performance events
    logic       cycle_count_en;
    logic       inst_count_en; 
    logic       cache_hit_event;
    logic       cache_miss_event;
    logic       branch_taken_event;
    logic       branch_mispred_event;
    logic       pipeline_stall_event;

    // Counter values
    logic [63:0] cycle_counter;
    logic [63:0] inst_counter;
    logic [63:0] cache_hit_counter;
    logic [63:0] cache_miss_counter;
    logic [63:0] branch_taken_counter;
    logic [63:0] branch_mispred_counter;
    logic [63:0] pipeline_stall_counter;

    // Control signals
    logic        counter_reset;
    logic        counter_enable;

    // Monitor modport
    modport monitor (
        output  cycle_counter, inst_counter, cache_hit_counter, cache_miss_counter,
                branch_taken_counter, branch_mispred_counter, pipeline_stall_counter,
        input   cycle_count_en, inst_count_en, cache_hit_event, cache_miss_event,
                branch_taken_event, branch_mispred_event, pipeline_stall_event,
                counter_reset, counter_enable
    );

    // CPU modport
    modport cpu (
        input   cycle_counter, inst_counter, cache_hit_counter, cache_miss_counter,
                branch_taken_counter, branch_mispred_counter, pipeline_stall_counter,
        output  cycle_count_en, inst_count_en, cache_hit_event, cache_miss_event,
                branch_taken_event, branch_mispred_event, pipeline_stall_event,
                counter_reset, counter_enable
    );

endinterface : perf_monitor_if

//==============================================================================
// JTAG Interface - Standard JTAG TAP interface
//==============================================================================
interface jtag_if (
    input logic tck,
    input logic trst_n
);

    // JTAG TAP signals
    logic       tms;
    logic       tdi;
    logic       tdo;
    logic       tdo_oe;

    // TAP controller modport
    modport tap_controller (
        input   tms, tdi,
        output  tdo, tdo_oe
    );

    // External modport
    modport external (
        output  tms, tdi,
        input   tdo, tdo_oe
    );

endinterface : jtag_if

//==============================================================================
// Utility Functions for Interface Connections
//==============================================================================

// Function to connect two memory interfaces
function automatic void connect_mem_if(
    mem_if master,
    mem_if slave
);
    slave.addr  = master.addr;
    slave.wdata = master.wdata;
    slave.strb  = master.strb;
    slave.we    = master.we;
    slave.req   = master.req;
    
    master.rdata = slave.rdata;
    master.ready = slave.ready;
    master.error = slave.error;
endfunction

// Function to initialize AXI4-Lite interface to idle state
function automatic void init_axi4_lite_if(axi4_lite_if axi);
    // Write address channel
    axi.awaddr  = '0;
    axi.awprot  = '0;
    axi.awvalid = '0;
    
    // Write data channel
    axi.wdata   = '0;
    axi.wstrb   = '0;
    axi.wvalid  = '0;
    
    // Write response channel
    axi.bready  = '0;
    
    // Read address channel
    axi.araddr  = '0;
    axi.arprot  = '0;
    axi.arvalid = '0;
    
    // Read data channel
    axi.rready  = '0;
endfunction

`endif // ELINNOS_INTERFACES_SVH

//==============================================================================
// End of Interfaces Header File  
//==============================================================================