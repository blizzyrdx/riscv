`timescale 1ns/1ps
`default_nettype none //indicates no new wires are made by default, and all wires must be explicitly declared

// performs arithmetic and logical calculations
module rv32_alu (
    input  wire logic [31:0] a, //two 32-bit inputs to the ALU
    input  wire logic [31:0] b,
    input  wire logic [3:0]  op,
    output logic [31:0] y //outputs
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

    always_comb begin
        case (op)
            ALU_ADD : y = a + b;
            ALU_SUB : y = a - b;
            ALU_AND : y = a & b;
            ALU_OR  : y = a | b;
            ALU_XOR : y = a ^ b;
            ALU_SLT : y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU: y = (a < b) ? 32'd1 : 32'd0;
            ALU_SLL : y = a << b[4:0];
            ALU_SRL : y = a >> b[4:0];
            ALU_SRA : y = $signed(a) >>> b[4:0];
            default : y = 32'd0;
        endcase
    end
endmodule

`default_nettype wire
