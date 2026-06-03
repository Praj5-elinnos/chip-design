`timescale 1ns/1ps

//==============================================================================
// Complex CPU Design with Nested Modules
// This design demonstrates a hierarchical structure with multiple levels
//==============================================================================

// Top-level CPU module
module complex_cpu (
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [31:0] data_in,
    output wire [31:0] data_out,
    output wire [31:0] address,
    output wire mem_read,
    output wire mem_write,
    output wire [3:0] cpu_state
);

    // Internal signals
    wire [31:0] alu_result;
    wire [31:0] reg_data_a, reg_data_b;
    wire [4:0] reg_addr_a, reg_addr_b, reg_addr_w;
    wire reg_write_en;
    wire [3:0] alu_op;
    wire [31:0] immediate;
    wire branch_taken;
    wire jump_en;
    wire [31:0] pc_next;
    wire [31:0] pc_current;
    wire cache_hit, cache_miss;
    wire [31:0] cache_data;
    
    // Control unit instance
    control_unit ctrl_unit (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .alu_flags(alu_result[31:28]),
        .reg_addr_a(reg_addr_a),
        .reg_addr_b(reg_addr_b),
        .reg_addr_w(reg_addr_w),
        .reg_write_en(reg_write_en),
        .alu_op(alu_op),
        .immediate(immediate),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch_taken(branch_taken),
        .jump_en(jump_en),
        .cpu_state(cpu_state)
    );
    
    // ALU instance
    alu alu_unit (
        .clk(clk),
        .rst(rst),
        .op_a(reg_data_a),
        .op_b(reg_data_b),
        .immediate(immediate),
        .alu_op(alu_op),
        .result(alu_result)
    );
    
    // Register file instance
    register_file reg_file (
        .clk(clk),
        .rst(rst),
        .read_addr_a(reg_addr_a),
        .read_addr_b(reg_addr_b),
        .write_addr(reg_addr_w),
        .write_data(alu_result),
        .write_en(reg_write_en),
        .data_a(reg_data_a),
        .data_b(reg_data_b)
    );
    
    // Memory interface instance
    memory_interface mem_if (
        .clk(clk),
        .rst(rst),
        .address_in(alu_result),
        .data_in(reg_data_b),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .cache_hit(cache_hit),
        .cache_data(cache_data),
        .address_out(address),
        .data_out(data_out)
    );

endmodule

// Control Unit with nested instruction decoder
module control_unit (
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [3:0] alu_flags,
    output reg [4:0] reg_addr_a,
    output reg [4:0] reg_addr_b,
    output reg [4:0] reg_addr_w,
    output reg reg_write_en,
    output reg [3:0] alu_op,
    output reg [31:0] immediate,
    output reg mem_read,
    output reg mem_write,
    output reg branch_taken,
    output reg jump_en,
    output reg [3:0] cpu_state
);

    // Internal signals
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd;
    wire [15:0] imm16;
    wire [25:0] target;
    wire [2:0] decode_type;
    wire decode_valid;
    
    // State machine states
    parameter FETCH = 4'b0000, DECODE = 4'b0001, EXECUTE = 4'b0010, MEMORY = 4'b0011, WRITEBACK = 4'b0100;
    
    // Instruction decoder instance
    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .immediate(imm16),
        .target(target),
        .decode_type(decode_type),
        .valid(decode_valid)
    );
    
    // Pipeline control signals
    reg [2:0] pipeline_stage;
    reg [31:0] instruction_buffer [0:3];
    reg [3:0] hazard_flags;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cpu_state <= FETCH;
            pipeline_stage <= 3'b000;
            reg_write_en <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            branch_taken <= 1'b0;
            jump_en <= 1'b0;
            hazard_flags <= 4'b0000;
        end else begin
            case (cpu_state)
                FETCH: begin
                    cpu_state <= DECODE;
                    instruction_buffer[pipeline_stage] <= instruction;
                    pipeline_stage <= pipeline_stage + 1;
                end
                DECODE: begin
                    reg_addr_a <= rs;
                    reg_addr_b <= rt;
                    reg_addr_w <= rd;
                    immediate <= {{16{imm16[15]}}, imm16};
                    cpu_state <= EXECUTE;
                end
                EXECUTE: begin
                    alu_op <= opcode[3:0];
                    cpu_state <= MEMORY;
                end
                MEMORY: begin
                    mem_read <= (opcode == 6'b100011);
                    mem_write <= (opcode == 6'b101011);
                    cpu_state <= WRITEBACK;
                end
                WRITEBACK: begin
                    reg_write_en <= decode_valid && (decode_type != 3'b111);
                    cpu_state <= FETCH;
                end
            endcase
        end
    end

endmodule

// Instruction decoder
module instruction_decoder (
    input wire [31:0] instruction,
    output wire [5:0] opcode,
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [15:0] immediate,
    output wire [25:0] target,
    output reg [2:0] decode_type,
    output reg valid
);

    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign immediate = instruction[15:0];
    assign target = instruction[25:0];
    
    // Decoder logic
    always @(*) begin
        case (opcode)
            6'b000000: begin // R-type
                decode_type = 3'b001;
                valid = 1'b1;
            end
            6'b001000, 6'b001001: begin // I-type (ADDI, ADDIU)
                decode_type = 3'b010;
                valid = 1'b1;
            end
            6'b000010, 6'b000011: begin // J-type (J, JAL)
                decode_type = 3'b011;
                valid = 1'b1;
            end
            6'b100011, 6'b101011: begin // Load/Store
                decode_type = 3'b100;
                valid = 1'b1;
            end
            default: begin
                decode_type = 3'b000;
                valid = 1'b0;
            end
        endcase
    end

endmodule

// ALU with arithmetic and logic units
module alu (
    input wire clk,
    input wire rst,
    input wire [31:0] op_a,
    input wire [31:0] op_b,
    input wire [31:0] immediate,
    input wire [3:0] alu_op,
    output reg [31:0] result
);

    // Internal computation units
    wire [31:0] add_result, sub_result, and_result, or_result;
    wire [31:0] xor_result, sll_result, srl_result, sra_result;
    wire [31:0] mult_result_lo, mult_result_hi;
    
    // Arithmetic unit
    arithmetic_unit arith_unit (
        .op_a(op_a),
        .op_b(op_b),
        .add_result(add_result),
        .sub_result(sub_result),
        .mult_lo(mult_result_lo),
        .mult_hi(mult_result_hi)
    );
    
    // Logic unit
    logic_unit logic_unit_inst (
        .op_a(op_a),
        .op_b(op_b),
        .and_result(and_result),
        .or_result(or_result),
        .xor_result(xor_result)
    );
    
    // Shift unit
    shift_unit shift_unit_inst (
        .op_a(op_a),
        .shift_amount(op_b[4:0]),
        .sll_result(sll_result),
        .srl_result(srl_result),
        .sra_result(sra_result)
    );
    
    // ALU operation selection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 32'b0;
        end else begin
            case (alu_op)
                4'b0000: result <= add_result;
                4'b0001: result <= sub_result;
                4'b0010: result <= and_result;
                4'b0011: result <= or_result;
                4'b0100: result <= xor_result;
                4'b0101: result <= sll_result;
                4'b0110: result <= srl_result;
                4'b0111: result <= sra_result;
                4'b1000: result <= mult_result_lo;
                default: result <= 32'b0;
            endcase
        end
    end

endmodule

// Arithmetic unit
module arithmetic_unit (
    input wire [31:0] op_a,
    input wire [31:0] op_b,
    output wire [31:0] add_result,
    output wire [31:0] sub_result,
    output wire [31:0] mult_lo,
    output wire [31:0] mult_hi
);

    wire [63:0] mult_full;
    
    assign add_result = op_a + op_b;
    assign sub_result = op_a - op_b;
    assign mult_full = op_a * op_b;
    assign mult_lo = mult_full[31:0];
    assign mult_hi = mult_full[63:32];

endmodule

// Logic unit
module logic_unit (
    input wire [31:0] op_a,
    input wire [31:0] op_b,
    output wire [31:0] and_result,
    output wire [31:0] or_result,
    output wire [31:0] xor_result
);

    assign and_result = op_a & op_b;
    assign or_result = op_a | op_b;
    assign xor_result = op_a ^ op_b;

endmodule

// Shift unit
module shift_unit (
    input wire [31:0] op_a,
    input wire [4:0] shift_amount,
    output wire [31:0] sll_result,
    output wire [31:0] srl_result,
    output wire [31:0] sra_result
);

    assign sll_result = op_a << shift_amount;
    assign srl_result = op_a >> shift_amount;
    assign sra_result = $signed(op_a) >>> shift_amount;

endmodule

// Register file with multiple banks
module register_file (
    input wire clk,
    input wire rst,
    input wire [4:0] read_addr_a,
    input wire [4:0] read_addr_b,
    input wire [4:0] write_addr,
    input wire [31:0] write_data,
    input wire write_en,
    output wire [31:0] data_a,
    output wire [31:0] data_b
);

    wire [31:0] bank0_data_a, bank0_data_b, bank1_data_a, bank1_data_b;
    
    // Register banks
    reg_bank bank0 (.clk(clk), .rst(rst), .addr_a(read_addr_a[3:0]), .addr_b(read_addr_b[3:0]), 
                   .write_addr(write_addr[3:0]), .write_data(write_data), 
                   .write_en(write_en & ~read_addr_a[4]), .data_a(bank0_data_a), .data_b(bank0_data_b));
    
    reg_bank bank1 (.clk(clk), .rst(rst), .addr_a(read_addr_a[3:0]), .addr_b(read_addr_b[3:0]), 
                   .write_addr(write_addr[3:0]), .write_data(write_data), 
                   .write_en(write_en & read_addr_a[4]), .data_a(bank1_data_a), .data_b(bank1_data_b));
    
    assign data_a = read_addr_a[4] ? bank1_data_a : bank0_data_a;
    assign data_b = read_addr_b[4] ? bank1_data_b : bank0_data_b;

endmodule

// Individual register bank
module reg_bank (
    input wire clk,
    input wire rst,
    input wire [3:0] addr_a,
    input wire [3:0] addr_b,
    input wire [3:0] write_addr,
    input wire [31:0] write_data,
    input wire write_en,
    output reg [31:0] data_a,
    output reg [31:0] data_b
);

    reg [31:0] registers [0:15];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (write_en) begin
            registers[write_addr] <= write_data;
        end
    end
    
    always @(*) begin
        data_a = registers[addr_a];
        data_b = registers[addr_b];
    end

endmodule

// Memory interface with cache controller
module memory_interface (
    input wire clk,
    input wire rst,
    input wire [31:0] address_in,
    input wire [31:0] data_in,
    input wire mem_read,
    input wire mem_write,
    output wire cache_hit,
    output wire [31:0] cache_data,
    output reg [31:0] address_out,
    output reg [31:0] data_out
);

    // Cache controller
    cache_controller cache_ctrl (
        .clk(clk),
        .rst(rst),
        .address(address_in),
        .data_in(data_in),
        .read_en(mem_read),
        .write_en(mem_write),
        .hit(cache_hit),
        .data_out(cache_data)
    );
    
    // Memory access logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            address_out <= 32'b0;
            data_out <= 32'b0;
        end else begin
            address_out <= address_in;
            if (cache_hit) begin
                data_out <= cache_data;
            end else begin
                data_out <= 32'hDEADBEEF; // Default data for cache miss
            end
        end
    end

endmodule

// Cache controller with tag and data arrays
module cache_controller (
    input wire clk,
    input wire rst,
    input wire [31:0] address,
    input wire [31:0] data_in,
    input wire read_en,
    input wire write_en,
    output reg hit,
    output reg [31:0] data_out
);

    // Cache parameters
    parameter CACHE_SIZE = 16;
    parameter TAG_BITS = 8;
    parameter INDEX_BITS = 4;
    
    wire [INDEX_BITS-1:0] index;
    wire [TAG_BITS-1:0] tag;
    
    assign index = address[INDEX_BITS+1:2];
    assign tag = address[TAG_BITS+INDEX_BITS+1:INDEX_BITS+2];
    
    // Cache line signals
    wire [31:0] line_data_out [0:CACHE_SIZE-1];
    wire line_hit [0:CACHE_SIZE-1];
    
    // Cache line instances
    genvar i;
    generate
        for (i = 0; i < CACHE_SIZE; i = i + 1) begin : cache_line_gen
            cache_line line (
                .clk(clk),
                .rst(rst),
                .enable(index == i),
                .tag_in(tag),
                .data_in(data_in),
                .read_en(read_en),
                .write_en(write_en),
                .hit(line_hit[i]),
                .data_out(line_data_out[i])
            );
        end
    endgenerate
    
    always @(*) begin
        hit = line_hit[index];
        data_out = line_data_out[index];
    end

endmodule

// Individual cache line
module cache_line (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [7:0] tag_in,
    input wire [31:0] data_in,
    input wire read_en,
    input wire write_en,
    output reg hit,
    output reg [31:0] data_out
);

    reg valid;
    reg [7:0] tag;
    reg [31:0] data;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid <= 1'b0;
            tag <= 8'b0;
            data <= 32'b0;
            hit <= 1'b0;
            data_out <= 32'b0;
        end else if (enable) begin
            if (write_en) begin
                valid <= 1'b1;
                tag <= tag_in;
                data <= data_in;
            end
            
            if (read_en || write_en) begin
                hit <= valid && (tag == tag_in);
                data_out <= data;
            end
        end
    end

endmodule