`timescale 1ns/1ps
`default_nettype none

// actual CPU core module
// nettype and timescale are set to override

module rv32_core (
    input  wire logic        clk,
    input  wire logic        reset,
    input  wire logic        ce,

    output logic [31:0] pc,
    input  wire logic [31:0] instr,

    output logic        mem_we,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    input  wire logic [31:0] mem_rdata,

    output logic [31:0] debug_x1
);
    localparam logic [3:0]
        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4,
        ALU_SLT  = 4'd5,
        ALU_SLTU = 4'd6,
        ALU_SLL  = 4'd7,
        ALU_SRL  = 4'd8,
        ALU_SRA  = 4'd9;

    localparam logic [6:0]
        OPCODE_LUI    = 7'b0110111,
        OPCODE_AUIPC  = 7'b0010111,
        OPCODE_JAL    = 7'b1101111,
        OPCODE_JALR   = 7'b1100111,
        OPCODE_BRANCH = 7'b1100011,
        OPCODE_LOAD   = 7'b0000011,
        OPCODE_STORE  = 7'b0100011,
        OPCODE_OPIMM  = 7'b0010011,
        OPCODE_OP     = 7'b0110011;

    logic [31:0] next_pc;
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rs1, rs2, rd;

    logic [31:0] rs1_data, rs2_data;
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    logic [31:0] alu_a, alu_b, alu_y;
    logic [3:0]  alu_op;

    logic        rd_we_dec;
    logic [31:0] rd_wdata;
    logic        store_dec;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31:12], 12'b0};
    assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    rv32_regfile regfile_i (
        .clk      (clk),
        .reset    (reset),
        .we       (rd_we_dec && ce),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .wd       (rd_wdata),
        .rd1      (rs1_data),
        .rd2      (rs2_data),
        .debug_x1 (debug_x1)
    );

    rv32_alu alu_i (
        .a  (alu_a),
        .b  (alu_b),
        .op (alu_op),
        .y  (alu_y)
    );

    always_ff @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else if (ce)
            pc <= next_pc;
    end

    always_comb begin
        next_pc   = pc + 32'd4;
        rd_we_dec = 1'b0;
        rd_wdata  = 32'd0;
        store_dec = 1'b0;

        alu_a     = rs1_data;
        alu_b     = rs2_data;
        alu_op    = ALU_ADD;

        mem_addr  = rs1_data + imm_i;
        mem_wdata = rs2_data;

        case (opcode)
            OPCODE_LUI: begin
                rd_we_dec = 1'b1;
                rd_wdata  = imm_u;
            end

            OPCODE_AUIPC: begin
                rd_we_dec = 1'b1;
                rd_wdata  = pc + imm_u;
            end

            OPCODE_JAL: begin
                rd_we_dec = 1'b1;
                rd_wdata  = pc + 32'd4;
                next_pc   = pc + imm_j;
            end

            OPCODE_JALR: begin
                if (funct3 == 3'b000) begin
                    rd_we_dec = 1'b1;
                    rd_wdata  = pc + 32'd4;
                    next_pc   = (rs1_data + imm_i) & 32'hFFFF_FFFE;
                end
            end

            OPCODE_BRANCH: begin
                case (funct3)
                    3'b000: if (rs1_data == rs2_data)               next_pc = pc + imm_b; // BEQ
                    3'b001: if (rs1_data != rs2_data)               next_pc = pc + imm_b; // BNE
                    3'b100: if ($signed(rs1_data) < $signed(rs2_data))  next_pc = pc + imm_b; // BLT
                    3'b101: if ($signed(rs1_data) >= $signed(rs2_data)) next_pc = pc + imm_b; // BGE
                    3'b110: if (rs1_data < rs2_data)                next_pc = pc + imm_b; // BLTU
                    3'b111: if (rs1_data >= rs2_data)               next_pc = pc + imm_b; // BGEU
                    default: ;
                endcase
            end

            OPCODE_LOAD: begin
                // This educational core implements LW only.
                if (funct3 == 3'b010) begin
                    mem_addr  = rs1_data + imm_i;
                    rd_we_dec = 1'b1;
                    rd_wdata  = mem_rdata;
                end
            end

            OPCODE_STORE: begin
                // This educational core implements SW only.
                if (funct3 == 3'b010) begin
                    mem_addr  = rs1_data + imm_s;
                    mem_wdata = rs2_data;
                    store_dec = 1'b1;
                end
            end

            OPCODE_OPIMM: begin
                rd_we_dec = 1'b1;
                alu_a     = rs1_data;
                alu_b     = imm_i;

                case (funct3)
                    3'b000: alu_op = ALU_ADD;  // ADDI
                    3'b010: alu_op = ALU_SLT;  // SLTI
                    3'b011: alu_op = ALU_SLTU; // SLTIU
                    3'b100: alu_op = ALU_XOR;  // XORI
                    3'b110: alu_op = ALU_OR;   // ORI
                    3'b111: alu_op = ALU_AND;  // ANDI
                    3'b001: begin               // SLLI
                        alu_op = ALU_SLL;
                        alu_b  = {27'd0, instr[24:20]};
                    end
                    3'b101: begin
                        alu_b = {27'd0, instr[24:20]};
                        alu_op = instr[30] ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    end
                    default: alu_op = ALU_ADD;
                endcase

                rd_wdata = alu_y;
            end

            OPCODE_OP: begin
                rd_we_dec = 1'b1;
                alu_a     = rs1_data;
                alu_b     = rs2_data;

                case (funct3)
                    3'b000: alu_op = instr[30] ? ALU_SUB : ALU_ADD; // SUB/ADD
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase

                rd_wdata = alu_y;
            end

            default: begin
                // Unknown instruction behaves like a NOP.
            end
        endcase
    end

    // A store is committed only on a CPU clock-enable pulse.
    assign mem_we = store_dec && ce;

endmodule

`default_nettype wire
