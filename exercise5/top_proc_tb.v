`timescale 1ns / 1ps

module top_proc_tb;

    // Inputs to the DUT
    reg clk;
    reg rst;
    reg [31:0] instr;
    reg [31:0] dReadData;

    // Outputs from the DUT
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire MemRead;
    wire MemWrite;
    wire [31:0] WriteBackData;

    // Instantiate the DUT
    top_proc top_proc (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WriteBackData(WriteBackData)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        dReadData = 0;
        instr = 0;

        #10 rst = 0; // Release reset

        // Test ADD (R-type)
        instr = 32'b0000000_00010_00001_000_00100_0110011; // ADD x4, x1, x2
        #10 $display("ADD Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SUB (R-type)
        instr = 32'b0100000_00010_00001_000_00101_0110011; // SUB x5, x1, x2
        #10 $display("SUB Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test AND (R-type)
        instr = 32'b0000000_00010_00001_111_00110_0110011; // AND x6, x1, x2
        #10 $display("AND Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test OR (R-type)
        instr = 32'b0000000_00010_00001_110_00111_0110011; // OR x7, x1, x2
        #10 $display("OR Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test XOR (R-type)
        instr = 32'b0000000_00010_00001_100_01000_0110011; // XOR x8, x1, x2
        #10 $display("XOR Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SLT (R-type)
        instr = 32'b0000000_00010_00001_010_01001_0110011; // SLT x9, x1, x2
        #10 $display("SLT Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SLL (R-type)
        instr = 32'b0000000_00010_00001_001_01010_0110011; // SLL x10, x1, x2
        #10 $display("SLL Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SRL (R-type)
        instr = 32'b0000000_00010_00001_101_01011_0110011; // SRL x11, x1, x2
        #10 $display("SRL Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SRA (R-type)
        instr = 32'b0100000_00010_00001_101_01100_0110011; // SRA x12, x1, x2
        #10 $display("SRA Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test ADDI (I-type)
        instr = 32'b000000000001_00001_000_01101_0010011; // ADDI x13, x1, 1
        #10 $display("ADDI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test ANDI (I-type)
        instr = 32'b000000000001_00001_111_01110_0010011; // ANDI x14, x1, 1
        #10 $display("ANDI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test ORI (I-type)
        instr = 32'b000000000001_00001_110_01111_0010011; // ORI x15, x1, 1
        #10 $display("ORI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test XORI (I-type)
        instr = 32'b000000000001_00001_100_10000_0010011; // XORI x16, x1, 1
        #10 $display("XORI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SLTI (I-type)
        instr = 32'b000000000001_00001_010_10001_0010011; // SLTI x17, x1, 1
        #10 $display("SLTI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SLLI (I-type)
        instr = 32'b000000000001_00001_001_10010_0010011; // SLLI x18, x1, 1
        #10 $display("SLLI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SRLI (I-type)
        instr = 32'b000000000001_00001_101_10011_0010011; // SRLI x19, x1, 1
        #10 $display("SRLI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test SRAI (I-type)
        instr = 32'b010000000001_00001_101_10100_0010011; // SRAI x20, x1, 1
        #10 $display("SRAI Test: PC=%h, Result=%h", PC, WriteBackData);

        // Test LW (I-type)
        instr = 32'b000000000100_00001_010_10101_0000011; // LW x21, 4(x1)
        #10 $display("LW Test: PC=%h, Data=%h", PC, dReadData);

        // Test SW (S-type)
        instr = 32'b0000000_10101_00001_010_00010_0100011; // SW x21, 4(x1)
        #10 $display("SW Test: PC=%h, Addr=%h, Data=%h", PC, dAddress, dWriteData);

        // Test BEQ (B-type)
        instr = 32'b0000000_00001_00001_000_00000_1100011; // BEQ x1, x1, PC+0
        #10 $display("BEQ Test: PC=%h, Branch Taken=%b", PC, WriteBackData == PC);

        $finish;
    end

endmodule
