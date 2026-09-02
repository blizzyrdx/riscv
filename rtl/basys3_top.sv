`timescale 1ns/1ps
`default_nettype none

// Basys3 top-level module
module basys3_top (
    input  wire logic        CLK100MHZ, // 100 MHz clock input
    input  wire logic        btnC, // Center pushbutton (FPGA Reset)
    input  wire logic [15:0] sw, // Switches (FPGA Inputs)
    output logic [15:0] led // LED (FPGA Outputs)
);
    logic [23:0] divider; // slows CPU down from 100 MHz to a slower speed for visible execution
    logic        cpu_ce; 
    logic [31:0] out_port;
    logic [31:0] debug_pc;
    logic [31:0] debug_x1;

    // In slow mode, execute one instruction each time this 24-bit counter wraps:
    // 100 MHz / 2^24 = about 5.96 instructions/second.
    always_ff @(posedge CLK100MHZ) begin
        if (btnC)
            divider <= 24'd0; // if button presses goes to 0, reset the counter to 0
        else
            divider <= divider + 24'd1; // specifies 24 bits in decimal (10), and increments the counter by 1 each clock cycle
    end

    // SW0 = 0: slow visible execution
    // SW0 = 1: full 100 MHz execution
    assign cpu_ce = sw[0] ? 1'b1 : (&divider);

    rv32_soc #(
        .PROGRAM_FILE("demo.mem")
    ) soc_i (
        .clk      (CLK100MHZ),
        .reset    (btnC),
        .cpu_ce   (cpu_ce),
        .in_port  (sw),
        .out_port (out_port),
        .debug_pc (debug_pc),
        .debug_x1 (debug_x1)
    );

    // LED[7:0]  = memory-mapped output value
    // LED[15:8] = low 8 bits of PC word address
    always_comb begin
        led[7:0]  = out_port[7:0];
        led[15:8] = debug_pc[9:2];
    end
endmodule

`default_nettype wire
