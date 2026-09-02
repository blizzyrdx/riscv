`timescale 1ns/1ps
`default_nettype none //indicates no new wires are made by default, and all wires must be explicitly declared

// performs arithmetic and logical calculations
module rv32_alu (
    input  wire logic [31:0] a, //two 32-bit inputs to the ALU
    input  wire logic [31:0] b,
    input  wire logic [3:0]  op,
    output logic [31:0] y //outputs
);

//in assembly: add x3, x1, x2 results in x3 = x1 + x2, where x1 and x2 are the inputs to the ALU, and x3 is the output of the ALU
    localparam logic [3:0] // localparam is similar to a constant in c++
        ALU_ADD  = 4'd0, // 4 bits, decimal 0
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4,
        ALU_SLT  = 4'd5,
        ALU_SLTU = 4'd6,
        ALU_SLL  = 4'd7,
        ALU_SRL  = 4'd8,
        ALU_SRA  = 4'd9;

    always_comb begin //combinational logic block, meaning the output is continuously updated based on the inputs
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
