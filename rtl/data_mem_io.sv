`timescale 1ns/1ps
`default_nettype none

module data_mem_io #(
    parameter integer WORDS = 256
) (
    input  logic        clk,
    input  logic        reset,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic [15:0] in_port,
    output logic [31:0] out_port
);
    localparam logic [31:0] IO_OUT_ADDR = 32'h1000_0000;
    localparam logic [31:0] IO_IN_ADDR  = 32'h1000_0004;

    logic [31:0] mem [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'd0;
    end

    always_comb begin
        if (addr == IO_OUT_ADDR)
            rdata = out_port;
        else if (addr == IO_IN_ADDR)
            rdata = {16'd0, in_port};
        else if (addr[31:2] < WORDS)
            rdata = mem[addr[31:2]];
        else
            rdata = 32'd0;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            out_port <= 32'd0;
        end else if (we) begin
            if (addr == IO_OUT_ADDR)
                out_port <= wdata;
            else if (addr[31:2] < WORDS)
                mem[addr[31:2]] <= wdata;
        end
    end
endmodule

`default_nettype wire
