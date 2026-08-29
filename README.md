# Tiny RV32I FPGA CPU — Basys 3

This project is a small, synthesizable **32-bit RISC-V RV32I-style CPU** written in SystemVerilog for learning and FPGA experimentation. It is deliberately simple: single-cycle datapath, separate instruction/data memories, 32 integer registers, memory-mapped I/O, and no pipeline or cache.

## What it supports

Implemented instructions:

- Integer register-register: `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA`
- Integer immediate: `ADDI ANDI ORI XORI SLTI SLTIU SLLI SRLI SRAI`
- Memory: `LW SW`
- Branches: `BEQ BNE BLT BGE BLTU BGEU`
- Jumps: `JAL JALR`
- Upper immediates: `LUI AUIPC`

Not implemented yet: byte/halfword loads and stores, multiply/divide, CSR instructions, interrupts, exceptions, privilege modes, compressed instructions, pipeline, cache, MMU, or operating-system support.

## Basys 3 demo behavior

The included program is:

```asm
addi x1, x0, 0
lui  x2, 0x10000
loop:
addi x1, x1, 1
sw   x1, 0(x2)
jal  x0, loop
```

Memory-mapped I/O:

- `0x1000_0000` — 32-bit output register. The Basys 3 shows bits `[7:0]` on LEDs 0–7.
- `0x1000_0004` — read-only 16-bit switch input register.

FPGA controls:

- **Center button (btnC):** CPU reset.
- **SW0 = 0:** slow mode, about 5.96 instructions/second.
- **SW0 = 1:** full-speed mode using the 100 MHz board clock.
- **LED[7:0]:** output counter written by the program.
- **LED[15:8]:** low 8 bits of the PC word address, so you can watch the instruction loop.

In slow mode, LEDs 0–7 should count upward. Each increment takes three CPU instructions, so the visible count changes roughly twice per second.

## Folder structure

```text
riscv_fpga_cpu/
├── rtl/
│   ├── rv32_alu.sv
│   ├── rv32_regfile.sv
│   ├── rv32_core.sv
│   ├── instr_mem.sv
│   ├── data_mem_io.sv
│   ├── rv32_soc.sv
│   └── basys3_top.sv
├── sim/
│   └── tb_rv32_soc.sv
├── program/
│   ├── demo.S
│   └── demo.mem
├── constraints/
│   └── basys3.xdc
├── create_vivado_project.tcl
└── README.md
```

## Fastest way to open it in Vivado

1. Unzip this folder.
2. Open **Vivado**.
3. In the Tcl Console, change directory to this unzipped folder. Example:

```tcl
cd C:/Users/YourName/Downloads/riscv_fpga_cpu
```

4. Run:

```tcl
source create_vivado_project.tcl
```

The script creates a Vivado project for the Basys 3 part `xc7a35tcpg236-1`, adds the RTL, constraints, memory file, and simulation testbench, and selects `basys3_top` as the synthesis top module.

Then use:

1. **Run Synthesis**
2. **Run Implementation**
3. **Generate Bitstream**
4. **Open Hardware Manager**
5. **Open Target → Auto Connect**
6. **Program Device**

Keep SW0 OFF at first. Press the center button once to reset the CPU. LEDs 0–7 should begin counting.

## Run the simulation in Vivado

The testbench is `sim/tb_rv32_soc.sv`.

1. In Flow Navigator, select **Run Simulation → Run Behavioral Simulation**.
2. Watch `debug_pc`, `debug_x1`, and `out_port`.
3. The testbench prints the CPU state each clock and ends with a PASS if the output register reaches at least 5.

## How the CPU works

At a high level, every enabled clock cycle does this:

1. `pc` selects one 32-bit instruction from instruction memory.
2. The decoder splits the instruction into opcode, register numbers, function bits, and immediate value.
3. The register file reads `rs1` and `rs2`.
4. The ALU performs arithmetic, logic, comparison, shift, or address calculation.
5. Loads read data memory; stores write data memory or memory-mapped I/O.
6. A result may be written to `rd`.
7. The PC normally advances by 4, unless a branch or jump changes it.

`x0` is permanently zero, as required by RISC-V.

## Important design note

This is an educational CPU, not a fully compliant production RISC-V implementation. It implements a useful subset of RV32I and uses simple asynchronous memory reads to keep the datapath easy to understand. That makes it ideal for a first FPGA CPU, but a later version should use synchronous block RAM and a multi-cycle or pipelined architecture for better FPGA timing and resource usage.

## Writing your own program

`program/demo.mem` contains one 32-bit machine-code instruction per line in hexadecimal. You can replace it with a different program as long as the program uses only supported instructions.

A real RISC-V assembler can generate machine code for you. A convenient future upgrade is to install a `riscv32-unknown-elf` or `riscv64-unknown-elf` GCC/binutils toolchain and use `objcopy`/a conversion script to turn the compiled binary into a `.mem` file.

When changing `demo.mem`, regenerate the bitstream so Vivado rebuilds instruction memory with the new contents.

## Good next upgrades

1. Add a seven-segment-display peripheral.
2. Add UART transmit so the CPU can print text to your PC.
3. Add byte and halfword loads/stores.
4. Add a small assembler/build script.
5. Change instruction/data memory to FPGA block RAM.
6. Convert the datapath to a multi-cycle CPU.
7. Add a 5-stage pipeline: IF, ID, EX, MEM, WB.
8. Add the RISC-V M extension for multiply/divide.
