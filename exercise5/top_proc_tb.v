`timescale 1ns/1ps
module top_proc_tb;

    // Testbench signals
    reg clk;
    reg rst;
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire MemRead;
    wire MemWrite;
    wire [31:0] WriteBackData;
    reg [31:0] instr;
    reg [31:0] dReadData;

    // Memory models
    reg [31:0] instructionMemory [0:255];
    reg [31:0] dataMemory [0:255];

    // DUT instantiation
    top_proc #(32'h00400000) dut (
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
        // Initialize instruction memory
        $readmemb("rom_bytes.data", instructionMemory);

        // Initialize data memory
        // $readmemh("ram_bytes.data", dataMemory);

        // Reset the processor
        rst = 1;
        #10 rst = 0;

        // Simulation loop
        while (1) begin
            @(posedge clk);
            // Fetch instruction
            instr = instructionMemory[PC[31:2]];

            // Handle memory read
            if (MemRead) begin
                dReadData = dataMemory[dAddress[31:2]];
            end

            // Handle memory write
            if (MemWrite) begin
                dataMemory[dAddress[31:2]] = dWriteData;
            end
        end
    end

    // Dump waveforms
    initial begin
        $dumpfile("top_proc_tb.vcd");
        $dumpvars(0, top_proc_tb);
        #1000 $finish;
    end

endmodule
