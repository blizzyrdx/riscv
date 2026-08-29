`timescale 1ns/1ps
`default_nettype none

// instruction memory module
module instr_mem #(
    parameter integer WORDS = 256,
    parameter string  INIT_FILE = "demo.mem"
) (
    input  wire logic [31:0] addr,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'h0000_0013; // NOP = addi x0,x0,0
        $readmemh(INIT_FILE, mem);
    end

    always_comb begin
        if (addr[31:2] < WORDS)
            rdata = mem[addr[31:2]];
        else
            rdata = 32'h0000_0013;
    end
endmodule

`default_nettype wire
