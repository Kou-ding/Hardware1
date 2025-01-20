`timescale 1ns / 1ps

`include "alu.v"
`include "regfile.v"
`include "rom.v"
`include "ram.v"
`include "rom_bytes.data"

module datapath #(parameter INITIAL_PC = 32'h00400000) (
    input clk,                  // Clock
    input rst,                  // Reset
    input [31:0] instr          // Instruction from instruction memory
    input PCSrc,                // Program Counter (PC) source
    input ALUSrc,               // Second ALU operand source
    input RegWrite,             // Write data in register file
    input MemToReg,             // Input multiplexer for register file
    input [3:0] ALUCtrl,        // ALU control signals (show which operation to perform)
    input loadPC,               // Update PC
    output reg [31:0] PC,       // Program Counter
    output Zero,                // ALU zero flag
    output [31:0] dAddress,     // Address for data memory
    input [31:0] dReadData,     // Read data from data memory
    output [31:0] dWriteData,   // Data to be written to data memory
    output [31:0] WriteBackData // Data to be written back to register file
);
    // External modules
    // Register file 
    regfile u_regfile (
        .clk(clk),
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(rd),
        .writeData(writeData),
        .write(RegWrite),
        .readData1(readData1),
        .readData2(readData2)
    );
    // ALU
    alu u_alu (
        .op1(readData1),
        .op2(op2),
        .alu_op(ALUCtrl),
        .zero(Zero),
        .result(result)
    );
    // Data memory
    DATA_MEMORY u_data_memory (
        .clk(clk),
        .we(MemWrite),
        .addr(dAddress),
        .din(dWriteData),
        .dout(dReadData)
    );
    // Instruction memory
    INSTRUCTION_MEMORY u_instruction_memory (
        .clk(clk),
        .addr(PC[10:2]),
        .dout(instr)
    );
    
    // Internal signals
    wire readData1 = u_regfile.readData1; //alu.op1
    wire op2 = (ALUSrc) ? immI : readData2; //alu.op2
    wire [31:0] result; //alu.result
    // Write-back multiplexer
    assign WriteBackData = (MemToReg) ? dReadData : result;
    // Branch target calculation
    assign branchTarget = PC + immB;

    // Program Counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= INITIAL_PC;
        end else if (loadPC) begin
            PC <= (PCSrc) ? branchTarget : PC + 4;
        end
    end
    
    // I-type instructions (immediate)
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};
    // S-type instructions (store)
    wire [31:0] immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    // B-type instructions (branch)
    wire [31:0] immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

    // Instruction decoding
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd = instr[11:7];
    





        
    // Internal signals
    reg [31:0] nextPC;
    wire [31:0] branchTarget, immediateValue, regData1, regData2;
    wire [31:0] result;
    reg [31:0] writeData;

    // Instruction memory instantiation
    wire [8:0] instrAddr = PC[10:2]; // Convert PC to word address
    INSTRUCTION_MEMORY u_instruction_memory (
        .clk(clk),
        .addr(instrAddr),
        .dout(instr)
    );

    // Data memory instantiation
    wire [8:0] dataAddr = aluResult[10:2]; // Convert ALU result to word address
    DATA_MEMORY u_data_memory (
        .clk(clk),
        .we(MemWrite),
        .addr(dataAddr),
        .din(regData2),
        .dout(dReadData)
    ); 

    // Data memory interface
    assign dAddress = aluResult;
    assign dWriteData = regData2;

    // Zero flag output
    assign Zero = zeroFlag;
endmodule
