// CPU Core - 32-bit RISC-V Pipeline
// Advanced chip design with performance optimizations

module cpu_core #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter REG_COUNT = 32
) (
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Instruction Memory Interface
    output logic [ADDR_WIDTH-1:0]  imem_addr,
    input  logic [DATA_WIDTH-1:0]  imem_data,
    output logic                   imem_req,
    input  logic                   imem_ready,
    
    // Data Memory Interface
    output logic [ADDR_WIDTH-1:0]  dmem_addr,
    output logic [DATA_WIDTH-1:0]  dmem_wdata,
    input  logic [DATA_WIDTH-1:0]  dmem_rdata,
    output logic [3:0]             dmem_strb,
    output logic                   dmem_we,
    output logic                   dmem_req,
    input  logic                   dmem_ready,
    
    // Debug Interface
    output logic [DATA_WIDTH-1:0]  debug_pc,
    output logic [4:0]             debug_reg_addr,
    output logic [DATA_WIDTH-1:0]  debug_reg_data,
    output logic                   debug_valid
);

    // Pipeline Registers
    typedef struct packed {
        logic [DATA_WIDTH-1:0] pc;
        logic [DATA_WIDTH-1:0] instruction;
        logic                  valid;
    } if_id_reg_t;
    
    typedef struct packed {
        logic [DATA_WIDTH-1:0] pc;
        logic [DATA_WIDTH-1:0] rs1_data;
        logic [DATA_WIDTH-1:0] rs2_data;
        logic [DATA_WIDTH-1:0] imm;
        logic [4:0]            rd_addr;
        logic [6:0]            opcode;
        logic [2:0]            funct3;
        logic [6:0]            funct7;
        logic                  reg_write;
        logic                  mem_read;
        logic                  mem_write;
        logic                  valid;
    } id_ex_reg_t;
    
    if_id_reg_t  if_id_reg, if_id_next;
    id_ex_reg_t  id_ex_reg, id_ex_next;
    
    // Register File
    logic [DATA_WIDTH-1:0] reg_file [REG_COUNT-1:0];
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [DATA_WIDTH-1:0] rs1_data, rs2_data, rd_data;
    logic reg_write_en;
    
    // ALU
    logic [DATA_WIDTH-1:0] alu_a, alu_b, alu_result;
    logic [3:0] alu_op;
    logic alu_zero, alu_overflow;
    
    // Control Unit
    logic branch_taken, jump;
    logic [DATA_WIDTH-1:0] branch_target;
    
    // Pipeline Control
    logic stall, flush;
    
    // Program Counter
    logic [DATA_WIDTH-1:0] pc, pc_next;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= '0;
            if_id_reg <= '0;
            id_ex_reg <= '0;
            reg_file <= '{default: '0};
        end else begin
            if (!stall) begin
                pc <= pc_next;
                if_id_reg <= if_id_next;
                id_ex_reg <= id_ex_next;
            end
            
            // Register Write Back
            if (reg_write_en && rd_addr != 5'b0) begin
                reg_file[rd_addr] <= rd_data;
            end
        end
    end
    
    // Instruction Fetch Stage
    assign imem_addr = pc;
    assign imem_req = 1'b1;
    
    always_comb begin
        if_id_next.pc = pc;
        if_id_next.instruction = imem_data;
        if_id_next.valid = imem_ready && !flush;
        
        // PC Update Logic
        if (branch_taken || jump) begin
            pc_next = branch_target;
        end else begin
            pc_next = pc + 4;
        end
    end
    
    // Instruction Decode Stage
    assign rs1_addr = if_id_reg.instruction[19:15];
    assign rs2_addr = if_id_reg.instruction[24:20];
    assign rd_addr = if_id_reg.instruction[11:7];
    
    assign rs1_data = reg_file[rs1_addr];
    assign rs2_data = reg_file[rs2_addr];
    
    // ALU Implementation
    alu_unit #(.DATA_WIDTH(DATA_WIDTH)) alu_inst (
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result),
        .zero(alu_zero),
        .overflow(alu_overflow)
    );
    
    // Debug Interface
    assign debug_pc = pc;
    assign debug_reg_addr = rd_addr;
    assign debug_reg_data = reg_file[rd_addr];
    assign debug_valid = if_id_reg.valid;
    
endmodule

// ALU Unit
module alu_unit #(
    parameter DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0] a,
    input  logic [DATA_WIDTH-1:0] b,
    input  logic [3:0]            op,
    output logic [DATA_WIDTH-1:0] result,
    output logic                  zero,
    output logic                  overflow
);

    always_comb begin
        case (op)
            4'b0000: result = a + b;           // ADD
            4'b0001: result = a - b;           // SUB
            4'b0010: result = a & b;           // AND
            4'b0011: result = a | b;           // OR
            4'b0100: result = a ^ b;           // XOR
            4'b0101: result = a << b[4:0];     // SLL
            4'b0110: result = a >> b[4:0];     // SRL
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA
            4'b1000: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1001: result = (a < b) ? 1 : 0; // SLTU
            default: result = '0;
        endcase
        
        zero = (result == '0);
        overflow = ((a[31] == b[31]) && (result[31] != a[31])) && (op == 4'b0000 || op == 4'b0001);
    end

endmodule