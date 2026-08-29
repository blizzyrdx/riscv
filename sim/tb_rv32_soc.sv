//testbench files
`timescale 1ns/1ps
`default_nettype none

module tb_rv32_soc;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic cpu_ce = 1'b1;
    logic [15:0] in_port = 16'h0000;
    logic [31:0] out_port;
    logic [31:0] debug_pc;
    logic [31:0] debug_x1;

    always #5 clk = ~clk; // 100 MHz

    rv32_soc #(
        .PROGRAM_FILE("demo.mem")
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .cpu_ce   (cpu_ce),
        .in_port  (in_port),
        .out_port (out_port),
        .debug_pc (debug_pc),
        .debug_x1 (debug_x1)
    );

    initial begin
        $display("Starting RV32I CPU test...");
        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        repeat (30) begin
            @(posedge clk);
            $display("t=%0t pc=%08h x1=%0d out=%0d", $time, debug_pc, debug_x1, out_port);
        end

        if (out_port >= 32'd5) begin
            $display("PASS: CPU executed demo program. out_port=%0d", out_port);
        end else begin
            $error("FAIL: expected out_port to reach at least 5, got %0d", out_port);
        end

        $finish;
    end
endmodule

`default_nettype wire
