`timescale 1ns/1ps
`default_nettype none

// Acts as the top-level module for the RV32 SoC, acting as a motherboard 
module rv32_soc #(
    parameter string PROGRAM_FILE = "demo.mem"
) (
    input  wire logic        clk,
    input  wire logic        reset,
    input  wire logic        cpu_ce,
    input  wire logic [15:0] in_port,
    output logic [31:0] out_port,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_x1
);
    logic [31:0] instr;
    logic        mem_we;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [31:0] mem_rdata;

    instr_mem #(
        .WORDS(256),
        .INIT_FILE(PROGRAM_FILE)
    ) imem_i (
        .addr  (debug_pc),
        .rdata (instr)
    );

    data_mem_io #(
        .WORDS(256)
    ) dmem_i (
        .clk      (clk),
        .reset    (reset),
        .we       (mem_we),
        .addr     (mem_addr),
        .wdata    (mem_wdata),
        .rdata    (mem_rdata),
        .in_port  (in_port),
        .out_port (out_port)
    );

    rv32_core core_i (
        .clk       (clk),
        .reset     (reset),
        .ce        (cpu_ce),
        .pc        (debug_pc),
        .instr     (instr),
        .mem_we    (mem_we),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_rdata (mem_rdata),
        .debug_x1  (debug_x1)
    );
endmodule

`default_nettype wire
