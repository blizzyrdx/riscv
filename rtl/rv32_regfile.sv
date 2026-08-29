`timescale 1ns/1ps
`default_nettype none

module rv32_regfile (
    input  logic        clk,
    input  logic        reset,
    input  logic        we,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wd,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] debug_x1
);
    logic [31:0] regs [0:31];
    integer i;

    assign rd1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];
    assign debug_x1 = regs[1];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else if (we && (rd != 5'd0)) begin
            regs[rd] <= wd;
        end
    end
endmodule

`default_nettype wire
